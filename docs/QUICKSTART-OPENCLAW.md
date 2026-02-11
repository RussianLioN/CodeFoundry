# 🚀 Quick Start: OpenClaw на ainetic.tech

> **Цель:** Запустить OpenClaw с Ollama Cloud API и протестировать базовую функциональность
>
> **Время:** 30-60 минут

---

## 📋 План действий

1. **Получить OLLAMA_API_KEY** (5 мин)
2. **Настроить .env.orchestrator** (5 min)
3. **Запустить OpenClaw Gateway** (10 min)
4. **Подключить Telegram Bot** (10 min)
5. **Протестировать** (20 мин)

---

## 1️⃣ Получить OLLAMA_API_KEY

### Шаги:

1. Перейдите на https://ollama.com/settings/keys
2. Войдите или создайте аккаунт (FREE tier доступен)
3. Нажмите "Generate API Key"
4. Скопируйте ключ (формата: `sk-xxxxx-xxxxx-xxxxx-xxxxx`)

### 💰 Pricing (gemini-3-flash-preview:cloud)

| Метрика | Цена |
|---------|------|
| Input tokens | **$0.50 / 1M tokens** |
| Output tokens | **$3.00 / 1M tokens** |
| FREE tier | Ежедневное использование |
| Context window | **1,000,000 tokens** |

---

## 2️⃣ Настроить .env.orchestrator на ainetic.tech

### SSH на сервер:

```bash
ssh ainetic.tech
cd /opt/openclaw
```

### Создать .env.orchestrator:

```bash
# Копируем пример
cp openclaw/docker/.env.orchestrator.example .env.orchestrator

# Редактируем
nano .env.orchestrator
```

### Обязательные настройки:

```bash
# ============================================================
# Ollama Cloud API Configuration
# ============================================================

# Сгенерируйте ключ на https://ollama.com/settings/keys
OLLAMA_API_KEY=sk-ВАШ_КЛЮК_ЗДЕСЬ

# Модель (gemini-3-flash-preview:cloud)
OLLAMA_MODEL=gemini-3-flash-preview:cloud
OLLAMA_BASE_URL=https://api.ollama.cloud

# ============================================================
# Telegram Bot Configuration
# ============================================================

# Получите токен от @BotFather
TELEGRAM_BOT_TOKEN=ВАШ_ТЕЛЕГРАМ_ТОКЕН

# Ваш Telegram ID (получить от @userinfobot)
AUTHORIZED_USER_IDS=ВАШ_TELEGRAM_ID
```

### Сохранить и выйти: `Ctrl+X`, `Y`, `Enter`

---

## 3️⃣ Запустить OpenClaw Gateway

### Запуск через docker-compose:

```bash
cd /opt/openclaw

# Запуск стека
docker compose -f server/docker-compose.orchestrator.yml up -d

# Проверка статуса
docker compose -f server/docker-compose.orchestrator.yml ps
```

### Ожидаемый результат:

```
NAME                                    STATUS    PORTS
openclaw-orchestrator-gateway          Up        0.0.0.0:18789->18789, 0.0.0.0:18790->18790
openclaw-orchestrator-telegram-bot     Up
claude-code-runner                     Up (restarting)
```

### Проверка Gateway:

```bash
# Health check
curl http://localhost:18790/health

# Ожидаемый ответ:
# {"status":"ok","timestamp":"2026-02-11T..."}
```

### Логи Gateway:

```bash
# Просмотр логов
docker compose -f server/docker-compose.orchestrator.yml logs -f gateway
```

---

## 4️⃣ Подключить Telegram Bot

### Создать бота (если ещё нет):

1. Откройте Telegram
2. Найдите @BotFather
3. Отправьте `/newbot`
4. Следуйте инструкциям:
   - Имя бота: `OpenClawBot` (или любое)
   - Username: `my_openclaw_bot` (уникальный)
5. Скопируйте токен (формата: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### Обновить .env.orchestrator:

```bash
nano .env.orchestrator

# Замените:
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
AUTHORIZED_USER_IDS=ВАШ_TELEGRAM_ID
```

### Перезапустить Telegram Bot:

```bash
docker compose -f server/docker-compose.orchestrator.yml restart telegram-bot
```

### Проверить подключение:

```bash
# Логи бота
docker compose -f server/docker-compose.orchestrator.yml logs -f telegram-bot
```

Ищите строку:
```
Connected to Gateway ws://gateway:18789
```

---

## 5️⃣ Тестирование

### Тест 1: Базовые команды

Отправьте в Telegram боту:

```
/start
/help
/status
```

**Ожидаемый результат:** Бот отвечает на каждую команду

---

### Тест 2: Свободное общение (Chat Mode)

```
Привет!
Как дела?
Что ты умеешь?
```

**Ожидаемый результат:** OpenClaw отвечает на обычном языке

---

### Тест 3: Skills (если workspace настроен)

```
Создай git commit
Сделай code review
```

**Ожидаемый результат:** OpenClaw выполняет навыки

---

## ✅ Проверочный чек-лист

Перед завершением убедитесь:

- [ ] OLLAMA_API_KEY получен и настроен
- [ ] Gateway работает на порту 18789
- [ ] Health check на порту 18790 отвечает
- [ ] Telegram Bot подключён к Gateway
- [ ] Бот отвечает на `/start`, `/help`, `/status`
- [ ] Chat mode работает (отвечает на "Привет")
- [ ] Skills выполняются (если workspace настроен)

---

## 🐛 Troubleshooting

### Gateway не запускается:

```bash
# Логи
docker compose -f server/docker-compose.orchestrator.yml logs gateway

# Частые проблемы:
# - OLLAMA_API_KEY не указан
# - Порт 18789 уже занят
# - Нет доступа к Ollama Cloud API
```

### Telegram Bot не подключается:

```bash
# Логи бота
docker compose -f server/docker-compose.orchestrator.yml logs telegram-bot

# Частые проблемы:
# - TELEGRAM_BOT_TOKEN неверный
# - AUTHORIZED_USER_IDS не содержит ваш ID
# - Gateway не запущен
```

### OpenClaw не отвечает:

```bash
# Проверить WebSocket соединение
netstat -tn | grep 18789

# Перезапустить стек
docker compose -f server/docker-compose.orchestrator.yml restart
```

---

## 📚 Следующие шаги

После успешного запуска:

1. **Настроить workspace** — скопировать skills и агентов
2. **Расширить функционал** — добавить новые skills
3. **Интеграция с Claude Code** — создать skill для работы

**Подробнее:**
- [Workspace Setup](../openclaw/workspace/README.md)
- [Skills System](../openclaw/workspace/SKILLS-INDEX.md)
- [Multi-Agent Routing](../openclaw/workspace/AGENTS.md)

---

**Версия:** 1.0
**Дата:** 2026-02-11
**Статус:** READY FOR DEPLOYMENT
