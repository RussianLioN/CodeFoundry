# ⚙️ Конфигурация OpenClaw

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [⚙️ Конфигурация](#)

---

## Обзор

Полное руководство по конфигурации OpenClaw для работы с system-prompts проектом.

---

## 📂 Структура Конфигурации

```
~/.openclaw/
├── openclaw.json              # Главная конфигурация
├── credentials/               # API ключи (gitignore)
│   ├── anthropic.json
│   ├── openai.json
│   └── telegram.json
├── workspace/                 # Рабочее пространство
│   ├── AGENTS.md
│   ├── SOUL.md
│   ├── TOOLS.md
│   └── skills/
└── state/                     # Состояние сессий
    ├── sessions.json
    └── channels.json
```

---

## 📋 Главный Конфиг (openclaw.json)

### Полная Конфигурация

```json
{
  "$schema": "https://openclaw.ai/schema/config.json",

  "gateway": {
    "bind": "127.0.0.1",
    "port": 18789,
    "verbose": false,

    "tailscale": {
      "mode": "funnel",
      "resetOnExit": false
    },

    "auth": {
      "mode": "password",
      "password": "${GATEWAY_PASSWORD}",
      "allowTailscale": true
    }
  },

  "agent": {
    "model": "anthropic/claude-opus-4-5",

    "defaults": {
      "workspace": "/opt/openclaw/workspace",
      "thinkingLevel": "medium",
      "verboseLevel": "normal",
      "sendPolicy": "auto"
    },

    "auth": {
      "anthropic": {
        "apiKey": "${ANTHROPIC_API_KEY}",
        "baseUrl": "https://api.anthropic.com"
      }
    },

    "sandbox": {
      "mode": "non-main",
      "image": "openclaw-sandbox:latest",
      "allowlist": [
        "bash",
        "read",
        "write",
        "edit",
        "git"
      ],
      "denylist": [
        "browser",
        "canvas",
        "nodes",
        "cron"
      ]
    }
  },

  "channels": {
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "allowFrom": ["*"],
      "webhookUrl": "",
      "groups": {
        "*": {
          "requireMention": true
        }
      },
      "dmPolicy": "pairing"
    },

    "whatsapp": {
      "enabled": false
    },

    "discord": {
      "enabled": false
    }
  },

  "browser": {
    "enabled": true,
    "color": "#FF4500",
    "profile": "default"
  },

  "canvas": {
    "enabled": true,
    "theme": "dark"
  },

  "logging": {
    "level": "info",
    "file": "/var/log/openclaw.log",
    "maxSize": "100MB",
    "maxFiles": 10
  },

  "session": {
    "defaultThinking": "medium",
    "compactOnReset": true,
    "maxHistoryMessages": 100
  }
}
```

---

## 🔧 Секции Конфигурации

### 1. Gateway

```json
{
  "gateway": {
    "bind": "127.0.0.1",      // Loopback only (безопасность)
    "port": 18789,            // WebSocket порт
    "verbose": false,         // Детальные логи

    "tailscale": {
      "mode": "funnel",       // off | serve | funnel
      "resetOnExit": false    // Сброс Serve/Funnel при выходе
    },

    "auth": {
      "mode": "password",     // none | password
      "password": "...",      // Обязателен для funnel
      "allowTailscale": true  // Разрешить Tailscale identity
    }
  }
}
```

**Режимы Tailscale:**

| Режим | Описание | Когда использовать |
|-------|----------|-------------------|
| `off` | Tailscale не используется | Локальная разработка |
| `serve` | Tailnet-only HTTPS | Доступ только из вашей сети |
| `funnel` | Публичный HTTPS с паролем | Доступ из интернета |

### 2. Agent

```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-5",

    "defaults": {
      "workspace": "/opt/openclaw/workspace",
      "thinkingLevel": "off|minimal|low|medium|high|xhigh",
      "verboseLevel": "silent|quiet|normal|verbose|debug",
      "sendPolicy": "auto|manual|never"
    },

    "auth": {
      "anthropic": {
        "apiKey": "sk-ant-...",
        "baseUrl": "https://api.anthropic.com"
      }
    }
  }
}
```

**Поддерживаемые модели:**

| Модель | Описание | Рекомендуется для |
|--------|----------|-------------------|
| `anthropic/claude-opus-4-5` | Лучшее качество | Production |
| `anthropic/claude-sonnet-4-5` | Баланс скорость/качество | Development |
| `anthropic/claude-haiku-4-5` | Максимальная скорость | Простые задачи |
| `openai/gpt-4o` | GPT-4 Omni | Альтернатива |
| `openai/o1` | OpenAI o1 | Развитые рассуждения |

### 3. Sandbox

```json
{
  "sandbox": {
    "mode": "non-main",       // off | non-main | all
    "image": "openclaw-sandbox:latest",

    "allowlist": [
      "bash",     // Выполнение команд
      "read",     // Чтение файлов
      "write",    // Запись файлов
      "edit",     // Редактирование
      "git",      // Git операции
      "sessions_list",
      "sessions_history",
      "sessions_send"
    ],

    "denylist": [
      "browser",  // Управление браузером
      "canvas",   // Canvas A2UI
      "nodes",    // Device nodes
      "cron",     // Cron jobs
      "gateway",  // Gateway control
      "discord",  // Discord actions
      "slack"     // Slack actions
    ]
  }
}
```

**Режимы sandbox:**

| Режим | Описание | Безопасность |
|-------|----------|--------------|
| `off` | Все инструменты на хосте | ⚠️ Низкая (только main) |
| `non-main` | Docker для не-main сессий | ✅ Высокая |
| `all` | Docker для всех сессий | ✅ Максимальная |

### 4. Channels

#### Telegram

```json
{
  "channels": {
    "telegram": {
      "botToken": "123456:ABC-DEF1234...",
      "allowFrom": ["*"],               // ["*"] = все, или список Telegram ID
      "webhookUrl": "",

      "groups": {
        "*": {
          "requireMention": true        // Требовать @упоминание в группах
        }
      },

      "dmPolicy": "pairing",            // open | pairing
      "mediaMaxMb": 20
    }
  }
}
```

**Получение Telegram ID:**

```
1. Откройте @userinfobot в Telegram
2. Отправьте /start
3. Получите ваш numeric ID
4. Добавьте в allowFrom
```

#### WhatsApp

```json
{
  "channels": {
    "whatsapp": {
      "enabled": true,
      "allowFrom": ["*"],
      "groups": ["*"]
    }
  }
}
```

### 5. Tools

```json
{
  "browser": {
    "enabled": true,
    "color": "#FF4500",
    "profile": "default",
    "headless": true,
    "viewport": {
      "width": 1920,
      "height": 1080
    }
  },

  "canvas": {
    "enabled": true,
    "theme": "dark"
  }
}
```

---

## 🔐 Credentials

API ключи хранятся отдельно от основной конфигурации:

```
~/.openclaw/credentials/
├── anthropic.json
├── openai.json
└── telegram.json
```

**anthropic.json:**
```json
{
  "apiKey": "sk-ant-xxxxx",
  "baseUrl": "https://api.anthropic.com"
}
```

**telegram.json:**
```json
{
  "botToken": "123456:ABC-DEF1234..."
}
```

---

## 🎯 Workspace Конфигурация

### Структура Workspace

```
/opt/openclaw/workspace/
├── AGENTS.md              # Определение агентов
├── SOUL.md                # Личность ассистента
├── TOOLS.md               # Доступные инструменты
├── USER.md                # Пользовательские предпочтения
└── skills/                # Custom skills
    ├── development/
    ├── devops/
    └── ai-assistants/
```

### AGENTS.md

```markdown
# OpenClaw Agents

## Main Agent
Обрабатывает личные сообщения.

## Development Agent
Специализирован на написании кода.

## DevOps Agent
Специализирован на деплое.
```

**Подробнее:** [workspace/AGENTS.md](../workspace/AGENTS.md)

---

## 🔄 Environment Variables

OpenClaw поддерживает переменные окружения:

```bash
# API Keys
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."

# Channels
export TELEGRAM_BOT_TOKEN="123456:..."
export DISCORD_BOT_TOKEN="..."

# Tailscale
export TS_AUTH_KEY="tskey-auth-..."

# Gateway
export GATEWAY_PASSWORD="secure-password"

# Workspace
export OPENCLAW_WORKSPACE="/opt/openclaw/workspace"
```

---

## ✅ Валидация Конфигурации

```bash
# Проверка конфигурации
openclaw doctor

# Вывод:
# ✅ OpenClaw version: 2025.1.5
# ✅ Node.js version: 22.0.0
# ✅ Configuration: valid
# ✅ Anthropic API key: set
# ✅ Telegram bot: configured
# ✅ Workspace: /opt/openclaw/workspace
```

---

## 📝 Примеры Конфигураций

### Минимальная Конфигурация

```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-5"
  },
  "channels": {
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}"
    }
  }
}
```

### Production Конфигурация

```json
{
  "gateway": {
    "tailscale": {
      "mode": "funnel"
    },
    "auth": {
      "mode": "password",
      "password": "${GATEWAY_PASSWORD}"
    }
  },
  "agent": {
    "model": "anthropic/claude-opus-4-5",
    "sandbox": {
      "mode": "non-main"
    }
  },
  "channels": {
    "telegram": {
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "allowFrom": ["123456789"],
      "dmPolicy": "pairing"
    }
  }
}
```

---

## 📚 См. Также

- [🦞 OpenClaw README](../README.md)
- [🎯 Workspace](../workspace/README.md)
- [📱 Telegram настройка](../telegram/README.md)
- [🔒 Tailscale настройка](../tailscale/README.md)
- [🐳 Docker sandbox](../docker/README.md)

---

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [⚙️ Конфигурация](#)
