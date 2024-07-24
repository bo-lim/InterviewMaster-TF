# VPC

resource "aws_vpc" "itm-vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ITM-VPC"
    created-by = "itm"
    service = "vpc"
  }
}
# POD를 위한 CIDR
resource "aws_vpc_ipv4_cidr_block_association" "pods" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "100.65.0.0/16"
}

# IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.itm-vpc.id

  tags = {
    Name = "ITM-IGW"
    created-by = "itm"
    service = "internet-gateway"
  }
}

resource "aws_route_table" "igw_route_table" {
  vpc_id = aws_vpc.itm-vpc.id

  tags = {
    Name = "itm-pub-rt"
    created-by = "itm"
    service = "routing-table"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.igw_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}