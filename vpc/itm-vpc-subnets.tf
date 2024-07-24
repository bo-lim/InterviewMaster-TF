# subnet
## public
resource "aws_subnet" "itm-vpc-pub-2a" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ITM-VPC-PUB-2A"
    created-by = "itm"
    service = "argo"
  }
}

resource "aws_subnet" "itm-vpc-pub-2c" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "ITM-VPC-PUB-2C"
    created-by = "itm"
    service = "gitlab"
  }
}

resource "aws_subnet" "itm-vpc-eks-2a" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "10.10.8.0/21"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "ITM-VPC-EKS-2A"
    created-by = "itm"
    service = "eks"
    "karpenter.sh/discovery" = "itm-eks"
  }
}

resource "aws_subnet" "itm-vpc-eks-2c" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "10.10.16.0/21"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "ITM-VPC-EKS-2C"
    created-by = "itm"
    service = "eks"
    "karpenter.sh/discovery" = "itm-eks"
  }
}

resource "aws_subnet" "itm-vpc-red-2a" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "10.10.3.0/28"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "ITM-VPC-RED-2A"
    created-by = "itm"
    service = "redis"
  }
}

resource "aws_subnet" "itm-vpc-red-2c" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "10.10.4.0/28"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "ITM-VPC-RED-2C"
    created-by = "itm"
    service = "redis"
  }
}

## POD SUBNET
resource "aws_subnet" "itm-vpc-pod-2a" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "100.65.0.0/19"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "ITM-VPC-POD-2A"
    created-by = "itm"
    service = "eks"
  }
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.pods
  ]
}

resource "aws_subnet" "itm-vpc-pod-2c" {
  vpc_id     = aws_vpc.itm-vpc.id
  cidr_block = "100.65.32.0/19"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "ITM-VPC-POD-2C"
    created-by = "itm"
    service = "eks"
  }
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.pods
  ]
}

########
# PUBLIC
########

resource "aws_route_table_association" "public_2a" {
  subnet_id      = aws_subnet.itm-vpc-pub-2a.id
  route_table_id = aws_route_table.igw_route_table.id
  depends_on = [
    aws_route_table.igw_route_table
  ]
}

resource "aws_route_table_association" "public_2c" {
  subnet_id      = aws_subnet.itm-vpc-pub-2c.id
  route_table_id = aws_route_table.igw_route_table.id
  depends_on = [
    aws_route_table.igw_route_table
  ]
}

########
# PRIVATE
########

resource "aws_route_table_association" "eks_2a" {
  subnet_id      = aws_subnet.itm-vpc-eks-2a.id
  route_table_id = aws_route_table.nat_2a.id
  depends_on = [
    aws_route_table.nat_2a
  ]
}

resource "aws_route_table_association" "eks_2c" {
  subnet_id      = aws_subnet.itm-vpc-eks-2c.id
  route_table_id = aws_route_table.nat_2c.id
  depends_on = [
    aws_route_table.nat_2c
  ]
}

resource "aws_route_table_association" "redis_2a" {
  subnet_id      = aws_subnet.itm-vpc-red-2a.id
  route_table_id = aws_route_table.nat_2a.id
  depends_on = [
    aws_route_table.nat_2a
  ]
}

resource "aws_route_table_association" "redis_2c" {
  subnet_id      = aws_subnet.itm-vpc-red-2c.id
  route_table_id = aws_route_table.nat_2c.id
  depends_on = [
    aws_route_table.nat_2c
  ]
}

resource "aws_route_table_association" "eks_pod_2a" {
  subnet_id      = aws_subnet.itm-vpc-pod-2a.id
  route_table_id = aws_route_table.nat_2a.id
  depends_on = [
    aws_route_table.nat_2a
  ]
}

resource "aws_route_table_association" "eks_pod_2c" {
  subnet_id      = aws_subnet.itm-vpc-pod-2c.id
  route_table_id = aws_route_table.nat_2c.id
  depends_on = [
    aws_route_table.nat_2c
  ]
}