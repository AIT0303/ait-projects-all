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
    key            = "organizations/terraform.tfstate"
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
  aws_region                = "ap-northeast-1"
  organization_email_domain = "ait0303.com"      # TODO: 自分のメールドメインに変更
  organization_email_prefix = "aws+"
}
