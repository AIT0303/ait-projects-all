# ベースイメージ
FROM python:3.11-slim

# 作業ディレクトリ作成
WORKDIR /app

# 必要ファイルコピー
COPY app.py requirements.txt ./

# 依存パッケージインストール
RUN pip install --no-cache-dir -r requirements.txt

# アプリ起動
CMD ["python", "app.py"]
