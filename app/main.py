# app/main.py
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI(title="Mini Vector Search Playground", version="0.1.0")

@app.get("/healthz")
def healthz():
    return {"ok": True}

@app.get("/", response_class=HTMLResponse)
def home():
    return """
    <!doctype html>
    <html>
      <head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Mini VS Playground</title></head>
      <body style="font-family: system-ui; max-width: 760px; margin: 2rem auto;">
        <h1>Mini Vector Search Playground</h1>
        <p>Server is running. See <code>/healthz</code>.</p>
      </body>
    </html>
    """

