# 🚨 CodeFoundry Disaster Recovery Plan

> **Процедуры восстановления на ainetic.tech при критических сбоях**

**Version:** 1.0.0
**Last Updated:** 2025-02-03
**RTO:** 4 часа (Recovery Time Objective)
**RPO:** 24 часа (Recovery Point Objective)

---

## 📋 Содержание

- [Уровни серьёзности инцидентов](#уровни-серьёзности)
- [Процедуры восстановления](#процедуры-восстановления)
- [Тестирование восстановления](#тестирование-восстановления)
- [Runbooks для конкретных сценариев](#runbooks)

---

## 🎯 Уровни серьёзности инцидентов

### 🔴 Level 1: Критический (Service Down)

**Симптомы:**
- Все контейнеры crashed
- Telegram бот не отвечает
- Нет доступа к ainetic.tech
- Данные недоступны

**Triage:**
```bash
# Проверить доступность
ping -c 3 ainetic.tech
ssh root@ainetic.tech "docker ps"

# Если SSH работает:
cd ~/projects/CodeFoundry/server
make status
make logs
```

**MTTR:** 1 час
**Путь восстановления:** Restart containers → Restore from backup

---

### 🟠 Level 2: Серьёзный (Data Loss)

**Симптомы:**
- Утеряна volumes (Ollama models, logs)
- Удалены конфигурационные файлы
| Level | Статус | Прогресс |
|------|--------|----------|
| **Фаза 1:** Реструктуризация | ✅ Завершена | 100% |
| **Фаза 2:** OpenClaw Integration | ✅ Завершена | 100% |
| **Фаза 3:** Project Templates | ✅ Завершена | 100% |
| **Фаза 4:** DevOps Инфраструктура | ✅ Завершена | 100% |
| **Фаза 5:** Observability | ✅ Завершена | 100% |
| **Фаза 6:** Automation | ✅ Завершена | 100% |
| **Фаза 7:** Agent Inheritance | ✅ Завершена | 100% |
| **Фаза 8:** AI-First Interface | ✅ Завершена | 100% |
| **Фаза 8.5:** Telegram Bot | 🔄 В работе | 25% |
| **Фаза 9:** Documentation Agent | ⏳ Планируется | 0% |
| **Фаза 10:** Remote Testing Infra | 🔄 В работе | 75% |
| **Фаза 8.5:** Telegram Bot | 🔄 В работе | 25% |
| **Фаза 9:** Documentation Agent | ⏳ Планируется | 0% |
| **Фаза 10:** Remote Testing Infra | 🔄 В работе | 75% |

### 🤖 Фаза 8.5: Telegram Bot Integration (НОВАЯ!)

### TELEBOT-001: Telegram Bot MVP ✅
- **Статус:** ВЫПОЛНЕНО
- **Приоритет:** ВЫСОКИЙ
- **Описание:** Telegram Bot для удалённой работы через OpenClaw
- **Экспертное мнение:** 13 экспертов — **8.1/10, ЕДИНОГЛАСНО** (см. `docs/experts-opinions-telegram-bot.md`)
- **Файлы:
  - ✅ openclaw/telegram-bot/src/bot.ts — главный файл бота (300+ строк)
  - ✅ openclaw/telegram-bot/src/types.ts — TypeScript типы
  - ✅ openclaw/telegram-bot/src/session-manager.ts — управление сессиями (150+ строк)
  - ✅ openclaw/telegram-bot/src/gateway-client.ts — WebSocket клиент (250+ строк)
  - ✅ openclaw/telegram-bot/src/commands/ — обработчики команд
  - ✅ openclaw/telegram-bot/src/utils/logger.ts — Winston logger
  - ✅ openclaw/telegram-bot/package.json — зависимости
  - ✅ openclaw/telegram-bot/tsconfig.json — TypeScript конфиг
  - ✅ openclaw/telegram-bot/Dockerfile — multi-stage build
  - ✅ openclaw/telegram-bot/.env.example — конфигурация
  - ✅ openclaw/telegram-bot/README.md — документация
  - ✅ openclaw/docker/docker-compose.yml — добавлен telegram-bot service
  - ✅ openclaw/docker/.env.example — добавлены TELEGRAM_BOT_TOKEN, AUTHORIZED_USER_IDS
- **Команды:**
  - ✅ /start — инициализация бота
  - ✅ /help — справка
  - ✅ /new — создание проекта
  - ✅ /status — статус системы
- **Возможности:**
  - ✅ WebSocket подключение к Gateway
  - ✅ Session management с timeout
  - ✅ User authorization (AUTHORIZED_USER_IDS)
  - ✅ Natural language support (через Gateway)
  - ✅ Progress indicators для операций
  - ✅ Auto-reconnect к Gateway
  - ✅ Graceful shutdown
  - **Интеграция:**
  - ✅ Добавлен в docker-compose.yml
  - ✅ Health check
  - ✅ Resource limits (CPU: 1, Memory: 512M)
- **Завершено:** 2025-02-02

### TELEBOT-002: Bot Testing & Validation ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Описание:** Тестирование бота с реальным Telegram API

### TELEBOT-003: Enhanced Commands ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Описание:** Дополнительные команды бота
- **Команды:**
  - ⏳ /deploy — деплой проекта
  - ⏳ /logs — просмотр логов
  - ⏳ /agents — управление AI агентами
  - ⏳ /projects — список проектов

### TELEBOT-004: Production Hardening ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Описание:** Подготовка к production
- **Задачи:**
  - ⏳ Redis для session persistence
  - ⏳ Rate limiting
  - ⏳ Enhanced error handling
  - ⏳ Metrics & monitoring (Prometheus)
  - ⏳ Alerting (Telegram notifications)

---

## 🚨 Процедуры восстановления

### Procedure 1: Container Restart (Level 1)

**Когда использовать:** Контейнеры crashed, но данные целы

```bash
# 1. SSH на сервер
ssh root@ainetic.tech

# 2. Проверить состояние
cd ~/projects/CodeFoundry/server
make status
make logs

# 3. Перезапустить контейнеры
make restart-test

# 4. Проверить health
make health

# 5. Если не помогло - перезапустить Docker
sudo systemctl restart docker
make start-test
```

**Expected time:** 5 минут

---

### Procedure 2: Volume Recovery (Level 2)

**Когда использовать:** Утеряны volumes, данные недоступны

```bash
# 1. SSH на сервер
ssh root@ainetic.tech

# 2. Остановить контейнеры
cd ~/projects/CodeFoundry/server
make stop-test

# 3. Восстановить volumes из бэкапа
make backup-restore 20250203-120000

# 4. Перезапустить контейнеры
make start-test

# 5. Проверить данные
make shell
ls -la /var/log/tests/
```

**Expected time:** 30 минут

---

### Procedure 3: Full Recovery (Level 2)

**Когда использовать:** Полная потеря сервера

```bash
# 1. Получить новый сервер (или переустановить OS)
# 2. SSH на новый сервер

# 3. Установить зависимости
bash <(curl -s https://raw.githubusercontent.com/.../server/setup.sh)

# 4. Клонировать проект
git clone git@github.com:RussianLioN/CodeFoundry.git ~/projects/CodeFoundry

# 5. Настроить окружение
cd ~/projects/CodeFoundry/server
cp .env.test.example .env.test
nano .env.test  # Вставить реальные значения

# 6. Восстановить из бэкапа (если есть)
make backup-restore LATEST

# 7. Запуск
make sync
make start-test
```

**Expected time:** 2-4 часа

---

## 🧪 Тестирование восстановления

### Validation Checklist

После восстановления проверить:

```bash
# 1. Container status
make status
# Expected: All containers "Up X seconds"

# 2. Gateway health
curl http://localhost:18790/health
# Expected: {"status":"healthy"}

# 3. Telegram bot
./test-telegram.sh --scenario start
# Expected: Bot responds to /start

# 4. Logs accessible
make logs-short
# Expected: Recent logs shown

# 5. Backup available
make backup-list
# Expected: List of backups shown
```

### Success Criteria

- [ ] Все контейнеры в состоянии "Up"
- [ ] Gateway health check passes
- [ ] Telegram bot отвечает на команды
- [ ] Логи доступны
- [ ] Backup создан (если это была backup операция)
- [ ] RTO met (< 4 часа)

---

## 📚 Runbooks

### Runbook 1: Gateway Down

**Symptom:**
```bash
$ curl http://localhost:18790/health
curl: (7) Failed to connect
```

**Recovery:**
```bash
# 1. Check container
docker ps | grep gateway

# 2. Check logs
make logs-gateway

# 3. Restart
docker restart codefoundry-test-gateway-1

# 4. If fails - full recovery
make stop-test
docker-compose -f server/docker-compose.test.yml up -d gateway
```

---

### Runbook 2: Ollama Models Lost

**Symptom:**
```bash
$ docker logs codefoundry-test-ollama-1
Error: model not found
```

**Recovery:**
```bash
# 1. Check volume
docker volume ls | grep ollama

# 2. Restore from backup
BACKUP_TIMESTAMP=$(ls -t /backups/codefoundry/ | grep ollama | tail -1)
make backup-restore $BACKUP_TIMESTAMP

# 3. Verify
docker exec codefoundry-test-ollama-1 ollama list
```

---

### Runbook 3: Server Unreachable

**Symptom:**
```bash
$ ssh root@ainetic.tech
ssh: connect to host ainetic.tech port 22: Connection refused
```

**Recovery:**
```bash
# 1. Check via VPS console (DigitalOcean, etc.)
# 2. Verify server is running
# 3. Check firewall rules
# 4. Restart SSH service
sudo systemctl restart sshd

# 5. If server is down - create new one
```

---

## 🔒 Prevention

### Daily Checks

```bash
# Cron job: /etc/cron.d/codefoundry-backup
0 2 * * * root /root/projects/system-prompts/server/backup.sh
```

### Weekly Maintenance

```bash
# Review backup retention
make backup-list

# Check disk usage
df -h

# Review logs
make logs

# Test restore procedure
make backup-test
```

---

## 📞 Emergency Contacts

| Situation | Contact | Priority |
|-----------|---------|----------|
| Server down | VPS provider | URGENT |
| Application crash | DevOps engineer | HIGH |
| Data loss | Backup & DR specialist | CRITICAL |
| Security incident | Security team | CRITICAL |

---

## 📊 RTO/RPO Definitions

| Metric | Target | Current |
|--------|--------|---------|
| RTO | 4 hours | TBD |
| RPO | 24 hours | TBD |
| Data Loss Target | 0% | 0% |

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
**Next Review:** After first real recovery event
