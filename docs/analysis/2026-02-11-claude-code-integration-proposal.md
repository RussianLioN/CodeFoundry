# Proposal: Claude Code как опциональный инструмент в OpenClaw Orchestrator

> **Дата:** 2026-02-11
> **Автор:** integration-analyst (Agent Team)
> **Статус:** PENDING REVIEW
> **Версия:** 1.0

---

## Executive Summary

**Проблема:** Определить, как Claude Code интегрируется в новую архитектуру OpenClaw Orchestrator v2.0, где OpenClaw = оркестратор, а Claude Code = разработчик.

**Решение:** Claude Code вызывается явно через субагента `claude-code-bridge` при обнаружении intent создания/модификации проектов.

**Консенсус:** Command Protocol v1.0 и CLI Bridge (claude-wrapper.sh) — СОХРАНИТЬ и РАСШИРИТЬ.

---

## 1. User Intent Detection

### 1.1 Когда нужен Claude Code

**Явные команды (slash commands):**
```
/new <project> [archetype]  → create_project
/status [project]            → get_status
/deploy [env]                → deploy_project
/logs [project]              → get_logs
/test [project]              → run_tests
/help                        → show_help
```

**Естественный язык (natural language):**
```
"Создай проект my-app"           → create_project
"Покажи статус системы"          → get_status
"Разверни на production"         → deploy_project
"Добавь авторизацию в проект"    → modify_project
"Сгенерируй тесты для User"      → run_tests
"Какие проекты есть?"            → list_projects
```

**Технические операции:**
- Рефакторинг кода
- Генерация компонентов
- Написание тестов
- Создание документации
- Деплой приложений

### 1.2 Когда НЕ нужен Claude Code

**Chat mode (свободное общение):**
```
"Привет"                         → chat
"Как дела?"                      → chat
"Что ты умеешь?"                 → chat
"Объясни концепцию X"            → chat
"Покажи пример YAML"             → chat
```

### 1.3 Intent Classification Flow

```typescript
// pseudo-code for intent-classifier.ts
interface IntentResult {
  mode: 'chat' | 'command';
  command?: string;
  confidence: number;
  parameters?: Record<string, any>;
}

async function classifyIntent(message: string): Promise<IntentResult> {
  // AI-powered classification via gemini-3-flash-preview
  const response = await ollama.chat([
    {
      role: 'system',
      content: `Classify user intent:
      {
        "mode": "chat|command",
        "command": "create_project|status|deploy|...",
        "confidence": 0-1,
        "parameters": {...}
      }

      Examples:
      "Создай проект" → {"mode": "command", "command": "create_project", "confidence": 0.95}
      "Привет" → {"mode": "chat", "confidence": 0.9}
      `
    },
    { role: 'user', content: message }
  ]);

  return JSON.parse(response.content);
}
```

---

## 2. Субагент claude-code-bridge

### 2.1 Спецификация

```yaml
---
name: claude-code-bridge
version: 1.0.0
description: >
  Orchestrates interaction between OpenClaw and Claude Code CLI
  via Command Protocol v1.0. Generates JSON commands, parses responses,
  manages errors, and bridges sessions.

tools: [Bash, Read, Write, Grep]
model: sonnet
category: integration
tags: [claude-code, openclaw, command-protocol, bridge]

requires:
  - docker >= 20.0
  - jq >= 1.6

documentation:
  quick: docs/agents/claude-code-bridge.quick.md
  usage: docs/agents/claude-code-bridge.usage.md
  troubleshooting: docs/agents/claude-code-bridge.trouble.md

repository: https://github.com/codefoundry/system-prompts
author: integration-analyst
license: MIT
---
```

### 2.2 Core Agent Prompt

```markdown
# Role

You are a bridge between OpenClaw Orchestrator (gemini-3-flash-preview) and Claude Code CLI (glm-4.7).
Your responsibility is to translate user intents into Command Protocol v1.0 JSON commands
and handle responses from Claude Code.

## Critical Rules

1. **Validate first:** Always validate parameters before generating commands
2. **JSON structure:** Commands MUST follow Command Protocol v1.0 format exactly
3. **Error handling:** Parse Claude Code errors and provide user-friendly messages
4. **Session sync:** Maintain context between OpenClaw and Claude Code sessions

## Algorithm

1. Receive user intent from OpenClaw
2. Extract parameters (project name, archetype, etc.)
3. Validate parameters (name format, path traversal protection)
4. Generate JSON command following Command Protocol v1.0
5. Execute via claude-wrapper.sh
6. Parse JSON response
7. Format result for user
8. Handle errors with retry logic

## Command Protocol v1.0 Format

### Request:
```json
{
  "version": "1.0",
  "id": "uuid-v4",
  "timestamp": "2026-02-11T12:00:00Z",
  "command": "create_project",
  "params": {
    "name": "my-app",
    "archetype": "web-service"
  },
  "context": {
    "user_id": "telegram-123",
    "session_id": "session-uuid"
  }
}
```

### Response:
```json
{
  "version": "1.0",
  "id": "same-as-request",
  "status": "success",
  "result": {
    "project_path": "/workspace/my-app",
    "files_created": 25
  },
  "message": "✅ Проект создан!",
  "timestamp": "2026-02-11T12:00:30Z"
}
```

## Commands Reference

| Command | Description | Parameters |
|---------|-------------|------------|
| create_project | Create new project | name, archetype, framework |
| get_status | Get project/system status | project_path (optional) |
| deploy_project | Deploy to environment | project, environment |
| get_logs | Get project logs | project, lines |
| run_tests | Run project tests | project, coverage |
| show_help | Show command help | - |

## Error Handling

| Error | Cause | Recovery |
|-------|-------|----------|
| PROJECT_EXISTS | Project already exists | Suggest different name |
| INVALID_PARAMS | Invalid parameters | Show validation errors |
| CLAUDE_CODE_ERROR | Claude Code failure | Retry with rephrased command |
| TIMEOUT | Command timeout | Suggest checking status |

## Files Reference

- Protocol spec: `docs/commands/PROTOCOL-v1.md`
- CLI Bridge: `server/scripts/claude-wrapper.sh`
- Gateway integration: `openclaw/gateway/src/command-executor.ts`

## @see-also

- [Command Protocol v1.0](docs/commands/PROTOCOL-v1.md)
- [OpenClaw Architecture](docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
- [CLI Bridge Script](server/scripts/claude-wrapper.sh)
```

### 2.3 Routing Rule

```json
{
  "pattern": "claude-code.*bridge|claude.*wrapper|command.*protocol",
  "agent": "claude-code-bridge",
  "priority": "high",
  "description": "Claude Code integration via Command Protocol v1.0"
}
```

---

## 3. Command Protocol v1.0 — Судьба

### 3.1 РЕШЕНИЕ: СОХРАНИТЬ ✅

**Статус реализации:**
- ✅ Спецификация: `docs/commands/PROTOCOL-v1.md` (413 строк)
- ✅ CLI Bridge: `server/scripts/claude-wrapper.sh` (294 строки)
- ✅ Gateway integration: `openclaw/gateway/src/command-executor.ts`
- ✅ Тестирование: 4/4 tests passed (ainetic.tech validation)

**Почему СХРАНИТЬ:**

1. **Правильная архитектура:** JSON protocol = clean separation
2. **Уже работает:** 100% тестов пройдено
3. **Масштабируется:** Версионирование с начала (v1.0)
4. **Безопасность:** Валидация на слое bridge

**Почему НЕ ИЗМЕНЯТЬ:**
- JSON format корректен
- Error handling проработан
- Transport layer абстрагирован
- Консенсус 13 экспертов = 8.8/10

### 3.2 Roadmap Expansion

**Phase 1 (MVP) — Текущий статус:**
```yaml
commands:
  - create_project ✅
  - status ✅
  - help ✅
```

**Phase 2 (Enhanced) — Следующие шаги:**
```yaml
commands:
  - create_project ✅
  - status ✅
  - help ✅
  - deploy ⏳
  - logs ⏳
  - test ⏳

features:
  - Session persistence
  - Progress indicators
  - Multi-command workflows
```

**Phase 3 (Production):**
```yaml
commands:
  - All Phase 2 commands
  - agents (manage AI agents)
  - projects (list/switch)
  - config (project settings)

features:
  - Multi-user support
  - Rate limiting
  - RBAC
```

---

## 4. CLI Bridge (claude-wrapper.sh) — Судьба

### 4.1 РЕШЕНИЕ: НУЖЕН ✅

**Статус реализации:**
- ✅ 294 строки Bash + jq
- ✅ 4/4 unit tests passed
- ✅ Валидация JSON
- ✅ Error handling
- ✅ Logging

**Почему НУЖЕН:**

1. **JSON ↔ CLI трансляция**
   - Gateway говорит JSON
   - Claude Code понимает CLI
   - Bridge = translator

2. **Безопасность**
   ```bash
   # Path traversal protection
   if [[ "$name" == *".."* ]]; then
     error_response "$id" "INVALID_PARAMS" "Path traversal detected"
     return 1
   fi
   ```

3. **Docker интеграция**
   ```bash
   docker exec "$CLAUDE_CODE_CONTAINER" \
     claude code new "$name" \
     --archetype "$archetype"
   ```

4. **Error handling + retry**
   - Parse exit codes
   - Capture stderr
   - Format JSON responses

### 4.2 Архитектура Bridge

```
┌─────────────────────────────────────────────────────────┐
│                  CLI Bridge Flow                        │
└─────────────────────────────────────────────────────────┘

1. Input (JSON from Gateway):
   {"command": "create_project", "params": {...}}

2. Validation:
   ✓ JSON syntax
   ✓ Protocol version
   ✓ Command name
   ✓ Parameters

3. Transformation:
   JSON → CLI arguments
   {"name": "my-app"} → --name my-app

4. Execution:
   docker exec claude-code-runner claude code ...

5. Response Parsing:
   CLI output → JSON response

6. Output (JSON to Gateway):
   {"status": "success", "result": {...}}
```

---

## 5. Примеры запросов "продолжить работу с проектом"

### 5.1 Создание проекта

```
User: /new my-app web-service

OpenClaw [Intent: create_project]:
  → claude-code-bridge.generateCommand({
      command: "create_project",
      params: { name: "my-app", archetype: "web-service" }
    })

Bridge [Generates JSON]:
  {
    "version": "1.0",
    "command": "create_project",
    "params": {"name": "my-app", "archetype": "web-service"}
  }

claude-wrapper.sh [Executes]:
  $ docker exec claude-code-runner \
      claude code new my-app --archetype web-service

Claude Code [Responds]:
  ✅ Created 25 files

Bridge [Formats]:
  {
    "status": "success",
    "result": {"files_created": 25, "project_path": "/workspace/my-app"},
    "message": "✅ Проект my-app создан! 📁 Файлов: 25"
  }

OpenClaw → User:
  ✅ Проект my-app создан!
  📁 Файлов: 25
  📦 Archetype: web-service
  📝 Next: /status my-app
```

### 5.2 Продолжение работы

```
User: Добавь кнопку в форму

OpenClaw [Intent: modify_project + context]:
  → claude-code-bridge.generateCommand({
      command: "create_component",
      params: {
        project: "my-app",
        component: "Button",
        context: "form"
      }
    })

Bridge [Generates JSON]:
  {
    "version": "1.0",
    "command": "create_component",
    "params": {"project": "my-app", "component": "Button"}
  }

claude-wrapper.sh [Executes]:
  $ docker exec claude-code-runner \
      claude code create component Button \
      --project /workspace/my-app

Claude Code [Responds]:
  ✅ Created Button.tsx, Button.test.tsx

Bridge [Formats]:
  {
    "status": "success",
    "result": {"files": ["Button.tsx", "Button.test.tsx"]},
    "message": "✅ Компонент Button добавлен"
  }

OpenClaw → User:
  ✅ Компонент Button добавлен
  📁 Button.tsx
  📁 Button.test.tsx
  📝 Next: /test my-app
```

### 5.3 Статус проекта

```
User: Какой статус?

OpenClaw [Intent: get_status]:
  → claude-code-bridge.generateCommand({
      command: "status",
      params: {}
    })

Bridge [Executes]:
  $ docker exec claude-code-runner \
      claude code status --output json

Claude Code [Responds]:
  {
    "projects": ["my-app", "another-app"],
    "active": "my-app"
  }

OpenClaw → User:
  📊 Статус системы:
  ✅ Проектов: 2
  📁 Активный: my-app
  💾 Memory: 45%
```

---

## 6. Архитектурная диаграмма

```
┌─────────────────────────────────────────────────────────────────┐
│                    OpenClaw Orchestrator v2.0                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Telegram   │────▶│  OpenClaw    │────▶│  Intent     │
│   User      │     │  Gateway     │     │  Classifier │
└─────────────┘     └──────────────┘     └─────────────┘
                          │
                    gemini-3-flash
                 (Ollama Cloud API)
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
      ┌─────────────┐         ┌─────────────┐
      │  Chat Mode  │         │ Command Mode│
      │             │         │             │
      │  Free-form  │         │  claude-    │
      │  conversation       │  code-bridge │
      │             │         │  (subagent) │
      └─────────────┘         └─────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │  Command        │
                            │  Protocol v1.0  │
                            │  (JSON)         │
                            └─────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │  CLI Bridge     │
                            │  (claude-       │
                            │   wrapper.sh)   │
                            └─────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │  Claude Code    │
                            │  CLI (glm-4.7)  │
                            └─────────────────┘
                                      │
                                      ▼
                            ┌─────────────────┐
                            │  Generated      │
                            │  Code/Actions   │
                            └─────────────────┘
```

---

## 7. План реализации

### 7.1 P0 (Критично) — 4-6 часов

| # | Задача | Время | Результат |
|---|--------|-------|-----------|
| 1 | Создать `.claude/agents/claude-code-bridge.md` | 1h | Субагент готов |
| 2 | Добавить routing rule | 30m | Auto-routing работает |
| 3 | Обновить `.claude/AGENTS.md` | 15m | Агент зарегистрирован |
| 4 | Исправить ORCH-007.5 (Intent Pre-Classifier) | 2-4h | AI intent recognition |
| 5 | Создать schema для claude-code-bridge | 30m | Валидация включена |

### 7.2 P1 (Важно) — 1-2 дня

| # | Задача | Время | Результат |
|---|--------|-------|-----------|
| 6 | Enhanced commands (deploy, logs, test) | 1 день | 10+ команд |
| 7 | Session persistence | 1 день | Redis/File storage |
| 8 | Progress indicators | 1 день | UX улучшен |
| 9 | Quick start documentation | 2h | Быстрый старт |

### 7.3 P2 (Желательно)

| # | Задача | Время | Результат |
|---|--------|-------|-----------|
| 10 | Multi-command workflows | 2-3 дня | Сложные сценарии |
| 11 | Error recovery automation | 1 день | Retry logic |
| 12 | Monitoring integration | 2 дня | Prometheus metrics |

---

## 8. Критические решения

### 8.1 Command Protocol v1.0

**РЕШЕНИЕ:** ✅ СОХРАНИТЬ

**Обоснование:**
- 100% тестов пройдено
- Консенсус 13 экспертов (8.8/10)
- Правильная архитектура
- Версионирование с начала

### 8.2 CLI Bridge (claude-wrapper.sh)

**РЕШЕНИЕ:** ✅ НУЖЕН

**Обоснование:**
- JSON ↔ CLI трансляция
- Безопасность (валидация)
- Docker интеграция
- Error handling

### 8.3 Intent Detection

**РЕШЕНИЕ:** ✅ AI Intent Classifier (Вариант D)

**Обоснование:**
- Сохраняет AI-first архитектуру
- Оптимизация (1 AI call)
- Масштабируется
- Естественный язык

---

## 9. Риски и митигация

### 9.1 Risk: Multi-turn dialogue complexity

**Митигация:**
- Command Protocol v1.0 = stateless
- Session context в OpenClaw
- Bridge = simple translation

### 9.2 Risk: Claude Code unavailable

**Митигация:**
- Health checks перед вызовом
- Fallback: SSH → прямой Claude Code
- User notification: "Claude Code занят, повторите"

### 9.3 Risk: Parameter validation errors

**Митигация:**
- Двойная валидация (Gateway + Bridge)
- Clear error messages
- Examples в error responses

---

## 10. Success Metrics

### 10.1 Technical

| Метрика | Цель | Как измерить |
|---------|------|--------------|
| Command success rate | >95% | Логи bridge |
| Response time | <30s | Тайминг |
| Error recovery | >90% | Retry success |

### 10.2 User Experience

| Метрика | Цель | Как измерить |
|---------|------|--------------|
| Intent detection accuracy | >90% | A/B testing |
| Task completion rate | >85% | User feedback |
| Session continuity | >80% | Return users |

---

## 11. Заключение

**Ключевые выводы:**

1. **Command Protocol v1.0** — СОХРАНИТЬ (правильная архитектура)
2. **CLI Bridge** — НУЖЕН (JSON ↔ CLI трансляция)
3. **claude-code-bridge** — СОЗДАТЬ субагента для оркестрации
4. **Intent Detection** — AI-powered (Вариант D)

**Время до production-ready:** 1-2 дня после fix ORCH-007.5

**Следующие шаги:**
1. Создать `.claude/agents/claude-code-bridge.md`
2. Добавить routing rule
3. Исправить ORCH-007.5
4. Расширить команды Phase 2

---

**Версия:** 1.0
**Статус:** PENDING REVIEW
**Автор:** integration-analyst (Agent Team)
**Дата:** 2026-02-11

---

## Связанные документы

- [Command Protocol v1.0](../commands/PROTOCOL-v1.md)
- [OpenClaw Orchestrator Architecture](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
- [Expert Consilium Report](./2026-02-11-openclaw-expert-consilium-report.md)
- [AGENT-CREATION-GUIDE](../agents/AGENT-CREATION-GUIDE.md)
