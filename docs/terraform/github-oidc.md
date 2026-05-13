# GitHub Actions OIDC 認証

## 概要

GitHub Actions から AWS リソースを操作する際の認証方式として、OIDC（OpenID Connect）を使用します。
従来の Access Key 方式と比較して、セキュリティが大幅に向上します。

---

## OIDC vs Access Key

### Access Key 認証（従来の方法）

```
┌─────────────────┐     Access Key ID + Secret     ┌─────────────┐
│  GitHub Actions │ ─────────────────────────────▶ │     AWS     │
│                 │     (永続的なキー)              │             │
└─────────────────┘                                └─────────────┘
```

**問題点:**
- Access Key は**永続的**（削除するまで有効）
- GitHub Secrets に保存 → 漏洩リスク
- 定期的なローテーションが必要
- キーが漏洩したら即座に不正アクセス可能

---

### OIDC 認証（推奨）

```
┌─────────────────┐                              ┌─────────────┐
│  GitHub Actions │ ──(1) JWT トークン要求──────▶ │   GitHub    │
│                 │ ◀──(2) JWT トークン発行────── │   OIDC      │
└─────────────────┘                              └─────────────┘
        │
        │ (3) JWT トークンを提示
        │    「私は ait0303/ait-projects-all の
        │     main ブランチから実行しています」
        ▼
┌─────────────────┐                              ┌─────────────┐
│       AWS       │ ──(4) GitHub に確認─────────▶ │   GitHub    │
│   IAM Role      │ ◀──(5) 本物です────────────── │   OIDC      │
└─────────────────┘                              └─────────────┘
        │
        │ (6) 一時的な認証情報を発行（15分〜1時間）
        ▼
┌─────────────────┐
│  GitHub Actions │  ← これで AWS 操作可能
└─────────────────┘
```

**メリット:**
- **キーの保存が不要** → 漏洩リスクなし
- **一時的な認証情報** → 自動で失効（最大1時間）
- **条件付きアクセス** → 特定のリポジトリ/ブランチのみ許可可能

---

## 比較表

| 項目 | Access Key | OIDC |
|------|------------|------|
| 認証情報の保存 | GitHub Secrets に保存 | 不要 |
| 有効期限 | 永続（手動で削除まで） | 一時的（最大1時間） |
| ローテーション | 手動で必要 | 自動（毎回新しい） |
| 漏洩リスク | 高い | 低い |
| 条件制限 | できない | リポジトリ/ブランチ指定可能 |
| 設定の複雑さ | 簡単 | やや複雑 |

---

## 仕組みの詳細

### 1. AWS に登録する OIDC Provider

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"  # GitHub の OIDC エンドポイント
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}
```

**意味:** 「GitHub が発行した JWT トークンを信頼する」という設定

### 2. IAM Role の信頼ポリシー

```hcl
resource "aws_iam_role" "github_actions_terraform" {
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
            "token.actions.githubusercontent.com:sub" = "repo:ait0303/ait-projects-all:*"
          }
        }
      }
    ]
  })
}
```

**意味:** 「`ait0303/ait-projects-all` からのリクエストのみ許可」

### 3. JWT トークンの中身

GitHub Actions が発行する JWT には以下の情報が含まれる：

```json
{
  "sub": "repo:ait0303/ait-projects-all:ref:refs/heads/main",
  "repository": "ait0303/ait-projects-all",
  "actor": "tanaka",
  "ref": "refs/heads/main",
  "event_name": "push"
}
```

AWS はこの情報を見て「本当にこのリポジトリからのリクエストか」を確認します。

---

## セットアップ手順

### Step 1: OIDC Provider を AWS に作成

```bash
cd Terraform/multi-account-iac/05-github-oidc
terraform init
terraform apply
```

出力例：
```
Outputs:

role_arn = "arn:aws:iam::216876474007:role/github-actions-terraform-role"
aws_region = "ap-northeast-1"
```

### Step 2: GitHub Secrets に Role ARN を設定

1. GitHub リポジトリ → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** をクリック
3. 以下を入力：
   - Name: `AWS_ROLE_ARN`
   - Secret: `arn:aws:iam::216876474007:role/github-actions-terraform-role`

### Step 3: GitHub Actions ワークフローで使用

```yaml
permissions:
  id-token: write   # OIDC に必要
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ap-northeast-1
```

---

## セキュリティ設定（本番向け）

### ブランチ制限

特定のブランチからのみ許可：

```hcl
Condition = {
  StringEquals = {
    "token.actions.githubusercontent.com:sub" = "repo:ait0303/ait-projects-all:ref:refs/heads/main"
  }
}
```

### 権限の最小化

AdministratorAccess ではなく、必要な権限のみ付与：

```hcl
resource "aws_iam_role_policy" "terraform_minimal" {
  role = aws_iam_role.github_actions_terraform.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "dynamodb:*",
          "iam:*",
          # ... 必要な権限のみ
        ]
        Resource = "*"
      }
    ]
  })
}
```

---

## トラブルシューティング

### エラー: "Not authorized to perform sts:AssumeRoleWithWebIdentity"

**原因:** 信頼ポリシーの条件が一致しない

**確認ポイント:**
1. リポジトリ名が正しいか（`ait0303/ait-projects-all`）
2. `id-token: write` パーミッションがあるか
3. OIDC Provider の URL が正しいか

### エラー: "OpenIDConnect provider's HTTPS certificate doesn't match"

**原因:** thumbprint が古い

**解決:** thumbprint を `ffffffffffffffffffffffffffffffffffffffff` に設定（AWS が自動検証）

---

## 参考リンク

- [GitHub Docs: OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS Docs: OIDC Provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Terraform: aws_iam_openid_connect_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider)
