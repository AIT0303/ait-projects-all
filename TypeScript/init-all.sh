#!/bin/bash

# 現在のディレクトリ（ait-ts）をベースとして処理
BASE_DIR=$(pwd)

echo "📦 TypeScriptアプリのGitHubリポジトリ化を開始します..."
echo "▶ 対象ディレクトリ: $BASE_DIR"

for dir in "$BASE_DIR"/*/; do
  cd "$dir"
  APP_NAME=$(basename "$dir")

  echo "🔧 処理中: $APP_NAME"

  # ① Git初期化 & 初期ファイル作成
  git init
  echo -e "node_modules/\ndist/\n.env\n.vscode/\n.DS_Store" > .gitignore

  # README作成
  echo "# $APP_NAME" > README.md
  echo -e "\nこのアプリは TypeScript を使用したアプリケーションです。" >> README.md

  # MIT LICENSE
  echo -e "MIT License\n\n© $(date +%Y) あなたの名前" > LICENSE

  git add .
  git commit -m "initial commit"

  # ② GitHubリポジトリ作成 & push
  gh repo create "$APP_NAME" --public --source=. --remote=origin --push

  echo "✅ 完了: $APP_NAME"
done

echo "🎉 全アプリのGitHubアップロードが完了しました！"
