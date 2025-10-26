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

## Chatmodes (example + local workflow)

This repository includes a committed, sanitized example chatmode at `.github/chatmodes/example.chatmode.md` to document the format.

Personal chatmodes (your local agent/assistant configurations) are intended to remain local and out of version control. To keep real chatmodes private and avoid accidental commits:

- The repository `.gitignore` already excludes `.github/chatmodes/`.
- If you want a safety guard, install the `pre-commit` tool and run `pre-commit install` — this repo includes a `pre-commit` config that prevents committing files inside `.github/chatmodes/`.

Quick setup:

```bash
# install pre-commit (if you don't have it)
pip install --user pre-commit

# install hooks for this repo (run once per developer)
pre-commit install

# Now commits that include .github/chatmodes/ will be blocked.
```

If you prefer not to use `pre-commit`, keep using `.gitignore` and avoid staging files from `.github/chatmodes/`.

Copying the example to a local chatmode

To create a local, editable chatmode from the committed example (safe workflow):

```bash
# copy the example to your local chatmodes directory
mkdir -p .github/chatmodes
cp .github/chatmodes/example.chatmode.md .github/chatmodes/my.chatmode.md
# edit the copy as needed (keep secrets out of the file!)
${EDITOR:-nano} .github/chatmodes/my.chatmode.md
```

Notes:
- The copied file `my.chatmode.md` will be ignored by Git (thanks to `.gitignore`).
- Do not commit files from `.github/chatmodes/` unless they are sanitized templates.

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

