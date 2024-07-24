#################
# ap-northeast-2a
#################

resource "aws_eip" "vpc_iep_2a" {
  domain = "vpc"
  tags = {
    Name = "itm-eip-2a"
    created-by = "itm"
    service = "eip"
  }
}

resource "aws_nat_gateway" "nat_2a" {
  allocation_id = aws_eip.vpc_iep_2a.id
  subnet_id     = aws_subnet.itm-vpc-pub-2a.id
  tags = {
    Name = "itm-vpc-nat-2a"
    created-by = "itm"
    service = "nat"
  }
  depends_on = [
    aws_eip.vpc_iep_2a,
    aws_subnet.itm-vpc-pub-2a
  ]
}

resource "aws_route_table" "nat_2a" {
  vpc_id = aws_vpc.itm-vpc.id
  tags = {
    Name = "itm-vpc-nat-rt-2a"
    created-by = "itm"
    service = "routing-table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2a.id
  }
  depends_on = [
    aws_nat_gateway.nat_2a
  ]
}

#################
# ap-northeast-2C
#################

resource "aws_eip" "vpc_iep_2c" {
  domain = "vpc"
  tags = {
    Name = "itm-eip-2c"
    created-by = "itm"
    service = "eip"
  }
}

resource "aws_nat_gateway" "nat_2c" {
  allocation_id = aws_eip.vpc_iep_2c.id
  subnet_id     = aws_subnet.itm-vpc-pub-2c.id
  tags = {
    Name = "itm-vpc-nat-2c"
    created-by = "itm"
    service = "nat"
  }
  depends_on = [
    aws_eip.vpc_iep_2c,
    aws_subnet.itm-vpc-pub-2c
  ]
}

resource "aws_route_table" "nat_2c" {
  vpc_id = aws_vpc.itm-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2c.id
  }
  depends_on = [
    aws_nat_gateway.nat_2c
  ]
  tags = {
    Name = "itm-vpc-nat-rt-2c"
    created-by = "itm"
    service = "routing-table"
  }
}
