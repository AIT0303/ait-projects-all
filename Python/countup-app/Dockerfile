# ベースイメージとしてPythonの公式イメージを使用
# Alpine版は軽量なので推奨
FROM python:3.9-slim-buster

# 作業ディレクトリを設定
WORKDIR /app

# 必要なPythonパッケージをインストール
# requirements.txtを先にコピーすることで、依存関係の変更がなければキャッシュを活用できる
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションのコードをコンテナにコピー
COPY . .

# アプリケーションがリッスンするポートを公開
# App ServiceはPORT環境変数でポートを指定するので、ここでは情報提供のみ
EXPOSE 8000

# アプリケーションをGunicornで起動
# 0.0.0.0:8000 でリッスンし、app.py内の 'app' というFlaskアプリケーションインスタンスを実行
# Gunicornは'PORT'環境変数を自動的に使用するので、EXPOSEと合わせる
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]