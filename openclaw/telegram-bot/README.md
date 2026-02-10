# OpenClaw Telegram Bot

Telegram бот для AI-powered разработки через OpenClaw Gateway.

## 📋 Описание

Бот предоставляет интерфейс для работы с CodeFoundry через Telegram:
- Создание проектов одной командой
- Управление проектами удалённо
- AI-ассистент через естественный язык
- Прогресс операций в реальном времени

## 🏗️ Архитектура

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Telegram   │────▶│ Telegram Bot │────▶│  OpenClaw   │
│   Client    │     │   :polling   │     │   Gateway   │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Session    │
                    │   Manager    │
                    └──────────────┘
```

## 🚀 Быстрый старт

### Локальная разработка

```bash
# Установка зависимостей
npm install

# Настройка окружения
cp .env.example .env
nano .env
# Добавьте TELEGRAM_BOT_TOKEN

# Сборка
npm run build

# Запуск
npm start
```

### Docker режим

```bash
# Через docker-compose (рекомендуется)
cd ../docker
docker-compose up -d telegram-bot

# Просмотр логов
docker-compose logs -f telegram-bot
```

## 📡 Команды

| Команда | Описание | Пример |
|---------|----------|--------|
| `/start` | Инициализация бота | `/start` |
| `/help` | Справка | `/help` |
| `/new` | Создать проект | `/new telegram-bot my-bot` |
| `/status` | Статус системы | `/status` |

## 💬 Естественный язык

Бот поддерживает команды на русском языке:

```
Создай проект telegram-bot для доставки еды
Задеплой проект my-bot в production
Сгенерируй агента для проекта my-app
```

## ⚙️ Конфигурация

`.env` файл:

```bash
# Telegram
TELEGRAM_BOT_TOKEN=123456:ABC-DEF
AUTHORIZED_USER_IDS=123456789,987654321

# Gateway
GATEWAY_URL=ws://gateway:18789

# Sessions
SESSION_TIMEOUT=3600000  # 1 час

# Logging
LOG_LEVEL=info
NODE_ENV=production
```

## 📁 Структура проекта

```
telegram-bot/
├── src/
│   ├── bot.ts              # Главный файл бота
│   ├── types.ts            # TypeScript типы
│   ├── session-manager.ts  # Управление сессиями
│   ├── gateway-client.ts   # WebSocket клиент Gateway
│   ├── commands/           # Обработчики команд
│   │   ├── index.ts
│   │   ├── start.ts
│   │   ├── help.ts
│   │   ├── new.ts
│   │   └── status.ts
│   └── utils/
│       └── logger.ts       # Winston logger
├── dist/                   # Скомпилированный JS
├── Dockerfile              # Multi-stage build
├── package.json            # Зависимости
├── tsconfig.json           # TypeScript конфиг
├── .env.example            # Пример конфигурации
└── README.md               # Этот файл
```

## 🔧 Разработка

```bash
# Режим разработки с hot reload
npm run dev

# Сборка
npm run build

# Запуск продакшн
npm start

# Тесты
npm test

# Линтинг
npm run lint
npm run lint:fix
```

## 🐳 Docker

### Сборка образа

```bash
docker build -t openclaw/telegram-bot:latest .
```

### Запуск контейнера

```bash
docker run -d \
  --name openclaw-bot \
  -e TELEGRAM_BOT_TOKEN=xxx \
  -e GATEWAY_URL=ws://gateway:18789 \
  openclaw/telegram-bot:latest
```

## 🔐 Безопасность

### User Authorization

Настройте `AUTHORIZED_USER_IDS` для ограничения доступа:

```bash
# Добавьте через запятую ID пользователей Telegram
AUTHORIZED_USER_IDS=123456789,987654321
```

### Как узнать свой Telegram ID:

1. Отправьте сообщение боту `@userinfobot`
2. Или используйте `@GetMyIdBot`

## 📊 Мониторинг

### Health check

```bash
# Bot должен отвечать на сообщения
curl https://api.telegram.org/bot<TOKEN>/getMe
```

### Логи

```bash
# Docker logs
docker logs -f openclaw-bot

# Логи в файле (production)
tail -f logs/combined.log
```

## 🧪 Тестирование

```bash
# Локальное тестирование
npm run dev

# Тестовые команды
/start
/help
/new telegram-bot test-bot
```

## 🔗 Интеграция

### С OpenClaw Gateway

Бот подключается к Gateway через WebSocket:

```typescript
// Автоматическое переподключение
gatewayClient.connect()

// Отправка сообщения
await gatewayClient.sendChat(content, userId)

// Прогресс операции
await gatewayClient.sendMessageWithProgress(
  message,
  (update) => console.log(update.progress)
)
```

### С Telegram Bot API

```typescript
// Отправка сообщения
await bot.sendMessage(chatId, text, { parse_mode: 'Markdown' })

// Typing indicator
await bot.sendChatAction(chatId, 'typing')
```

## 🛠️ Troubleshooting

### Бот не отвечает

```bash
# Проверьте токен
curl https://api.telegram.org/bot<TOKEN>/getMe

# Проверьте логи
docker logs openclaw-bot

# Проверьте Gateway
docker logs openclaw-gateway
```

### Gateway не подключается

```bash
# Проверьте здоровье Gateway
curl http://localhost:18790/health

# Проверьте docker сеть
docker network inspect openclaw-network
```

### Команды не работают

```bash
# Проверьте авторизацию
# Убедитесь что ваш ID в AUTHORIZED_USER_IDS

# Проверьте логи
docker logs openclaw-bot | grep "User"
```

## 📝 License

MIT

## 🤝 Contributing

См. `CONTRIBUTING.md` в корне проекта.

## 📚 Документация

- [OpenClaw Gateway](../gateway/README.md)
- [CodeFoundry Documentation](../../../docs/)
- [Telegram Bot API](https://core.telegram.org/bots/api)

---

**Version:** 1.0.0
**Last updated:** 2025-02-02
