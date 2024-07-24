data "terraform_remote_state" "vpc" {
	backend = "local" 
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.main.id
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "eks" {
  name = format("/aws/service/eks/optimized-ami/%s/amazon-linux-2/recommended/image_id", var.k8s_version)
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.seoul
}