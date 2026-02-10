# CodeFoundry CLI Commands Index

> **Slash Commands** для Claude Code с AI-First интерфейсом

---

## 📋 Overview

CodeFoundry предоставляет набор slash-команд для управления проектами, генерации агентов и деплоя через естественный язык.

**Использование:**
- В Claude Code: `/cf-new`, `/cf-agents`, `/cf-deploy`
- Через Gateway: "Создай проект telegram-bot", "Задеплой в production"

---

## 🚀 Commands

### `/cf-new` — Create New Project

**Создаёт новый IT проект из архетипа.**

```
/cf-new [project-type] [project-name] [options]
```

**Примеры:**
```
/cf-new telegram-bot my-bot
/cf-new web-service shop-api --language=typescript
"Create a telegram bot for food delivery"
```

**Документация:** [cf-new.md](./cf-new.md)

---

### `/cf-agents` — Generate AI Agents

**Генерирует специализированные AI-агенты для проекта.**

```
/cf-agents [project-name] [options]
```

**Примеры:**
```
/cf-agents my-bot --all
/cf-agents my-bot --agents=coordinator,reviewer
"Generate agents for my-delivery-bot"
```

**Документация:** [cf-agents.md](./cf-agents.md)

---

### `/cf-deploy` — Deploy Project

**Деплоит проект в окружение с проверками и rollback.**

```
/cf-deploy [project-name] [environment] [options]
```

**Примеры:**
```
/cf-deploy my-bot staging
/cf-deploy my-bot production --require-approval
"Deploy my-delivery-bot to production"
```

**Документация:** [cf-deploy.md](./cf-deploy.md)

---

### `/cf-optimize` — Audit Token Usage

**Аудит и оптимизация файлов инструкций по расходу токенов.**

```
/cf-optimize [mode] [options]
```

**Примеры:**
```
/cf-optimize
/cf-optimize --quick
/cf-optimize --file instructions/git-operations.md
"Сколько токенов тратят инструкции?"
```

**Документация:** [cf-optimize.md](./cf-optimize.md)

---

## 🤖 AI Agents Reference

### Available Agents

| Agent | Description | Use Case |
|-------|-------------|----------|
| **Coordinator** | Оркестрация агентов | Multi-agent workflows |
| **Code Assistant** | Написание кода | Implementation |
| **Reviewer** | Code review | Quality assurance |
| **Tester** | Генерация тестов | Test coverage |
| **Documentation** | Документация | API docs, README |
| **Debugger** | Отладка | Bug fixing |
| **Security** | Безопасность | Security analysis |
| **Performance** | Оптимизация | Performance tuning |

**Документация:** [../AGENTS.md](../AGENTS.md)

---

## 🔄 Auto-Routing

Команды автоматически маршрутизируются к нужным агентам на основе ключевых слов:

```javascript
"Write a new endpoint"      → Code Assistant
"Review this code"          → Reviewer
"Generate tests for User"   → Tester
"Debug authentication"      → Debugger
"Check for vulnerabilities" → Security
```

**Конфигурация:** [auto-routing-rules.json](../auto-routing-rules.json)

---

## ⚙️ Configuration

Настройки в `.claude/settings.json`:

```json
{
  "commands": {
    "cf-new": {
      "defaultLocation": "./workspace/projects",
      "generateAgents": true
    },
    "cf-agents": {
      "recommendedAgents": {
        "telegram-bot": ["coordinator", "code_assistant", "reviewer"]
      }
    },
    "cf-deploy": {
      "defaultEnvironment": "staging",
      "requireApproval": { "production": true }
    }
  }
}
```

---

## 🌐 Integration

### With Claude Code
```
/cf-new telegram-bot my-bot
```

### With Gateway (WebSocket)
```javascript
{
  type: 'chat',
  content: 'Создай проект telegram-bot'
}
```

### Natural Language
```
"Create a telegram bot for food delivery"
"Создай проект web-service для API"
"Deploy my bot to production"
```

---

## 📚 Related Documentation

- **[settings.json](../settings.json)** — Claude Code настройки
- **[auto-routing-rules.json](../auto-routing-rules.json)** — Правила маршрутизации
- **[../AGENTS.md](../AGENTS.md)** — Реестр AI агентов
- **[../../PROJECT.md](../../PROJECT.md)** — Архитектура CodeFoundry
- **[../../README.md](../../README.md)** — Основная документация

---

**Version:** 1.0.0
**Last updated:** 2025-02-02
