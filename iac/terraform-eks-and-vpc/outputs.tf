output "db_instance_endpoint" {
  description = "The endpoint of the database."
  value       = module.db.db_instance_endpoint
}

output "db_instance_port" {
  description = "The port of the database service."
  value       = module.db.db_instance_port
}

output "db_subnet_group_id" {
  description = "The subnet group ID of the database service."
  value       = module.db.db_subnet_group_id
}

output "vpc_id" {
  description = "VPC ID"
  value = module.vpc.default_vpc_id
}