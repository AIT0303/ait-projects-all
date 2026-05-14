# Terraform State ロックと競合対策

## 概要

Terraform は State ファイルの同時書き込みを防ぐため、DynamoDB によるロック機構を使用します。
CI/CD で複数のワークフローが同時実行されると、このロックが競合してエラーになります。

---

## State ロックの仕組み

### なぜロックが必要か

```
┌─────────────────────────────────────────────────────────────────┐
│  ロックなしの場合（危険）                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  開発者A: terraform apply     開発者B: terraform apply          │
│         │                            │                          │
│         ▼                            ▼                          │
│    State 読み込み              State 読み込み                   │
│    (version: 1)                (version: 1)                     │
│         │                            │                          │
│         ▼                            ▼                          │
│    リソース作成                 リソース作成                    │
│    (EC2 追加)                  (RDS 追加)                       │
│         │                            │                          │
│         ▼                            ▼                          │
│    State 書き込み              State 書き込み                   │
│    (version: 2)                (version: 2) ← 上書き！          │
│                                                                 │
│    結果: 開発者A の変更が消える → State と実環境が不整合        │
└─────────────────────────────────────────────────────────────────┘
```

### DynamoDB ロックの動作

```
┌─────────────────────────────────────────────────────────────────┐
│  ロックありの場合（安全）                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  開発者A: terraform apply     開発者B: terraform apply          │
│         │                            │                          │
│         ▼                            ▼                          │
│    Lock 取得 ✅                 Lock 取得 ❌                    │
│    (DynamoDB)                  "Error: Lock held by A"          │
│         │                            │                          │
│         ▼                            │ (待機 or 失敗)           │
│    State 読み込み                    │                          │
│         │                            │                          │
│         ▼                            │                          │
│    リソース作成                      │                          │
│         │                            │                          │
│         ▼                            │                          │
│    State 書き込み                    │                          │
│         │                            │                          │
│         ▼                            ▼                          │
│    Lock 解放 ✅                 Lock 取得 ✅（今度は成功）       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## CI/CD での競合シナリオ

### シナリオ1: 同じ PR に連続 push

```
PR #1 に対して:

09:00 - commit A を push → terraform plan 開始
09:01 - commit B を push → terraform plan 開始（2つ目）
           │
           ▼
    ┌─────────────────┐
    │ 競合発生！      │
    │ Lock held by    │
    │ commit A の job │
    └─────────────────┘
```

**解決:** `cancel-in-progress: true` で古い実行をキャンセル

### シナリオ2: 複数 PR が同じモジュールを変更

```
PR #1 (02-identity-center を変更) → terraform plan
PR #2 (02-identity-center を変更) → terraform plan
           │
           ▼
    ┌─────────────────┐
    │ 競合発生！      │
    │ 同じ State に   │
    │ 同時アクセス    │
    └─────────────────┘
```

**解決:** `concurrency.group` で直列化

### シナリオ3: Apply の途中でキャンセル

```
main にマージ → terraform apply 開始
                     │
                     ▼
              リソース作成中...
                     │
            ❌ キャンセル（危険！）
                     │
                     ▼
    ┌─────────────────────────────┐
    │ State と実環境が不整合に！  │
    │ 半分だけ作成された状態      │
    └─────────────────────────────┘
```

**解決:** main ブランチでは `cancel-in-progress: false`

---

## 本プロジェクトの設定

### ワークフロー設定

```yaml
# .github/workflows/terraform.yml

concurrency:
  group: terraform-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}
```

### 動作の説明

| 状況 | group | cancel-in-progress | 動作 |
|------|-------|-------------------|------|
| PR へ push | `terraform-refs/pull/1/merge` | `true` | 古い実行をキャンセル |
| 別の PR | `terraform-refs/pull/2/merge` | `true` | 別グループなので並列OK |
| main へ push | `terraform-refs/heads/main` | `false` | キャンセルせず待機 |

### 図解

```
┌─────────────────────────────────────────────────────────────────┐
│  PR #1 への連続 push                                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  push 1 → plan 開始 ──────────────────────────×（キャンセル）   │
│                                                │                │
│  push 2 → plan 開始 ─────────────────────────────────→ 完了    │
│                                                                 │
│  ※ 最新の push のみ実行される                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  main への連続マージ（複数 PR）                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  merge 1 → apply 開始 ────────────────────────────────→ 完了   │
│                                                           │     │
│  merge 2 → apply 待機 ────────────────────────────────────→完了│
│                                                                 │
│  ※ キャンセルせず順番に実行                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 追加の対策オプション

### オプション1: モジュール単位の concurrency

より細かい制御が必要な場合:

```yaml
jobs:
  plan:
    concurrency:
      group: terraform-plan-${{ matrix.module }}-${{ github.head_ref }}
      cancel-in-progress: true
```

**効果:** 同じモジュールの plan のみ直列化、異なるモジュールは並列OK

### オプション2: State Lock のタイムアウト設定

Terraform 側で待機時間を設定:

```hcl
# providers.tf
terraform {
  backend "s3" {
    # ...
    dynamodb_table = "tfstate-lock"

    # ロック取得を最大5分待機
    # （デフォルトは即座に失敗）
  }
}
```

環境変数で設定:
```bash
export TF_LOCK_TIMEOUT=300s  # 5分待機
```

### オプション3: 手動 Lock 解除

ロックが残ってしまった場合:

```bash
# Lock ID を確認
terraform plan
# Error: Lock Info:
#   ID:        xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# 強制解除
terraform force-unlock xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

---

## トラブルシューティング

### エラー: "Error acquiring the state lock"

```
Error: Error acquiring the state lock

Error message: ConditionalCheckFailedException: The conditional request failed
Lock Info:
  ID:        abc123
  Path:      s3://bucket/terraform.tfstate
  Operation: OperationTypePlan
  Who:       runner@github-actions
  Version:   1.7.0
  Created:   2024-01-01 00:00:00.000000 +0000 UTC
```

**対処:**
1. 実行中のワークフローがないか確認
2. なければ `terraform force-unlock abc123` で解除
3. DynamoDB テーブルを直接確認して古いロックを削除

### エラー: "Canceled workflow"

```
The workflow was canceled.
```

**原因:** `cancel-in-progress: true` により古い実行がキャンセルされた

**対処:** 正常動作。最新の push の実行結果を確認

---

## ベストプラクティス

1. **PR は小さく**: 大きな変更は競合リスクが高い
2. **モジュール分割**: 独立したモジュールは並列実行可能
3. **main への直接 push 禁止**: ブランチ保護で PR 必須に
4. **Lock タイムアウト設定**: 長時間の plan/apply がある場合

---

## 参考リンク

- [GitHub Actions: concurrency](https://docs.github.com/en/actions/using-jobs/using-concurrency)
- [Terraform: State Locking](https://developer.hashicorp.com/terraform/language/state/locking)
- [AWS: DynamoDB for Terraform Locking](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-state-locking)
