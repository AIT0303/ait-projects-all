data "aws_caller_identity" "current" {}

locals {
  bucket_name = var.environment != "" ? "${var.project_name}-${var.environment}-tfstate-${data.aws_caller_identity.current.account_id}" : "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
  table_name  = var.environment != "" ? "${var.project_name}-${var.environment}-tfstate-lock" : "${var.project_name}-tfstate-lock"

  default_tags = {
    Name      = "Terraform State"
    ManagedBy = "Terraform"
  }
}

# S3 Bucket for Terraform state
resource "aws_s3_bucket" "tfstate" {
  bucket = local.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.default_tags, var.tags, {
    Name = "Terraform State Bucket"
  })
}

resource "aws_s3_bucket_versioning" "tfstate" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.default_tags, var.tags, {
    Name = "Terraform State Lock Table"
  })
}
