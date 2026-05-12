# ベースイメージ
FROM python:3.11-slim

# 作業ディレクトリ
WORKDIR /app

# 依存ファイルをコピー
COPY requirements.txt .

# パッケージインストール
RUN pip install --no-cache-dir -r requirements.txt

# アプリのソースコードをコピー
COPY . .

# ポート指定（Flask用）
EXPOSE 5200

# アプリ起動コマンド
CMD ["python", "app.py"]

