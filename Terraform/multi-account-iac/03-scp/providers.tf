terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "ait-multi-account-management-tfstate-216876474007"
    key            = "scp/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "ait-multi-account-management-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = local.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "multi-account-iac"
    }
  }
}

locals {
  aws_region      = "ap-northeast-1"
  ou_workloads_id = "ou-f2qy-5lkxwb3b"
  ou_prod_id      = "ou-f2qy-uvsgmhrl"
  ou_dev_id       = "ou-f2qy-b0o7lyoi"
}
