variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "user-reviews"
}

variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
  default     = "1.30"
}

variable "ami_release_version" {
  description = "Default EKS AMI release version for node groups"
  type        = string
  default     = "1.30.4-20241011"
}

variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "10.10.0.0/16"
}