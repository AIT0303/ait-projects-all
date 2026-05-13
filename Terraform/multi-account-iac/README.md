# AWS Multi-Account IaC

TerraformでAWS Organizations マルチアカウント環境を構築するための学習プロジェクト。

## 構成

```
multi-account-iac/
├── 00-bootstrap/        # tfstate用 S3 + DynamoDB (最初に実行)
├── 01-organizations/    # OU構造 + メンバーアカウント作成
├── 02-identity-center/  # IAM Identity Center設定
├── 03-scp/              # Service Control Policies
├── 04-baseline-org/     # CloudTrail, GuardDuty
└── modules/             # 共通モジュール
```

## 前提条件

- AWS CLI がインストール済み
- Terraform >= 1.0.0
- AWS Organizations が有効化済み
- 管理アカウントの認証情報が設定済み

## セットアップ手順

### 1. AWS認証情報の設定

```bash
# AWS CLIの設定
aws configure

# または環境変数
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-northeast-1"
```

### 2. Bootstrap (tfstate用インフラ作成)

```bash
cd 00-bootstrap
terraform init
terraform plan
terraform apply
```

実行後、出力されるバックエンド設定を各モジュールの `providers.tf` に反映。

### 3. Organizations (OU + アカウント作成)

```bash
cd ../01-organizations
terraform init
terraform plan -var="organization_email_domain=example.com"
terraform apply -var="organization_email_domain=example.com"
```

**注意**: メンバーアカウント作成には一意のメールアドレスが必要。
Gmail の場合は `yourname+dev@gmail.com` のようにエイリアスを使用可能。

### 4. IAM Identity Center

```bash
cd ../02-identity-center
terraform init

# 01-organizations の出力から account ID を取得して指定
terraform plan \
  -var="dev_account_id=123456789012" \
  -var="prod_account_id=123456789013"

terraform apply \
  -var="dev_account_id=123456789012" \
  -var="prod_account_id=123456789013"
```

**前提**: IAM Identity Center をAWSコンソールで事前に有効化する必要あり。

### 5. SCP (Service Control Policies)

```bash
cd ../03-scp
terraform init

# 01-organizations の出力から OU ID を取得して指定
terraform plan \
  -var="ou_prod_id=ou-xxxx-xxxxxxxx" \
  -var="ou_workloads_id=ou-xxxx-yyyyyyyy"

terraform apply \
  -var="ou_prod_id=ou-xxxx-xxxxxxxx" \
  -var="ou_workloads_id=ou-xxxx-yyyyyyyy"
```

### 6. Baseline (CloudTrail, GuardDuty)

```bash
cd ../04-baseline-org
terraform init
terraform plan
terraform apply
```

## OU構造

```
Root
├── Workloads
│   ├── Development (dev-account)
│   └── Production (prod-account)
├── Security
└── Sandbox
```

## Permission Sets

| Permission Set | 説明 |
|----------------|------|
| AdministratorAccess | フル管理者権限 |
| ReadOnlyAccess | 読み取り専用 |
| DeveloperAccess | PowerUser (IAM変更不可) |

## SCPポリシー

| ポリシー | 対象OU | 説明 |
|----------|--------|------|
| DenyLeaveOrganization | Workloads | 組織からの離脱を禁止 |
| DenyRootUserProduction | Production | 本番でのrootユーザー使用禁止 |
| DenyUnapprovedRegions | Workloads | 許可リージョン以外での操作禁止 |

## 変数ファイルの例

`terraform.tfvars.example`:
```hcl
aws_region               = "ap-northeast-1"
organization_email_domain = "example.com"
organization_email_prefix = "aws+"
```

## コスト

- Organizations: 無料
- メンバーアカウント作成: 無料
- IAM Identity Center: 無料
- SCP: 無料
- CloudTrail: S3ストレージ料金のみ
- GuardDuty: 分析データ量に応じた課金

## 注意事項

- メンバーアカウントの削除には90日のクローズ期間が必要
- 本番環境では `prevent_destroy = true` を有効化推奨
- SCPは管理アカウントには適用されない
