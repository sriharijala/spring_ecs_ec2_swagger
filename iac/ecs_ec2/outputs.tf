
output "alb_url" {
  value = format("%s%s%s", "http://", aws_lb.main.dns_name, ":8080/swagger-ui/index.html")

}

output "mysql_db_url" {
  value = aws_db_instance.mysql.endpoint
}

output "mysql_host" {
  value = aws_db_instance.mysql.address
}

output "public_cidr" {
  value = aws_subnet.public[*].cidr_block
}

output "private_cidr" {
  value = aws_subnet.private[*].cidr_block
}

