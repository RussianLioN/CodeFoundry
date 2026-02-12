# 🚀 OpenClaw: Быстрый Старт через Telegram

> [🏠 Главная](../../README.md) → [📋 Docs](../INDEX.md) → [📚 Reference](INDEX.md) → **OpenClaw Quickstart**

> **Бот:** @codefoundrybot
> **Сервер:** ainetic.tech
> **Дата:** 2026-02-12

---

## 🔗 Связанные документы

| Документ | Описание |
|----------|----------|
| [Complete Guide](openclaw-complete-guide-2026.md) | Полное руководство (25 Tools + 53 Skills) |
| [Architecture](OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md) | Архитектура OpenClaw v2.0.1 |

---

## 1. Найти бота

```
Telegram → Поиск → @codefoundrybot
```

Или прямая ссылка: https://t.me/codefoundrybot

---

## 2. Базовые команды

| Команда | Что делает |
|---------|------------|
| `/start` | Начать работу |
| `/help` | Справка |
| `/status` | Статус системы |
| `/new <name>` | Создать проект |

---

## 3. Примеры запросов

### Создание проекта
```
/new my-api web-service
```

### Вопрос к AI
```
Какие архетипы проектов доступны?
```

### Статус системы
```
/status
```

---

## 4. Архетипы проектов

| Архетип | Описание |
|---------|----------|
| `web-service` | REST/GraphQL API |
| `ai-agent` | AI assistant с RAG |
| `telegram-bot` | Telegram бот |
| `cli-tool` | CLI приложение |
| `fullstack` | Next.js + NestJS |
| `microservices` | Микросервисы |

---

## 5. Диагностика

### Если бот не отвечает

```bash
# SSH на сервер
ssh root@ainetic.tech

# Проверить контейнеры
docker ps --filter 'name=openclaw'

# Перезапустить бота
cd /root/projects/CodeFoundry
docker-compose -f server/docker-compose.orchestrator.yml restart telegram-bot
```

### Проверить Gateway

```bash
curl http://ainetic.tech:18790/health
```

---

## 6. Полезные ссылки

| Ресурс | URL |
|--------|-----|
| Полное руководство | docs/reference/openclaw-complete-guide-2026.md |
| Архитектура | docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md |
| Официальные docs | https://docs.openclaw.ai |

---

**Начните прямо сейчас:** Найдите @codefoundrybot в Telegram и отправьте `/start`!