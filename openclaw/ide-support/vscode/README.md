# 📦 VS Code + Cline Support

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../../README.md) → [🎨 IDE Support](../README.md) → [📦 VS Code](#)

---

## Description

Интеграция OpenClaw с VS Code через расширение Cline — автономный AI ассистент для Visual Studio Code.

---

## 🎯 Почему VS Code + Cline?

**Преимущества:**
- ✅ **VS Code Native** — работает внутри привычного IDE
- ✅ **Open Source** — полностью открытый код
- ✅ **Multiple LLMs** — поддержка разных моделей (Claude, GPT-4, Local)
- ✅ **.clinerules** — автоматическая загрузка промптов
- ✅ **Auto-commit** — автоматические коммиты
- ✅ **MCP Support** — Model Context Protocol

---

## 📦 Установка

### 1. Установка VS Code

```bash
# macOS
brew install --cask visual-studio-code

# Linux
# Скачать с https://code.visualstudio.com/

# Windows
# Скачать с https://code.visualstudio.com/
```

### 2. Установка Cline

```
1. Откройте VS Code
2. Перейдите в Extensions (Cmd+Shift+X)
3. Найдите "Cline" (автор: All Hands AI)
4. Нажмите Install
```

### 3. Настройка OpenClaw

```bash
# В корне проекта
cat > .clinerules << 'EOF'
# 🦞 OpenClaw System Prompt

> Загружается из: /opt/openclaw/workspace/SYSTEM.md

**Это автоматическая копия. Источник: openclaw/workspace/**

Для изменений редактируйте: /opt/openclaw/workspace/SYSTEM.md
EOF

# Синхронизация промптов
/opt/openclaw/scripts/sync-ide-rules.sh
```

### 4. Конфигурация API Key

```
1. Откройте VS Code Settings (Cmd+,)
2. Найдите "Cline: API Key"
3. Введите ваш Anthropic API key
   или OpenRouter API key для нескольких моделей
```

---

## 🔄 Как Это Работает

```
┌─────────────────────────────────────────────────────┐
│                   .clinerules                        │
│  (автоматически загружается Cline)                   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                Cline Extension                       │
│  • Парсит .clinerules                               │
│  • Индексирует проект                               │
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

### 1. Sidebar Chat

```
1. Откройте Cline sidebar (иконка справа)
2. Введите запрос

👤 "Создай React компонент для карточки товара"

🤖 Cline (with OpenClaw):
    [Code Generator Agent activated]
    📦 Generating component...

    ✅ Created: src/components/ProductCard.tsx
    ✅ Created: src/components/ProductCard.css

    Хотите внести изменения?
```

### 2. Inline Mode

```
1. Выделите код
2. Нажмите Ctrl+Shift+X
3. Введите инструкцию: "Рефактори используя хуки"

🤖 Cline:
    [Refactoring...]

    // До:
    class ProductCard extends Component {
      render() { ... }
    }

    // После:
    function ProductCard() { ... }

    ✅ Refactored to functional component
```

### 3. Auto-Commit Mode

```
# После каждого изменения Cline предложит коммит

🤖 Cline:
    Changes made:
    M src/components/ProductCard.tsx

    Commit message:
    feat: add product card component

    Do you want to commit? [Y/n]
```

---

## 🔧 Конфигурация

### .clinerules

```markdown
# 🦞 OpenClaw System Prompt

## Role
Ты AI ассистент с агentic архитектурой OpenClaw.

## Agents
- Main Agent (управление)
- Development Agent (разработка)
- DevOps Agent (деплой)
- Prompt Engineer (промпты)
- Code Generator (генерация)
- Debugger (отладка)

## Skills
@ref: /opt/openclaw/workspace/SKILLS-INDEX.md

## Workflow
1. Анализируй запрос
2. Route к агенту
3. Используй skill
4. Выполни задачу
5. Предложи коммит
```

### VS Code Settings (settings.json)

```json
{
  "cline.enabled": true,
  "cline.apiProvider": "anthropic",
  "cline.modelId": "claude-opus-4-5-20251101",
  "cline.temperature": 0.7,
  "cline.autoCommit": true,
  "cline.autoFormat": true,
  "cline.mcpEnabled": true,
  "cline.contextTokens": 8000
}
```

---

## 📝 Usage Examples

### Генерация Кода

```
👤 "Создай Express API для управления пользователями"

🤖 Cline (with OpenClaw):
    [Development Agent activated]
    📦 Using skill: code-generator

    Generating CRUD API:

    ✅ Created: models/User.ts
    ✅ Created: routes/users.ts
    ✅ Created: controllers/userController.ts
    ✅ Created: services/userService.ts
    ✅ Created: middleware/validate.ts

    📦 Routes:
    GET    /api/users       - List all users
    GET    /api/users/:id   - Get user by ID
    POST   /api/users       - Create user
    PUT    /api/users/:id   - Update user
    DELETE /api/users/:id   - Delete user

    ✅ API ready
```

### Debugging

```
👤 "Найди почему не работает авторизация"

🤖 Cline:
    [Debugger Agent activated]

    📊 Analysing auth flow...

    🔍 Found issue in src/auth/login.ts:45

    Problem: JWT secret not loaded from environment

    // Текущий код:
    const token = jwt.sign(payload, 'secret'); // ❌ Hardcoded

    // Исправление:
    const token = jwt.sign(payload, process.env.JWT_SECRET); // ✅

    ✅ Fix applied

    📝 Don't forget to add JWT_SECRET to .env
```

### Code Review

```
👤 "Проверь изменения в PR"

🤖 Cline:
    [Code Review skill activated]

    📊 Reviewing changes...

    📁 auth/login.ts: ⚠️ Issues found
       - Line 23: Missing rate limiting
       - Line 31: No error handling for invalid credentials

    📁 models/user.ts: ✅ Good
       - Proper TypeScript types
       - Clean structure

    📁 routes/auth.ts: ⚠️ Issues
       - Missing input validation

    💬 Recommendations:
       1. Add express-rate-limit middleware
       2. Add try/catch around async operations
       3. Add input validation middleware

    📝 Estimated fixes: 15 minutes
```

---

## 🎯 Keyboard Shortcuts

| Клавиша | Действие |
|---------|----------|
| `Ctrl+Shift+X` | Открыть Cline (inline) |
| `Ctrl+Shift+A` | Открыть Cline sidebar |
| `Ctrl+Enter` | Отправить сообщение |
| `Ctrl+K` | Коммит через Cline |
| `Esc` | Закрыть панель |

---

## 🔗 MCP (Model Context Protocol)

### Подключение внешних инструментов

```json
// .mcp.json
{
  "tools": [
    {
      "name": "database",
      "type": "postgres",
      "connection": "postgresql://localhost:5432/mydb"
    },
    {
      "name": "filesystem",
      "type": "local",
      "path": "./src"
    }
  ]
}
```

```
👤 "Проверь структуру таблицы users в БД"

🤖 Cline:
    [Using MCP: database]

    📊 Table: users

    | Column | Type | Nullable |
    |--------|------|----------|
    | id | uuid | NO |
    | email | varchar | NO |
    | name | varchar | YES |
    | created_at | timestamp | NO |

    ✅ Structure retrieved
```

---

## 🛡️ Безопасность

### Permissions

Cline имеет **доступ только к проекту**:
- ✅ Чтение файлов в проекте
- ✅ Запись в файлы проекта
- ✅ Git операции
- ❌ **Нет** доступа к системе

### Рекомендации

```yaml
Безопасно:
  - Изолированные проекты
  - Персональная разработка

С осторожностью:
  - Проекты с API keys
  - Командные репозитории

Рекомендуется:
  - .env в .gitignore
  - Не коммитить секреты
```

---

## 🔗 Интеграция с OpenClaw VDS

### Синхронизация Промптов

```bash
# На VDS
cd /opt/openclaw
git pull origin main

# Локально
cd /path/to/project
/opt/openclaw/scripts/sync-ide-rules.sh

# .clinerules обновлён из workspace/
```

---

## 📊 Сравнение

| Характеристика | VS Code + Cline | Cursor | Claude Code |
|----------------|-----------------|--------|-------------|
| IDE | VS Code | Форк VS Code | CLI |
| Open Source | ✅ | ❌ | ❌ |
| LLM Choice | ✅ Любой | Claude | Claude |
| Extensions | ✅ Все | Большинство | N/A |
| MCP Support | ✅ | ❌ | ❌ |
| Voice | ❌ | ❌ | ✅ |

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

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../../README.md) → [🎨 IDE Support](../README.md) → [📦 VS Code](#)
