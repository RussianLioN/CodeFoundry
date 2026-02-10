# 🔧 Skill: Docker Deploy

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🚀 DevOps Skills](#)
---

## Description

Автоматизация деплоя через Docker и Docker Compose на различные окружения.

---

## 🎯 Capabilities

### 🚀 Deploy to Environment

**Использование:**
```
👤 "Задеплой на стейджинг"
👤 "Перезапусти контейнеры"
👤 "Деплой новой версии сервиса"
```

**Действия:**
```bash
1. Читает docker-compose.yml конфигурацию
2. Собирает или pull-ит образы
3. Запускает/перезапускает контейнеры
4. Проверяет здоровье сервисов (health check)
5. Показывает результаты
```

---

### 📦 Build Images

**Использование:**
```
👤 "Собери docker image"
👤 "Пересобери образ после изменений"
👤 "Оптимизируй docker образ"
```

**Действия:**
```bash
# Multi-stage build для оптимизации
docker build -t myapp:latest -f Dockerfile .

# С кэшированием слоёв
docker build --cache-from=base -t myapp:latest .

# Для production
docker build --target production -t myapp:prod .
```

---

### 🔄 Service Management

**Использование:**
```
👤 "Проверь статус контейнеров"
👤 "Останови сервис user-service"
👤 "Перезапусти api-gateway"
👤 "Покажи логи сервиса"
```

**Действия:**
```bash
# Статус всех сервисов
docker-compose ps

# Статус конкретного сервиса
docker-compose ps user-service

# Остановка
docker-compose stop user-service

# Запуск
docker-compose start user-service

# Перезапуск
docker-compose restart api-gateway

# Логи
docker-compose logs -f user-service

# Логи за последние 100 строк
docker-compose logs --tail=100 user-service
```

---

### 🔍 Health Checks

**Использование:**
```
👤 "Проверь здоровье всех сервисов"
👤 "Доступен ли API?"
👤 "Сервисы здоровы?"
```

**Действия:**
```bash
# Проверка всех сервисов
docker-compose ps

# Health check через API
curl -f http://localhost:3000/health || echo "API is down"

# Docker health check
docker inspect --format='{{.State.Health.Status}}' api-gateway

# Подробная проверка
docker-compose config
docker-compose ps -a
```

---

### 🌐 Multi-Environment Deploy

**Окружения:**
- `local` — локальная разработка
- `staging` — тестовое окружение
- `production` — боевое окружение

**Использование:**
```
👤 "Задеплой на staging"
👤 "Деплой на прод"
```

**Действия:**
```bash
# Staging
docker-compose -f docker-compose.staging.yml up -d

# Production
docker-compose -f docker-compose.prod.yml up -d

# Rolling update (production)
docker-compose -f docker-compose.prod.yml up -d --force-recreate
```

---

## 🔗 Integration with Tools

Использует инструменты:
- **bash** — выполнение команд
- **docker** — управление контейнерами
- **write** — создание конфигураций
- **read** — чтение текущих файлов

---

## 📝 Docker Compose Templates

### Basic Web Service

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Microservices

```yaml
version: '3.8'

services:
  api-gateway:
    build: ./services/api-gateway
    ports:
      - "8080:8080"
    depends_on:
      - user-service
      - order-service

  user-service:
    build: ./services/user-service
    environment:
      - DB_HOST=postgres
    depends_on:
      - postgres

  order-service:
    build: ./services/order-service
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis
```

---

## 🚀 Deploy Workflows

### New Service Deployment

```
1. 📝 Созда docker-compose.yml
2. 🐳 Созда Dockerfile (если нет)
3. 🔧 Настроить переменные окружения
4. 🚀 Запуск deploy
5. ✅ Проверка здоровья
```

### Update Deployment

```
1. 📥 Pull изменений
2. 🏗️ Пересобрать образы
3. 🔄 Перезапустить сервисы
4. ✅ Проверить новую версию
```

### Rollback Deployment

```
1. 🔄 git revert или checkout предыдущей версии
2. 🏗️ Пересобрать старые образы
3. 🚀 Запустить предыдущую версию
4. ✅ Проверить откат
```

---

## 🔧 Configuration Management

### Environment Variables

```bash
# .env файл
DB_HOST=postgres
DB_PORT=5432
DB_NAME=myapp
DB_USER=user
DB_PASSWORD=secure_password
REDIS_HOST=redis
API_PORT=3000
NODE_ENV=production
```

### Secrets Management

```bash
# Docker secrets (Swarm mode)
echo "secure_password" | docker secret create db_password

# В docker-compose.yml
secrets:
  db_password:
    external: true
```

---

## 📊 Monitoring Deployments

### Health Check Scripts

```bash
#!/bin/bash
# health-check.sh

services=("api-gateway" "user-service" "order-service")

for service in "${services[@]}"; do
  echo "Checking $service..."
  if docker-compose ps $service | grep -q "Up"; then
    echo "✅ $service is UP"
  else
    echo "❌ $service is DOWN"
  fi
done
```

### Metrics Collection

```bash
# Docker stats
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Container logs
docker-compose logs --tail=100 --follow
```

---

## 🛡️ Security Best Practices

### 1. Secrets Management

```yaml
# ❌ НЕ ДЕЛАЙТЕ ТАК:
environment:
  - DB_PASSWORD=secret123

# ✅ ПРАВИЛЬНО:
secrets:
  db_password:
    external: true
environment:
  - DB_PASSWORD_FILE=/run/secrets/db_password
```

### 2. User Permissions

```dockerfile
# ❌ НЕ ДЕЛАЙТЕ ТАК:
USER root

# ✅ ПРАВИЛЬНО:
RUN adduser -D appuser
USER appuser
```

### 3. Image Scanning

```bash
# Сканирование на уязвимости
trivy image myapp:latest

# Проверка base образов
docker scout cves alpine:3.19
```

---

## 📝 Usage Examples

### Сценарий 1: Новый Деплой

```
👤 "Задеплой новую версию API на staging"

🤖 Docker Deploy Skill:
    1. 📋 Reading docker-compose.staging.yml...
    2. 🏗️ Pulling latest images...
    3. 🔄 Recreating containers...
    4. ✅ Deployed to staging:
       - api-gateway → v2.1.0 (from v2.0.0)
       - user-service → v1.5.0 (from v1.4.0)
    5. 🧪 Running health checks...
    6. ✅ All services healthy
```

### Сценарий 2: Rollback

```
👤 "Откали последний деплой, сломалось"

🤖 Docker Deploy Skill:
    1. 📋 Current version: v2.1.0
    2. 🔄 Rolling back to v2.0.0...
    3. 🏗️ Rebuilding previous images...
    4. 🚀 Deployed v2.0.0
    5. ✅ Rollback complete
    6. 📊 Status: All systems operational
```

### Сценарий 3: Voice Command

```
🗣️ "Перезапусти контейнеры и покажи статус"

🤖 Docker Deploy Skill:
    1. 🔄 Restarting containers...
    2. ✅ Restarted: 3 containers
    3. 📊 Current status:
       - api-gateway: ✅ Up (健康)
       - user-service: ✅ Up (健康)
       - order-service: ⚠️ Restarting...
    4. ✅ All systems operational
```

---

## 🔗 Voice Commands

| Голосовая команда | Действие |
|-------------------|----------|
| "Задеплой на стейджинг" | Deploy to staging |
| "Перезапусти сервис" | Restart service |
| "Останови все контейнеры" | Stop all |
| "Запусти всё" | Start all |
| "Покажи статус контейнеров" | Show status |
| "Собери образ" | Build image |
| "Покажи логи" | Show logs |

---

## 🐛 Troubleshooting

### Проблема: Контейнер не запускается

```
👤 "Контейнер падает с ошибкой"

🤖 Docker Deploy Skill:
    1. 🔍 Checking logs...
    2. 📋 Found: Port 3000 already in use
    3. 💬 Solutions:
       a) Kill process on port 3000: lsof -ti:3000 | xkill -9
       b) Change port in docker-compose.yml
       c) Check for conflicting containers
```

### Проблема: Out of Memory

```
👤 "Мало памяти на сервере"

🤖 Docker Deploy Skill:
    1. 📊 Checking resource usage...
    2. 💡 Recommendations:
       a) Limit container memory
       b) Increase server RAM
       c) Use docker-compose down to free resources
```

---

## 📚 См. Также

- [🚀 DevOps Skills Index](../README.md)
- [🔧 CI Pipeline](ci-pipeline.md)
- [📊 Monitoring](monitoring.md)
- [↩️ Rollback](rollback.md)
- [🎯 Workspace](../README.md)
- [🤖 Agents](../AGENTS.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🐳 Docker Deploy](#)
