# Command Protocol v1.0

> **OpenClaw Orchestrator ↔ Claude Code CLI Bridge**
>
> **Версия:** 1.0.0
> **Дата:** 2025-02-05
> **Статус:** MVP Implementation

---

## 📋 Обзор

Command Protocol — это JSON-протокол связи между OpenClaw Gateway (оркестратор) и Claude Code CLI (разработчик).

```
┌─────────────────┐     JSON Command      ┌─────────────────┐
│  OpenClaw       │ ─────────────────────▶│  CLI Bridge     │
│  Gateway        │                       │  (claude-wrapper)│
│  (gemini-3-flash)│◀─────────────────────│                 │
└─────────────────┘    JSON Response       └─────────────────┘
                                                      │
                                                      ▼
                                              ┌─────────────────┐
                                              │  Claude Code    │
                                              │  (glm-4.7)      │
                                              └─────────────────┘
```

---

## 🔄 Формат Запроса (Request)

### Базовая структура

```json
{
  "version": "1.0",
  "id": "uuid-v4",
  "timestamp": "2025-02-05T12:00:00Z",
  "command": "command_name",
  "params": {
    "key": "value"
  },
  "context": {
    "user_id": "telegram-123456789",
    "session_id": "session-uuid",
    "request_id": "request-uuid"
  }
}
```

### Поля

| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `version` | string | ✅ Да | Версия протокола (всегда "1.0") |
| `id` | string | ✅ Да | Уникальный ID команды (UUID v4) |
| `timestamp` | string | ✅ Да | ISO 8601 timestamp |
| `command` | string | ✅ Да | Имя команды |
| `params` | object | ✅ Да | Параметры команды |
| `context` | object | ❌ Нет | Контекст выполнения |

---

## 📤 Формат Ответа (Response)

### Успешный ответ

```json
{
  "version": "1.0",
  "id": "same-as-request",
  "status": "success",
  "result": {
    "data": "command-specific"
  },
  "message": "User-friendly message",
  "timestamp": "2025-02-05T12:00:05Z"
}
```

### Ошибка

```json
{
  "version": "1.0",
  "id": "same-as-request",
  "status": "error",
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description",
    "details": {}
  },
  "timestamp": "2025-02-05T12:00:05Z"
}
```

### Поля ответа

| Поле | Тип | Обязательное | Описание |
|------|-----|--------------|----------|
| `version` | string | ✅ Да | Версия протокола |
| `id` | string | ✅ Да | ID запроса |
| `status` | string | ✅ Да | "success" или "error" |
| `result` | object | ❌ Нет | Результат (при success) |
| `message` | string | ❌ Нет | Сообщение для пользователя |
| `error` | object | ❌ Нет | Ошибка (при error) |
| `timestamp` | string | ✅ Да | ISO 8601 timestamp |

---

## 🎯 Поддерживаемые Команды (MVP)

### 1. create_project

Создаёт новый проект через Claude Code.

**Запрос:**
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
    "user_id": "telegram-123456789",
    "session_id": "session-abc"
  }
}
```

**Ответ (success):**
```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "success",
  "result": {
    "project_name": "my-app",
    "project_path": "/workspace/my-app",
    "files_created": 25,
    "archetype": "web-service",
    "framework": "nextjs"
  },
  "message": "✅ Проект my-app создан!\n📁 Файлов: 25\n📦 Archetype: web-service\n🔧 Framework: Next.js",
  "timestamp": "2025-02-05T12:00:30Z"
}
```

**Ответ (error):**
```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "error",
  "error": {
    "code": "PROJECT_EXISTS",
    "message": "Проект my-app уже существует",
    "details": {
      "existing_path": "/workspace/my-app"
    }
  },
  "timestamp": "2025-02-05T12:00:05Z"
}
```

---

### 2. status

Получает статус системы.

**Запрос:**
```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "timestamp": "2025-02-05T12:00:00Z",
  "command": "status",
  "params": {},
  "context": {
    "user_id": "telegram-123456789"
  }
}
```

**Ответ:**
```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "status": "success",
  "result": {
    "gateway": "healthy",
    "claude_code": "ready",
    "projects": [
      {
        "name": "my-app",
        "path": "/workspace/my-app",
        "status": "active"
      }
    ],
    "system": {
      "uptime": "2h 15m",
      "memory_usage": "45%",
      "disk_usage": "23%"
    }
  },
  "message": "📊 Статус системы:\n✅ Gateway: healthy\n✅ Claude Code: ready\n📁 Проектов: 1",
  "timestamp": "2025-02-05T12:00:02Z"
}
```

---

### 3. help

Показывает справку.

**Запрос:**
```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "timestamp": "2025-02-05T12:00:00Z",
  "command": "help",
  "params": {},
  "context": {}
}
```

**Ответ:**
```json
{
  "version": "1.0",
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "status": "success",
  "result": {
    "commands": [
      {
        "name": "/new",
        "description": "Создать новый проект",
        "usage": "/new <project-name> [archetype]",
        "example": "/new my-app web-service"
      },
      {
        "name": "/status",
        "description": "Статус системы",
        "usage": "/status",
        "example": "/status"
      },
      {
        "name": "/help",
        "description": "Показать справку",
        "usage": "/help",
        "example": "/help"
      }
    ]
  },
  "message": "📖 Доступные команды:\n\n/new <name> — Создать проект\n/status — Статус системы\n/help — Справка",
  "timestamp": "2025-02-05T12:00:01Z"
}
```

---

## 🔧 Коды Ошибок

| Код | Описание | HTTP Analogue |
|-----|----------|---------------|
| `UNKNOWN_COMMAND` | Неизвестная команда | 404 |
| `INVALID_PARAMS` | Неверные параметры | 400 |
| `PROJECT_EXISTS` | Проект уже существует | 409 |
| `PROJECT_NOT_FOUND` | Проект не найден | 404 |
| `CLAUDE_CODE_ERROR` | Ошибка Claude Code | 500 |
| `TIMEOUT` | Таймаут выполнения | 504 |
| `UNAUTHORIZED` | Неавторизованный доступ | 401 |

---

## 🔐 Безопасность

### Валидация

**Обязательные проверки:**
1. ✅ Валидный JSON
2. ✅ Версия протокола = "1.0"
3. ✅ Наличие обязательных полей
4. ✅ Команда в списке разрешённых
5. ✅ Параметры соответствуют схеме

### Авторизация

**User ID проверка:**
```typescript
const AUTHORIZED_USERS = process.env.AUTHORIZED_USER_IDS.split(',');

if (!AUTHORIZED_USERS.includes(context.user_id)) {
  return {
    status: "error",
    error: { code: "UNAUTHORIZED", message: "Access denied" }
  };
}
```

### Санитизация

**Проверки параметров:**
```typescript
// Имя проекта: только буквы, цифры, дефисы
if (!/^[a-z0-9-]+$/.test(params.name)) {
  throw new Error("Invalid project name");
}

// Длина имени: 1-50 символов
if (params.name.length < 1 || params.name.length > 50) {
  throw new Error("Project name too long");
}

// Path traversal защита
if (params.name.includes('..')) {
  throw new Error("Path traversal detected");
}
```

---

## 📡 Транспорт

### Method 1: CLI Bridge (MVP)

```
Gateway → exec → claude-wrapper.sh → docker exec → Claude Code
```

**Пример:**
```bash
echo '{"command":"status"}' | ./claude-wrapper.sh
```

### Method 2: HTTP API (Future)

```
Gateway → HTTP POST → /api/commands → Claude Code Service
```

---

## 🧪 Тестирование

### Unit Tests

```bash
# Test JSON parsing
echo '{"version":"1.0","command":"help"}' | jq .

# Test CLI Bridge
./scripts/claude-wrapper.sh < test-request.json
```

### Integration Tests

```bash
# Test full flow
curl -X POST http://gateway:18789/command \
  -H "Content-Type: application/json" \
  -d '{"command":"status"}'
```

---

## 📈 Roadmap

### v1.0 (MVP) — Сейчас
- ✅ 3 команды: create_project, status, help
- ✅ CLI Bridge через bash
- ✅ Базовая валидация

### v1.1 (Week 2)
- 🔄 Команды: deploy, logs, test
- 🔄 Session persistence
- 🔄 Progress indicators

### v1.2 (Week 3-4)
- 🔄 File upload/download
- 🔄 Multi-command workflows
- 🔄 Enhanced error handling

### v2.0 (Month 2)
- 🔄 HTTP API
- 🔄 WebSocket streaming
- 🔄 Multi-user support

---

## 📚 Связанные Документы

- [OpenClaw Orchestrator Architecture](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
- [Experts Opinions](../experts-opinions-openclaw-orchestrator.md)
- [Remote Testing Architecture](../remote-testing/ARCHITECTURE.md)

---

**Версия:** 1.0.0
**Статус:** ACTIVE
**Автор:** Claude Code (Session #11)
**Дата:** 2025-02-05
