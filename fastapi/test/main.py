from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from db import SessionLocal

app = FastAPI()

# DBセッションの依存関係
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/health/db")
def db_health(db: Session = Depends(get_db)):
    result = db.execute("SELECT 1").fetchone()
    return {"status": "ok", "result": result}
