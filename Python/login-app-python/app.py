from flask import Flask, redirect, url_for, session
from authlib.integrations.flask_client import OAuth
from authlib.common.security import generate_token
import os

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "Kouki1803&")

oauth = OAuth(app)

oauth.register(
    name='oidc',
    authority='https://cognito-idp.ap-northeast-1.amazonaws.com/ap-northeast-1_BG6Rqd14w',
    client_id='5rgc3cbhd2qf1i2t93l3dtjku9',
    client_secret='11t94r8pqa8sg92p0n19ggs1vjus8pi1a1gbj25nkktg74rugrrt',
    server_metadata_url='https://cognito-idp.ap-northeast-1.amazonaws.com/ap-northeast-1_BG6Rqd14w/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email phone profile'}
)

@app.route('/')
def index():
    user = session.get('user')
    if user:
        username = user.get('preferred_username') or user.get('cognito:username') or 'ユーザー'
        return f"<h2>ログイン成功です！</h2><p>こんにちは、{username} さん。</p><a href='/logout'>ログアウト</a>"
    return 'ようこそ！<a href="/login">ログイン</a>'

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
    session.pop('user', None)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='localhost', port=5050)
