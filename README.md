# 🚀 Mini Vector Search Playground

A tiny **FastAPI** web app that ingests a CSV (`id,text`) and provides **semantic search** using vector embeddings.  
Built for experimentation with **OpenAI** or **Ollama** models and backed by **ChromaDB** for persistence.

Perfect as a Hacktoberfest starter project 🎉

---

## ✨ Features
- Upload a CSV (`id,text`) → instantly indexed
- Search semantically with embeddings (`GET /search?q=...`)
- Switch provider at runtime:
  - `openai` (uses `text-embedding-3-small` by default)
  - `ollama` (runs on your own droplet)
- Simple browser UI + JSON API
- Lightweight persistence with **ChromaDB**

---

## 🛠 Quickstart (Local)

```bash
# 1. Clone repo
git clone https://github.com/<your-username>/mini-vector-search-playground.git
cd mini-vector-search-playground

# 2. Setup virtual env
python -m venv .venv && source .venv/bin/activate

# 3. Install deps
pip install -r requirements.txt

# 4. Configure environment
cp .env.example .env
# set EMBED_PROVIDER=openai or ollama
# set OPENAI_API_KEY if using OpenAI

# 5. Run server
uvicorn app.main:app --reload --port 8080

