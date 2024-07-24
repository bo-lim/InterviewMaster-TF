# subnet
## public
resource "aws_subnet" "itm_dev_vpc_pub_2a" {
  vpc_id     = aws_vpc.itm_dev_vpc.id
  cidr_block = "172.168.1.0/28"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ITM-DEV-VPC-PUB-2A"
    created-by = "itm"
    service = "cloud9"
  }
}

resource "aws_route_table_association" "dev_public_2a" {
  subnet_id      = aws_subnet.itm_dev_vpc_pub_2a.id
  route_table_id = aws_route_table.dev_igw_route_table.id
  depends_on = [
    aws_route_table.dev_igw_route_table
  ]
}