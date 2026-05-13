terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Initially use local state, then migrate to S3 after bootstrap
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket"
  #   key            = "bootstrap/terraform.tfstate"
  #   region         = "ap-northeast-1"
  #   dynamodb_table = "terraform-lock"
  #   encrypt        = true
  # }
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
  environment  = "management"
}
