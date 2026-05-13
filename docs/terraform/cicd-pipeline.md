# Terraform CI/CD パイプライン

## 概要

GitHub Actions を使用して Terraform の実行を自動化します。
PR 作成時に Plan を実行し、main ブランチへのマージ時に Apply を実行します。

---

## パイプライン構成

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   PR 作成   │ ──▶ │  fmt check  │ ──▶ │  validate   │ ──▶ │    plan     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                                                   │
                                                                   ▼
                                                          ┌─────────────────┐
                                                          │ PR にコメント   │
                                                          │ (Plan 結果)     │
                                                          └─────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ main マージ │ ──▶ │  手動承認   │ ──▶ │   apply     │
└─────────────┘     │ (optional)  │     └─────────────┘
                    └─────────────┘
```

---

## ワークフローファイル

**場所:** `.github/workflows/terraform.yml`

### トリガー条件

```yaml
on:
  push:
    branches:
      - main
    paths:
      - 'Terraform/**'
  pull_request:
    branches:
      - main
    paths:
      - 'Terraform/**'
```

- `Terraform/` 配下のファイルが変更された場合のみ実行
- main ブランチへの PR と Push で実行

### 必要なパーミッション

```yaml
permissions:
  id-token: write      # OIDC 認証に必要
  contents: read       # リポジトリの読み取り
  pull-requests: write # PR へのコメント
```

---

## ジョブの詳細

### 1. detect-changes

変更されたモジュールを検出します。

```yaml
- name: Detect changed modules
  run: |
    CHANGED_MODULES=$(git diff --name-only $BASE_SHA $HEAD_SHA | \
      grep "^Terraform/multi-account-iac/" | \
      cut -d'/' -f3 | \
      grep -E "^[0-9]{2}-" | \
      sort -u)
```

**例:**
- `Terraform/multi-account-iac/02-identity-center/main.tf` を変更
- → `02-identity-center` が検出される
- → このモジュールのみ Plan/Apply が実行される

### 2. plan (PR 時)

```yaml
plan:
  if: github.event_name == 'pull_request'
  strategy:
    matrix:
      module: ${{ fromJson(needs.detect-changes.outputs.modules) }}
  steps:
    - terraform fmt -check
    - terraform init
    - terraform validate
    - terraform plan
    - PR にコメント
```

PR に以下のようなコメントが投稿されます：

```markdown
## Terraform Plan: `02-identity-center`

| Step | Status |
|------|--------|
| 🖌 Format | ✅ |
| ⚙️ Init | ✅ |
| 📋 Validate | ✅ |
| 📝 Plan | ✅ |
```

### 3. apply (main マージ時)

```yaml
apply:
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  environment: production  # 手動承認
  steps:
    - terraform init
    - terraform apply -auto-approve
```

---

## Environment による手動承認

### 設定手順

1. GitHub リポジトリ → **Settings** → **Environments**
2. **New environment** をクリック
3. Name: `production`
4. **Environment protection rules** で以下を設定：
   - ✅ Required reviewers → 自分を追加
   - （オプション）Wait timer: 5 minutes

### 動作

main にマージされると：
1. ワークフローが `apply` ジョブで一時停止
2. 指定した Reviewer に通知
3. Reviewer が承認すると Apply が実行

```
┌─────────────┐     ┌─────────────────────┐     ┌─────────────┐
│ main マージ │ ──▶ │ "Review pending"    │ ──▶ │   apply     │
└─────────────┘     │  承認待ち           │     └─────────────┘
                    └─────────────────────┘
                           │
                           ▼
                    ┌─────────────────────┐
                    │ Slack/Email 通知    │
                    │ → Reviewer が承認   │
                    └─────────────────────┘
```

---

## 使い方

### 新しい変更を適用する場合

```bash
# 1. ブランチを作成
git checkout -b feature/update-identity-center

# 2. 変更を加える
vim Terraform/multi-account-iac/02-identity-center/main.tf

# 3. コミット & プッシュ
git add .
git commit -m "Update identity center config"
git push origin feature/update-identity-center

# 4. GitHub で PR を作成
#    → 自動で Plan が実行される
#    → PR に結果がコメントされる

# 5. レビュー後、main にマージ
#    → 自動で Apply が実行される（承認後）
```

### ローカルで事前確認

CI を待たずにローカルで確認：

```bash
cd Terraform/multi-account-iac/02-identity-center

# フォーマットチェック
terraform fmt -check -recursive

# 構文検証
terraform validate

# Plan
terraform plan
```

---

## Matrix 戦略

複数のモジュールが変更された場合、並列で実行されます：

```yaml
strategy:
  fail-fast: false      # 1つ失敗しても他は継続
  max-parallel: 1       # Apply は1つずつ（競合防止）
  matrix:
    module: ["02-identity-center", "04-baseline-org"]
```

**Plan 時:** 並列実行（高速）
**Apply 時:** 順次実行（競合防止）

---

## Secrets の設定

### 必須

| Secret 名 | 値 | 説明 |
|-----------|-----|------|
| `AWS_ROLE_ARN` | `arn:aws:iam::216876474007:role/github-actions-terraform-role` | OIDC 用 IAM Role |

### 設定方法

1. GitHub リポジトリ → **Settings**
2. **Secrets and variables** → **Actions**
3. **New repository secret**

---

## トラブルシューティング

### Plan が失敗する

**確認ポイント:**
1. `AWS_ROLE_ARN` が正しいか
2. OIDC Provider が作成されているか
3. IAM Role の信頼ポリシーが正しいか

```bash
# OIDC Provider の確認
aws iam list-open-id-connect-providers

# IAM Role の確認
aws iam get-role --role-name github-actions-terraform-role
```

### "No changes" でも毎回実行される

**原因:** パス指定が広すぎる

**解決:** `paths` を適切に設定
```yaml
paths:
  - 'Terraform/multi-account-iac/**'
  - '!Terraform/multi-account-iac/README.md'  # README は除外
```

### State Lock エラー

**原因:** 前回の実行が中断された

**解決:**
```bash
cd Terraform/multi-account-iac/XX-module
terraform force-unlock <LOCK_ID>
```

---

## セキュリティ考慮事項

### 1. ブランチ保護

main ブランチを保護して、直接 Push を禁止：

1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. ✅ Require a pull request before merging
4. ✅ Require approvals (1人以上)

### 2. 権限の最小化

本番環境では AdministratorAccess ではなく、必要な権限のみ付与。

### 3. Plan 結果のレビュー

Apply 前に必ず Plan 結果を確認：
- 意図しない削除がないか
- 変更内容が正しいか

---

## 参考リンク

- [GitHub Actions: Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions: Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Terraform: GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
