# AWS マルチアカウント構成 - Terraform 学習ノート

## 概要

このプロジェクトでは、AWS Organizations を使用したマルチアカウント構成を Terraform で構築する方法を学習しました。

```
┌─────────────────────────────────────────────────────────────┐
│                    Management Account                        │
│                      (tanaty)                                │
│                   216876474007                               │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ IAM Identity│  │ CloudTrail  │  │  GuardDuty  │          │
│  │   Center    │  │  (組織全体) │  │  (組織全体) │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │  Workloads  │  │   Security  │  │   Sandbox   │
    │     OU      │  │     OU      │  │     OU      │
    └─────────────┘  └─────────────┘  └─────────────┘
      │       │
      ▼       ▼
    ┌───┐   ┌───┐
    │Dev│   │Prod│
    │OU │   │OU  │
    └───┘   └───┘
      │       │
      ▼       ▼
  ┌───────┐ ┌───────┐   ┌───────┐   ┌───────────┐
  │  dev  │ │ prod  │   │ Audit │   │Log Archive│
  │account│ │account│   │account│   │  account  │
  └───────┘ └───────┘   └───────┘   └───────────┘
```

---

## モジュール構成

### 00-bootstrap - Terraform State 管理

**目的**: Terraform の状態ファイル（tfstate）を安全に管理するためのバックエンド環境を構築

**作成されるリソース**:
- **S3 バケット**: tfstate ファイルの保存先（暗号化・バージョニング有効）
- **DynamoDB テーブル**: State Locking（同時実行防止）

**学んだこと**:
```hcl
# State Locking の仕組み
# 複数人が同時に terraform apply すると競合が発生する
# DynamoDB でロックをかけることで、1人ずつ順番に実行される
backend "s3" {
  bucket         = "ait-multi-account-management-tfstate-216876474007"
  key            = "bootstrap/terraform.tfstate"
  region         = "ap-northeast-1"
  dynamodb_table = "ait-multi-account-management-tfstate-lock"  # ロック用
  encrypt        = true
}
```

---

### 01-organizations - AWS Organizations 構成

**目的**: 組織単位（OU）の階層構造とメンバーアカウントの管理

**作成されるリソース**:
- **Organizational Units (OU)**: Workloads, Dev, Prod, Security, Sandbox
- **Member Accounts**: dev-account, prod-account

**学んだこと**:

1. **OU の用途**
   | OU | 用途 |
   |---|---|
   | Workloads | 本番・開発ワークロードの親OU |
   | Dev | 開発環境アカウント |
   | Prod | 本番環境アカウント |
   | Security | セキュリティ・監査用（Audit, Log Archive） |
   | Sandbox | 実験・検証用 |

2. **既存リソースの Import**
   ```hcl
   # 手動で作成済みのリソースを Terraform 管理下に置く
   import {
     to = aws_organizations_organizational_unit.workloads
     id = "ou-f2qy-5lkxwb3b"
   }
   ```

---

### 02-identity-center - IAM Identity Center (SSO)

**目的**: 複数アカウントへのシングルサインオン環境を構築

**作成されるリソース**:
- **Permission Sets**: AdministratorAccess, DeveloperAccess, ReadOnlyAccess
- **Groups**: Admins, Developers, Auditors
- **Account Assignments**: グループとアカウントの紐付け

**学んだこと**:

1. **Permission Set と IAM Policy の違い**
   - **IAM Policy**: 1つのアカウント内で使用
   - **Permission Set**: 複数アカウントに一括適用可能

2. **グループベースのアクセス管理**
   ```
   ┌──────────┐     ┌─────────────────┐     ┌─────────────┐
   │  User    │ ──▶ │     Group       │ ──▶ │  Account    │
   │ (tanaka) │     │ (Admins)        │     │ (dev, prod) │
   └──────────┘     └─────────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────────┐
                    │ Permission Set  │
                    │(Administrator)  │
                    └─────────────────┘
   ```

3. **権限マトリクス**
   | グループ | Management | Dev | Prod | Audit | Log Archive |
   |---------|------------|-----|------|-------|-------------|
   | Admins | Admin | Admin | Admin | Admin | Admin |
   | Developers | - | Developer | ReadOnly | - | - |
   | Auditors | ReadOnly | ReadOnly | ReadOnly | - | - |

---

### 03-scp - Service Control Policies

**目的**: 組織全体のセキュリティガードレールを設定

**作成されるポリシー**:
- **DenyLeaveOrganization**: アカウントが組織を離脱することを禁止
- **DenyRootUserProduction**: 本番環境での root ユーザー操作を禁止
- **DenyUnapprovedRegions**: 許可されたリージョン以外でのリソース作成を禁止

**学んだこと**:

1. **SCP の特徴**
   - IAM Policy より上位で適用される「最大権限」を定義
   - Deny のみ記述するのが一般的（Allow は IAM で管理）
   - Management Account には適用されない

2. **リージョン制限の実装**
   ```json
   {
     "Effect": "Deny",
     "NotAction": [
       "iam:*",           // グローバルサービスは除外
       "organizations:*",
       "cloudfront:*",
       "route53:*"
     ],
     "Resource": "*",
     "Condition": {
       "StringNotEquals": {
         "aws:RequestedRegion": ["ap-northeast-1", "us-east-1"]
       }
     }
   }
   ```

---

### 04-baseline-org - 組織レベルのセキュリティサービス

**目的**: 組織全体のセキュリティ監視・監査環境を構築

**有効にしたリソース**:

| サービス | 用途 | 課金 |
|---------|------|------|
| **CloudTrail** | 全アカウントの API 操作ログを集約 | 管理イベント1つは無料 |
| **GuardDuty** | 脅威検出（不正アクセス、マルウェア等） | 30日無料、以降従量課金 |
| **AWS Budgets** | コストアラート | 2つまで無料 |

**学んだこと**:

1. **Organization Trail**
   ```hcl
   resource "aws_cloudtrail" "org_trail" {
     is_organization_trail = true  # 全アカウントのログを集約
     is_multi_region_trail = true  # 全リージョンを記録
   }
   ```

2. **GuardDuty の自動有効化**
   ```hcl
   resource "aws_guardduty_organization_configuration" "main" {
     auto_enable_organization_members = "ALL"  # 新規アカウントも自動有効化
   }
   ```

3. **Budget アラート設定**
   - 予測が 50% を超えたら通知
   - 実績が 80% を超えたら通知
   - 実績が 100% を超えたら通知

---

## Terraform のベストプラクティス（学んだこと）

### 1. locals vs variables

```hcl
# ❌ variables.tf + var.xxx（このプロジェクトでは不採用）
variable "aws_region" {
  default = "ap-northeast-1"
}
# 呼び出し: var.aws_region

# ✅ providers.tf に locals（このプロジェクトで採用）
locals {
  aws_region = "ap-northeast-1"
}
# 呼び出し: local.aws_region
```

**理由**: 呼び出し側で `var.` を使いたくない、設定をまとめて見やすくする

### 2. for_each を使わない理由

```hcl
# for_each のデメリット
# - どこを変えればいいか分かりにくい
# - plan 出力が読みにくい（this["admins_dev"]）
# - チームメンバーが理解しにくい

# 明示的なリソース定義を採用
resource "aws_ssoadmin_account_assignment" "admins_dev" { ... }
resource "aws_ssoadmin_account_assignment" "admins_prod" { ... }
```

### 3. Import ブロック

```hcl
# 既存リソースを Terraform 管理下に置く
import {
  to = aws_guardduty_detector.main
  id = "82cac7b4c45268d0322a3024773c9cb9"
}
```

### 4. S3 バケット削除時の注意

```hcl
# バージョニング有効なバケットは force_destroy が必要
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "..."
  force_destroy = true  # destroy 時に中身も削除
}
```

---

## コスト管理のポイント

### 無料で使えるサービス
- IAM Identity Center
- AWS Organizations
- IAM Access Analyzer
- AWS Budgets（2つまで）

### 課金に注意が必要なサービス
- GuardDuty（30日無料トライアル後、アカウント数 × 従量課金）
- CloudTrail（データイベントは有料）
- AWS Config（記録リソース数による）
- Security Hub（30日無料トライアル後）

### 学習後の推奨アクション
```bash
# 課金サービスを削除
cd 04-baseline-org
terraform destroy

# または、コメントアウトして apply
```

---

## ファイル構成

```
multi-account-iac/
├── 00-bootstrap/           # Terraform State 管理
│   ├── main.tf
│   └── providers.tf
├── 01-organizations/       # OU・アカウント管理
│   ├── accounts.tf
│   ├── imports.tf
│   ├── ous.tf
│   └── providers.tf
├── 02-identity-center/     # SSO 設定
│   ├── assignments.tf
│   ├── groups.tf
│   ├── imports.tf
│   ├── main.tf
│   ├── permission_sets.tf
│   └── providers.tf
├── 03-scp/                 # Service Control Policies
│   ├── main.tf
│   ├── policies/
│   │   ├── deny-leave-org.json
│   │   ├── deny-regions.json
│   │   └── deny-root-prod.json
│   └── providers.tf
├── 04-baseline-org/        # セキュリティサービス
│   ├── imports.tf
│   ├── main.tf
│   └── providers.tf
└── modules/
    └── tfstate-backend/    # State バックエンド用モジュール
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

---

## 参考リンク

- [AWS Organizations ドキュメント](https://docs.aws.amazon.com/organizations/)
- [IAM Identity Center ドキュメント](https://docs.aws.amazon.com/singlesignon/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected - マルチアカウント戦略](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)
