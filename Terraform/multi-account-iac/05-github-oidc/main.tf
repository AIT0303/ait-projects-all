data "aws_caller_identity" "current" {}

# =============================================================================
# GitHub OIDC Provider
# =============================================================================
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub の OIDC thumbprint（固定値）
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]

  tags = {
    Name = "GitHub Actions OIDC Provider"
  }
}

# =============================================================================
# IAM Role for GitHub Actions (Terraform)
# =============================================================================
resource "aws_iam_role" "github_actions_terraform" {
  name = "github-actions-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # このリポジトリからのみ認証を許可
            "token.actions.githubusercontent.com:sub" = "repo:${local.github_org}/${local.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "GitHub Actions Terraform Role"
  }
}

# Terraform 実行に必要な権限（AdministratorAccess - 本番では絞ること推奨）
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# =============================================================================
# Outputs
# =============================================================================
output "role_arn" {
  description = "GitHub Actions 用 IAM Role ARN（GitHub Secrets に設定）"
  value       = aws_iam_role.github_actions_terraform.arn
}

output "aws_region" {
  description = "AWS Region"
  value       = local.aws_region
}
