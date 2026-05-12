# SQLAlchemyのインスタンスを初期化
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# 単語を保存するWordモデルの定義
class Word(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    
    # 単語（最大100文字）
    word = db.Column(db.String(100), nullable=False)
    
    # 意味（最大255文字）
    meaning = db.Column(db.String(255), nullable=False)