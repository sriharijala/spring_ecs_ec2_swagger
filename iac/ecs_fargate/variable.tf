variable "AWS_REGION" {
  default = "us-east-1"
}


variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "aws_availability_zones" {
  description = "for multi zone deployment"
  default     = []
}

variable "tags" {
  default = {
    Name = "app-reviews"
  }
  description = "Common resource tags"
  type        = map(string)
}

variable "project" {
  type    = string
  default = "app-reviews"
}


variable "environment" {
  type    = string
  default = "development"
}

variable "bastion_ami" {
  type    = string
  default = "ami-0fff1b9a61dec8a5f"
}

variable "bastion_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "database_name" {
  type    = string
  default = "socialmedia"
}

variable "key_name" {
  type    = string
  default = "mysql"
}

variable "user-reviews-service" {
  type    = string
  default = "user-reviews-service"
}

variable "user-reviews-image" {
  type    = string
  default = "307946673854.dkr.ecr.us-east-1.amazonaws.com/sjala/user-reviews:04de733-2024-10-14-18-59"
}

variable "ec2-key-pair" {
  type    = string
  default = "jala_key_pair"
}