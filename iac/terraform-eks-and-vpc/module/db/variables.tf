variable "project" {
  description = "Project"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"
  default = {
    Name = "user-reviews"
  }
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "identifier" {
  description = "The database identifier, here used as deploy environment."
  type        = string
  default     = "socialmedia"
}

variable "name" {
  description = "The name of the database to create."
  type        = string
  default     = "socialmedia"
}

variable "username" {
  description = "The administrator username for the database."
  type        = string
  default     = "sjala"
}

variable "password" {
  description = "The password for the administrator user of the database."
  type        = string
  default     = "JalaJala123"
}

variable "port" {
  description = "The port for database service."
  type        = number
  default     = 3306
}