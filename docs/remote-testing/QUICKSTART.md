# 🚀 CodeFoundry Remote Testing - Quick Start

> Быстрый старт для работы с remote testing на ainetic.tech

---

## ⚡ 5-Minute Setup

### Шаг 1: SSH на сервер

```bash
ssh root@ainetic.tech
```

### Шаг 2: Клонирование проекта

```bash
# Клонировать (первый раз)
git clone git@github.com:RussianLioN/CodeFoundry.git ~/projects/CodeFoundry

# Или обновить (если уже клонировано)
cd ~/projects/CodeFoundry
git pull origin main
```

### Шаг 3: Настройка окружения

```bash
cd ~/projects/CodeFoundry/server

# Создать .env.test из примера
cp .env.test.example .env.test

# Редактировать конфигурацию
nano .env.test
```

**Обязательные настройки:**
```bash
TELEGRAM_BOT_TOKEN=your_actual_bot_token
AUTHORIZED_USER_IDS=your_telegram_user_id
```

### Шаг 4: Первая синхронизация

```bash
# Синхронизировать с GitHub
make sync
```

### Шаг 5: Запуск тестового контейнера

```bash
# Запустить тестовый контейнер
make start-test

# Проверить статус
make status

# Посмотреть логи
make logs
```

### Шаг 6: Тестирование Telegram бота

```bash
# Запустить тесты
./test-telegram.sh

# Или интерактивный режим
./test-telegram.sh --interactive
```

---

## 📋 Основные команды

### Синхронизация

```bash
make sync              # Синхронизировать с GitHub
make sync-status       # Проверить статус
make sync-force        # Принудительная синхронизация
```

### Контейнеры

```bash
make start-test        # Запустить тестовый контейнер
make stop-test         # Остановить
make restart-test      # Перезапустить
make status            # Статус всех контейнеров
make health            # Проверка health
```

### Логи

```bash
make logs              # Все логи (follow mode)
make logs-short        # Последние 50 строк
make logs-gateway      # Только gateway
make logs-bot          # Только telegram bot
```

### Сессии

```bash
make start-session SESSION=my-test     # Создать сессию
make stop-session SESSION=my-test      # Остановить сессию
make list-sessions                     # Список сессий
make attach-session SESSION=my-test    # Подключиться к сессии
```

### Тестирование

```bash
./test-telegram.sh                    # Все тесты
./test-telegram.sh --scenario=start   # Конкретный тест
./test-telegram.sh --watch            # Мониторинг логов
./test-telegram.sh --interactive      # Интерактивный режим
```

---

## 🧪 Типичный рабочий процесс

### Вариант 1: Быстрое тестирование

```bash
# 1. На локальной машине
git add .
git commit -m "feat: new feature"
git push origin main

# 2. На сервере ainetic.tech
ssh root@ainetic.tech
cd ~/projects/CodeFoundry
make sync
make stop-test          # Остановить если запущен
make start-test         # Запустить
make logs               # Мониторить
```

### Вариант 2: Тестирование сессии

```bash
# Создать именованную сессию
./telegram-test-session.sh create my-feature-test

# Запустить тесты
./telegram-test-session.sh test my-feature-test

# Посмотреть логи
./telegram-test-session.sh logs my-feature-test

# Завершить сессию
./telegram-test-session.sh stop my-feature-test
```

---

## 🔧 Конфигурация

### Минимальный .env.test

```bash
# Project
PROJECT_DIR=/root/projects/CodeFoundry
GITHUB_REPO=git@github.com:RussianLioN/CodeFoundry.git

# Telegram (обязательно!)
TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
AUTHORIZED_USER_IDS=123456789

# Containers (обычно не менять)
COMPOSE_PROJECT_NAME=codefoundry-test
SESSION_TIMEOUT=86400000
```

---

## 🐛 Быстрые решения проблем

### Проблема: Контейнер не запускается

```bash
# Проверить логи
docker-compose -f server/docker-compose.test.yml logs

# Пересоздать
make clean
make start-test
```

### Проблема: Telegram бот не отвечает

```bash
# Проверить токен
grep TELEGRAM_BOT_TOKEN server/.env.test

# Проверить контейнер
make status

# Проверить логи
make logs-bot

# Тест подключения
curl https://api.telegram.org/bot$TOKEN/getMe
```

### Проблема: Синхронизация не работает

```bash
# Проверить git статус
git status

# Принудительная синхронизация
make sync-force

# Проверить SSH ключи
ssh -T git@github.com
```

---

## 📊 Мониторинг

### Запустить мониторинг

```bash
cd ~/projects/CodeFoundry/server
docker-compose -f docker-compose.monitoring.yml up -d
```

### Доступ к сервисам

| Сервис | URL | Логин |
|--------|-----|-------|
| Grafana | http://ainetic.tech:3000 | admin/admin |
| Prometheus | http://ainetic.tech:9090 | - |
| cAdvisor | http://ainetic.tech:8080 | - |

---

## 📚 Дополнительная документация

- [ARCHITECTURE.md](ARCHITECTURE.md) — Архитектура
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Решение проблем
- [../server/README.md](../server/README.md) — Server documentation

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
