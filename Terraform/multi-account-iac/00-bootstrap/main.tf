# Terraform State Backend using module
module "tfstate_backend" {
  source = "../modules/tfstate-backend"

  project_name = local.project_name
  environment  = local.environment

  tags = {
    Purpose = "Bootstrap"
  }
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}
