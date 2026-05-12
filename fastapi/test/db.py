import boto3
import json
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Secrets Manager から RDS のユーザー情報（username/password）を取得
def get_secret(secret_name: str, region_name: str = "ap-northeast-1") -> dict:
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response["SecretString"])
    return secret

# Secrets Manager に登録されたシークレット名
SECRET_NAME = "rds!cluster-cuvynt13t06x-abc123"  # あなたのシークレット名に置換

# Aurora 固定情報（host, port, dbname）
DB_HOST = "database-1.cluster-cuvynt13t06x.ap-northeast-1.rds.amazonaws.com"
DB_PORT = 3306
DB_NAME = "database-1"

# シークレットから取得した情報を使って DB接続URLを作成
secret = get_secret(SECRET_NAME)

DB_URL = (
    f"mysql+pymysql://{secret['username']}:{secret['password']}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# SQLAlchemy エンジン作成
engine = create_engine(DB_URL)
SessionLocal = sessionmaker(bind=engine)
