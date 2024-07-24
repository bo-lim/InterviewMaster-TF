locals {
  tags = {
    created-by = "itm"
  }
}

locals {
  itm_vpc_id = data.terraform_remote_state.vpc.outputs.itm_vpc_id
  itm_subnet_eks_2a = data.terraform_remote_state.vpc.outputs.itm_subnet_eks_2a
  itm_subnet_eks_2c = data.terraform_remote_state.vpc.outputs.itm_subnet_eks_2c
}