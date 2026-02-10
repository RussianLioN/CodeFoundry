# 📱 Telegram Bot Archetype

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [📱 Telegram Bot](#)

---

## Description

Шаблон для создания Telegram ботов с FSM (Finite State Machine), inline клавиатурами и middleware.

---

## 🎯 Характеристики

### Tech Stack

| Компонент | Технология |
|-----------|------------|
| **Runtime** | Python 3.11+ |
| **Framework** | aiogram 3.x |
| **Database** | PostgreSQL + SQLAlchemy |
| **Cache** | Redis (сессии, rate limiting) |
| **State Machine** | aiogram FSM |
| **Deployment** | Docker + K8s |

### Features Out-of-the-Box

✅ **FSM States** — состояние пользователя (меню, формы, диалоги)
✅ **Inline Keyboards** — интерактивные кнопки
✅ **Callback Handling** — обработка нажатий
✅ **Middleware** — logging, auth, rate limiting
✅ **Multi-language** — поддержка i18n
✅ **Admin Commands** — управление ботом
✅ **Webhook Support** — production ready
✅ **Polling Mode** — для разработки

---

## 🚀 Quick Start

### 1. Создание проекта

**Через CodeFoundry (рекомендуется):**
```bash
cd CodeFoundry
make new ARCHETYPE=telegram-bot NAME=my-bot
cd my-bot
```

**Вручную:**
```bash
cp -r /path/to/CodeFoundry/templates/archetypes/telegram-bot ~/projects/my-bot
cd ~/projects/my-bot
git init
```

### 2. Конфигурация

```bash
cp .env.example .env
nano .env
```

```bash
# Bot token от @BotFather
BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz

# Webhook URL (для production)
WEBHOOK_URL=https://my-bot.example.com/webhook
WEBHOOK_SECRET=random_secret_string
```

### 3. Запуск

```bash
# Development (polling)
make dev

# Production (webhook)
make deploy
```

---

## 📂 Структура Проекта

```
telegram-bot/
├── 📋 docs/
│   ├── ARCHITECTURE.md
│   ├── STATE_MACHINE.md
│   └── DEPLOYMENT.md
│
├── 🐳 docker/
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── ☸️ k8s/
│   └── ...
│
├── 🤖 openclaw/
│   └── workspace/
│       ├── AGENTS.md
│       └── skills/
│
├── 📝 src/
│   ├── app/
│   │   ├── main.py
│   │   ├── config.py
│   │   └── i18n.py
│   ├── handlers/
│   │   ├── commands.py   # /start, /help
│   │   ├── callbacks.py   # button clicks
│   │   └── messages.py    # text messages
│   ├── middlewares/
│   │   ├── auth.py
│   │   ├── logging.py
│   │   └── throttling.py
│   ├── fsm/
│   │   ├── states.py      # State definitions
│   │   └── routes.py      # Transitions
│   ├── keyboards/
│   │   ├── inline.py      # Inline keyboards
│   │   └── reply.py       # Reply keyboards
│   ├── filters/
│   │   ├── chat_type.py   # Private/group filters
│   │   └── user.py        # User role filters
│   └── models/
│       ├── user.py
│       └── chat.py
│
└── 🔧 scripts/
    ├── setup-bot.sh
    ├── set-webhook.sh
    └── delete-webhook.sh
```

---

## 🤖 OpenClaw Integration

### Multi-Agent Configuration

```
Main Agent (Координатор)
    ├── Dev Agent (Код бота)
    ├── BotConfig Agent (Конфигурация бота)
    └── Review Agent (Ревью)
```

---

## 🎨 FSM States

### State Machine Example

```python
# src/fsm/states.py
from aiogram.fsm.state import State, StatesGroup

class FormStates(StatesGroup):
    """Состояния для формы ввода данных"""
    NAME = State()
    EMAIL = State()
    AGE = State()
    CONFIRM = State()

class MenuStates(StatesGroup):
    """Состояния главного меню"""
    MAIN = State()
    SETTINGS = State()
    HELP = State()

# src/fsm/routes.py
from aiogram import Router
from aiogram.fsm.context import FSMContext

router = Router()

@router.message(FormStates.NAME)
async def process_name(message: Message, state: FSMContext):
    await state.update_data(name=message.text)
    await message.answer("Отлично! Теперь введи email:")
    await state.set_state(FormStates.EMAIL)
```

---

## 📝 Handler Examples

### Commands

```python
# src/handlers/commands.py
from aiogram import Router, types
from aiogram.filters import Command

router = Router()

@router.message(Command("start"))
async def cmd_start(message: types.Message):
    await message.answer(
        "Привет! 👋\n\n"
        "Я бот-помощник. Выберите действие:",
        reply_markup=keyboards.main_menu()
    )

@router.message(Command("help"))
async def cmd_help(message: types.Message):
    help_text = (
        "📖 <b>Справка</b>\n\n"
        "/start - Начать работу\n"
        "/help - Эта справка\n"
        "/settings - Настройки\n"
    )
    await message.answer(help_text, parse_mode="HTML")
```

### Callbacks

```python
# src/handlers/callbacks.py
from aiogram import Router, types
from aiogram.filters.callback_data import CallbackData

router = Router()

@router.callback_query(lambda c: c.data.startswith("menu_"))
async def menu_callback(query: types.CallbackQuery):
    menu_item = query.data.split("_")[1]

    if menu_item == "profile":
        await query.message.edit_text("Ваш профиль")
    elif menu_item == "settings":
        await query.message.edit_text("Настройки", reply_markup=keyboards.settings())
    elif menu_item == "about":
        await query.message.edit_text("О боте...")

    await query.answer()
```

---

## 🔧 Makefile Commands

```bash
make help         # Show all commands
make init         # Initialize project
make dev          # Start polling mode
make webhook      # Set webhook
make delete-hook  # Delete webhook
make test         # Run tests
make lint         # Run linter
make deploy       # Deploy to production
```

---

## 📚 Additional Resources

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)
- [📋 Все Архетипы](../README.md)

### OpenClaw Integration
- [🦞 OpenClaw README](../../../openclaw/README.md)
- [🤖 Agents](../../../openclaw/workspace/AGENTS.md)
- [🎨 Skills Index](../../../openclaw/workspace/SKILLS-INDEX.md)

### Telegram Bot Documentation
- [📖 aiogram Docs](https://docs.aiogram.dev/)
- [📖 Bot API](https://core.telegram.org/bots/api)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.1.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs |
| 1.0.0 | 2025-11-05 | Первая версия archetype |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [📱 Telegram Bot](#)
