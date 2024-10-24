# --- Create VPC ---
data "aws_availability_zones" "available" { state = "available" }

locals {
  azs_count  = 2 #use two zones
  azs_names  = data.aws_availability_zones.available.names
}


resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project}-vpc" }
}

resource "aws_subnet" "public" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1 + count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-${local.azs_names[count.index]}" }
}

resource "aws_subnet" "private" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 3 + count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-private-${local.azs_names[count.index]}" }
}

resource "aws_subnet" "firewall" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 5 + count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-private-${local.azs_names[count.index]}" }
}

# --- Internet Gateway ---

resource "aws_internet_gateway" "main" {
  vpc_id     = aws_vpc.main.id
  tags       = { Name = "${var.project}-igw" }
}

resource "aws_eip" "main" {
  depends_on = [aws_internet_gateway.main]
  count      = local.azs_count
  tags       = { Name = "${var.project}-eip-${local.azs_names[count.index]}" }
}

# --- Public Route Table ---
resource "aws_route_table" "public" {
  depends_on = [aws_internet_gateway.main]
  vpc_id     = aws_vpc.main.id
  tags       = { Name = "${var.project}-rt-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  depends_on     = [aws_route_table.public]
  count          = local.azs_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# --- Private Route Table ---
resource "aws_route_table" "private" {
  depends_on = [aws_internet_gateway.main]
  vpc_id     = aws_vpc.main.id
  tags       = { Name = "${var.project}-rt-private" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_route_table.private]
  count          = local.azs_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


