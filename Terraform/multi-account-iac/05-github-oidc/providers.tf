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
    key            = "github-oidc/terraform.tfstate"
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
  aws_region  = "ap-northeast-1"
  github_org  = "AIT0303"          # GitHub Organization または Username（大文字小文字注意）
  github_repo = "ait-projects-all" # リポジトリ名
}
