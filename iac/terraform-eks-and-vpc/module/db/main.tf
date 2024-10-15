module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.9.0"

  identifier = var.identifier
  db_name    = var.identifier

  engine            = "MySQL"
  engine_version    = "8.0.35"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type = "gp3"
  

  //name     = var.name
  username = var.username
  password = var.password
  port     = var.port

  maintenance_window = "Fri:20:00-Fri:21:00"
  backup_window      = "22:00-23:00"

  backup_retention_period = 0

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = "default"

  # DB Security group
 // vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # DB parameter group
  create_db_parameter_group = false
  parameter_group_name = "default.mysql8.0"

  # DB option group
  create_db_option_group = false
  //option_group_name      = "defaultmysql80"
  
}

resource "aws_db_subnet_group" "rds_subnet" {
  tags       = { Name = "${var.project}-rds_subnet" }
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = var.public_subnets

}

resource "aws_security_group" "rds_sg" {
  tags   = var.tags
  name   = "${var.project}-rds-sg"
  vpc_id = var.vpc_id


  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

