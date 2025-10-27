# --------------------------------------
# Makefile for Mini Vector Search Playground
# --------------------------------------

IMAGE ?= mini-vs
PORT ?= 8080

.PHONY: help build run run-openai clean

help:
	@echo ""
	@echo "Available targets:"
	@echo "  build        Build Docker image"
	@echo "  run          Run container with Ollama provider"
	@echo "  run-openai   Run container with OpenAI provider"
	@echo "  clean        Remove image and cached layers"
	@echo ""

build:
	docker build -t $(IMAGE) .

run:
	docker run --rm -p $(PORT):8080 \
	  --add-host=host.docker.internal:host-gateway \
	  -e EMBED_PROVIDER=ollama \
	  -e OLLAMA_URL=http://host.docker.internal:11434 \
	  -e OLLAMA_EMBED_MODEL=nomic-embed-text \
	  -e API_KEY=secret123 \
	  -v "$$(pwd)/data:/app/data" \
	  $(IMAGE)

run-openai:
	docker run --rm -p $(PORT):8080 \
	  -e EMBED_PROVIDER=openai \
	  -e OPENAI_API_KEY=$$OPENAI_API_KEY \
	  -e OPENAI_EMBED_MODEL=text-embedding-3-small \
	  -v "$$(pwd)/data:/app/data" \
	  $(IMAGE)

clean:
	docker image rm $(IMAGE) || true

