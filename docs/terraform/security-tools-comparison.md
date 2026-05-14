# IaC セキュリティスキャンツール比較

## 概要

Terraform コードのセキュリティスキャンに使用される主要な3ツールを比較します。

---

## ツール一覧

| 項目 | Trivy | Checkov | Snyk |
|------|-------|---------|------|
| **開発元** | Aqua Security | Bridgecrew (Palo Alto) | Snyk |
| **ライセンス** | OSS (Apache 2.0) | OSS (Apache 2.0) | 商用 + 無料枠 |
| **料金** | 無料 | 無料 | 無料枠あり / 有料 |
| **対応 IaC** | Terraform, K8s, Docker | Terraform, CloudFormation, K8s, ARM | Terraform, K8s, CloudFormation |
| **コンテナスキャン** | ✅ | ❌ | ✅ |
| **脆弱性DB** | 統合 | 別途 | 独自DB (充実) |

---

## 1. Trivy

### 特徴

```
┌─────────────────────────────────────────────────────┐
│                      Trivy                          │
├─────────────────────────────────────────────────────┤
│  コンテナ   │   IaC    │ ファイルシステム │  SBOM   │
│  イメージ   │ スキャン │    スキャン      │  生成   │
└─────────────────────────────────────────────────────┘
              ↑
         tfsec が統合（2023年〜）
```

- **オールインワン**: コンテナ + IaC + ファイルシステムを1ツールでスキャン
- **tfsec の後継**: tfsec のルールセットを完全統合
- **高速**: Go 製でスキャンが速い
- **CI/CD 統合**: GitHub Actions, GitLab CI 等に対応

### 検出例

```
HIGH: S3 bucket does not have encryption enabled
──────────────────────────────────────────────────────
 Terraform/multi-account-iac/00-bootstrap/main.tf:15-20

  15 │ resource "aws_s3_bucket" "tfstate" {
  16 │   bucket = "my-tfstate-bucket"
  17 │ }

 See https://avd.aquasec.com/misconfig/avd-aws-0088
```

### GitHub Actions での使用

```yaml
- name: Run Trivy
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'config'
    scan-ref: 'Terraform/'
```

### ローカル実行

```bash
# インストール
brew install trivy

# Terraform スキャン
trivy config ./Terraform/multi-account-iac

# コンテナスキャン（おまけ）
trivy image nginx:latest
```

### 長所・短所

| 長所 | 短所 |
|------|------|
| コンテナ + IaC を1ツールで | Checkov より検出ルールが少ない |
| tfsec の後継で将来性あり | カスタムポリシーがやや複雑 |
| 高速 | ドキュメントが英語のみ |

---

## 2. Checkov

### 特徴

```
┌─────────────────────────────────────────────────────┐
│                     Checkov                         │
├─────────────────────────────────────────────────────┤
│  2000+ の組み込みポリシー                           │
│  ├── AWS (500+)                                    │
│  ├── Azure (300+)                                  │
│  ├── GCP (200+)                                    │
│  └── Kubernetes (200+)                             │
└─────────────────────────────────────────────────────┘
```

- **ポリシー数が最多**: 2000+ の組み込みルール
- **Python 製**: カスタムポリシーを Python で書ける
- **グラフベース解析**: リソース間の関係を分析
- **Bridgecrew 連携**: SaaS ダッシュボードで可視化可能

### 検出例

```
Check: CKV_AWS_274: "Disallow IAM roles, users, and groups from using the AWS AdministratorAccess policy"
	FAILED for resource: aws_iam_role_policy_attachment.github_actions_admin
	File: /05-github-oidc/main.tf:45-49

		45 | resource "aws_iam_role_policy_attachment" "github_actions_admin" {
		46 |   role       = aws_iam_role.github_actions_terraform.name
		47 |   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
		48 | }
```

### GitHub Actions での使用

```yaml
- name: Run Checkov
  uses: bridgecrewio/checkov-action@v12
  with:
    directory: Terraform/
    soft_fail: true
```

### ローカル実行

```bash
# インストール
pip install checkov

# 実行
checkov -d ./Terraform/multi-account-iac

# 特定のチェックのみ
checkov -d . --check CKV_AWS_274

# 特定のチェックを除外
checkov -d . --skip-check CKV_AWS_274,CKV_AWS_28
```

### 長所・短所

| 長所 | 短所 |
|------|------|
| ポリシー数が最多 | Python 依存（環境構築が必要） |
| カスタムポリシーが書きやすい | Trivy より遅い |
| 無料で全機能使える | コンテナスキャンは別ツール必要 |

---

## 3. Snyk

### 特徴

```
┌─────────────────────────────────────────────────────┐
│                       Snyk                          │
├─────────────────────────────────────────────────────┤
│  商用サービス + CLI ツール                          │
│                                                     │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌────────┐│
│  │ Code    │  │ Open    │  │Container│  │  IaC   ││
│  │ (SAST)  │  │ Source  │  │         │  │        ││
│  └─────────┘  └─────────┘  └─────────┘  └────────┘│
└─────────────────────────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────┐
            │  Snyk Dashboard │  ← Web UI で一元管理
            │  (SaaS)         │
            └─────────────────┘
```

- **統合プラットフォーム**: コード、依存関係、コンテナ、IaC を一元管理
- **脆弱性 DB が充実**: セキュリティ専門チームが運営
- **開発者体験重視**: IDE プラグイン、PR コメント、自動修正提案
- **コンプライアンス対応**: SOC2, HIPAA 等のレポート生成

### 料金プラン

| プラン | 料金 | 制限 |
|--------|------|------|
| Free | $0 | 200 テスト/月、1 ユーザー |
| Team | $25/月/開発者 | 無制限テスト |
| Enterprise | 要問合せ | SSO, カスタムポリシー等 |

### GitHub Actions での使用

```yaml
- name: Run Snyk IaC
  uses: snyk/actions/iac@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    file: Terraform/
```

### ローカル実行

```bash
# インストール
npm install -g snyk

# 認証
snyk auth

# IaC スキャン
snyk iac test ./Terraform/multi-account-iac

# 依存関係スキャン（おまけ）
snyk test
```

### 長所・短所

| 長所 | 短所 |
|------|------|
| 脆弱性 DB が最も充実 | 無料枠に制限あり |
| Web ダッシュボードで可視化 | API キーの管理が必要 |
| 自動修正提案 | OSS プロジェクト以外は有料推奨 |
| IDE 統合が優秀 | 学習コストが若干高い |

---

## 比較まとめ

### 検出能力

```
ポリシー数:      Checkov > Trivy ≈ Snyk
脆弱性DB精度:    Snyk > Trivy > Checkov
更新頻度:        Snyk > Trivy > Checkov
```

### ユースケース別おすすめ

| ユースケース | おすすめ | 理由 |
|-------------|---------|------|
| **学習・個人開発** | Trivy + Checkov | 無料、十分な検出力 |
| **スタートアップ** | Checkov | ポリシー数最多、無料 |
| **エンタープライズ** | Snyk | ダッシュボード、コンプライアンス |
| **コンテナ + IaC** | Trivy | 1ツールで両方対応 |
| **厳密なセキュリティ** | Snyk + Checkov | 商用DB + OSS の組み合わせ |

### CI/CD での組み合わせ例

```yaml
# パターン1: OSS のみ（本プロジェクトの構成）
security-scan:
  steps:
    - Trivy (IaC + コンテナ)
    - Checkov (IaC 詳細)

# パターン2: 商用 + OSS
security-scan:
  steps:
    - Snyk (メイン)
    - Checkov (補完)

# パターン3: フルスキャン
security-scan:
  steps:
    - Trivy (コンテナ)
    - Snyk (IaC + 依存関係)
    - Checkov (カスタムポリシー)
```

---

## 実行速度比較

同じ Terraform コードベース（約50ファイル）でのスキャン時間:

| ツール | 実行時間 | メモリ使用量 |
|--------|---------|-------------|
| Trivy | ~5秒 | ~100MB |
| Checkov | ~15秒 | ~200MB |
| Snyk | ~10秒 | ~150MB |

※ 環境により変動

---

## 本プロジェクトの選択理由

**Trivy + Checkov** を採用:

1. **無料で使える** - 学習環境に最適
2. **検出力が十分** - 主要なセキュリティ問題をカバー
3. **将来性** - Trivy は tfsec の後継として開発継続
4. **補完関係** - Trivy の高速さ + Checkov のポリシー数

---

## 参考リンク

- [Trivy 公式ドキュメント](https://trivy.dev/)
- [Checkov 公式ドキュメント](https://www.checkov.io/)
- [Snyk 公式サイト](https://snyk.io/)
- [OWASP IaC Security](https://owasp.org/www-project-devsecops-guideline/latest/02b-Infrastructure-as-Code)
