# 🦞 OpenClaw Integration

> [🏠 Главная](../README.md) → [🦞 OpenClaw](README.md) → [📄 Главная](#)

---

## Что Такое OpenClaw?

**OpenClaw** — это personal AI assistant, который:
- Работает на **любой ОС** (macOS, Linux, Windows WSL2)
- Поддерживает **10+ каналов**: Telegram, WhatsApp, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, Matrix, Zalo, WebChat
- Имеет **Voice Wake + Talk Mode** с ElevenLabs
- **Gateway WebSocket** на порту 18789 как control plane
- Поддерживает **Tailscale Serve/Funnel** для безопасного удалённого доступа
- Может работать **на Linux VDS** — клиенты подключаются через Tailscale или SSH туннели
- Поддерживает **browser control**, **Canvas**, **nodes**
- Имеет **Sandbox режим** для безопасности (Docker per-session)
- Поддерживает **Multi-agent routing** — разные агенты для разных каналов

**Официальный репозиторий:** [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw)

---

## Зачем OpenClaw в Этом Проекте?

### Проблема
Традиционные AI IDE работают только **локально**. Нельзя:
- Разрабатывать через Telegram с телефона
- Голосовыми командами управлять кодом
- Иметь 24/7 доступного AI ассистента
- Работать с любого устройства

### Решение: OpenClaw на VDS

```
┌─────────────────────────────────────────────────────────────┐
│                     VDS Server (24/7)                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              OpenClaw Gateway                         │  │
│  │         WebSocket: 127.0.0.1:18789                   │  │
│  │                                                      │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │  │
│  │  │ Dev Agent   │  │ DevOps Agent│  │ Prompt Agent │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │  │
│  │                                                      │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │         Workspace + Skills                    │  │  │
│  │  │  /workspace/system-prompts                    │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                           │                                 │
│         ┌─────────────────┼─────────────────┐               │
│         ▼                 ▼                 ▼               │
│   ┌─────────┐      ┌─────────┐      ┌─────────┐            │
│   │Telegram │      │ WhatsApp│      │  Slack  │            │
│   │   Bot   │      │   Bot   │      │   Bot   │            │
│   └─────────┘      └─────────┘      └─────────┘            │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  Tailscale  │
                    │     VPN     │
                    └─────────────┘
```

---

## 🚀 Быстрый Старт

### Вариант A: Установка на VDS (Рекомендуется)

```bash
# 1. Скопируйте скрипт установки
curl -fsSL https://raw.githubusercontent.com/RussianLioN/CodeFoundry/main/openclaw/scripts/install-openclaw.sh | bash

# 2. Следуйте инструкциям мастера
openclaw onboard

# 3. Настройте Telegram бота
./openclaw/scripts/setup-telegram.sh

# 4. Готово! Пишите в Telegram бота
```

**Подробнее:** [📥 Установка на VDS](install/VDS-SETUP.md)

### Вариант B: Локальная установка

```bash
# 1. Установите OpenClaw
npm install -g openclaw@latest

# 2. Запустите мастер настройки
openclaw onboard

# 3. Запустите Gateway
openclaw gateway --port 18789
```

**Подробнее:** [📥 Локальная установка](install/local-setup.md)

---

## 📂 Структура OpenClaw Директории

```
openclaw/
├── 📄 README.md                      # Этот файл
│
├── 📥 install/                       # Установка
│   ├── VDS-SETUP.md                  # Установка на VDS
│   ├── local-setup.md                # Локальная установка
│   └── verify.md                     # Проверка установки
│
├── ⚙️ config/                        # Конфигурация
│   ├── README.md                     # Обзор конфигурации
│   ├── openclaw.json                 # Главный конфиг
│   ├── channels.json                 # Настройка каналов
│   └── sandbox.json                  # Docker sandbox
│
├── 🎯 workspace/                     # Workspace и Skills
│   ├── README.md                     # Обзор workspace
│   ├── AGENTS.md                     # Определение агентов
│   ├── SOUL.md                       # Личность ассистента
│   ├── TOOLS.md                      # Манифест инструментов
│   └── skills/                       # 🎨 Custom Skills
│       ├── development/              # Skills для разработки
│       │   ├── git-workflow.md
│       │   ├── testing-strategy.md
│       │   └── code-review.md
│       ├── devops/                   # Skills для DevOps
│       │   ├── docker-deploy.md
│       │   ├── ci-pipeline.md
│       │   └── monitoring.md
│       └── ai-assistants/            # Skills для AI ассистентов
│           ├── prompt-engineer.md
│           ├── code-generator.md
│           └── debugger.md
│
├── 🐳 docker/                        # Docker конфигурация
│   ├── README.md
│   ├── Dockerfile.openclaw           # OpenClaw container
│   ├── Dockerfile.sandbox            # Per-session sandbox
│   └── docker-compose.yml            # OpenClaw stack
│
├── 🔒 tailscale/                     # Tailscale VPN
│   ├── README.md
│   ├── serve-config.yaml             # Serve/Funnel config
│   └── auth-keys/                    # Auth keys (gitignore)
│
├── 📱 telegram/                      # Telegram интеграция
│   ├── README.md
│   ├── bot-setup.md                  # Настройка бота
│   ├── voice-handler.md              # Обработка голоса
│   └── commands/                     # Telegram команды
│       ├── status.md
│       ├── new.md
│       ├── deploy.md
│       └── voice.md
│
└── 🔧 scripts/                       # Скрипты автоматизации
    ├── install-openclaw.sh           # VDS install
    ├── setup-telegram.sh             # Telegram setup
    ├── setup-tailscale.sh            # VPN setup
    └── health-check.sh               # Health monitoring
```

---

## 🎯 Ключевые Возможности

### 1. Multi-Agent Routing

Разные агенты для разных задач:

| Агент | Специализация | Триггер |
|-------|---------------|---------|
| **Main Agent** | Общая разработка | Личные сообщения |
| **Dev Agent** | Написание кода | "напиши", "создай", "рефактори" |
| **DevOps Agent** | Деплой и инфра | "деплой", "docker", "k8s" |
| **Prompt Agent** | Промпт-инжиниринг | "промпт", "инструкция" |

**Подробнее:** [AGENTS.md](workspace/AGENTS.md)

### 2. Voice Commands

Управление разработкой голосом через Telegram:

```
🗣️ "Создай новый проект для REST API"
🤖 OpenClaw: Создаёт структуру проекта...

🗣️ "Задеплой на стейджинг"
🤖 OpenClaw: Выполняет docker-compose up...

🗣️ "Напиши тесты для функции авторизации"
🤖 OpenClaw: Генерирует тесты...
```

**Подробнее:** [📱 Voice Handler](telegram/voice-handler.md)

### 3. Skills System

Переиспользуемые навыки агентов:

- **Git Workflow** — автоматизация Git операций
- **Testing Strategy** — генерация тестов
- **Code Review** — ревью кода
- **Docker Deploy** — деплой через Docker
- **CI Pipeline** — настройка CI/CD
- **Monitoring** — мониторинг и алерты

**Подробнее:** [🎯 Skills Index](workspace/SKILLS-INDEX.md)

### 4. Remote Access

Доступ к ассистенту откуда угодно:

- **Tailscale Funnel** — публичный HTTPS с паролем
- **Tailscale Serve** — tailnet-only доступ
- **SSH Tunnel** — резервный вариант

**Подробнее:** [🔒 Tailscale Setup](tailscale/README.md)

---

## 🔗 Быстрые Ссылки

### Установка
- [📥 Установка на VDS](install/VDS-SETUP.md)
- [📥 Локальная установка](install/local-setup.md)
- [✅ Проверка установки](install/verify.md)

### Конфигурация
- [⚙️ Обзор конфигурации](config/README.md)
- [📋 OpenClaw конфиг](config/openclaw.json)
- [📱 Каналы](config/channels.json)
- [🐳 Sandbox](config/sandbox.json)

### Workspace
- [🎯 Workspace обзор](workspace/README.md)
- [🤖 Агенты](workspace/AGENTS.md)
- [👤 Личность](workspace/SOUL.md)
- [🔧 Инструменты](workspace/TOOLS.md)
- [🎨 Skills Index](workspace/SKILLS-INDEX.md)

### Интеграции
- [🐳 Docker](docker/README.md)
- [📱 Telegram](telegram/README.md)
- [🔒 Tailscale](tailscale/README.md)

### Скрипты
- [🔧 install-openclaw.sh](scripts/install-openclaw.sh)
- [📱 setup-telegram.sh](scripts/setup-telegram.sh)
- [🔒 setup-tailscale.sh](scripts/setup-tailscale.sh)
- [🏥 health-check.sh](scripts/health-check.sh)

---

## 📚 См. Также

- [📋 Главный индекс документации](../docs/INDEX.md)
- [🗺️ Карта навигации](../docs/nav/nav-map.md)
- [📋 TASKS.md](../TASKS.md) - Текущие задачи проекта
- [📖 PROJECT.md](../PROJECT.md) - Архитектура проекта

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия OpenClaw интеграции |

---

> [🏠 Главная](../README.md) → [🦞 OpenClaw](README.md) → [📄 Главная](#)
