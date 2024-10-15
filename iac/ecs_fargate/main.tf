resource "aws_vpc" "main" {

  # IP Range for the VPC
  cidr_block = "10.0.0.0/16"
  tags       = var.tags
}

resource "aws_subnet" "public1" {
  depends_on = [
    aws_vpc.main
  ]
    #VPC in which subnet has to be created!
  vpc_id                  = aws_vpc.main.id
  # IP Range of this subnet
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  # Data Center of this subnet.
  availability_zone       = "us-east-1a"
  tags                    = { Name = "${var.project}-public1-subnet" }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "${var.project}-private1-subnet" }
}

resource "aws_subnet" "public2" {
  depends_on = [
    aws_vpc.main
  ]
    #VPC in which subnet has to be created!
  vpc_id                  = aws_vpc.main.id
  # IP Range of this subnet
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  # Data Center of this subnet.
  availability_zone       = "us-east-1b"
  tags                    = { Name = "${var.project}-public2-subnet" }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "${var.project}-private2-subnet" }
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.public1,
    aws_subnet.private1,
    aws_subnet.public2,
    aws_subnet.private2
  ]
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-IG-Public-&-Private-VPC"
  }
}

#Create a routing table for Internet Gateway!
resource "aws_route_table" "public-rt" {
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.Internet_Gateway
  ]
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-public-rt" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }
}

#Associate the routing table to the Public Subnet!
resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-rt.id
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP1" {
  depends_on = [
    aws_route_table_association.public1_assoc
  ]
}

#Associate the routing table to the Public Subnet!
resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-rt.id
}


# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP2" {
  depends_on = [
    aws_route_table_association.public2_assoc
  ]
}


# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY_1" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP1
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP1.id
  
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public1.id
  tags = {
    Name = "${var.project}-Nat-Gateway_1"
  }
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY_2" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP2
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP2.id
  
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public2.id
  tags = {
    Name = "${var.project}-Nat-Gateway_2"
  }
}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT1" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY_1
  ]

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY_1.id
  }

  tags = {
    Name = "${var.project} - Route Table for NAT Gateway 1"
  }

}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT2" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY_2
  ]

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY_2.id
  }

  tags = {
    Name = "${var.project} - Route Table for NAT Gateway 2"
  }

}

# Creating an Route Table Association of the NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association1" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT1
  ]

#  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id      = aws_subnet.private1.id

# Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT1.id
  
}

# Creating an Route Table Association of the NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association2" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT2
  ]

#  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id      = aws_subnet.private2.id

# Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT2.id

}


resource "aws_db_subnet_group" "rds_subnet" {
  tags       = { Name = "${var.project}-rds_subnet" }
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

}

resource "aws_db_instance" "mysql" {
  tags                    = { Name = "${var.project}-mysql" }
  identifier              = var.database_name
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "sjala"
  password                = "JalaJala123"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  backup_retention_period = 0
  apply_immediately       = true
  deletion_protection     = false #
  db_name                 = var.database_name
  #availability_zone       = "us-east-1a"
  #publicly_accessible = true
  #multi_az = true
  

}

#security groups
resource "aws_security_group" "ecs_sg" {
  tags   = { Name = "${var.project}-ecs-sg" }
  name   = "${var.project}-ecs-sg_allow_ssh"
  vpc_id = aws_vpc.main.id

# Created an inbound rule for webserver access!
  ingress {
    description = "HTTP for webserver"
    from_port   = 8080
    to_port     = 8080

    # Here adding tcp instead of http, because http in part of tcp only!
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ping"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outward Network Traffic for the services
  egress {
    description = "ping"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  tags   = var.tags
  name   = "${var.project}-rds-sg"
  vpc_id = aws_vpc.main.id

  /* after testing uncomment this and remove the otehr ingress block wide open one.teams*/
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.BH-SG.id]
  }

# Created an inbound rule for MySQL Bastion Host
  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.BH-SG.id]
  }
  egress {
    description = "output from MySQL"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh

}

resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  tags                   = { Name = "${var.project}-bastion" }
  key_name               = "${var.ec2-key-pair}"
  depends_on             = [aws_subnet.public1 ]
  #user_data              = file("install_sql_client.sh")

  # Code for installing the softwares!
  provisioner "remote-exec" {
    inline = [
      "sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm",
      "sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y",
      "sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023",
      "sudo dnf install mysql-community-client -y"
    ]
  }
  
}

# Creating security group for Bastion Host/Jump Box
resource "aws_security_group" "BH-SG" {

  tags = { Name = "${var.project}-BH-SG" }

  depends_on = [
    aws_vpc.main,
    aws_subnet.public1,
    aws_subnet.private1,
    aws_subnet.public2,
    aws_subnet.private2
  ]

  description = "MySQL Access only from the EC2 Instances in public1"
  name = "${var.project}-BH-SG"
  vpc_id = aws_vpc.main.id

  # Created an inbound rule for Bastion Host SSH
  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from Bastion Host"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Creating security group for MySQL Bastion Host Access
resource "aws_security_group" "DB-SG-SSH" {

  depends_on = [
    aws_vpc.main,
    aws_security_group.BH-SG
  ]

  description = "MySQL Bastion host access for updates!"
  name = "mysql-sg-bastion-host"
  vpc_id = aws_vpc.main.id

  # Created an inbound rule for MySQL Bastion Host
  ingress {
    description = "Bastion Host SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.BH-SG.id]
  }

  egress {
    description = "output from MySQL BH"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ECS cluster tasks
resource "aws_ecs_cluster" "app_cluster" {
  tags = { Name = "${var.project}-app-cluster" }
  name = "user-reviews-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"

  }
  
}

# Create ECS task role to execute tasks in ECS Cluster
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project}-role-name"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project}-role-name-task"
 
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
  }
  EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_ecs_task_definition" "app_task" {
  tags                     = { Name = "${var.project}-app-task" }
  family                   = "user-reviews-task"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
   

  container_definitions = jsonencode([
    {
      name      = "user-review-container"
      image     = "${var.user-reviews-image}" # Change this to your microservice image
      essential = true
      
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "user_service" {
  tags            = { Name = "${var.project}-user_service" }
  name            = "user-reviews-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public1.id, aws_subnet.public2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

#expose using ALB
resource "aws_lb" "app_lb" {
  tags               = { Name = "${var.project}-app_lb" }
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.public1.id,aws_subnet.public2.id]
}

resource "aws_lb_target_group" "app_tg" {
  tags     = { Name = "${var.project}-app-tg" }
  name     = "app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "app_listener" {
  tags              = { Name = "${var.project}-app-listner" }
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

#outputs
output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "ec2BationKey" {
  value     = tls_private_key.private_key.private_key_pem
  sensitive = true
}

output "ec2_bastion" {
  value = aws_instance.bastion.arn
}
