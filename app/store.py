import os
import pathlib
from typing import List, Dict, Tuple
import logging

import chromadb
from chromadb.config import Settings

# --- Config & setup ---
DB_DIR = os.getenv("DB_DIR", "./data")
pathlib.Path(DB_DIR).mkdir(parents=True, exist_ok=True)

# Disable Chroma telemetry noise
os.environ.setdefault("CHROMADB_TELEMETRY", "False")
os.environ.setdefault("CHROMADB_DISABLE_TELEMETRY", "1")
logging.getLogger("chromadb.telemetry").setLevel(logging.CRITICAL)
logging.getLogger("chromadb").setLevel(logging.WARNING)

# Create persistent ChromaDB client
_client = chromadb.PersistentClient(
    path=DB_DIR,
    settings=Settings(allow_reset=False, anonymized_telemetry=False)
)

# Use a collection called "documents"
_collection = _client.get_or_create_collection(
    name="documents",
    metadata={"hnsw:space": "cosine"}  # cosine distance metric
)


# --- Validation helpers ---
def _validate_upsert(ids: List[str], texts: List[str], embeddings: List[List[float]]):
    if not ids or not texts or not embeddings:
        raise ValueError("ids, texts, and embeddings must be non-empty.")
    if not (len(ids) == len(texts) == len(embeddings)):
        raise ValueError("ids, texts, and embeddings must have the same length.")
    d = len(embeddings[0])
    if d == 0:
        raise ValueError("Embeddings must be non-empty vectors.")
    for i, e in enumerate(embeddings):
        if len(e) != d:
            raise ValueError(f"Embedding at index {i} has dimension {len(e)}; expected {d}.")
    for i, (doc_id, text) in enumerate(zip(ids, texts)):
        if not str(doc_id).strip():
            raise ValueError(f"id at index {i} is empty.")
        if not str(text).strip():
            raise ValueError(f"text at index {i} is empty.")


def _normalize_metadatas(metadatas: List[Dict] | None, n: int) -> List[Dict]:
    """
    Chroma requires each metadata dict to be non-empty.
    If None or empty, insert {"source": "manual"}.
    """
    if metadatas is None:
        return [{"source": "manual"} for _ in range(n)]
    if len(metadatas) != n:
        raise ValueError("metadatas length must match texts length.")
    fixed = []
    for m in metadatas:
        if not isinstance(m, dict):
            raise ValueError("Each metadata must be a dict.")
        if len(m) == 0:
            m = {"source": "manual"}
        fixed.append(m)
    return fixed


# --- Public API ---
def upsert_texts(
    ids: List[str],
    texts: List[str],
    embeddings: List[List[float]],
    metadatas: List[Dict] | None = None,
) -> int:
    """Insert or update documents with embeddings. Returns number of records upserted."""
    _validate_upsert(ids, texts, embeddings)
    metadatas = _normalize_metadatas(metadatas, len(texts))

    BATCH = 128
    total = 0
    for i in range(0, len(texts), BATCH):
        sl = slice(i, i + BATCH)
        _collection.upsert(
            ids=ids[sl],
            documents=texts[sl],
            embeddings=embeddings[sl],
            metadatas=metadatas[sl],
        )
        total += len(texts[sl])
    return total


def query_texts(query_embedding: List[float], k: int = 5) -> Tuple[List[str], List[str], List[float], List[Dict]]:
    """
    Query top-k similar documents for a given embedding.
    Returns (ids, documents, similarities, metadatas).
    """
    if not query_embedding or not isinstance(query_embedding, list):
        raise ValueError("query_embedding must be a non-empty list of floats.")

    # Cap k between 1 and 50
    k = max(1, min(int(k), 50))

    res = _collection.query(query_embeddings=[query_embedding], n_results=k)

    ids = res.get("ids", [[]])[0]
    docs = res.get("documents", [[]])[0]
    dists = res.get("distances", [[]])[0]
    metas = res.get("metadatas", [[]])[0]

    # Convert cosine distance -> similarity
    sims = [float(1 - d) if d is not None else 0.0 for d in dists]
    return ids, docs, sims, metas


def count() -> int:
    """Return number of documents stored in collection."""
    c = _collection.count()
    return int(c) if isinstance(c, int) else int(c or 0)

