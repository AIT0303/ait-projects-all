# Terraform セキュリティスキャン

## 概要

PR 作成時に自動でセキュリティスキャンを実行し、Terraform コードの脆弱性を検出します。

---

## 使用ツール

### Trivy

Aqua Security の統合セキュリティスキャナー。tfsec の後継として、Terraform の設定ミスや脆弱性を検出。

**特徴:**
- tfsec の後継（tfsec は開発終了予定）
- Terraform `import` ブロック（1.5+）に対応
- コンテナ、ファイルシステム、IaC 全般をスキャン可能

**検出例:**
- S3 バケットの暗号化が無効
- セキュリティグループで 0.0.0.0/0 からのアクセスを許可
- IAM ポリシーが過度に permissive
- CloudTrail のログ検証が無効

**公式サイト:** https://trivy.dev/

### Checkov

IaC 全般のセキュリティスキャナー（Terraform, CloudFormation, Kubernetes 等対応）。

**検出例:**
- リソースにタグが設定されていない
- 暗号化が有効でない
- ログが有効でない
- ネットワーク設定が安全でない

**公式サイト:** https://www.checkov.io/

---

## CI/CD での実行

### パイプライン構成

```
PR 作成
    │
    ├── security-scan (並列実行)
    │   ├── Trivy
    │   └── Checkov
    │
    └── plan (並列実行)
        └── terraform plan
```

### PR へのコメント

```markdown
## 🔒 Security Scan Results

| Scanner | Status |
|---------|--------|
| Trivy | ✅ Passed |
| Checkov | ⚠️ Issues Found |

> 詳細は Actions ログを確認してください。
```

---

## soft_fail について

現在の設定では `continue-on-error: true`（soft_fail相当）になっています：

```yaml
- name: Run Trivy (Terraform)
  uses: aquasecurity/trivy-action@master
  continue-on-error: true  # 失敗してもワークフローを継続
  with:
    scan-type: 'config'
    scan-ref: 'Terraform/multi-account-iac'
```

**意味:**
- セキュリティ問題が検出されても PR のマージは可能
- ログに警告として記録される

**本番向け設定:**
```yaml
continue-on-error: false  # セキュリティ問題があればマージをブロック
```

---

## ローカルでの実行

### Trivy

```bash
# インストール (macOS)
brew install trivy

# 実行
cd Terraform/multi-account-iac
trivy config .

# 特定のモジュールのみ
trivy config ./05-github-oidc
```

### Checkov

```bash
# インストール
pip install checkov

# 実行
cd Terraform/multi-account-iac
checkov -d .

# 特定のモジュールのみ
checkov -d ./05-github-oidc
```

---

## 検出された問題の対処

### 1. 問題を修正する（推奨）

セキュリティ問題を修正してコミット。

### 2. 問題を無視する（例外的に）

正当な理由がある場合、コメントで無視できます。

**Trivy:**
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"

  #trivy:ignore:AVD-AWS-0088
  # 理由: このバケットはログ専用のため
}
```

**Checkov:**
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"

  #checkov:skip=CKV_AWS_18:ログバケットのためスキップ
}
```

---

## よくある検出項目と対処法

### AWS S3

| 検出内容 | 対処法 |
|---------|--------|
| バケット暗号化が無効 | `aws_s3_bucket_server_side_encryption_configuration` を追加 |
| パブリックアクセスが許可 | `aws_s3_bucket_public_access_block` を追加 |
| バージョニングが無効 | `aws_s3_bucket_versioning` を追加 |
| ログが無効 | `aws_s3_bucket_logging` を追加 |

### AWS IAM

| 検出内容 | 対処法 |
|---------|--------|
| ワイルドカード (*) の使用 | 具体的なリソース ARN を指定 |
| AdministratorAccess の使用 | 必要最小限のポリシーに変更 |

### AWS Security Group

| 検出内容 | 対処法 |
|---------|--------|
| 0.0.0.0/0 からの ingress | 必要な IP 範囲に制限 |
| 全ポートの開放 | 必要なポートのみ開放 |

---

## tfsec からの移行について

tfsec は Trivy に統合される予定のため、本プロジェクトでは Trivy を使用しています。

**移行理由:**
- tfsec は開発終了予定
- Trivy は Terraform `import` ブロック（1.5+）に対応
- Trivy はコンテナスキャンなど他のセキュリティ機能も統合

---

## 参考リンク

- [Trivy ドキュメント](https://trivy.dev/latest/docs/)
- [Checkov ドキュメント](https://www.checkov.io/1.Welcome/Quick%20Start.html)
- [AWS Security Best Practices](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp.html)
