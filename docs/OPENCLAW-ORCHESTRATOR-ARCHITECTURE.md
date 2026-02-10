> [🏠 Главная](../README.md) → **🤖 OpenClaw Orchestrator**

---
# 🏗️ OpenClaw Orchestrator Architecture

> **Новая архитектура:** OpenClaw = Orchestration Layer, Claude Code = Development Layer
>
> **Дата:** 2025-02-05
> **Версия:** 2.0
> **Экспертный консенсус:** 8.8/13 — ОТЛИЧНО

---

## 📋 Executive Summary

**OpenClaw больше НЕ является разработчиком кода.** OpenClaw теперь — **оркестратор/UI слой**, который управляет Claude Code (glm-4.7) для выполнения разработки.

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│  Telegram   │────▶│  OpenClaw    │────▶│  Claude Code│────▶│  Generated  │
│   User      │     │  Orchestrator│     │   Developer │     │    Code     │
└─────────────┘     └──────────────┘     └─────────────┘     └─────────────┘
                          │
                    gemini-3-flash
                 (Ollama Cloud API)
```

---

## 🎯 Ключевые Изменения

| Было (v1.0) | Стало (v2.0) |
|-------------|--------------|
| OpenClaw = Разработчик | OpenClaw = Оркестратор |
| OpenClaw пишет код напрямую | OpenClaw управляет Claude Code |
| Одна модель для всего | Две модели: gemini-3-flash + glm-4.7 |
| Локальный Ollama | Ollama Cloud API (бесплатный/дешёвый) |
| Прямая генерация | Command Protocol |

---

## 🔄 Полный Workflow

### 1. Основной сценарий (Telegram → OpenClaw → Claude Code)

```
┌─────────────────────────────────────────────────────────────────┐
│                     User Workflow                               │
└─────────────────────────────────────────────────────────────────┘

1. Пользователь в Telegram:
   User: "/new my-app web"

2. Telegram Bot → OpenClaw Gateway (WebSocket):
   {
     "intent": "create_project",
     "project_name": "my-app",
     "archetype": "web-service"
   }

3. OpenClaw (gemini-3-flash):
   → Parse intent
   → Validate parameters
   → Generate Claude Code command
   → Command: {
       "version": "1.0",
       "command": "create_project",
       "archetype": "web-service",
       "name": "my-app",
       "context": {
         "path": "/workspace/my-app",
         "framework": "nextjs"
       }
     }

4. CLI Bridge → Claude Code:
   $ claude code create project web-service \
       --name my-app \
       --path /workspace/my-app \
       --framework nextjs

5. Claude Code (glm-4.7):
   → Generate project structure
   → Create files
   → Run tests
   → Response: {
       "status": "success",
       "files_created": 25,
       "tests_passed": 5
     }

6. OpenClaw → Telegram Bot:
   "✅ Проект my-app создан!
    📁 Файлов: 25
    ✅ Тесты: 5 passed
    📝 Next steps: /help"

7. Пользователь получает результат в Telegram
```

### 2. Альтернативный сценарий (SSH → Claude Code напрямую)

```
┌─────────────────────────────────────────────────────────────────┐
│                   Manual Workflow                               │
└─────────────────────────────────────────────────────────────────┘

1. SSH на ainetic.tech:
   $ ssh user@ainetic.tech

2. Запуск Claude Code напрямую:
   $ cd /workspace
   $ claude code

3. Работа в Claude Code CLI:
   User: create project web-service my-app
   Claude: [generating...]
   Claude: ✅ Created 25 files

4. Преимущества:
   - Полный контроль
   - Доступ к всем возможностям Claude Code
   - Лучше для сложных задач
```

---

## 🏗️ Архитектурные Слои

### Layer 1: UI Layer (Telegram Bot)

```yaml
component: Telegram Bot
technology: aiogram (Python)
responsibilities:
  - Receive user messages
  - Display responses
  - File uploads/downloads
  - Progress indicators
endpoints:
  - webhook: /telegram/webhook
  - commands: /start, /new, /status, /help
```

### Layer 2: Orchestration Layer (OpenClaw)

```yaml
component: OpenClaw Gateway
model: gemini-3-flash-preview (Ollama Cloud API)
responsibilities:
  - Intent parsing (NLU)
  - Command generation
  - Session management
  - Progress tracking
  - Error handling
  - Response formatting

capabilities:
  - 1M token context window
  - Fast inference (<2s)
  - Cost-effective (FREE or $0.5/1M tokens)

should_not:
  - Generate code directly
  - Make technical decisions
  - Access file system
```

### Layer 3: Development Layer (Claude Code)

```yaml
component: Claude Code CLI
model: glm-4.7 / glm-4.7-flash
responsibilities:
  - Code generation
  - Project scaffolding
  - Testing
  - Documentation
  - Refactoring
  - Debugging

capabilities:
  - Deep code understanding
  - Multi-language support
  - Best practices
  - Production-ready code

should_not:
  - Parse natural language
  - Manage user sessions
```

### Layer 4: CLI Bridge (OpenClaw ↔ Claude Code)

```yaml
component: claude-wrapper.sh
technology: Bash + jq
responsibilities:
  - JSON command parsing
  - Claude Code execution
  - Response aggregation
  - Error handling
  - Logging

protocol:
  format: JSON
  versioning: v1.0
  transport: docker exec
```

---

## 📡 Command Protocol v1.0

### Request Format

```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2025-02-05T12:00:00Z",
  "command": "create_project",
  "params": {
    "name": "my-app",
    "archetype": "web-service",
    "framework": "nextjs"
  },
  "context": {
    "session_id": "session-123",
    "user_id": "telegram-987654321",
    "project_path": "/workspace/my-app"
  }
}
```

### Response Format

```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "success",
  "result": {
    "files_created": 25,
    "tests_passed": 5,
    "project_path": "/workspace/my-app"
  },
  "logs": [
    "Creating project structure...",
    "Generating components...",
    "Running tests..."
  ],
  "errors": []
}
```

### Supported Commands (MVP)

| Command | Описание | Параметры |
|---------|----------|-----------|
| `create_project` | Создать проект | `name`, `archetype`, `framework` |
| `get_status` | Статус проекта | `project_path` |
| `get_help` | Справка | - |

---

## 🔧 Техническая Реализация

### Docker Compose Stack

```yaml
# docker-compose.orchestrator.yml
version: '3.8'

services:
  # OpenClaw Orchestrator
  openclaw-orchestrator:
    build:
      context: ./openclaw/gateway
      dockerfile: Dockerfile.gateway
    environment:
      - PORT=18789
      - HEALTH_PORT=18790
      - OLLAMA_BASE_URL=https://api.ollama.cloud
      - OLLAMA_MODEL=gemini-3-flash-preview
      - OLLAMA_API_KEY=${OLLAMA_API_KEY}
      - CLAUDE_CODE_HOST=claude-code-runner
    ports:
      - "18789:18789"
      - "18790:18790"
    volumes:
      - ./sessions:/sessions
      - ./projects:/workspace:cached
    depends_on:
      - telegram-bot
      - claude-code-runner
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:18790/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  # Telegram Bot
  telegram-bot:
    build:
      context: ./openclaw/telegram-bot
      dockerfile: Dockerfile
    environment:
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
      - AUTHORIZED_USER_IDS=${AUTHORIZED_USER_IDS}
      - GATEWAY_URL=ws://openclaw-orchestrator:18789
    depends_on:
      - openclaw-orchestrator
    restart: unless-stopped

  # Claude Code Runner
  claude-code-runner:
    image: claude-code:latest
    environment:
      - CLAUDE_MODEL=glm-4.7
      - DEFAULT_PROJECT_DIR=/workspace
    volumes:
      - ./projects:/workspace:cached
      - ./scripts/claude-wrapper.sh:/usr/local/bin/claude-wrapper:ro
    working_dir: /workspace
    # CLI accessible via docker exec
    stdin_open: true
    tty: true
```

### CLI Bridge Script

```bash
#!/usr/bin/env bash
# scripts/claude-wrapper.sh

set -euo pipefail

# Read JSON command from stdin
COMMAND_JSON=$(cat)

# Parse command
COMMAND=$(echo "$COMMAND_JSON" | jq -r '.command')
PARAMS=$(echo "$COMMAND_JSON" | jq -r '.params')
CONTEXT=$(echo "$COMMAND_JSON" | jq -r '.context')

# Execute via Claude Code CLI
case "$COMMAND" in
  create_project)
    NAME=$(echo "$PARAMS" | jq -r '.name')
    ARCHETYPE=$(echo "$PARAMS" | jq -r '.archetype')

    docker exec -it claude-code-runner \
      claude code create project \
        --name "$NAME" \
        --archetype "$ARCHETYPE" \
        --output json \
        2>&1
    ;;

  get_status)
    PROJECT_PATH=$(echo "$CONTEXT" | jq -r '.project_path')

    docker exec claude-code-runner \
      claude code status \
        --project "$PROJECT_PATH" \
        --output json
    ;;

  *)
    echo '{"error": "Unknown command"}' >&2
    exit 1
    ;;
esac
```

---

## 🔐 Безопасность

### User Authorization

```typescript
// telegram-bot/src/auth.ts
const AUTHORIZED_USER_IDS = process.env.AUTHORIZED_USER_IDS.split(',');

function isAuthorized(userId: number): boolean {
  return AUTHORIZED_USER_IDS.includes(userId.toString());
}
```

### Command Validation

```typescript
// openclaw/gateway/src/command-validator.ts
function validateCommand(cmd: Command): ValidationResult {
  // Check for command injection
  if (cmd.command.includes('../')) {
    return { valid: false, error: 'Path traversal detected' };
  }

  // Check parameter limits
  if (cmd.params.name.length > 100) {
    return { valid: false, error: 'Name too long' };
  }

  return { valid: true };
}
```

### Ollama Cloud API

```bash
# Ollama Cloud authentication
export OLLAMA_API_KEY="your-api-key"
export OLLAMA_BASE_URL="https://api.ollama.cloud"

# Free tier (2026)
# - gemini-3-flash-preview: FREE
# - Rate limits: 100 requests/minute
```

---

## 📊 Мониторинг

### Prometheus Metrics

```yaml
# prometheus/monitoring-orchestrator.yml
groups:
  - name: openclaw_orchestrator
    rules:
      - alert: OpenClawDown
        expr: up{job="openclaw-orchestrator"} == 0
        for: 5m
        annotations:
          summary: "OpenClaw Orchestrator недоступен"

      - alert: ClaudeCodeDown
        expr: up{job="claude-code-runner"} == 0
        for: 5m
        annotations:
          summary: "Claude Code Runner недоступен"

      - alert: HighCommandLatency
        expr: openclaw_command_duration_seconds > 30
        for: 5m
        annotations:
          summary: "Высокая задержка команд"
```

---

## 🚀 Roadmap

### Phase 1: MVP (Week 1)

```yaml
commands:
  - /new <project> <archetype>
  - /status
  - /help

features:
  - Basic command protocol
  - No session persistence
  - Simple error handling

deliverables:
  - Command Protocol v1.0 spec
  - CLI Bridge scripts
  - Telegram Bot MVP
  - OpenClaw Gateway updates
```

### Phase 2: Enhanced (Week 2-3)

```yaml
commands:
  - All MVP commands
  - /deploy <env>
  - /logs
  - /test

features:
  - Session persistence (Redis/File)
  - Progress indicators
  - File upload/download
  - Multi-command workflows

deliverables:
  - Session Manager
  - Enhanced error handling
  - File Bridge
  - Monitoring integration
```

### Phase 3: Production (Week 4+)

```yaml
commands:
  - All enhanced commands
  - /agents (manage AI agents)
  - /projects (list projects)
  - /config (project settings)

features:
  - Multi-user support
  - Rate limiting
  - Role-based access
  - Full observability

deliverables:
  - Multi-user architecture
  - Rate limiter
  - RBAC system
  - Production hardening
```

---

## 📚 Связанные Документы

| Документ | Описание |
|----------|----------|
| [Expert Opinions](./experts-opinions-openclaw-orchestrator.md) | Мнения 13 экспертов |
| [Ollama Research](./research/ollama-gemini3-flash-deployment.md) | Ollama Cloud API |
| [Remote Testing Architecture](./remote-testing/ARCHITECTURE.md) | Инфраструктура ainetic.tech |
| [PROJECT.md](../PROJECT.md) | Общее описание проекта |

---

## 🎯 Критические Следующие Шаги

### P0 (КРИТИЧНО):

1. **ARCHITECT-001**: Определить Command Protocol v1.0
   - JSON schema
   - Error handling
   - Versioning

2. **PROTOCOL-001**: Реализовать CLI Bridge
   - `claude-wrapper.sh`
   - JSON parsing
   - Docker integration

3. **GATEWAY-001**: Обновить OpenClaw Gateway
   - Ollama Cloud API integration
   - Command generation (не code generation!)
   - Session management

### P1 (ВАЖНО):

4. **BOT-002**: Telegram Bot MVP
   - 3 команды
   - Basic error handling
   - Progress indicators

5. **DOCS-001**: Обновить документацию
   - PROJECT.md
   - TASKS.md
   - README.md

---

**Версия:** 2.0
**Статус:** НА УТВЕРЖДЕНИИ (Expert consensus: 8.8/13)
**Следующий шаг:** Implement Command Protocol v1.0

---

Sources:
- [Ollama gemini-3-flash-preview](https://ollama.com/library/gemini-3-flash-preview)
- [Ollama Cloud API](https://ollama.com/pricing)
- [Expert Consensus](./experts-opinions-openclaw-orchestrator.md)
