# Intent Parser Skill

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → [Skills](SKILLS-INDEX.md) → **Intent Parser**

---

## Purpose

Convert natural language user input into structured command objects that can be executed by the system.

---

## How It Works

```
User Input (Natural Language)
        ↓
   Intent Parser (AI)
        ↓
   Structured Intent Object
        ↓
   Command Resolver
        ↓
   Executable Command
```

---

## Intent Categories

| Category | Trigger Patterns | Parameters |
|----------|-----------------|------------|
| `create_project` | создай проект, новый проект, инициализируй | archetype, name, location |
| `generate_agents` | сгенерируй агента, создай агента, agents | project_name, project_type |
| `deploy` | задеплой, деплой, разверни | environment, project_name |
| `git_commit` | закоммить, commit, сохрани | message |
| `git_push` | запуш, push, отправь | branch |
| `run_tests` | запусти тесты, тесты, testing | scope |
| `show_status` | статус, состояние, как дела | N/A |
| `help` | помощь, help, что умеешь | N/A |

---

## Entity Extraction Rules

### 1. Archetype Detection

```yaml
patterns:
  web:
    - "API"
    - "сервер"
    - "backend"
    - "REST"
    - "GraphQL"
    → web-service

  telegram:
    - "бот"
    - "telegram"
    - "TG"
    → telegram-bot

  ai:
    - "AI"
    - "чат-бот"
    - "ассистент"
    - "GPT"
    → ai-agent

  fullstack:
    - "SaaS"
    - "фронтенд+бэкенд"
    - "полный стек"
    → fullstack

  data:
    - "ETL"
    - "пайплайн"
    - "данные"
    - "ELT"
    → data-pipeline
```

### 2. Name Extraction

```yaml
patterns:
  explicit:
    - "Создай проект [NAME]"
    - "Проект с названием [NAME]"
    → extract directly

  implicit:
    - "API для заказов" → orders-api
    - "Бот доставки" → delivery-bot
    - "SaaS для задач" → task-saas
    → infer from context

  validation:
    - alphanumeric only
    - min length: 3
    - max length: 30
    - no special characters except hyphen
```

### 3. Parameter Validation

```yaml
create_project:
  required:
    - archetype
    - name
  optional:
    - location (default: ./)
    - language (inferred from archetype)
    - framework (inferred from archetype)

generate_agents:
  required:
    - project_name
  optional:
    - project_type (inferred from project)
    - language (detected from project)
```

---

## Response Format

### Success Response

```json
{
  "status": "success",
  "intent": {
    "category": "create_project",
    "confidence": 0.95,
    "parameters": {
      "archetype": "telegram-bot",
      "name": "my-bot",
      "location": "./my-bot",
      "language": "python",
      "framework": "aiogram"
    },
    "clarifications_needed": []
  },
  "command": {
    "executable": "make",
    "args": ["new", "ARCHETYPE=telegram-bot", "NAME=my-bot"],
    "cwd": "/workspace/system-prompts"
  }
}
```

### Ambiguity Response

```json
{
  "status": "ambiguity",
  "intent": {
    "category": "create_project",
    "confidence": 0.6,
    "parameters": {
      "name": "my-service"
    },
    "clarifications_needed": [
      {
        "field": "archetype",
        "question": "Какой тип проекта?",
        "options": [
          "web-service — REST/GraphQL API",
          "telegram-bot — Telegram бот",
          "ai-agent — AI ассистент",
          "fullstack — Fullstack приложение"
        ]
      }
    ]
  },
  "suggested_command": null
}
```

### Error Response

```json
{
  "status": "error",
  "error": {
    "code": "UNABLE_TO_PARSE",
    "message": "Не удалось понять запрос",
    "suggestions": [
      "Создай проект telegram-bot my-bot",
      "Сгенерируй агенты для проекта my-service",
      "Покажи статус"
    ]
  }
}
```

---

## Examples

### Example 1: Clear Intent

**Input:** "Создай fullstack проект my-saas"

**Parsing:**
```
Intent: create_project (confidence: 1.0)
├── archetype: fullstack (detected from "fullstack")
├── name: my-saas (explicit)
├── location: ./my-saas (default)
└── language: TypeScript (inferred from archetype)
```

**Command:** `make new ARCHETYPE=fullstack NAME=my-saas`

---

### Example 2: Implicit Archetype

**Input:** "Создай бота для доставки еды"

**Parsing:**
```
Intent: create_project (confidence: 0.95)
├── archetype: telegram-bot (inferred from "бот")
├── name: food-delivery-bot (inferred from "доставки еды")
├── location: ./food-delivery-bot (default)
└── framework: aiogram (default for telegram-bot)
```

**Clarification Needed:** None (high confidence)

**Command:** `make new ARCHETYPE=telegram-bot NAME=food-delivery-bot`

---

### Example 3: Ambiguous Intent

**Input:** "Создай проект"

**Parsing:**
```
Intent: create_project (confidence: 0.4)
├── archetype: null (MISSING)
├── name: null (MISSING)
└── clarifications_needed: 2
```

**Response:**
```
Хотите создать проект. Уточните детали:

1️⃣ Какой тип проекта?
   • web-service — REST/GraphQL API
   • telegram-bot — Telegram бот
   • ai-agent — AI ассистент
   • fullstack — Fullstack приложение
   • data-pipeline — ETL пайплайн

2️⃣ Как назвать проект?
   (например: my-service, delivery-bot, task-manager)
```

---

### Example 4: Generate Agents

**Input:** "Сгенерируй агентов для my-service"

**Parsing:**
```
Intent: generate_agents (confidence: 0.98)
├── project_name: my-service (explicit)
├── project_type: web-service (detected from project)
└── language: python (detected from project)
```

**Command:** `make generate-agents NAME=my-service TYPE=web-service`

---

### Example 5: Deploy

**Input:** "Задеплой на staging"

**Parsing:**
```
Intent: deploy (confidence: 0.9)
├── environment: staging (explicit)
└── project_name: . (current directory)
```

**Command:** `make deploy ENV=staging`

---

## Integration Points

### With Command Resolver

```typescript
interface IntentParser {
  parse(input: string): Promise<ParsedIntent>;
}

interface CommandResolver {
  resolve(intent: ParsedIntent): ExecutableCommand;
}

interface Executor {
  execute(command: ExecutableCommand): Promise<ExecutionResult>;
}
```

### With Multi-turn Dialogue

```
User: "Создай проект"
   ↓
Parser: Detects ambiguity
   ↓
AI: Asks clarification question
   ↓
User: "telegram-bot my-bot"
   ↓
Parser: Re-parses with new context
   ↓
Resolver: Generates command
   ↓
Executor: Runs make new ARCHETYPE=telegram-bot NAME=my-bot
```

---

## Configuration

```yaml
intent_parser:
  confidence_threshold: 0.8
    # Below this: ask for clarification

  max_clarifications: 3
    # Maximum questions before asking for full rephrase

  timeout_ms: 5000
    # Maximum time to parse intent

  language: ru
    # Primary language for input

  fallback_command:
    executable: "make"
    args: ["help"]
```

---

## Testing

```bash
# Test intent parsing
curl -X POST http://localhost:18789/intent/parse \
  -H "Content-Type: application/json" \
  -d '{"input": "Создай проект telegram-bot my-bot"}'

# Expected response:
{
  "status": "success",
  "intent": {...},
  "command": {...}
}
```

---

## @see-also

- [🎯 Agent Router](../agents/agent-router.md) — Route intents to agents
- [🛠️ Command Executor](../skills/command-executor.md) — Execute parsed commands
- [📋 Project Initializer](../agents/project-initializer.md) — Project creation workflow

---

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → [Skills](SKILLS-INDEX.md) → **Intent Parser**
