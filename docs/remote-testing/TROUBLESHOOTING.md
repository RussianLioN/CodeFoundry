# 🔧 CodeFoundry Remote Testing - Troubleshooting

> Решение проблем при работе с remote testing на ainetic.tech

---

## 📋 Содержание

- [Контейнеры](#контейнеры)
- [Telegram Bot](#telegram-bot)
- [Gateway](#gateway)
- [Синхронизация](#синхронизация)
- [Сессии](#сессии)
- [Мониторинг](#мониторинг)
- [Производительность](#производительность)

---

## 🐳 Контейнеры

### Контейнер не запускается

**Симптомы:**
```bash
$ make start-test
ERROR: for gateway  Cannot create container for service gateway
```

**Решения:**

1. **Проверить свободное место:**
```bash
df -h
docker system df
```

2. **Очистить ресурсы:**
```bash
docker system prune -a
make clean-all
```

3. **Проверить конфликты портов:**
```bash
netstat -tulpn | grep -E '18789|18790'
```

4. **Пересоздать сеть:**
```bash
docker network rm codefoundry-test-net
make start-test
```

### Контейнер постоянно перезапускается

**Симптомы:**
```bash
$ make status
gateway    Restarting (1) 5 seconds ago
```

**Решения:**

1. **Посмотреть логи:**
```bash
docker logs --tail=100 codefoundry-test-gateway-1
```

2. **Проверить health check:**
```bash
docker inspect codefoundry-test-gateway-1 | jq '.[0].State.Health'
```

3. **Проверить ресурсы:**
```bash
docker stats codefoundry-test-gateway-1
```

4. **Пересобрать образ:**
```bash
make rebuild
```

### Нет доступа к контейнеру

**Симптомы:**
```bash
$ make shell
ERROR: No container found
```

**Решения:**

1. **Проверить список контейнеров:**
```bash
docker ps -a | grep codefoundry
```

2. **Использовать правильное имя:**
```bash
docker ps --filter "name=codefoundry" --format "{{.Names}}"
```

3. **Запустить контейнер:**
```bash
make start-test
```

---

## 🤖 Telegram Bot

### Бот не отвечает на команды

**Симптомы:**
Команды в Telegram не дают ответа.

**Диагностика:**

1. **Проверить токен:**
```bash
curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getMe" | jq
```

2. **Проверить авторизованных пользователей:**
```bash
grep AUTHORIZED_USER_IDS server/.env.test
```

3. **Проверить работу контейнера:**
```bash
make logs-bot
docker ps | grep telegram-bot
```

**Решения:**

1. **Неверный токен:**
```bash
# Получить новый токен у @BotFather
nano server/.env.test
# TELEGRAM_BOT_TOKEN=новый_токен
make restart-test
```

2. **User ID не в списке:**
```bash
# Узнать свой ID у @userinfobot
nano server/.env.test
# AUTHORIZED_USER_IDS=ваш_id
make restart-test
```

3. **Контейнер не запущен:**
```bash
make start-test
```

### Бот отвечает "Internal Error"

**Симптомы:**
```
Bot: "Произошла внутренняя ошибка"
```

**Диагностика:**

1. **Проверить логи бота:**
```bash
make logs-bot
docker logs --tail=50 codefoundry-test-telegram-bot-1
```

2. **Проверить подключение к Gateway:**
```bash
docker logs codefoundry-test-gateway-1 | grep -i error
```

**Решения:**

1. **Gateway недоступен:**
```bash
make restart-test
# Или только gateway
docker restart codefoundry-test-gateway-1
```

2. **Ошибка в коде:**
```bash
make shell
cd /workspace/openclaw/telegram-bot
npm test
```

### Бот не подключается к Gateway

**Симптомы:**
```
Bot logs: "Failed to connect to Gateway"
```

**Диагностика:**

1. **Проверить Gateway:**
```bash
curl http://localhost:18790/health
```

2. **Проверить сеть:**
```bash
docker network inspect codefoundry-test-net
```

**Решения:**

1. **Gateway не запущен:**
```bash
docker ps | grep gateway
docker start codefoundry-test-gateway-1
```

2. **Неверный хост в .env.test:**
```bash
grep GATEWAY_HOST server/.env.test
# Должно быть: GATEWAY_HOST=gateway (не localhost!)
```

3. **Проблемы с сетью:**
```bash
docker network rm codefoundry-test-net
make start-test
```

---

## 🌐 Gateway

### Gateway не отвечает на /health

**Симптомы:**
```bash
$ curl http://localhost:18790/health
curl: (7) Failed to connect
```

**Решения:**

1. **Проверить запущен ли контейнер:**
```bash
docker ps | grep gateway
```

2. **Проверить логи:**
```bash
docker logs codefoundry-test-gateway-1
```

3. **Перезапустить:**
```bash
docker restart codefoundry-test-gateway-1
```

### Gateway возвращает ошибки

**Симптомы:**
```
{"error": "Failed to process request"}
```

**Диагностика:**

1. **Полные логи:**
```bash
docker logs --tail=100 codefoundry-test-gateway-1
```

2. **Проверить Ollama (если включен):**
```bash
docker logs codefoundry-test-ollama-1
curl http://localhost:11434/api/tags
```

**Решения:**

1. **Ollama недоступен:**
```bash
# Отключить в .env.test
OLLAMA_ENABLED=false
make restart-test
```

2. **Ошибка в конфигурации:**
```bash
grep GATEWAY_ server/.env.test
```

---

## 🔄 Синхронизация

### Git push не синхронизируется

**Симптомы:**
```bash
$ git push origin main
# OK
$ ssh ainetic.tech "make sync"
# Already up to date (но это не так!)
```

**Решения:**

1. **Принудительная синхронизация:**
```bash
make sync-force
```

2. **Проверить ветку:**
```bash
git branch
git status
```

3. **Вручную на сервере:**
```bash
ssh ainetic.tech
cd ~/projects/CodeFoundry
git fetch origin
git reset --hard origin/main
```

### Локальные изменения теряются

**Симптомы:**
```bash
$ make sync
ERROR: You have uncommitted changes
```

**Решения:**

1. **Сохранить изменения:**
```bash
git add .
git commit -m "Local changes"
git push
make sync
```

2. **Временно стэшить:**
```bash
git stash
make sync
git stash pop
```

3. **Отменить (если не нужны):**
```bash
make sync-force
```

---

## 📦 Сессии

### Сессия не создаётся

**Симптомы:**
```bash
$ ./telegram-test-session.sh create my-test
ERROR: Session already exists
```

**Решения:**

1. **Остановить старую сессию:**
```bash
./telegram-test-session.sh stop my-test
./telegram-test-session.sh create my-test
```

2. **Использовать другое имя:**
```bash
./telegram-test-session.sh create my-test-2
```

3. **Авто-имя:**
```bash
./telegram-test-session.sh create
```

### Не могу подключиться к сессии

**Симптомы:**
```bash
$ ./telegram-test-session.sh shell my-test
ERROR: Container not running
```

**Решения:**

1. **Проверить статус сессии:**
```bash
./telegram-test-session.sh list
```

2. **Создать заново:**
```bash
./telegram-test-session.sh create my-test
```

---

## 📊 Мониторинг

### Grafana не показывает данные

**Симптомы:**
Дашборд пустой, "No data".

**Решения:**

1. **Проверить Prometheus:**
```bash
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

2. **Проверить datasource:**
```bash
curl http://localhost:3000/api/datasources
# Проверить что Prometheus "healthy"
```

3. **Перезапустить мониторинг:**
```bash
cd ~/projects/CodeFoundry/server
docker-compose -f docker-compose.monitoring.yml restart
```

### Алерты не работают

**Симптомы:**
Алерты в Prometheus firing, но уведомлений нет.

**Решения:**

1. **Проверить Alertmanager:**
```bash
# Не запущен - это нормально если не настроен
docker ps | grep alertmanager
```

2. **Настроить webhook:**
```bash
# Добавить в prometheus/alerts/testing-alerts.yml
```

---

## ⚡ Производительность

### Медленный запуск контейнеров

**Симптомы:**
`make start-test` занимает > 30 секунд.

**Решения:**

1. **Проверить образы:**
```bash
docker images | grep codefoundry
```

2. **Предзагрузить образы:**
```bash
docker pull node:20-alpine
```

3. **Увеличить ресурсы:**
```bash
docker info | grep -E "CPUs|Memory"
```

### Высокое использование CPU

**Симптомы:**
```bash
$ docker stats
CONTAINER   CPU%  MEM%
gateway     150%  15%
```

**Решения:**

1. **Проверить процесс:**
```bash
docker top codefoundry-test-gateway-1
```

2. **Ограничить ресурсы:**
```bash
# В docker-compose.test.yml
deploy:
  resources:
    limits:
      cpus: '0.5'
```

3. **Перезапустить:**
```bash
make restart-test
```

### Утечка памяти

**Симптомы:**
Память растёт постоянно.

**Диагностика:**

1. **Мониторинг:**
```bash
watch -n 5 'docker stats --no-stream | grep gateway'
```

2. **Проверить лимиты:**
```bash
docker inspect codefoundry-test-gateway-1 | jq '.[0].HostConfig.Memory'
```

**Решения:**

1. **Перезапустить контейнер:**
```bash
docker restart codefoundry-test-gateway-1
```

2. **Настроить лимиты:**
```bash
# В docker-compose.test.yml
mem_limit: 512m
memswap_limit: 1g
```

---

## 🆘 Экстренная помощь

### Полный сброс

**Когда ничего не помогает:**

```bash
# 1. Остановить всё
make clean-all

# 2. Очистить Docker
docker system prune -a --volumes

# 3. Удалить проект (сохраните .env.test!)
cd /root
rm -rf ~/projects/CodeFoundry

# 4. Переклонировать
git clone git@github.com:RussianLioN/CodeFoundry.git ~/projects/CodeFoundry
cd ~/projects/CodeFoundry/server

# 5. Восстановить .env.test
cp ~/.env.test.backup .env.test

# 6. Начать заново
make sync
make start-test
```

### Сохранить логи для отладки

```bash
# Собрать все логи
mkdir -p /tmp/codefoundry-debug
docker logs codefoundry-test-gateway-1 > /tmp/codefoundry-debug/gateway.log
docker logs codefoundry-test-telegram-bot-1 > /tmp/codefoundry-debug/bot.log
docker ps -a > /tmp/codefoundry-debug/containers.txt
docker stats --no-stream > /tmp/codefoundry-debug/stats.txt

# Архив
tar czf /tmp/codefoundry-debug-$(date +%Y%m%d).tar.gz /tmp/codefoundry-debug
```

---

## 📞 Получить помощь

Если проблема не решена:

1. Собрать логи (см. выше)
2. Создать issue: https://github.com/RussianLioN/CodeFoundry/issues
3. Приложить:
   - Версию (`make version`)
   - Логи (`make logs-short`)
   - Конфигурацию (без токенов!)

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
