# 🤖 Multi-Agent System — AI Agent

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [🤖 AI Agent](../README.md) → [🤖 Agents](#)

---

## Agent Configuration for AI Assistant Development

Этот archetype использует **5 специализированных агентов** для разработки AI ассистентов.

---

## 🎯 Agent Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Main Agent                             │
│                   (Координатор)                             │
│                  Роутинг запросов                          │
└───────────────────────────┬─────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┬───────────────┐
        │                   │                   │               │
        ▼                   ▼                   ▼               ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐  ┌──────────────┐
│  Dev Agent    │   │Prompt Agent  │   │  ML Agent     │  │Review Agent │
│  (Код)        │   │(Промпты)     │   │  (Модели)     │  │  (Ревью)     │
│───────────────│   │───────────────│   │───────────────│  │──────────────│
│ API endpoints │   │System prompts│   │LLM config     │  │Code quality  │
│ RAG service   │   │Prompt A/B    │   │Vector DB      │  │Security      │
│ Tool calling  │   │Prompt version│   │Embeddings     │  │Performance   │
│              │   │              │   │RAG tuning     │  │              │
└───────────────┘   └───────────────┘   └───────────────┘  └──────────────┘
```

---

## 🦞 Main Agent (Coordinator)

**Role:** Координация всех агентов, роутинг запросов

**Tools:**
- `git` — все git операции
- `bash` — выполнение команд
- `read` — чтение всех файлов
- `write` — запись в корневые файлы

**Workspace:** `./` (полный доступ)

**Routing Logic:**
```python
if request.type == "code":
    → Dev Agent
elif request.type == "prompt":
    → Prompt Agent
elif request.type == "model" or "rag":
    → ML Agent
elif request.type == "review":
    → Review Agent
```

---

## 💻 Dev Agent (Developer)

**Role:** Написание кода API сервиса, RAG системы

**Tools:**
- `write` — создание файлов в `src/`
- `read` — чтение файлов
- `bash` — выполнение команд (pytest, poetry)
- `test-runner` — запуск тестов

**Workspace:** `./src`

**Responsibilities:**
- API endpoints (FastAPI routes)
- RAG service implementation
- Tool calling functions
- Database models
- Unit/Integration тесты

**Personality:**
```
Ты — Python backend разработчик со специализацией на AI/LLM приложениях.

Твоя специализация:
- FastAPI для REST API
- Async/await patterns
- Pydantic для валидации
- SQLAlchemy/Hibernate для БД
- Celery для задач

При написании RAG кода:
1. Обрабатывай ошибки gracefully
2. Логируй все LLM вызовы
3. Кэшируй embeddings
4. Используй batch operations
```

**Loaded Skills:**
- `@workspace/skills/python-development.md`
- `@workspace/skills/testing-strategy.md`

---

## ✨ Prompt Agent (Prompt Engineer)

**Role:** Промпт инжиниринг, оптимизация промптов

**Tools:**
- `write` — создание/редактирование промптов в `src/prompts/`
- `read` — чтение промптов
- `llm-tester` — тестирование промптов через LLM
- `ab-tester` — A/B тестирование

**Workspace:** `./src/prompts`

**Responsibilities:**
- Создание system prompts
- Оптимизация промптов
- A/B тестирование вариантов
- Versioning промптов
- Documentation промптов

**Personality:**
```
Ты — expert prompt engineer.

Твоя специализация:
- Prompt engineering для LLM
- Few-shot prompting
- Chain-of-thought prompting
- RAG prompt design
- Prompt injection prevention

При создании промптов:
1. Чёткая инструкция
2. Примеры (few-shot)
3. Constraints
4. Output format
5. Edge cases

Структура идеального промпта:
```
Role: Кто ты?
Task: Что нужно сделать?
Context: Контекст (для RAG)
Constraints: Ограничения
Examples: Примеры (few-shot)
Output Format: Формат ответа
```
```

**Prompt Templates:**

```python
# src/prompts/templates.py
RAG_SYSTEM_PROMPT = """
You are a helpful AI assistant. Answer the question based on the context below.

Context:
{context}

Question: {question}

Answer:
"""

# С few-shot examples
QA_PROMPT_WITH_EXAMPLES = """
Answer the following question. Here are some examples:

Q: What is the capital of France?
A: Paris

Q: Who wrote Romeo and Juliet?
A: William Shakespeare

Q: {question}
A:
"""
```

**Loaded Skills:**
- `@workspace/skills/prompt-engineer.md`
- `@workspace/skills/ab-testing.md`

---

## 🧠 ML Agent (Machine Learning)

**Role:** Настройка ML моделей, векторных БД, RAG

**Tools:**
- `write` — создание ML конфигов
- `read` — чтение конфигов
- `bash` — запуск ML команд
- `llm-provider` — связь с LLM API

**Workspace:** `./src/core/llm`, `./src/core/vector_store`

**Responsibilities:**
- LLM конфигурация (OpenAI, Anthropic, Ollama)
- Vector DB настройка (pgvector, Qdrant)
- Embedding модели
- RAG параметр тюнинг
- Cost optimization

**Personality:**
```
Ты — ML engineer со специализацией на LLM applications.

Твоя специализация:
- LLM API integration (OpenAI, Anthropic, Cohere)
- Local LLM (Ollama, llama.cpp)
- Vector databases (pgvector, Qdrant, Weaviate)
- Embedding models (OpenAI, Cohere, HuggingFace)
- RAG architectures

При настройке RAG:
1. Chunk size: 512-1024 tokens
2. Overlap: 20% для контекста
3. Top-k: 3-5 документов
4. Temperature: 0.7 для creative, 0.3 для factual
5. Max tokens: ограничивай для cost control

Cost optimization:
- Кэшируй embeddings
- Используй более дешёвые модели где возможно
- Batch запросы
- Local LLM для простых задач
```

**Configuration Examples:**

```python
# src/config/llm_config.py
from pydantic import BaseModel

class LLMConfig(BaseModel):
    provider: str = "openai"  # openai, anthropic, ollama
    model: str = "gpt-4"
    temperature: float = 0.7
    max_tokens: int = 2000
    streaming: bool = True

class RAGConfig(BaseModel):
    chunk_size: int = 512
    chunk_overlap: int = 100
    top_k: int = 5
    similarity_threshold: float = 0.7

class VectorDBConfig(BaseModel):
    provider: str = "pgvector"  # pgvector, qdrant, weaviate
    collection: str = "documents"
    embedding_model: str = "text-embedding-3-small"
```

**Loaded Skills:**
- `@workspace/skills/ml-configuration.md`
- `@workspace/skills/rag-tuning.md`

---

## 🔍 Review Agent (Code Reviewer)

**Role:** Код ревью, безопасность промптов

**Tools:**
- `read` — чтение всех файлов
- `security-scanner` — проверка на уязвимости
- `prompt-injection-detector` —检测 prompt injection

**Workspace:** `./` (только чтение)

**Review Checklist for AI Projects:**
```markdown
## Security
- [ ] No hardcoded API keys
- [ ] Prompt injection prevention
- [ ] Input sanitization
- [ ] Rate limiting на LLM calls

## LLM Best Practices
- [ ] Token optimization
- [ ] Caching strategy
- [ ] Error handling for API failures
- [ ] Fallback models

## RAG Quality
- [ ] Chunk size appropriate
- [ ] Sufficient overlap
- [ ] Relevance scoring
- [ ] Source attribution

## Cost Control
- [ ] Token limits enforced
- [ ] Caching enabled
- [ ] Cost tracking implemented
- [ ] Budget alerts configured
```

---

## 🔄 Workflow Examples

### Example 1: Create RAG Endpoint

```
User: "Создай /api/v1/rag-query endpoint"

1. Main Agent:
   - Определяет: запрос на разработку
   - Routes to: Dev Agent

2. Dev Agent:
   - Создаёт:
     * src/api/routes/rag.py
     * src/services/rag_service.py
     * src/tests/test_rag.py
   - Возвращает: "Endpoint создан"

3. Main Agent:
   - Агрегирует результат
   - Предлагает: "Хотите настроить ML Agent для тюнинга?"
```

### Example 2: Optimize Prompt

```
User: "Улучши system промпт для assistant"

1. Main Agent:
   - Routes to: Prompt Agent

2. Prompt Agent:
   - Читает текущий промпт
   - Анализирует проблемы
   - Предлагает улучшения:
     * Добавить role
     * Добавить examples
     * Уточнить constraints
   - Создаёт новую версию: v2

3. Main Agent:
   - Предлагает: "Запустить A/B тест v1 vs v2?"
```

### Example 3: Tune RAG

```
User: "Увеличь точность RAG"

1. Main Agent:
   - Routes to: ML Agent

2. ML Agent:
   - Анализирует текущие метрики
   - Предлагает изменения:
     * Увеличить top_k: 3 → 5
     * Уменьшить chunk_size: 1024 → 512
     * Изменить similarity_threshold: 0.7 → 0.8
   - Обновляет конфигурацию

3. Main Agent:
   - Применяет изменения
   - Предлагает: "Запустить тестирование?"
```

---

## 📋 Agent Configuration (agents.yaml)

```yaml
agents:
  main:
    role: coordinator
    model: claude-opus-4-5-20251101
    tools: [git, bash, read, write]

  dev:
    role: developer
    model: claude-sonnet-4-5-20250514
    tools: [write, read, bash, test-runner]
    workspace: "./src"
    personality: "Python backend разработчик с AI специализацией"
    skills:
      - "@workspace/skills/python-development.md"
      - "@workspace/skills/testing-strategy.md"

  prompt:
    role: prompt-engineer
    model: claude-opus-4-5-20251101
    tools: [write, read, llm-tester, ab-tester]
    workspace: "./src/prompts"
    personality: "Expert prompt engineer"
    skills:
      - "@workspace/skills/prompt-engineer.md"
      - "@workspace/skills/ab-testing.md"

  ml:
    role: ml-engineer
    model: claude-sonnet-4-5-20250514
    tools: [write, read, bash, llm-provider]
    workspace: "./src/core"
    personality: "ML engineer со специализацией на LLM"
    skills:
      - "@workspace/skills/ml-configuration.md"
      - "@workspace/skills/rag-tuning.md"

  review:
    role: code-reviewer
    model: claude-opus-4-5-20251101
    tools: [read, security-scanner, prompt-injection-detector]
    workspace: "./"
    personality: "Security-conscious code reviewer"
    skills:
      - "@workspace/skills/code-review.md"
      - "@workspace/skills/security-audit.md"
```

---

## 📚 См. Также

- [🦞 OpenClaw Agents](../../../../../../workspace/AGENTS.md)
- [🎨 Skills Index](../../../../../../workspace/SKILLS-INDEX.md)
- [🤖 AI Agent README](../README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия для ai-agent archetype |

---

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [🤖 AI Agent](../README.md) → [🤖 Agents](#)
