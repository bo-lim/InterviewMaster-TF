output "itm_vpc_id" {
  value = aws_vpc.itm-vpc.id
}

output "itm_subnet_eks_2a" {
  value = aws_subnet.itm-vpc-eks-2a.id
}

output "itm_subnet_eks_2c" {
  value = aws_subnet.itm-vpc-eks-2c.id
}