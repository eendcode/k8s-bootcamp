from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
def root():
    return {
        "message": "hello from a container",
        "env": os.getenv("ENV", "dev")
    }

@app.get("/health")
def health():
    return {"status": "ok"}