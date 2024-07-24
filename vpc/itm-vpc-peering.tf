resource "aws_vpc_peering_connection" "itm_vpc_peering" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  vpc_id = aws_vpc.itm-vpc.id
  peer_vpc_id = aws_vpc.itm_dev_vpc.id
  auto_accept = true
  tags = {
    Name = "ITM-VPC-PEERING"
    created-by = "itm"
    service = "vpc-peering"
  }
  depends_on = [
    aws_route_table.dev_igw_route_table,
    aws_route_table.igw_route_table,
    aws_internet_gateway.gw,
    aws_internet_gateway.dev_gw
  ]
}

resource "aws_route" "dev_vpcpeering_internet_access" {
  route_table_id         = aws_route_table.dev_igw_route_table.id
  destination_cidr_block = aws_vpc.itm-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.itm_vpc_peering.id
  depends_on = [
    aws_vpc_peering_connection.itm_vpc_peering
  ]
}

resource "aws_route" "vpcpeering_internet_access" {
  route_table_id         = aws_route_table.igw_route_table.id
  destination_cidr_block = aws_vpc.itm_dev_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.itm_vpc_peering.id
  depends_on = [
    aws_vpc_peering_connection.itm_vpc_peering
  ]
}

resource "aws_route" "nat_2a_access" {
  route_table_id         = aws_route_table.nat_2a.id
  destination_cidr_block = aws_vpc.itm_dev_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.itm_vpc_peering.id
  depends_on = [
    aws_vpc_peering_connection.itm_vpc_peering
  ]
}

resource "aws_route" "nat_2c_access" {
  route_table_id         = aws_route_table.nat_2c.id
  destination_cidr_block = aws_vpc.itm_dev_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.itm_vpc_peering.id
  depends_on = [
    aws_vpc_peering_connection.itm_vpc_peering
  ]
}
