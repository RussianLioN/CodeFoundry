# Архитектура системы субагентов OpenClaw

> Версия: 1.0.0
> Дата: 2026-02-11
> Автор: Subagent Architect Agent

---

## Executive Summary

OpenClaw — это **self-improving AI assistant**, который может создавать субагентов для специализации задач. Архитектура основана на трёх уровнях:

1. **Main Agent (OpenClaw)** — координатор с full system access
2. **Specialized Agents** — субагенты для конкретных доменов
3. **Skills System** — переиспользуемые блоки инструкций

**Ключевая инновация:** OpenClaw пишет себе субагентов (self-improving loop).

---

## 1. Классификация субагентов

### 1.1 По типу задач (Domain)

| Тип | Назначение | Примеры |
|-----|------------|---------|
| **Core** | Базовая функциональность | Intent Parser, Command Resolver, Executor |
| **Development** | Написание кода | Code Generator, Debugger, Refactorer |
| **DevOps** | Инфраструктура и деплой | Docker Deploy, CI Pipeline, Monitoring |
| **AI Assistant** | Работа с AI | Prompt Engineer, Code Reviewer |
| **Analysis** | Экспертный анализ | Expert Consilium, Decision Analyst |

### 1.2 По жизненному циклу (Lifecycle)

| Тип | Описание | Пример |
|-----|----------|--------|
| **Static** | Зашиты в коде | Intent Parser, Command Resolver |
| **Dynamic** | Генерируются на лету | Custom agents for specific tasks |
| **Ephemeral** | Временные для одной задачи | One-shot analyzers |
| **Persistent** | Хранятся в workspace | Code Assistant, DevOps Agent |

### 1.3 По модели (Model Tier)

| Tier | Model | Use Case | Стоимость |
|------|-------|----------|-----------|
| **Fast** | Haiku/Sonnet | Быстрые задачи, routing | Низкая |
| **Balanced** | Sonnet 4.5 | Стандартные операции | Средняя |
| **Deep** | Opus 4.6 | Сложная генерация, анализ | Высокая |

---

## 2. Мета-протокол взаимодействия OpenClaw ↔ Субагент

### 2.1 Communication Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        OpenClaw → Subagent Protocol                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  User Request                                                               │
│       │                                                                     │
│       ▼                                                                     │
│  ┌──────────────┐                                                           │
│  │ Intent       │  → Parse intent, extract parameters                      │
│  │ Parser       │                                                           │
│  └──────┬───────┘                                                           │
│         │                                                                   │
│         ▼                                                                   │
│  ┌──────────────┐                                                           │
│  │ Agent        │  → Route to appropriate subagent                         │
│  │ Router       │                                                           │
│  └──────┬───────┘                                                           │
│         │                                                                   │
│         ▼                                                                   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                     Subagent Invocation                               │   │
│  │                                                                      │   │
│  │  {                                                                  │   │
│  │    "agent": "code-generator",                                       │   │
│  │    "task": "Generate CRUD for User model",                          │   │
│  │    "context": {                                                     │   │
│  │      "model": "User",                                               │   │
│  │      "fields": ["id", "name", "email"],                            │   │
│  │      "language": "python",                                          │   │
│  │      "framework": "FastAPI"                                         │   │
│  │    },                                                               │   │
│  │    "tools": ["read", "write", "edit"],                              │   │
│  │    "timeout_ms": 30000                                              │   │
│  │  }                                                                  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│         │                                                                   │
│         ▼                                                                   │
│  ┌──────────────┐                                                           │
│  │ Subagent     │  → Execute task, return result                          │
│  │ Execution    │                                                           │
│  └──────┬───────┘                                                           │
│         │                                                                   │
│         ▼                                                                   │
│  ┌──────────────┐                                                           │
│  │ Result       │  → Format response, handoff to user                      │
│  │ Formatter    │                                                           │
│  └──────────────┘                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Request Format (JSON)

```json
{
  "version": "1.0",
  "timestamp": "2026-02-11T12:00:00Z",
  "request_id": "req-abc123",
  "source": {
    "channel": "telegram",
    "user_id": "owner_id",
    "message_id": 123
  },
  "task": {
    "type": "code_generation",
    "description": "Generate CRUD for User model",
    "parameters": {
      "model": "User",
      "fields": ["id", "name", "email", "created_at"],
      "language": "python",
      "framework": "FastAPI",
      "include_tests": true
    },
    "constraints": {
      "max_tokens": 4000,
      "timeout_ms": 30000,
      "sandbox": true
    }
  },
  "context": {
    "cwd": "/workspace/my-project",
    "git_branch": "feature/users-api",
    "relevant_files": ["src/models/user.py", "src/api/routes.py"]
  }
}
```

### 2.3 Response Format (JSON)

```json
{
  "version": "1.0",
  "request_id": "req-abc123",
  "timestamp": "2026-02-11T12:00:15Z",
  "status": "success",
  "result": {
    "files_created": [
      "src/api/routes/users.py",
      "src/services/user_service.py",
      "tests/test_users.py"
    ],
    "summary": "Generated CRUD for User model with 3 endpoints",
    "token_usage": {
      "input": 1200,
      "output": 2800,
      "total": 4000
    },
    "next_steps": [
      "Review generated code",
      "Run tests: pytest tests/test_users.py",
      "Integrate with main application"
    ]
  },
  "metadata": {
    "agent": "code-generator",
    "model": "sonnet-4.5",
    "execution_time_ms": 14500
  }
}
```

### 2.4 Error Handling Protocol

```json
{
  "status": "error",
  "error": {
    "code": "TASK_TIMEOUT",
    "message": "Subagent execution timed out after 30000ms",
    "recoverable": true,
    "suggestions": [
      "Try with fewer fields",
      "Increase timeout",
      "Use faster model (haiku)"
    ]
  },
  "fallback": {
    "agent": "main",
    "action": "ask_user_for_clarification"
  }
}
```

---

## 3. Format хранения субагентов

### 3.1 Структура директорий

```
/opt/openclaw/workspace/
│
├── agents/                           # Subagent definitions
│   ├── core/                         # Core agents (static)
│   │   ├── intent-parser.md
│   │   ├── command-resolver.md
│   │   └── command-executor.md
│   │
│   ├── development/                  # Development agents
│   │   ├── code-generator.md
│   │   ├── debugger.md
│   │   └── refactorer.md
│   │
│   ├── devops/                       # DevOps agents
│   │   ├── docker-deploy.md
│   │   ├── ci-pipeline.md
│   │   └── monitoring.md
│   │
│   ├── ai-assistants/                # AI assistant agents
│   │   ├── prompt-engineer.md
│   │   ├── code-reviewer.md
│   │   └── documentation-agent.md
│   │
│   └── generated/                    # Auto-generated agents
│       ├── custom-{task}-{timestamp}.md
│       └── temporary-{session-id}.md
│
├── skills/                           # Reusable skill blocks
│   ├── core/
│   ├── development/
│   ├── devops/
│   └── ai-assistants/
│
├── AGENTS.md                         # Agent registry
├── AGENTS-INDEX.json                 # Machine-readable index
└── AGENTS-SCHEMA.json                # Validation schema
```

### 3.2 Формат агента (Markdown + Frontmatter)

```markdown
---
name: code-generator
version: 1.0.0
description: Generates boilerplate code from templates
model: sonnet
temperature: 0.3
tools: [read, write, edit]
category: development
tags: [codegen, boilerplate, templates]
timeout_ms: 30000
sandbox: true
---

# Code Generator Agent

## Role
You are a Code Generator — specializes in generating boilerplate code from templates.

## Capabilities
- Generate CRUD operations
- Create API endpoints
- Generate test suites
- Create documentation stubs

## Workflow
1. Analyze request requirements
2. Select appropriate template
3. Generate code with placeholders
4. Validate syntax
5. Return generated files

## Templates
- `crud-python`: Python CRUD with SQLAlchemy
- `api-fastapi`: FastAPI REST API
- `api-nestjs`: NestJS microservice
- `test-pytest`: Pytest test suite

## Examples
@ref: skills/development/code-generator-examples.md

## Constraints
- Max tokens per file: 2000
- Always include type hints
- Add docstrings to all functions
- Generate tests alongside code

## Error Handling
- If template not found: suggest closest match
- If generation fails: provide partial result + error
- If validation fails: fix and retry
```

### 3.3 Machine-readable index (JSON)

```json
{
  "$schema": "AGENTS-SCHEMA.json",
  "version": "1.0.0",
  "last_updated": "2026-02-11T12:00:00Z",
  "agents": {
    "code-generator": {
      "file": "agents/development/code-generator.md",
      "category": "development",
      "model": "sonnet",
      "tools": ["read", "write", "edit"],
      "triggers": {
        "keywords": ["generate", "create", "boilerplate"],
        "patterns": ["generate (.+) (code|crud|api)"]
      },
      "capabilities": [
        "crud_generation",
        "api_generation",
        "test_generation"
      ]
    },
    "docker-deploy": {
      "file": "agents/devops/docker-deploy.md",
      "category": "devops",
      "model": "sonnet",
      "tools": ["bash", "docker", "read", "write"],
      "triggers": {
        "keywords": ["deploy", "docker", "container"],
        "patterns": ["deploy (.+) (docker|container)"]
      }
    }
  },
  "routing": {
    "default_agent": "main",
    "confidence_threshold": 0.7,
    "max_agents_per_request": 3
  }
}
```

---

## 4. Self-Improving Loop (OpenClaw пишет субагентов)

### 4.1 Как это работает

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Self-Improving Loop                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. GAP DETECTION                                                           │
│     │                                                                       │
│     ├── User: "I need X"                                                    │
│     ├── OpenClaw: No agent for X                                            │
│     └── Decision: Create new subagent                                      │
│                                                                             │
│  2. REQUIREMENT ANALYSIS                                                    │
│     │                                                                       │
│     ├── What type of task?                                                 │
│     ├── What tools needed?                                                 │
│     ├── What model tier?                                                   │
│     └── Sandbox required?                                                  │
│                                                                             │
│  3. AGENT GENERATION                                                        │
│     │                                                                       │
│     ├── Prompt Engineer agent generates agent definition                   │
│     ├── Uses agent template from templates/agents/                         │
│     ├── Saves to agents/generated/{name}-{timestamp}.md                    │
│     └── Updates AGENTS-INDEX.json                                          │
│                                                                             │
│  4. VALIDATION                                                              │
│     │                                                                       │
│     ├── Check frontmatter completeness                                     │
│     ├── Validate against schema                                            │
│     ├── Test with sample task                                              │
│     └── If fails: fix and retry                                            │
│                                                                             │
│  5. DEPLOY                                                                  │
│     │                                                                       │
│     ├── Agent becomes available immediately                                │
│     ├── Route to new agent                                                 │
│     └── Execute original task                                              │
│                                                                             │
│  6. LEARNING                                                                │
│     │                                                                       │
│     ├── Track agent usage                                                  │
│     ├── Monitor success rate                                               │
│     ├── If low usage: suggest deprecation                                  │
│     └── If high usage: suggest promotion to core                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Пример: Создание нового субагента

**User Request:**
> "Создай агента для генерации миграций базы данных"

**OpenClaw Internal Process:**

1. **Gap Detection:**
   - Search AGENTS-INDEX.json
   - No agent found for "migration" keyword
   - Decision: Create new agent

2. **Requirement Analysis:**
   ```yaml
   task_type: code_generation
   domain: database
   tools: [read, write, bash]
   model: sonnet
   sandbox: true
   examples_needed:
     - Alembic (Python)
     - Prisma (Node.js)
     - Atlas (Go)
   ```

3. **Agent Generation** (via Prompt Engineer):
   ```markdown
   ---
   name: migration-generator
   version: 1.0.0
   description: Generates database migrations from schema changes
   model: sonnet
   tools: [read, write, bash]
   category: development
   tags: [database, migration, schema]
   ---

   # Migration Generator Agent

   ## Role
   Generate database migrations from schema changes...

   ## Supported ORMs
   - Alembic (Python/SQLAlchemy)
   - Prisma (Node.js)
   - Atlas (Go)
   - Django Migrations

   ## Workflow
   1. Detect ORM from project
   2. Compare schema states
   3. Generate migration
   4. Validate SQL
   5. Apply migration (if requested)
   ```

4. **Validation:**
   ```bash
   # Validate against schema
   openclaw validate-agent agents/generated/migration-generator-20260211.md

   # Test with sample task
   openclaw test-agent migration-generator \
     --task "Generate migration for User.email field"
   ```

5. **Deploy:**
   ```bash
   # Agent is now available
   User: "Создай миграцию для добавления поля email"
   OpenClaw: → Routes to migration-generator
   ```

---

## 5. Примеры субагентов для MVP

### 5.1 Core Agents (Обязательные)

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| **Intent Parser** | `agents/core/intent-parser.md` | Parse user input into structured intents | Sonnet |
| **Command Resolver** | `agents/core/command-resolver.md` | Resolve intents to executable commands | Haiku |
| **Command Executor** | `agents/core/command-executor.md` | Execute commands with progress tracking | N/A |
| **Agent Router** | `agents/core/agent-router.md` | Route tasks to appropriate agents | Sonnet |

### 5.2 Development Agents (Для MVP)

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| **Code Generator** | `agents/development/code-generator.md` | Generate boilerplate code | Sonnet |
| **Debugger** | `agents/development/debugger.md` | Debug errors and fix bugs | Opus |
| **Test Generator** | `agents/development/test-generator.md` | Generate unit/integration tests | Sonnet |
| **Code Reviewer** | `agents/development/code-reviewer.md` | Review code for quality | Opus |

### 5.3 DevOps Agents (Для MVP)

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| **Docker Deploy** | `agents/devops/docker-deploy.md` | Deploy to Docker | Sonnet |
| **CI Pipeline** | `agents/devops/ci-pipeline.md` | Generate CI/CD pipelines | Sonnet |

### 5.4 AI Assistant Agents (Для MVP)

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| **Prompt Engineer** | `agents/ai-assistants/prompt-engineer.md` | Optimize prompts | Opus |
| **Documentation Agent** | `agents/ai-assistants/documentation.md` | Generate/update docs | Sonnet |

---

## 6. Взаимодействие между субагентами

### 6.1 Sequential Workflow

```yaml
workflow:
  name: "Create and Deploy API"

  steps:
    - agent: code-generator
      task: "Generate FastAPI CRUD for User"
      output: "generated_files"

    - agent: test-generator
      task: "Generate tests for User CRUD"
      depends_on: "generated_files"
      output: "test_files"

    - agent: code-reviewer
      task: "Review generated code"
      depends_on: ["generated_files", "test_files"]
      output: "review_report"

    - agent: docker-deploy
      task: "Deploy to staging"
      depends_on: "review_report"
      condition: "review_report.approved == true"
```

### 6.2 Parallel Execution

```yaml
workflow:
  name: "Full Stack Review"

  parallel:
    - agent: code-reviewer
      task: "Review backend code"
      files: "src/backend/"

    - agent: code-reviewer
      task: "Review frontend code"
      files: "src/frontend/"

    - agent: test-generator
      task: "Generate integration tests"
      files: "tests/"

  merge:
    agent: main
    task: "Compile review report"
```

### 6.3 Agent Handoff Protocol

```markdown
## Agent Handoff

**From:** code-generator
**To:** code-reviewer
**Reason:** Generated code requires review

---

### Context

Generated FastAPI CRUD for User model with 5 endpoints.

### Files Involved

- src/api/routes/users.py (new)
- src/services/user_service.py (new)
- tests/test_users.py (new)

### Task

Review for:
- Code quality
- Security vulnerabilities
- Best practices
- Test coverage

---

**Continue from here.**
```

---

## 7. Recommendations

### 7.1 Для MVP (Minimal Viable Product)

**MUST HAVE (P0):**
1. Intent Parser + Command Resolver + Executor (Core)
2. Code Generator (Development)
3. Docker Deploy (DevOps)

**SHOULD HAVE (P1):**
1. Debugger
2. Test Generator
3. Code Reviewer
4. Prompt Engineer

**NICE TO HAVE (P2):**
1. CI Pipeline
2. Documentation Agent
3. Monitoring Agent
4. Migration Generator

### 7.2 Self-Improving Loop Priority

**Phase 1 (Static):**
- Core agents hardcoded
- No dynamic generation

**Phase 2 (Semi-dynamic):**
- Prompt Engineer can generate new agents
- Manual validation required

**Phase 3 (Fully dynamic):**
- Automatic gap detection
- Auto-validation
- Auto-deployment

### 7.3 Storage Recommendation

**Use YAML for agent definitions** (more readable than JSON):

```yaml
# agents/development/code-generator.yaml
name: code-generator
version: 1.0.0
description: Generates boilerplate code
model: sonnet
tools: [read, write, edit]
triggers:
  keywords: [generate, create, boilerplate]
  patterns: ["generate (.+) (code|crud|api)"]
capabilities:
  - crud_generation
  - api_generation
  - test_generation
templates:
  - crud-python
  - api-fastapi
  - test-pytest
```

**Keep MD for documentation** (human-readable):

```markdown
# Code Generator Agent

## Overview
@ref: agents/development/code-generator.yaml

## Detailed Instructions
...
```

---

## 8. Next Steps

1. **Implement Core Agents**
   - Intent Parser
   - Command Resolver
   - Command Executor
   - Agent Router

2. **Create Agent Schema**
   - `AGENTS-SCHEMA.json`
   - Validation rules

3. **Implement Self-Improving Loop**
   - Gap detection
   - Agent generation
   - Validation

4. **Test with MVP Agents**
   - Code Generator
   - Docker Deploy
   - Test Generator

---

**Generated by:** Subagent Architect Agent
**Date:** 2026-02-11
**Version:** 1.0.0
