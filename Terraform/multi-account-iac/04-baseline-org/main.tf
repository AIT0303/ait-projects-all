data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "current" {}

# =============================================================================
# Organization CloudTrail
# =============================================================================
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${local.project_name}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name = "Organization CloudTrail Logs"
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${local.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${local.project_name}-org-trail"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "aws:SourceArn" = "arn:aws:cloudtrail:${local.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${local.project_name}-org-trail"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "org_trail" {
  name                          = "${local.project_name}-org-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_logging                = true

  tags = {
    Name = "Organization CloudTrail"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# =============================================================================
# GuardDuty (Organization-level)
# =============================================================================
resource "aws_guardduty_detector" "main" {
  enable = true

  tags = {
    Name = "Organization GuardDuty"
  }
}

resource "aws_guardduty_organization_admin_account" "main" {
  admin_account_id = data.aws_caller_identity.current.account_id

  depends_on = [aws_guardduty_detector.main]
}

resource "aws_guardduty_organization_configuration" "main" {
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.main.id

  depends_on = [aws_guardduty_organization_admin_account.main]
}

# =============================================================================
# AWS Budgets (Cost Alert)
# =============================================================================
resource "aws_budgets_budget" "monthly" {
  name         = "${local.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = local.budget_limit_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [local.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.alert_email]
  }
}

# =============================================================================
# AWS Config (コメントアウト - 必要時に有効化)
# =============================================================================
# resource "aws_s3_bucket" "config" {
#   bucket = "${local.project_name}-config-${data.aws_caller_identity.current.account_id}"
#
#   tags = {
#     Name = "AWS Config Logs"
#   }
# }
#
# resource "aws_s3_bucket_versioning" "config" {
#   bucket = aws_s3_bucket.config.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
#   bucket = aws_s3_bucket.config.id
#
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
#
# resource "aws_s3_bucket_public_access_block" "config" {
#   bucket = aws_s3_bucket.config.id
#
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
#
# resource "aws_s3_bucket_policy" "config" {
#   bucket = aws_s3_bucket.config.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AWSConfigBucketPermissionsCheck"
#         Effect = "Allow"
#         Principal = {
#           Service = "config.amazonaws.com"
#         }
#         Action   = "s3:GetBucketAcl"
#         Resource = aws_s3_bucket.config.arn
#       },
#       {
#         Sid    = "AWSConfigBucketDelivery"
#         Effect = "Allow"
#         Principal = {
#           Service = "config.amazonaws.com"
#         }
#         Action   = "s3:PutObject"
#         Resource = "${aws_s3_bucket.config.arn}/*"
#         Condition = {
#           StringEquals = {
#             "s3:x-amz-acl" = "bucket-owner-full-control"
#           }
#         }
#       }
#     ]
#   })
# }
#
# resource "aws_iam_service_linked_role" "config" {
#   aws_service_name = "config.amazonaws.com"
# }
#
# resource "aws_config_configuration_recorder" "main" {
#   name     = "${local.project_name}-config-recorder"
#   role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
#
#   recording_group {
#     all_supported = true
#   }
#
#   depends_on = [aws_iam_service_linked_role.config]
# }
#
# resource "aws_config_delivery_channel" "main" {
#   name           = "${local.project_name}-config-delivery"
#   s3_bucket_name = aws_s3_bucket.config.id
#
#   depends_on = [aws_config_configuration_recorder.main]
# }
#
# resource "aws_config_configuration_recorder_status" "main" {
#   name       = aws_config_configuration_recorder.main.name
#   is_enabled = true
#
#   depends_on = [aws_config_delivery_channel.main]
# }

# =============================================================================
# Security Hub (コメントアウト - 必要時に有効化)
# =============================================================================
# resource "aws_securityhub_account" "main" {}
#
# resource "aws_securityhub_organization_admin_account" "main" {
#   admin_account_id = data.aws_caller_identity.current.account_id
#
#   depends_on = [aws_securityhub_account.main]
# }
#
# resource "aws_securityhub_organization_configuration" "main" {
#   auto_enable           = true
#   auto_enable_standards = "DEFAULT"
#
#   depends_on = [aws_securityhub_organization_admin_account.main]
# }
#
# resource "aws_securityhub_standards_subscription" "aws_foundational" {
#   standards_arn = "arn:aws:securityhub:${local.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
#
#   depends_on = [aws_securityhub_account.main]
# }

# =============================================================================
# IAM Access Analyzer (コメントアウト - 無料だが必要時に有効化)
# =============================================================================
# resource "aws_accessanalyzer_analyzer" "org" {
#   analyzer_name = "${local.project_name}-access-analyzer"
#   type          = "ORGANIZATION"
#
#   tags = {
#     Name = "Organization Access Analyzer"
#   }
# }

# =============================================================================
# AWS Backup (コメントアウト - 必要時に有効化)
# =============================================================================
# resource "aws_backup_vault" "main" {
#   name = "${local.project_name}-backup-vault"
#
#   tags = {
#     Name = "Organization Backup Vault"
#   }
# }
#
# resource "aws_iam_role" "backup" {
#   name = "${local.project_name}-backup-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "backup.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "backup" {
#   role       = aws_iam_role.backup.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
# }
#
# resource "aws_iam_role_policy_attachment" "backup_restore" {
#   role       = aws_iam_role.backup.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
# }
#
# resource "aws_backup_plan" "daily" {
#   name = "${local.project_name}-daily-backup"
#
#   rule {
#     rule_name         = "daily-backup-rule"
#     target_vault_name = aws_backup_vault.main.name
#     schedule          = "cron(0 5 ? * * *)"
#
#     lifecycle {
#       delete_after = 30
#     }
#   }
#
#   tags = {
#     Name = "Daily Backup Plan"
#   }
# }
