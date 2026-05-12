from fastapi import FastAPI, Request, Header
from typing import Optional

app = FastAPI()

# 全てのヘッダーを表示するエンドポイント
@app.get("/headers")
async def read_headers(request: Request):
    return {"headers": dict(request.headers)}

# 特定のヘッダーだけを取り出すエンドポイント
@app.get("/custom")
async def read_custom_header(x_token: Optional[str] = Header(None)):
    return {"X-Token": x_token}
