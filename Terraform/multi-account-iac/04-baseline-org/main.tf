data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "current" {}

# =============================================================================
# Organization CloudTrail
# =============================================================================
resource "aws_s3_bucket" "cloudtrail" {
  count  = local.enable_cloudtrail ? 1 : 0
  bucket = "${local.project_name}-cloudtrail-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "Organization CloudTrail Logs"
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count  = local.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = local.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count  = local.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = local.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

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
        Resource = aws_s3_bucket.cloudtrail[0].arn
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
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
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
  count = local.enable_cloudtrail ? 1 : 0

  name                          = "${local.project_name}-org-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
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
  count  = local.enable_guardduty ? 1 : 0
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
  }

  tags = {
    Name = "Organization GuardDuty"
  }
}

# Enable GuardDuty organization admin (delegates to management account)
resource "aws_guardduty_organization_admin_account" "main" {
  count            = local.enable_guardduty ? 1 : 0
  admin_account_id = data.aws_caller_identity.current.account_id

  depends_on = [aws_guardduty_detector.main]
}

# Auto-enable GuardDuty for new member accounts
resource "aws_guardduty_organization_configuration" "main" {
  count = local.enable_guardduty ? 1 : 0

  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.main[0].id

  depends_on = [aws_guardduty_organization_admin_account.main]
}
