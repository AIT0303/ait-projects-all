# ベースイメージ
FROM python:3.11-slim

# 作業ディレクトリ
WORKDIR /app

# 依存ファイルをコピーしてインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションの全ファイルをコピー
COPY . .

# SecretsManagerなどで使うboto3とMySQL接続に対応

# 起動コマンド（uvicornでFastAPI起動）
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
