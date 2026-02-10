# 🤖 AI Agent Archetype

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🤖 AI Agent](#)

---

## Description

Шаблон для создания AI ассистентов, чат-ботов и RAG систем с векторными базами данных.

---

## 🎯 Характеристики

### Tech Stack

| Компонент | Технология |
|-----------|------------|
| **Runtime** | Python 3.11+ |
| **Framework** | FastAPI |
| **LLM Provider** | OpenAI / Anthropic / Local LLM |
| **Vector DB** | PostgreSQL + pgvector / Qdrant / Weaviate |
| **Cache** | Redis 7 |
| **Task Queue** | Celery + Redis |
| **Orchestration** | LangChain / LlamaIndex |
| **Frontend** | Streamlit / Gradio / React Chat UI |

### Features Out-of-the-Box

✅ **RAG System** — Retrieval Augmented Generation с векторным поиском
✅ **Multi-Model Support** — OpenAI, Anthropic, Local (Ollama)
✅ **Prompt Versioning** — контроль версий промптов
✅ **A/B Testing** — тестирование разных промптов
✅ **Streaming Responses** — SSE для real-time генерации
✅ **Rate Limiting** — per-user и per-API key
✅ **Cost Tracking** — отслеживание токенов и стоимости
✅ **Conversation Memory** — история диалогов
✅ **Tool Calling** — Function calling для LLM
✅ **Observability** — tracing через OpenTelemetry

---

## 🚀 Quick Start

### 1. Создание проекта

**Через CodeFoundry (рекомендуется):**
```bash
cd CodeFoundry
make new ARCHETYPE=ai-agent NAME=my-assistant
cd my-assistant
```

**Вручную:**
```bash
cp -r /path/to/CodeFoundry/templates/archetypes/ai-agent ~/projects/my-assistant
cd ~/projects/my-assistant
git init
```

### 2. Конфигурация

```bash
cp .env.example .env
nano .env  # Отредактируйте конфигурацию
```

```bash
# Минимальная конфигурация
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# или Local LLM
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama2
```

### 3. Запуск

```bash
# Docker Compose (всё включено)
make dev

# Или локально
poetry install
poetry run uvicorn app.main:app --reload
```

### 4. Проверка

```bash
# Health check
curl http://localhost:8000/health

# Chat endpoint
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'
```

---

## 📂 Структура Проекта

```
ai-agent/
├── 📋 docs/
│   ├── PROJECT.md
│   ├── ARCHITECTURE.md
│   ├── RAG_GUIDE.md
│   └── PROMPTS.md
│
├── 🐳 docker/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── docker-compose.yml
│
├── ☸️ k8s/
│   ├── base/
│   └── overlays/
│
├── 📊 monitoring/
│   ├── prometheus/
│   └── grafana/
│
├── 🤖 openclaw/
│   └── workspace/
│       ├── AGENTS.md
│       └── skills/
│
├── 📝 src/
│   ├── app/
│   │   ├── main.py
│   │   ├── api/
│   │   │   ├── routes/
│   │   │   └── dependencies.py
│   │   ├── core/
│   │   │   ├── llm/
│   │   │   │   ├── openai.py
│   │   │   │   ├── anthropic.py
│   │   │   │   └── ollama.py
│   │   │   ├── vector_store/
│   │   │   │   ├── pgvector.py
│   │   │   │   └── qdrant.py
│   │   │   ├── memory/
│   │   │   │   ├── conversation.py
│   │   │   │   └── vector_store.py
│   │   │   ├── prompts/
│   │   │   │   ├── system.py
│   │   │   │   └── templates.py
│   │   │   └── tools/
│   │   │       ├── calculator.py
│   │   │       ├── search.py
│   │   │       └── code_executor.py
│   │   ├── services/
│   │   │   ├── rag_service.py
│   │   │   ├── chat_service.py
│   │   │   └── embedding_service.py
│   │   ├── models/
│   │   │   ├── conversation.py
│   │   │   ├── message.py
│   │   │   └── document.py
│   │   └── config/
│   │       └── settings.py
│   ├── tests/
│   │   ├── unit/
│   │   ├── integration/
│   │   └── e2e/
│   └── prompts/
│       ├── system/
│       │   ├── default.txt
│       │   ├── assistant.txt
│       │   └── coder.txt
│       └── versions/
│           └── v1/
│
├── 📝 data/
│   ├── documents/     # Для RAG
│   └── embeddings/    # Кэш embeddings
│
├── 🔧 scripts/
│   ├── setup-project.sh
│   ├── ingest-docs.sh
│   └── migrate-prompts.sh
│
└── 📄 Makefile
```

---

## 🤖 OpenClaw Integration

### Multi-Agent Configuration

AI Agent archetype использует **5 специализированных агентов**:

```
┌─────────────────────────────────────────────────────────────┐
│                      Main Agent                             │
│                   (Координатор)                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  Dev Agent    │   │Prompt Agent   │   │ML Agent       │
│  (Код)        │   │(Промпты)      │   │(Модели)       │
└───────────────┘   └───────────────┘   └───────────────┘
        │
        └───────────────┐
                        ▼
                 ┌───────────────┐
                 │ Review Agent  │
                 │  (Ревью)      │
                 └───────────────┘
```

**Agent Routing:**
```
User Request → Main Agent
    ├─→ "создай endpoint" → Dev Agent
    ├─→ "улучши промпт" → Prompt Agent
    ├─→ "настрой модель" → ML Agent
    └─→ "проверь код" → Review Agent
```

---

## 🧩 RAG System

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Query                           │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Query Embedding                           │
│              (OpenAI text-embedding-3)                     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Vector Similarity Search                       │
│           (pgvector / Qdrant / Weaviate)                   │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Retrieve Top-k Documents                       │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Augment Prompt                             │
│        Insert retrieved docs into system prompt             │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Generate Response                          │
│              (GPT-4 / Claude / Local LLM)                   │
└─────────────────────────────────────────────────────────────┘
```

### Usage

```python
# src/services/rag_service.py
from app.core.vector_store import get_vector_store
from app.core.llm import get_llm

class RAGService:
    def __init__(self):
        self.vector_store = get_vector_store()
        self.llm = get_llm()

    async def query(self, question: str, top_k: int = 5):
        # 1. Embed query
        query_embedding = await self.embed_query(question)

        # 2. Search similar documents
        docs = await self.vector_store.similarity_search(
            embedding=query_embedding,
            k=top_k
        )

        # 3. Augment prompt
        context = "\n".join([doc.page_content for doc in docs])
        augmented_prompt = f"""
        Context:
        {context}

        Question: {question}

        Answer:
        """

        # 4. Generate response
        response = await self.llm.ainvoke(augmented_prompt)

        return {
            "answer": response,
            "sources": [doc.metadata for doc in docs]
        }
```

---

## 🎛️ Prompt Management

### Versioned Prompts

```
src/prompts/
├── system/
│   ├── default.txt
│   ├── assistant.txt
│   └── coder.txt
└── versions/
    └── v1/
        ├── default.txt
        ├── assistant.txt
        └── coder.txt
```

### A/B Testing

```python
# src/services/ab_test_service.py
class ABTestService:
    async def get_prompt(self, prompt_name: str, user_id: str):
        # Determine which variant to use
        variant = await self.get_variant(user_id, prompt_name)

        # Load prompt version
        prompt = await self.load_prompt(prompt_name, variant)

        return prompt, variant

    async def record_result(self, variant: str, metrics: dict):
        # Record metrics for analysis
        await self.metrics.record(variant, metrics)
```

---

## 📊 Cost Tracking

### Token & Cost Monitoring

```python
# src/services/cost_service.py
class CostService:
    def __init__(self):
        self.prices = {
            "gpt-4": {"input": 0.03, "output": 0.06},
            "gpt-3.5-turbo": {"input": 0.0015, "output": 0.002},
            "claude-3-opus": {"input": 0.015, "output": 0.075},
        }

    def calculate_cost(self, model: str, input_tokens: int, output_tokens: int):
        input_cost = (input_tokens / 1000) * self.prices[model]["input"]
        output_cost = (output_tokens / 1000) * self.prices[model]["output"]
        return input_cost + output_cost
```

---

## 🔧 Makefile Commands

```bash
make help          # Show all commands
make init          # Initialize project
make dev           # Start with docker-compose
make build         # Build Docker image
make test          # Run tests
make lint          # Run linter
make ingest-docs   # Ingest documents for RAG
make migrate       # Run migrations
make deploy-staging # Deploy to staging
```

---

## 📚 Additional Resources

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)
- [📋 Все Архетипы](../README.md)
- [🔄 GitOps 2.0](../README.md)

### OpenClaw Integration
- [🦞 OpenClaw README](../../../openclaw/README.md)
- [🤖 Agents](../../../openclaw/workspace/AGENTS.md)
- [🎨 Skills Index](../../../openclaw/workspace/SKILLS-INDEX.md)

### AI/ML Documentation
- [📖 RAG Tutorial](https://www.anthropic.com/index retrieval)
- [🤖 LangChain Docs](https://python.langchain.com/docs/)
- [🐳 Qdrant Docs](https://qdrant.tech/documentation/)

### Vector Database Resources
- [📖 Vector Database Guide](https://www.pinecone.io/learn/)
- [📖 pgvector Documentation](https://github.com/pgvector/pgvector)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.2.0 | 2025-01-31 | GitOps 2.0 добавлен, исправлены сломанные ссылки |
| 1.1.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs |
| 1.0.0 | 2025-11-05 | Первая версия archetype |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🤖 AI Agent](#)
