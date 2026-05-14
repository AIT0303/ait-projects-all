# Terraform セキュリティスキャン

## 概要

PR 作成時に自動でセキュリティスキャンを実行し、Terraform コードの脆弱性を検出します。

---

## 使用ツール

### tfsec

Terraform 専用のセキュリティスキャナー。AWS/Azure/GCP のベストプラクティスに基づいてチェック。

**検出例:**
- S3 バケットの暗号化が無効
- セキュリティグループで 0.0.0.0/0 からのアクセスを許可
- IAM ポリシーが過度に permissive
- CloudTrail のログ検証が無効

**公式サイト:** https://aquasecurity.github.io/tfsec/

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
    │   ├── tfsec
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
| tfsec | ✅ Passed |
| Checkov | ⚠️ Issues Found |

> 詳細は Actions ログを確認してください。
```

---

## soft_fail について

現在の設定では `soft_fail: true` になっています：

```yaml
- name: Run tfsec
  uses: aquasecurity/tfsec-action@v1.0.3
  with:
    soft_fail: true  # 失敗してもワークフローを継続
```

**意味:**
- セキュリティ問題が検出されても PR のマージは可能
- ログに警告として記録される

**本番向け設定:**
```yaml
soft_fail: false  # セキュリティ問題があればマージをブロック
```

---

## ローカルでの実行

### tfsec

```bash
# インストール (macOS)
brew install tfsec

# 実行
cd Terraform/multi-account-iac
tfsec .

# 特定のモジュールのみ
tfsec ./05-github-oidc
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

**tfsec:**
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"

  #tfsec:ignore:aws-s3-enable-bucket-logging
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

## 参考リンク

- [tfsec ドキュメント](https://aquasecurity.github.io/tfsec/)
- [Checkov ドキュメント](https://www.checkov.io/1.Welcome/Quick%20Start.html)
- [AWS Security Best Practices](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp.html)
