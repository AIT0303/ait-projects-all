# Development Account
resource "aws_organizations_account" "dev" {
  name      = "dev-account"
  email     = "${local.organization_email_prefix}dev@${local.organization_email_domain}"
  parent_id = aws_organizations_organizational_unit.dev.id

  # Prevent accidental deletion
  close_on_deletion = false

  # IAM user access to billing (optional)
  iam_user_access_to_billing = "ALLOW"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Environment = "development"
  }
}

# Production Account
resource "aws_organizations_account" "prod" {
  name      = "prod-account"
  email     = "${local.organization_email_prefix}prod@${local.organization_email_domain}"
  parent_id = aws_organizations_organizational_unit.prod.id

  close_on_deletion          = false
  iam_user_access_to_billing = "ALLOW"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Environment = "production"
  }
}

# Security/Audit Account (optional - for centralized logging)
# resource "aws_organizations_account" "security" {
#   name      = "security-account"
#   email     = "${local.organization_email_prefix}security@${local.organization_email_domain}"
#   parent_id = aws_organizations_organizational_unit.security.id
#
#   close_on_deletion          = false
#   iam_user_access_to_billing = "ALLOW"
#
#   lifecycle {
#     prevent_destroy = true
#   }
#
#   tags = {
#     Environment = "security"
#   }
# }
