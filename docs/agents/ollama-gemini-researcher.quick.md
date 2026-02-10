# 📙 ollama-gemini-researcher — Quick Start

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📙 ollama-gemini-researcher**

> Research specialist for Ollama + gemini-3-flash-preview deployment

---

## Prerequisites

```bash
# Access to research documentation
ls docs/research/ollama-gemini3-flash-deployment.md

# Docker environment (optional)
docker --version  # for containerized deployment
```

---

## 3 Steps to Start

### Step 1: Ask a question

```
User: "How do I deploy gemini-3-flash-preview with Ollama on ainetic.tech?"
→ ollama-gemini-researcher activated
→ Reading research documentation...
→ Providing answer with cited sources
```

### Step 2: Get deployment commands

Agent provides concrete commands:

```bash
# Pull model (test without API key first)
docker exec openclaw-ollama ollama pull gemini-3-flash-preview

# If auth required, get API key from https://ollama.com/settings/keys
export OLLAMA_API_KEY=your_key
docker exec -e OLLAMA_API_KEY=$key openclaw-ollama ollama pull gemini-3-flash-preview:cloud

# Test model
curl http://localhost:11434/api/chat \
  -d '{"model": "gemini-3-flash-preview", "messages": [{"role": "user", "content": "Hello!"}]}'
```

### Step 3: Integrate with OpenClaw

Agent guides Docker configuration:

```yaml
# docker-compose.yml
services:
  ollama:
    image: ollama/ollama:latest
    environment:
      - OLLAMA_API_KEY=${OLLAMA_API_KEY:-}
    volumes:
      - ollama_data:/root/.ollama
```

---

## Verify

Check model is running:

```bash
# List models
docker exec openclaw-ollama ollama list

# Expected output:
NAME                      ID              SIZE      MODIFIED
gemini-3-flash-preview    8b9f...         4.7 GB    2026-02-10
```

---

## Model Specs

| Feature | Value |
|---------|-------|
| **Context** | 1,000,000 tokens input, 64,000 tokens output |
| **Multimodal** | Yes (text + image) |
| **Cost** | FREE tier (2026) |
| **Rate limits** | 100 requests/minute |
| **Official docs** | https://ollama.com/library/gemini-3-flash-preview |

---

## Common Questions

```
Q: Do I need an API key?
A: Test without first. If error, get key from https://ollama.com/settings/keys

Q: What are hardware requirements?
A: Minimum 8GB RAM, 16GB recommended for 1M token context

Q: Can I run it locally?
A: Yes, but gemini-3-flash-preview requires Ollama Cloud API for best performance
```

---

## Next Steps

- [Full Usage Guide](ollama-gemini-researcher.usage.md) — Complete documentation
- [Research](../research/ollama-gemini3-flash-deployment.md) — In-depth research (17 sources)
- [OpenClaw Architecture](../plans/openclaw-orchestrator-architecture.md) — Integration guide

---

*← [Back to Agents Index](index.md) | [Full Usage](ollama-gemini-researcher.usage.md) →*
