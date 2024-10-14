variable "AWS_REGION" {
  default = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"
  default = {
    Name = "app-reviews"
  }
}

variable "project" {
  type    = string
  default = "review"
}


variable "environment" {
  type    = string
  default = "prod"
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

variable "database_password" {
  type    = string
  default = "JalaJala123"
}

variable "key_name" {
  type    = string
  default = "jala_key_pair"
}

variable "inbound_ports" {
  type    = list(string)
  default = [22, 80, 443]
}
