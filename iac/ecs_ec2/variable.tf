variable "AWS_REGION" {
  default = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"
  default = {
    Name = "user-reviews"
  }
}

variable "project" {
  type    = string
  default = "user-reviews"
}


variable "environment" {
  type    = string
  default = "prod"
}

variable "database_name" {
  type    = string
  default = "socialmedia"
}

variable "database_username" {
  type    = string
  default = "sjala"
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
  default = [22, 80, 443, 8080]
}

variable "user_reviews_image" {
  type = string
  default = "307946673854.dkr.ecr.us-east-1.amazonaws.com/sjala/user-reviews:1d0ed90-2024-10-17-01-02"
  #default = "nginxdemos/hello" #working
}




