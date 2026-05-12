from flask import Flask, render_template_string, request, session, redirect, url_for
import os

app = Flask(__name__)
# Secret Keyはセッション管理に必須です。本番環境では安全な方法で設定してください。
# 例: os.urandom(24).hex() で生成したものを環境変数に設定
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'a_super_secret_key_for_dev')

# グローバル変数としてカウントを保持 (本番ではDBなどを使うべきですが、今回はシンプルに)
# セッションを使ってユーザーごとにカウントを保持することも可能
# current_count = 0 # グローバル変数は複数のリクエストで共有されるため注意

# HTMLテンプレート
HTML_TEMPLATE = """
<!doctype html>
<html lang="ja">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Count Up App</title>
    <style>
        body { font-family: sans-serif; display: flex; flex-direction: column; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background-color: #f4f4f4; }
        .container { background-color: #fff; padding: 40px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); text-align: center; }
        h1 { color: #333; margin-bottom: 20px; }
        p { font-size: 3em; font-weight: bold; color: #007bff; margin-bottom: 30px; }
        button { background-color: #007bff; color: white; border: none; padding: 15px 30px; border-radius: 5px; font-size: 1.2em; cursor: pointer; transition: background-color 0.3s ease; }
        button:hover { background-color: #0056b3; }
        .reset-button { background-color: #dc3545; margin-top: 15px; }
        .reset-button:hover { background-color: #c82333; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Count Up App</h1>
        <p id="count">{{ count }}</p>
        <form method="post" action="/">
            <button type="submit" name="action" value="increment">Count Up!</button>
        </form>
        <form method="post" action="/">
            <button type="submit" name="action" value="reset" class="reset-button">Reset Count</button>
        </form>
    </div>
</body>
</html>
"""

@app.route('/', methods=['GET', 'POST'])
def index():
    # セッションからカウントを取得、なければ0を設定
    if 'count' not in session:
        session['count'] = 0

    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'increment':
            session['count'] += 1
        elif action == 'reset':
            session['count'] = 0
        return redirect(url_for('index')) # POST後にGETリクエストにリダイレクト (PRGパターン)
    
    return render_template_string(HTML_TEMPLATE, count=session['count'])

if __name__ == '__main__':
    # PORT環境変数を取得し、なければ5000を使用 (Docker/App ServiceでPORTが設定される)
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True) # debug=True は開発時のみ