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
    key            = "identity-center/terraform.tfstate"
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
  aws_region          = "ap-northeast-1"
  dev_account_id      = "943189351254"
  prod_account_id     = "058114476868"
  audit_account_id    = "499420147892"
  log_archive_account_id = "576366895894"
}
