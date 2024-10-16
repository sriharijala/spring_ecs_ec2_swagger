terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.17.0" }
  }
}

provider "aws" {
  profile = "default"
  region  = var.AWS_REGION
}

# --- Create VPC ---

data "aws_availability_zones" "available" { state = "available" }

locals {
  azs_count  = 2 #use two zones
  azs_names  = data.aws_availability_zones.available.names
  dbHostName = aws_db_instance.mysql.endpoint
}


resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project}-vpc" }


}

resource "aws_subnet" "public" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1 + count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-${local.azs_names[count.index]}" }
}

resource "aws_subnet" "private" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 3 + count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-private-${local.azs_names[count.index]}" }
}

# --- Internet Gateway ---

resource "aws_internet_gateway" "main" {
  depends_on = [aws_ecs_task_definition.app]
  vpc_id     = aws_vpc.main.id
  tags       = { Name = "${var.project}-igw" }
}

resource "aws_eip" "main" {
  depends_on = [aws_internet_gateway.main]
  count      = local.azs_count
  tags       = { Name = "${var.project}-eip-${local.azs_names[count.index]}" }
}

# --- Public Route Table ---
resource "aws_route_table" "public" {
  depends_on = [aws_internet_gateway.main]
  vpc_id     = aws_vpc.main.id
  tags       = { Name = "${var.project}-rt-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  depends_on     = [aws_route_table.public]
  count          = local.azs_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# --- Private Route Table ---
resource "aws_route_table" "private" {
  depends_on = [aws_internet_gateway.main]
  vpc_id     = aws_vpc.main.id
  tags       = { Name = "${var.project}-rt-private" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_route_table.private]
  count          = local.azs_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# --- ECS Cluster ---
resource "aws_ecs_cluster" "main" {
  name = var.project
}

# --- ECS Node Role ---

data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "ecs_node_role" {
  name_prefix        = "demo-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  depends_on  = [aws_iam_role.ecs_node_role]
  name_prefix = "${var.project}-ecs-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}

# --- ECS Node SG ---

resource "aws_security_group" "ecs_node_sg" {
  depends_on  = [aws_subnet.private]
  name_prefix = "${var.project}-ecs-node-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ECS 2 RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    #cidr_blocks = [aws_subnet.private[0].cidr_block,aws_subnet.private[1].cidr_block]
    #Check ECS Service definition -> Security Groups -> EC2 DB Security group should be one of the value in this array.
    security_groups = [aws_vpc.main.default_security_group_id, aws_security_group.rds_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- ECS Launch Template ---

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_ec2" {
  depends_on             = [aws_security_group.ecs_node_sg, aws_iam_instance_profile.ecs_node]
  name_prefix            = "${var.project}-ecs-ec2-"
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ecs_node_sg.id]

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
  monitoring { enabled = true }

  key_name = var.key_name

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config;
    EOF
  )
}

# --- ECS ASG ---
resource "aws_autoscaling_group" "ecs" {
  depends_on = [aws_launch_template.ecs_ec2]

  name_prefix               = "${var.project}-ecs-asg-"
  vpc_zone_identifier       = aws_subnet.public[*].id
  min_size                  = 2
  max_size                  = 8
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-ecs-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }


}

# --- ECS Capacity Provider ---

resource "aws_ecs_capacity_provider" "main" {

  depends_on = [aws_autoscaling_group.ecs]

  name = "${var.project}-ecs-ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  depends_on = [aws_ecs_cluster.main, aws_ecs_capacity_provider.main]

  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }
}


/*
resource "aws_ecr_repository" "app" {
  name                 = "swagger-ui/index.html"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
*/

# --- ECS Task Role ---

data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = "${var.project}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "${var.project}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- Cloud Watch Logs ---

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/${var.project}/ecsLogs"
  retention_in_days = 1
}

# --- ECS Task Definition ---
resource "aws_ecs_task_definition" "app" {
  depends_on         = [aws_db_instance.mysql]
  family             = "${var.project}-app"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 256


  container_definitions = jsonencode([{
    name         = "${var.project}-app",
    image        = "${var.user_reviews_image}",
    essential    = true,
    portMappings = [{ containerPort = 8080, hostPort = 8080 }],
    cpu                = 256,
    memory             = 256,
    environment = [
      { name = "Environment", value = "${var.environment}" },
      { name = "DB_HOST", value = "${var.database_host}" },
      { name = "DB_PORT", value = "3306" },
      { name = "DB_DATABASE", value = "${var.database_name}" },
      { name = "DB_USER", value = "${var.database_username}" },
      { name = "DB_PASSWORD", value = "${var.database_password}" },
      { name = "APP_CONFIG_DIR", value = "/usr/app" },
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://${var.database_host}:3306/socialmedia" }
    ]

    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-region"        = "us-east-1",
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name,
        "awslogs-stream-prefix" = "${var.project}-app"
      }
    },
  }])
}

#-- VPC Flow logs
resource "aws_cloudwatch_log_group" "network" {
  name              = "/${var.project}/networkLogs"
  retention_in_days = 1
}


resource "aws_flow_log" "vpclogs" {
  iam_role_arn    = aws_iam_role.ecs_node_role.arn
  log_destination = aws_cloudwatch_log_group.network.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

# --- ECS Service ---

resource "aws_security_group" "ecs_task" {
  name_prefix = "ecs-task-sg-"
  description = "Allow all traffic within the VPC"
  vpc_id      = aws_vpc.main.id

  #SG allows access to the service only for VPC network members.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  #access to the Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app" {

  depends_on = [aws_lb_target_group.app, aws_lb.main]

  name            = var.project
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2

  enable_ecs_managed_tags = true # It will tag the network interface with service name
  wait_for_steady_state   = true # Terraform will wait for the service to reach a steady state 

  network_configuration {
    security_groups = [aws_security_group.ecs_task.id]
    subnets         = aws_subnet.public[*].id
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    base              = 1
    weight            = 100
  }

  # each service instance is equally distributed across Availability Zones
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.project}-app"
    container_port   = 8080
  }
}

#-- RDS database
resource "aws_security_group" "rds_sg" {
  depends_on = [aws_vpc.main]

  tags   = var.tags
  name   = "${var.project}-rds-sg"
  vpc_id = aws_vpc.main.id



  /* after testing uncomment this and remove the otehr ingress block wide open one.teams*/
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    //security_groups = [aws_security_group.ecs_node_sg.id,aws_security_group.ecs_task.id]
    cidr_blocks = [aws_subnet.public[0].cidr_block, aws_subnet.public[1].cidr_block]
  }


  # Created an inbound rule for MySQL Bastion Host
  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #security_groups = [aws_security_group.ecs_node_sg.id, aws_security_group.ecs_node_sg.id]
    cidr_blocks = [aws_subnet.public[0].cidr_block, aws_subnet.public[1].cidr_block]
  }
  egress {
    description = "output from MySQL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_subnet_group" "rds_subnet" {
  depends_on = [aws_subnet.private]
  tags       = { Name = "${var.project}-rds_subnet" }
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.public[0].id, aws_subnet.public[1].id]
}

resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "rds_monitoring_attachment" {
  name       = "rds-monitoring-attachment"
  roles      = [aws_iam_role.rds_monitoring_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "mysql" {
  depends_on             = [aws_db_subnet_group.rds_subnet]
  tags                   = { Name = "${var.project}-mysql" }
  identifier             = var.database_name
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "sjala"
  password               = "JalaJala123"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id, aws_security_group.ecs_node_sg.id, aws_security_group.ecs_task.id, aws_security_group.http.id]


  apply_immediately   = true
  deletion_protection = false #
  db_name             = var.database_name
  #multi_az = true 

  backup_retention_period = 0 # Number of days to retain automated backups
  #backup_window = "03:00-04:00" # Preferred UTC backup window (hh24:mi-hh24:mi format)
  #maintenance_window = "mon:04:00-mon:04:30" # Preferred UTC maintenance window

  # Enable automated backups
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.project}-db-snap"

  # Enable enhanced monitoring
  #monitoring_interval = 60 # Interval in seconds (minimum 60 seconds)
  #monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

  # Enable performance insights
  #performance_insights_enabled = true


}


#--- Set up DB ---
data "local_file" "sql_script" {
  filename = "${path.module}/init/db_structure.sql"
}

/*
resource "null_resource" "db_setup" {
  depends_on = [aws_db_instance.mysql, aws_security_group.rds_sg]
  provisioner "local-exec" {
    command = "mysql --host=${aws_db_instance.mysql.address} --port=${aws_db_instance.mysql.port} --user=sjala --password=${var.database_password} --database=${var.database_name} < ${data.local_file.sql_script.content}"
  }
}
*/


# --- ALB ---
# service available from the public network
resource "aws_security_group" "http" {
  name_prefix = "${var.project}-http-sg-"
  description = "Allow all HTTP/HTTPS traffic from public"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.inbound_ports
    content {
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  depends_on         = [aws_internet_gateway.main]
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.http.id]
}

resource "aws_lb_target_group" "app" {
  name_prefix = "review"
  vpc_id      = aws_vpc.main.id
  protocol    = "HTTP"
  port        = 8080
  target_type = "ip"  #"instance"  --With "ip" getting error while updating the image from Github action ECS - target type ip is incompatible with the bridge network mode specified in the task definition
  deregistration_delay = 300

  /*
  health_check {
    enabled             = true
    path                = "/actuator/health"
    port                = 8080
    matcher             = 200
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
*/

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}

output "alb_url" {
  value = aws_lb.main.dns_name
}

/*
output "app_repo_url" {
  value = aws_ecr_repository.app.repository_url
}
*/

output "mysql_db_url" {
  value = aws_db_instance.mysql.endpoint
}

output "db_init_file_path" {
  value = data.local_file.sql_script.filename
}



/* TO DO outside 
Let’s run terraform apply again. We should see output with repository URL in AWS. Now push user-reviews to ECR.

# Get AWS repo url from Terraform outputs
export REPO=$(terraform output --raw demo_app_repo_url)
# Login to AWS ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $REPO

# Pull docker image & push to our ECR
docker pull --platform linux/amd64 sjala/user-reviews:1.0
docker tag strm/helloworld-http:latest $REPO:latest
docker push $REPO:latest
*/