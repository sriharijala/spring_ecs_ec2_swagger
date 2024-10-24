output "vpc_details" {
  value = {
    vpcx_id         = aws_vpc.main.id
    azs_count       = local.azs_count
    public_cidrs    = aws_subnet.public[*].cidr_block
    private_cidrs   = aws_subnet.private[*].cidr_block
    firewall_cidrs  = aws_subnet.firewall[*].cidr_block
    igw_id          = aws_internet_gateway.main.id
  }
}


