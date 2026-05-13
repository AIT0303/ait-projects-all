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
    key            = "baseline-org/terraform.tfstate"
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
  aws_region   = "ap-northeast-1"
  project_name = "ait-multi-account"

  # コメントアウト中 - 必要時に有効化
  # enable_cloudtrail = true
  # enable_guardduty  = true

  # Budget settings
  budget_limit_usd = "10"                         # 月額予算（USD）
  alert_email      = "kouki.06.15.1803@gmail.com" # アラート通知先
}
