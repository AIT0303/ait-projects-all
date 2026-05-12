from flask import Flask, redirect, url_for, session
from authlib.integrations.flask_client import OAuth
from authlib.common.security import generate_token
import os

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "Kouki1803&")

# OAuth / Cognito設定
oauth = OAuth(app)

oauth.register(
    name='oidc',
    client_id='38bb0fudb9inclu6r6p07bp1v9',
    client_secret='q14btuntja7r1arhdhbqmvk1v786a8h8f9m6adnbooh7crbfubs',
    server_metadata_url='https://ap-northeast-1z8l6rkaji.auth.ap-northeast-1.amazoncognito.com/oauth2/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email phone profile'}
)

@app.route('/')
def index():
    user = session.get('user')
    if user:
        username = user.get('preferred_username') or user.get('email') or 'ユーザー'
        return f"<h2>ログイン成功！</h2><p>こんにちは、{username} さん</p><a href='/logout'>ログアウト</a>"
    return '<a href="/login">ログイン</a>'

@app.route('/login')
def login():
    nonce = generate_token()
    session['nonce'] = nonce
    redirect_uri = url_for('authorize', _external=True)
    return oauth.oidc.authorize_redirect(redirect_uri, nonce=nonce)

@app.route('/authorize')
def authorize():
    token = oauth.oidc.authorize_access_token()
    nonce = session.get('nonce')
    userinfo = oauth.oidc.parse_id_token(token, nonce=nonce)
    session['user'] = userinfo
    return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5200)
