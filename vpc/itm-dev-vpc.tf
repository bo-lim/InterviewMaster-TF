# vpc

resource "aws_vpc" "itm_dev_vpc" {
  cidr_block       = "172.168.1.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "ITM-DEV-VPC"
    created-by = "itm"
    service = "vpc"
  }
}

# IGW
resource "aws_internet_gateway" "dev_gw" {
  vpc_id = aws_vpc.itm_dev_vpc.id

  tags = {
    Name = "ITM-DEV-IGW"
    created-by = "itm"
    service = "internet-gateway"
  }
}

resource "aws_route_table" "dev_igw_route_table" {
  vpc_id = aws_vpc.itm_dev_vpc.id

  tags = {
    Name = "ITM-DEV-PUB-RT"
    created-by = "itm"
    service = "routing-table"
  }
}

resource "aws_route" "dev_public_internet_access" {
  route_table_id         = aws_route_table.dev_igw_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_gw.id
}