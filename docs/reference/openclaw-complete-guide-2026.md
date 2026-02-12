# 📚 OpenClaw: Полное Руководство 2026

> [🏠 Главная](../../README.md) → [📋 Docs](../INDEX.md) → [📚 Reference](INDEX.md) → **OpenClaw Guide**

> **Дата обновления:** 2026-02-12
> **Источники:** Официальная документация, сообщество, GitHub
> **Версия OpenClaw:** 2.0+

---

## 🔗 Quick Links

| Документ | Описание |
|----------|----------|
| [Quickstart (Telegram)](openclaw-quickstart-telegram.md) | Быстрый старт за 5 минут |
| [Architecture](OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md) | Архитектура OpenClaw v2.0.1 |
| [System Reference](openclaw-ollama-gemini-telegram-system.md) | Технический справочник |

---

## 🎯 Что такое OpenClaw?

**OpenClaw** (ранее Clawdbot/Moltbot) — это **персональный AI-агент**, который работает на вашем устройстве и может **выполнять реальные действия**, а не просто вести беседу.

### Ключевое отличие от ChatGPT

| ChatGPT | OpenClaw |
|---------|----------|
| Только разговаривает | **Выполняет действия** |
| Даёт советы | **Делает работу за вас** |
| Данные в облаке | **Данные на вашем устройстве** |
| Пассивный | **Проактивный (Heartbeat)** |

**Пример:**
- ChatGPT: *"Вот как организовать файлы..."*
- OpenClaw: **организует файлы за вас**

---

## 📊 Архитектура OpenClaw

```
┌─────────────────────────────────────────────────────────────┐
│                    OPENCLAW ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Layer 1: CORE TOOLS (8) — Базовые возможности             │
│  ├── read, write, edit, apply_patch  (файлы)               │
│  ├── exec, process                    (команды)             │
│  └── web_search, web_fetch            (интернет)            │
│                                                             │
│  Layer 2: ADVANCED TOOLS (17) — Расширенные возможности    │
│  ├── browser, canvas, image           (браузер/визуал)      │
│  ├── memory_search, memory_get        (память)              │
│  ├── sessions_* (5 tools)             (мульти-сессии)       │
│  ├── message                          (мессенджеры)         │
│  ├── cron, gateway                    (автоматизация)       │
│  └── nodes, agents_list               (устройства/агенты)   │
│                                                             │
│  Layer 3: SKILLS (53+ official, 3000+ ClawHub)             │
│  ├── Notes: obsidian, notion, apple-notes                  │
│  ├── Productivity: gog (Google), github, tmux              │
│  ├── Communication: slack, discord, whatsapp               │
│  └── System: healthcheck, summarize, weather               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Быстрый старт

### Требования

| Требование | Версия |
|------------|--------|
| Node.js | 22+ |
| ОС | macOS, Linux, Windows (WSL) |
| API Key | Claude или GPT |

### Установка (официальный способ)

```bash
# macOS/Linux
curl -fsSL https://openclaw.ai/install.sh | bash

# Windows (PowerShell)
iwr -useb https://openclaw.ai/install.ps1 | iex
```

### Onboarding

```bash
# Запуск мастера настройки
openclaw onboard --install-daemon

# Проверка статуса
openclaw gateway status

# Открыть Control UI
openclaw dashboard
```

---

## 📱 Подключение Telegram

### Шаг 1: Создать бота

1. Откройте [@BotFather](https://t.me/BotFather) в Telegram
2. Отправьте `/newbot`
3. Следуйте инструкциям
4. Сохраните **BOT_TOKEN**

### Шаг 2: Настройка OpenClaw

```bash
# Создать конфигурацию
openclaw configure

# Добавить Telegram
# В .env или конфиге:
TELEGRAM_BOT_TOKEN=your_bot_token_here
```

### Шаг 3: Запуск

```bash
# Запустить с Telegram
openclaw start --channel telegram
```

### Доступные команды

| Команда | Описание |
|---------|----------|
| `/start` | Начать работу |
| `/help` | Справка |
| `/status` | Статус системы |
| `/new <name>` | Создать проект |

---

## 🛠 Tools: Полный Справочник

### Layer 1: Core Tools (обязательные)

| Tool | Функция | Риск | Рекомендация |
|------|---------|------|--------------|
| `read` | Читать файлы | Low | ✅ Всегда включать |
| `write` | Писать файлы | Medium | ✅ Включить |
| `edit` | Редактировать файлы | Medium | ✅ Включить |
| `apply_patch` | Применять патчи | Medium | ✅ Включить |
| `exec` | Выполнять команды | **Very High** | ⚠️ С approval! |
| `process` | Управлять процессами | Medium | ✅ Включить |
| `web_search` | Искать в интернете | Low | ✅ Включить |
| `web_fetch` | Загружать страницы | Medium | ✅ Включить |

### Layer 2: Advanced Tools (по необходимости)

| Tool | Функция | Риск | Use Case |
|------|---------|------|----------|
| `browser` | Управлять браузером | High | Автоматизация веб |
| `memory_*` | Помнить контекст | Medium | Персонализация |
| `sessions_*` | Мульти-сессии | Medium | Параллельные задачи |
| `message` | Отправлять сообщения | **Very High** | Уведомления |
| `cron` | Планировщик | High | Автоматизация |
| `nodes` | Управлять устройствами | **Very High** | IoT |

### Рекомендуемая конфигурация

```json
{
  "tools": {
    "allow": [
      "read", "write", "edit", "apply_patch",
      "exec", "process",
      "web_search", "web_fetch",
      "browser", "image",
      "memory_search", "memory_get",
      "sessions_list", "sessions_history",
      "message", "cron", "gateway"
    ],
    "deny": ["nodes"]
  },
  "approvals": {
    "exec": { "enabled": true }
  }
}
```

---

## 📖 Skills: Как создавать

### Что такое Skill?

**Skill = SKILL.md файл с инструкциями**

Skills — это "учебники" для AI. Они учат его **как** выполнять задачи.

### Структура Skill

```
my-skill/
├── SKILL.md          # Обязательно: инструкции
├── scripts/          # Опционально: скрипты
├── templates/        # Опционально: шаблоны
└── resources/        # Опционально: ресурсы
```

### Шаблон SKILL.md

```markdown
---
name: my-skill-name
description: Чёткое описание того, что делает skill.
---

# My Skill Name

Детальное описание назначения skill.

## Когда использовать

- Случай 1
- Случай 2

## Инструкции

1. Шаг 1
2. Шаг 2
3. Шаг 3

## Примеры

### Пример 1: Название

Запрос: "..."
Ожидаемый результат: "..."

## Ограничения

- Ограничение 1
- Ограничение 2
```

### Пример: Skill для создания проектов

```markdown
---
name: project-creator
description: Создаёт новые проекты из шаблонов CodeFoundry
---

# Project Creator

Создаёт новые проекты с выбранной архитектурой.

## Доступные архетипы

| Архетип | Описание |
|---------|----------|
| web-service | REST/GraphQL API |
| ai-agent | AI assistant с RAG |
| telegram-bot | aiogram, FSM |
| cli-tool | Go/Rust/Python CLI |

## Инструкции

1. Спросить пользователя о названии проекта
2. Предложить выбор архетипа
3. Создать директорию проекта
4. Скопировать шаблон
5. Настроить конфигурацию
6. Инициализировать git

## Пример

Запрос: "Создай проект my-api типа web-service"
Действие:
- mkdir /workspace/projects/my-api
- cp -r templates/archetypes/web-service/* .
- Настройка package.json
```

### Установка Skills

```bash
# Создать директорию
mkdir -p ~/.claude/skills/

# Скопировать skill
cp -r my-skill ~/.claude/skills/

# Проверить
head ~/.claude/skills/my-skill/SKILL.md
```

### ClawHub (3000+ skills)

```bash
# Поиск skills
openclaw skills search <keyword>

# Установка
openclaw skills install <skill-name>
```

---

## 🔧 Конфигурация

### Структура конфига

```json
{
  "ai": {
    "provider": "anthropic",
    "model": "claude-sonnet-4-5-20250929",
    "apiKey": "${ANTHROPIC_API_KEY}"
  },

  "tools": {
    "allow": ["read", "write", "exec", "web_search"],
    "deny": ["nodes"]
  },

  "approvals": {
    "exec": { "enabled": true }
  },

  "skills": {
    "allowBundled": [
      "gog", "github", "tmux",
      "weather", "summarize"
    ]
  },

  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN}"
    }
  },

  "heartbeat": {
    "enabled": true,
    "interval": "5m"
  },

  "memory": {
    "enabled": true,
    "maxContextLength": 50000
  }
}
```

---

## 🤖 Автоматизация

### Daily Brief (каждое утро)

```json
{
  "cron": {
    "tasks": [
      {
        "schedule": "47 6 * * *",
        "prompt": "Prepare daily brief: calendar, pending emails, weather, CI/CD status",
        "deliverTo": "telegram"
      }
    ]
  }
}
```

### Email Triage (2 раза в день)

```json
{
  "cron": {
    "tasks": [
      {
        "schedule": "0 9,18 * * *",
        "prompt": "Scan inbox, categorize by urgency, archive newsletters",
        "deliverTo": "telegram"
      }
    ]
  }
}
```

### CI/CD Monitoring

```json
{
  "heartbeat": {
    "enabled": true,
    "monitors": [
      {
        "type": "github_actions",
        "onFailure": "notify"
      }
    ]
  }
}
```

---

## 🔐 Безопасность

### Критические правила

| Правило | Почему |
|---------|--------|
| ✅ Включить `approval` для `exec` | Контроль команд |
| ✅ `message` только себе | Не отправлять от вашего имени |
| ❌ Не включать `nodes` без нужды | Камера, GPS, скриншоты |
| ⚠️ `1password` — только отдельный vault | Доступ ко всем паролям |

### Sandbox Mode

```bash
# Безопасный режим для тестирования
openclaw start --sandbox
```

---

## 📚 Ресурсы

### Официальные

| Ресурс | URL |
|--------|-----|
| Документация | https://docs.openclaw.ai |
| GitHub | https://github.com/openclaw/openclaw |
| ClawHub | https://clawhub.ai |

### Сообщество

| Ресурс | Описание |
|--------|----------|
| [Awesome Agent Skills](https://github.com/heilcheng/awesome-agent-skills) | 3000+ skills |
| [Yu WenHao Guide](https://yu-wenhao.com/en/blog/openclaw-tools-skills-tutorial) | 25 Tools + 53 Skills |
| [APIYI Guide](https://help.apiyi.com/en/openclaw-beginner-guide-en.html) | Beginner tutorial |

---

## 🆘 Troubleshooting

### Бот не отвечает

```bash
# 1. Проверить статус
openclaw gateway status

# 2. Проверить логи
openclaw logs --tail 50

# 3. Перезапустить
openclaw gateway restart
```

### Skill не загружается

```bash
# Проверить структуру
ls ~/.claude/skills/my-skill/SKILL.md

# Проверить синтаксис
head -20 ~/.claude/skills/my-skill/SKILL.md
```

### Ошибки API

```bash
# Проверить API key
openclaw doctor

# Тестовый запрос
openclaw message send --target self --message "Test"
```

---

**Источники:**
- [OpenClaw Official Docs](https://docs.openclaw.ai)
- [Awesome Agent Skills](https://github.com/heilcheng/awesome-agent-skills)
- [Yu WenHao Blog](https://yu-wenhao.com/en/blog/openclaw-tools-skills-tutorial)
- [APIYI Guide](https://help.apiyi.com/en/openclaw-beginner-guide-en.html)
- [YouTube Tutorial](https://www.youtube.com/watch?v=Zo7Putdga_4)

---

*Обновлено: 2026-02-12*