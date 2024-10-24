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



