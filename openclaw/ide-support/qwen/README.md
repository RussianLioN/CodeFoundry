# 🐉 QWEN Code Support

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../../README.md) → [🎨 IDE Support](../README.md) → [🐉 QWEN](#)

---

## Description

Интеграция OpenClaw с QWEN Code CLI — AI ассистент от Alibaba для терминала.

---

## 🎯 Почему QWEN Code?

**Преимущества:**
- ✅ **Open Source** — бесплатный и открытый код
- ✅ **CLI Mode** — работа через терминал
- ✅ **QWEN.md** — автоматическая загрузка промптов
- ✅ **Fast** — быстрая генерация кода
- ✅ **Multi-language** — поддержка многих языков
- ✅ **Local LLM Support** — можно запускать локально

---

## 📦 Установка

### 1. Установка QWEN Code CLI

```bash
# Через npm
npm install -g @qwen/cli

# Или через pip
pip install qwen-cli

# Проверка установки
qwen --version
```

### 2. Настройка OpenClaw

```bash
# В корне проекта
cat > QWEN.md << 'EOF'
# 🦞 OpenClaw System Prompt

> Загружается из: /opt/openclaw/workspace/SYSTEM.md

**Это автоматическая копия. Источник: openclaw/workspace/**

Для изменений редактируйте: /opt/openclaw/workspace/SYSTEM.md
EOF

# Синхронизация промптов
/opt/openclaw/scripts/sync-ide-rules.sh
```

### 3. Запуск

```bash
# В корне проекта
qwen

# Или с конкретным файлом
qwen src/app.ts

# Interactive mode
qwen --interactive
```

---

## 🔄 Как Это Работает

```
┌─────────────────────────────────────────────────────┐
│                     QWEN.md                          │
│  (автоматически загружается при старте)              │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                 QWEN Code CLI                        │
│  • Загружает QWEN.md                                │
│  • Парсит системные инструкции                      │
│  • Инициализирует агентов OpenClaw                  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│               OpenClaw Agents                        │
│  Main → Dev → DevOps → Prompt → CodeGen → Debugger  │
└─────────────────────────────────────────────────────┘
```

---

## 🎨 Режимы Работы

### 1. Interactive Mode

```bash
qwen

🤖 QWEN: Готов! OpenClaw загружен.
👤 Вы: Создай функцию для хеширования паролей
🤖 QWEN: [Routing to Development Agent]
   ✅ Created: src/utils/hash.ts
```

### 2. Direct Command

```bash
qwen "напиши тесты для AuthController"

🤖 QWEN: [Analyzing...]
   ✅ Tests created in tests/auth.test.ts
```

### 3. File Mode

```bash
qwen src/services/user.ts

🤖 QWEN: Файл загружен.
👤 Вы: Рефактори используя async/await
🤖 QWEN: [Refactoring...]
   ✅ Refactored
```

---

## 🔧 Конфигурация

### ~/.qwen/config.json

```json
{
  "model": "qwen-max",
  "temperature": 0.7,
  "maxTokens": 4096,
  "systemPrompt": "QWEN.md",
  "language": "ru",
  "autoFormat": true
}
```

### Project-Level .qwenrc.json

```json
{
  "workspace": "/opt/openclaw/workspace",
  "agents": ["main", "dev", "devops", "prompt", "codegen", "debugger"],
  "skills": [
    "git-workflow",
    "testing-strategy",
    "code-review",
    "debugging",
    "docker-deploy",
    "ci-pipeline",
    "monitoring",
    "prompt-engineer",
    "code-generator",
    "debugger"
  ]
}
```

---

## 📝 Usage Examples

### Генерация Кода

```
👤 "Создай FastAPI endpoint для пользователей"

🤖 QWEN (with OpenClaw):
    [Development Agent activated]
    📦 Using skill: code-generator

    ✅ Created: routers/users.py
    ✅ Created: schemas/user.py
    ✅ Created: services/user_service.py

    from fastapi import APIRouter, HTTPException
    from pydantic import BaseModel

    router = APIRouter()

    class UserCreate(BaseModel):
        email: str
        name: str

    @router.post("/users")
    async def create_user(data: UserCreate):
        return {"id": "123", "email": data.email, "name": data.name}
```

### Рефакторинг

```
👤 "Рефактори callback в async/await"

🤖 QWEN:
    [Refactoring...]

    // До:
    function fetchUser(id, callback) {
      db.query('SELECT * FROM users WHERE id = $1', [id], (err, res) => {
        if (err) return callback(err);
        callback(null, res.rows[0]);
      });
    }

    // После:
    async function fetchUser(id: string): Promise<User> {
      const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
      return result.rows[0];
    }

    ✅ Refactored to async/await
```

### Git Operations

```
👤 "Создай коммит"

🤖 QWEN:
    [Git Workflow skill]

    📊 Changes:
    M src/utils/hash.ts
    M src/auth/login.ts

    📝 Commit message:
    feat: add password hashing and authentication

    - Add bcrypt hashing for passwords
    - Implement JWT authentication
    - Add login endpoint

    ✅ Commit created: abc123def
```

---

## 🔗 Voice Commands (через терминал)

```bash
qwen --voice

🎤 Говорите...
🗣️ "Создай компонент для навигации"
🤖 QWEN: [Generating...]
   ✅ Navigation component created
```

---

## 🎯 Keyboard Shortcuts

| Клавиша | Действие |
|---------|----------|
| `Ctrl+C` | Прервать операцию |
| `Ctrl+D` | Завершить сессию |
| `Ctrl+L` | Очистить экран |
| `Tab` | Автодополнение |
| `Ctrl+R` | История команд |

---

## 🛡️ Безопасность

### Permissions

QWEN Code имеет **полный доступ**:
- ✅ Чтение любых файлов
- ✅ Запись в любые директории
- ✅ Выполнение команд

### Рекомендации

```yaml
Безопасно:
  - Локальные проекты
  - Персональная разработка

С осторожностью:
  - Production репозитории
  - Проекты с секретами
```

---

## 🔗 Локальный LLM

```bash
# Запуск QWEN локально
ollama run qwen2.5-coder:14b

# Настройка QWEN CLI
export QWEN_MODEL="ollama:qwen2.5-coder:14b"
qwen
```

---

## 📊 Сравнение

| Характеристика | QWEN | Claude Code | OpenClaw VDS |
|----------------|------|-------------|--------------|
| Open Source | ✅ | ❌ | ✅ |
| CLI Mode | ✅ | ✅ | ❌ |
| Voice | ✅ | ✅ | ✅ Telegram |
| Local LLM | ✅ | ❌ | ⚠️ |
| 24/7 доступ | ❌ | ❌ | ✅ |

---

## 📚 См. Также

- [🎨 IDE Support](../README.md) - Общая документация
- [🤖 Claude Code](../claude/README.md) - Claude Code CLI
- [🖱️ Cursor](../cursor/README.md) - Cursor IDE
- [🦞 OpenClaw Main](../../../README.md) - Главная

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../../README.md) → [🎨 IDE Support](../README.md) → [🐉 QWEN](#)
