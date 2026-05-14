# Terraform Lint チェック

## 概要

Lint（リント）とは、コードの品質をチェックするツールのこと。
Terraform では以下の3つのツールを組み合わせて品質を担保します。

| ツール | 役割 | 実行タイミング |
|--------|------|---------------|
| `terraform fmt` | フォーマット統一 | CI + ローカル |
| `terraform validate` | 構文チェック | CI + ローカル |
| `tflint` | ベストプラクティス | CI + ローカル |

---

## なぜ必要なのか

### 1. コードの一貫性

```hcl
# フォーマットなし（読みにくい）
resource "aws_s3_bucket" "example" {
bucket="my-bucket"
  tags={Name="example"
  Environment = "dev"}
}

# フォーマットあり（読みやすい）
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
  tags = {
    Name        = "example"
    Environment = "dev"
  }
}
```

### 2. 早期のエラー検出

```
┌─────────────────────────────────────────────────────────────────┐
│  Lint なしの場合                                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  コード作成 → PR → レビュー → マージ → Apply → エラー発覚！    │
│                                                  ↑              │
│                                            本番環境で問題       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Lint ありの場合                                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  コード作成 → Lint → エラー検出 → 修正 → PR → マージ → Apply   │
│               ↑                                                 │
│         ここで問題を発見                                        │
└─────────────────────────────────────────────────────────────────┘
```

### 3. レビュー負荷の軽減

| Lint なし | Lint あり |
|-----------|-----------|
| 「インデント直して」 | 自動チェック済み |
| 「命名規則違反」 | 自動チェック済み |
| 「非推奨の書き方」 | 自動チェック済み |
| → レビューで指摘 | → 本質的な議論に集中 |

---

## ないとどうなるか

### 問題1: コードスタイルがバラバラ

```hcl
# 開発者A のスタイル
resource "aws_instance" "web" {
    ami = "ami-12345"
    instance_type = "t3.micro"
}

# 開発者B のスタイル
resource "aws_instance" "app" {
  ami           = "ami-67890"
  instance_type = "t3.small"
}
```

→ 可読性が低下、Git diff が見づらい

### 問題2: 非推奨構文に気づかない

```hcl
# 古い書き方（Terraform 0.12 以前）
resource "aws_instance" "example" {
  ami = "${var.ami_id}"  # 非推奨: 不要な ${}
}

# 新しい書き方
resource "aws_instance" "example" {
  ami = var.ami_id  # シンプル
}
```

→ tflint がないと気づかない

### 問題3: プロバイダー固有の問題

```hcl
# tflint で検出できる問題
resource "aws_instance" "example" {
  ami           = "ami-12345"
  instance_type = "t3.micro-invalid"  # 存在しないインスタンスタイプ
}
```

→ `terraform validate` では検出できない、`terraform plan` で初めて失敗

### 問題4: 命名規則違反

```hcl
# 命名規則違反
resource "aws_s3_bucket" "MyBucket" {      # PascalCase
resource "aws_s3_bucket" "my-bucket" {     # kebab-case

# 正しい命名規則（snake_case）
resource "aws_s3_bucket" "my_bucket" {
```

---

## 各ツールの詳細

### terraform fmt

**役割:** フォーマットの統一

**検出例:**
- インデントの乱れ
- スペースの不統一
- 改行位置

**コマンド:**
```bash
# チェックのみ（CI 用）
terraform fmt -check -recursive

# 自動修正
terraform fmt -recursive
```

### terraform validate

**役割:** 構文の検証

**検出例:**
- 存在しない属性の参照
- 型の不一致
- 必須属性の欠落
- 循環参照

**コマンド:**
```bash
terraform init  # 先に init が必要
terraform validate
```

### tflint

**役割:** ベストプラクティスの検証

**検出例:**
- 非推奨構文（`${}`の不要な使用）
- 未使用の変数・ローカル
- 命名規則違反
- AWS 固有のエラー（無効なインスタンスタイプ等）

**コマンド:**
```bash
# インストール
brew install tflint

# 初期化（プラグインのダウンロード）
tflint --init

# 実行
tflint
```

---

## 費用

**すべて無料です。**

| ツール | 料金 | 備考 |
|--------|------|------|
| terraform fmt | 無料 | Terraform に付属 |
| terraform validate | 無料 | Terraform に付属 |
| tflint | 無料 | OSS (MIT License) |

CI での実行時間も数秒なので、GitHub Actions の無料枠で十分。

---

## ローカルでの使い方

### セットアップ

```bash
# macOS
brew install terraform
brew install tflint

# tflint プラグインの初期化
cd Terraform/multi-account-iac
tflint --init
```

### 日常的なワークフロー

```bash
# 1. コードを書く
vim main.tf

# 2. フォーマット
terraform fmt

# 3. Lint チェック
tflint

# 4. 構文検証
terraform validate

# 5. 問題なければコミット
git add . && git commit -m "Add new resource"
```

### 一括チェックスクリプト

```bash
#!/bin/bash
# lint.sh

set -e

echo "=== Format Check ==="
terraform fmt -check -recursive

echo "=== TFLint ==="
tflint --init
tflint

echo "=== Validate ==="
terraform init -backend=false
terraform validate

echo "=== All checks passed! ==="
```

---

## CI での設定

### 本プロジェクトの設定

```yaml
# .github/workflows/terraform.yml

- name: Terraform Format Check
  run: terraform fmt -check -recursive

- name: Setup TFLint
  uses: terraform-linters/setup-tflint@v4

- name: Init TFLint
  run: tflint --init

- name: Run TFLint
  run: tflint --format compact

- name: Terraform Validate
  run: terraform validate
```

### PR コメントでの結果表示

```
## Terraform Plan: `02-identity-center`

| Step | Status |
|------|--------|
| 🖌 Format | ✅ |
| 🔍 TFLint | ✅ |
| ⚙️ Init | ✅ |
| 📋 Validate | ✅ |
| 📝 Plan | ✅ |
```

---

## tflint の設定ファイル

本プロジェクトの設定: `Terraform/multi-account-iac/.tflint.hcl`

```hcl
# AWS プラグイン
plugin "aws" {
  enabled = true
  version = "0.31.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# 有効なルール
rule "terraform_deprecated_interpolation" { enabled = true }  # ${} の不要な使用
rule "terraform_deprecated_index" { enabled = true }          # 非推奨のインデックス
rule "terraform_unused_declarations" { enabled = true }       # 未使用の変数
rule "terraform_naming_convention" {                          # 命名規則
  enabled = true
  format  = "snake_case"
}
```

---

## よくあるエラーと対処法

### Error: terraform fmt -check failed

```
main.tf
--- old
+++ new
@@ -1,3 +1,3 @@
 resource "aws_s3_bucket" "example" {
-bucket = "my-bucket"
+  bucket = "my-bucket"
 }
```

**対処:**
```bash
terraform fmt
git add . && git commit --amend
```

### Error: terraform_unused_declarations

```
Warning: variable "unused_var" is declared but not used
```

**対処:**
- 変数を削除する
- または、意図的なら無視コメントを追加:
  ```hcl
  # tflint-ignore: terraform_unused_declarations
  variable "unused_var" {}
  ```

### Error: terraform_naming_convention

```
Warning: resource name "MyBucket" must match snake_case
```

**対処:**
```hcl
# Before
resource "aws_s3_bucket" "MyBucket" {}

# After
resource "aws_s3_bucket" "my_bucket" {}
```

---

## 比較: Lint ツール vs セキュリティスキャン

| 観点 | Lint (tflint等) | セキュリティ (Trivy等) |
|------|-----------------|----------------------|
| 目的 | コード品質 | セキュリティ |
| 検出対象 | 構文、命名、非推奨 | 脆弱性、設定ミス |
| 失敗時 | CI ブロック推奨 | soft_fail も可 |
| 実行速度 | 高速（数秒） | やや遅い（10秒〜） |

**両方必要:** Lint で品質を担保し、セキュリティスキャンで脆弱性を検出

---

## 参考リンク

- [TFLint 公式ドキュメント](https://github.com/terraform-linters/tflint)
- [TFLint AWS Plugin](https://github.com/terraform-linters/tflint-ruleset-aws)
- [Terraform fmt](https://developer.hashicorp.com/terraform/cli/commands/fmt)
- [Terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate)
