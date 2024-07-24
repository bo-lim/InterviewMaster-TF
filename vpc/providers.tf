terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "bolimuser"
  region = "ap-northeast-2"
  default_tags {
    tags = local.tags
  }
}
