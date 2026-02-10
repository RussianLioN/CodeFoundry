# 🌐 CodeFoundry Remote Testing Documentation

> Полная документация для remote testing infrastructure на ainetic.tech

---

## 📑 Документация

| Документ | Описание | Для кого |
|----------|----------|---------|
| [QUICKSTART](QUICKSTART.md) | Быстрый старт (5 мин) | Новички |
| [ARCHITECTURE](ARCHITECTURE.md) | Техническая архитектура | Архитекторы |
| [TROUBLESHOOTING](TROUBLESHOOTING.md) | Решение проблем | DevOps |

---

## 🚀 Быстрый старт

```bash
# 1. SSH на сервер
ssh root@ainetic.tech

# 2. Синхронизация
cd ~/projects/CodeFoundry
make sync

# 3. Запуск
make start-test

# 4. Тестирование
./test-telegram.sh
```

[Подробнее...](QUICKSTART.md)

---

## 🏗️ Архитектура

```
Local → GitHub → ainetic.tech → Ephemeral Containers → Test
```

**Компоненты:**
- **Test Stack:** Gateway, Telegram Bot, Test Runner
- **Monitor Stack:** Prometheus, Grafana, cAdvisor, Vector
- **Session Manager:** Lifecycle, isolation, cleanup

[Подробнее...](ARCHITECTURE.md)

---

## 🔧 Решение проблем

### Частые проблемы

| Проблема | Решение |
|----------|---------|
| Контейнер не запускается | `make clean && make start-test` |
| Бот не отвечает | Проверить `TELEGRAM_BOT_TOKEN` |
| Gateway down | `docker restart codefoundry-test-gateway-1` |
| Синхронизация не работает | `make sync-force` |

[Подробнее...](TROUBLESHOOTING.md)

---

## 📚 Server Documentation

- [Server README](../../server/README.md) — Скрипты и команды
- [Monitoring README](../../server/monitoring/README.md) — Мониторинг стек

---

## 🎯 Команды

### Основные

```bash
make sync              # Синхронизация с GitHub
make start-test        # Запуск тестов
make logs              # Логи
make stop-test         # Остановка
```

### Сессии

```bash
./telegram-test-session.sh create    # Создать сессию
./telegram-test-session.sh test      # Запустить тесты
./telegram-test-session.sh logs      # Логи сессии
```

### Тестирование

```bash
./test-telegram.sh                   # Все тесты
./test-telegram.sh --watch           # Мониторинг
./test-telegram.sh --interactive     # Интерактивно
```

---

## 📊 Мониторинг

| Сервис | URL | Логин |
|--------|-----|-------|
| Grafana | http://ainetic.tech:3000 | admin/admin |
| Prometheus | http://ainetic.tech:9090 | - |
| cAdvisor | http://ainetic.tech:8080 | - |

Запуск:
```bash
docker-compose -f server/docker-compose.monitoring.yml up -d
```

---

## 🔄 Workflow

### Разработка

```
1. Local: git commit + git push
2. Remote: ssh ainetic.tech
3. Remote: cd ~/projects/CodeFoundry
4. Remote: make sync
5. Remote: make start-test
6. Remote: ./test-telegram.sh
```

### Тестирование сессии

```
1. ./telegram-test-session.sh create my-feature
2. ./telegram-test-session.sh test my-feature
3. ./telegram-test-session.sh logs my-feature
4. ./telegram-test-session.sh stop my-feature
```

---

## 🔗 Связанные документы

- [PROJECT.md](../../PROJECT.md) — Архитектура проекта
- [TASKS.md](../../TASKS.md) — Трекер задач
- [SESSION.md](../../SESSION.md) — История сессий

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
