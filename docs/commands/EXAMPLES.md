# Command Protocol v1.0 - Examples

> **Примеры команд и ответов для тестирования**
>
> **Версия:** 1.0.0

---

## 📋 Тестовые Запросы

### 1. Help Command

```bash
echo '{
  "version": "1.0",
  "id": "test-001",
  "timestamp": "2025-02-05T12:00:00Z",
  "command": "help",
  "params": {}
}' | ./server/scripts/claude-wrapper.sh
```

**Ожидаемый ответ:**
```json
{
  "version": "1.0",
  "id": "test-001",
  "status": "success",
  "result": {
    "commands": [...]
  },
  "message": "📖 Доступные команды..."
}
```

---

### 2. Status Command

```bash
echo '{
  "version": "1.0",
  "id": "test-002",
  "timestamp": "2025-02-05T12:00:00Z",
  "command": "status",
  "params": {}
}' | ./server/scripts/claude-wrapper.sh
```

**Ожидаемый ответ:**
```json
{
  "version": "1.0",
  "id": "test-002",
  "status": "success",
  "result": {
    "gateway": "healthy",
    "claude_code": "ready",
    "projects": []
  }
}
```

---

### 3. Create Project Command

```bash
echo '{
  "version": "1.0",
  "id": "test-003",
  "timestamp": "2025-02-05T12:00:00Z",
  "command": "create_project",
  "params": {
    "name": "test-app",
    "archetype": "web-service",
    "framework": "nextjs"
  }
}' | ./server/scripts/claude-wrapper.sh
```

**Ожидаемый ответ:**
```json
{
  "version": "1.0",
  "id": "test-003",
  "status": "success",
  "result": {
    "project_name": "test-app",
    "project_path": "/workspace/test-app"
  }
}
```

---

## ❌ Примеры Ошибок

### Invalid Project Name

```bash
echo '{
  "version": "1.0",
  "id": "test-error-001",
  "command": "create_project",
  "params": {
    "name": "../malicious"
  }
}' | ./server/scripts/claude-wrapper.sh
```

**Ожидаемый ответ:**
```json
{
  "status": "error",
  "error": {
    "code": "INVALID_PARAMS",
    "message": "Path traversal detected"
  }
}
```

---

### Unknown Command

```bash
echo '{
  "version": "1.0",
  "id": "test-error-002",
  "command": "unknown_command"
}' | ./server/scripts/claude-wrapper.sh
```

**Ожидаемый ответ:**
```json
{
  "status": "error",
  "error": {
    "code": "UNKNOWN_COMMAND",
    "message": "Unknown command: unknown_command"
  }
}
```

---

## 🧪 Быстрый Тест

```bash
# One-liner для тестирования всех команд
./server/scripts/test-commands.sh
```
