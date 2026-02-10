# 🐳 OpenClaw Docker Stack

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🐳 Docker](#)

---

## Обзор

Полный Docker stack для OpenClaw с **Ollama** и **gemini-3-flash** моделью.

```
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Stack Architecture                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  openclaw-gateway (Node.js)                            │    │
│  │  • WebSocket Server :18789                             │    │
│  │  • Agent Orchestration                                 │    │
│  │  • Telegram Bot Integration                            │    │
│  │  • Session Management                                  │    │
│  └───────────────────┬────────────────────────────────────┘    │
│                      │                                         │
│                      ▼                                         │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  ollama-service (AI Runtime)                           │    │
│  │  • Ollama Server :11434                                │    │
│  │  • gemini-3-flash model                                │    │
│  │  • 131K context window                                 │    │
│  │  • Persistent model storage                            │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  Volumes:                                                        │
│  • ollama_models    - Model persistence                         │
│  • openclaw_logs    - Gateway logs                             │
│  • workspace/       - CodeFoundry + projects                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Требования

- Docker Engine 20.10+
- Docker Compose 2.0+
- 8GB RAM минимум (16GB рекомендуется)
- 10GB дисковое пространство для моделей

**Опционально для GPU:**
- NVIDIA Docker Runtime
- CUDA 12.0+
- NVIDIA GPU с 8GB+ VRAM

---

## 🚀 Быстрый Старт

### 1. Подготовка

```bash
cd openclaw/docker

# Создать .env файл
cat > .env << 'EOF'
# Workspace
WORKSPACE_DIR=./workspace

# Telegram Bot (опционально)
TELEGRAM_BOT_TOKEN=your_token_here
TELEGRAM_WEBHOOK_SECRET=your_secret_here

# Tailscale (опционально)
TS_AUTHKEY=your_tailscale_authkey_here

# Ollama
OLLAMA_BASE_URL=http://ollama-service:11434
OLLAMA_MODEL=gemini-3-flash

# Gateway
GATEWAY_PORT=18789
NODE_ENV=production
EOF
```

### 2. Запуск

```bash
# Автоматический запуск с инициализацией
chmod +x scripts/start-stack.sh
./scripts/start-stack.sh

# Или вручную:
docker-compose up -d
```

### 3. Инициализация Ollama

```bash
# Автоматическая инициализация
docker-compose exec ollama-service /models/init-ollama.sh

# Или вручную:
docker-compose exec ollama-service ollama pull gemini-3-flash
```

### 4. Проверка

```bash
# Статус
docker-compose ps

# Логи
docker-compose logs -f openclaw-gateway

# Тест
docker-compose exec ollama-service ollama run gemini-3-flash "Say OK"
```

---

## 📂 Структура

```
openclaw/docker/
├── docker-compose.yml          # Stack definition
├── Dockerfile.openclaw         # Gateway container
├── package.json                # Gateway dependencies
├── config/
│   └── openclaw.json          # Gateway configuration
├── ollama/
│   └── modelfile             # gemini-3-flash model definition
├── scripts/
│   ├── start-stack.sh        # Quick start script
│   └── init-ollama.sh        # Ollama initialization
└── README.md                  # This file
```

---

## 🐳 Сервисы

### openclaw-gateway

**Node.js сервис** для оркестрации AI агентов.

| Порт | Описание |
|------|----------|
| 18789 | Gateway WebSocket |
| 18790 | Health check endpoint |
| 18791 | Prometheus metrics |

### ollama-service

**AI runtime** на базе Ollama.

| Возможность | Значение |
|-------------|----------|
| Модель | gemini-3-flash |
| Контекст | 131K tokens |
| Порт | 11434 |
| GPU | Опционально (NVIDIA) |

---

## ⚙️ Конфигурация

### GPU Поддержка

Раскомментируйте в `docker-compose.yml`:

```yaml
ollama-service:
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu]
```

### Tailscale Tunnel

Опционально для удалённого доступа:

```bash
docker-compose --profile remote up -d
```

---

## 🔧 Команды

### Управление

```bash
# Запуск
docker-compose up -d

# Остановка
docker-compose down

# Рестарт
docker-compose restart

# Логи
docker-compose logs -f openclaw-gateway
```

### Ollama

```bash
# Список моделей
docker-compose exec ollama-service ollama list

# Информация о модели
docker-compose exec ollama-service ollama show gemini-3-flash

# Тест
docker-compose exec ollama-service ollama run gemini-3-flash "Hello"
```

---

## 🔗 Подключение

### WebSocket

```javascript
const ws = new WebSocket('ws://localhost:18789/ws');
ws.send(JSON.stringify({
  type: 'chat',
  content: 'Создай проект telegram-bot'
}));
```

### HTTP API

```bash
# Health check
curl http://localhost:18790/health

# Metrics
curl http://localhost:18791/metrics
```

### Ollama API

```bash
# Generate
curl http://localhost:11434/api/generate -d '{
  "model": "gemini-3-flash",
  "prompt": "Say OK"
}'
```

---

## 🐛 Troubleshooting

### Ollama не запускается

```bash
# Проверить логи
docker-compose logs ollama-service

# Увеличить start_period в healthcheck
```

### Модель не загружается

```bash
# Переинициализировать
docker-compose exec ollama-service /models/init-ollama.sh

# Проверить диск
docker system df
```

### Недостаточно памяти

```bash
# Уменьшить контекст в modelfile
PARAMETER num_ctx 32768  # вместо 131072
```

---

## 🔒 Sandbox Mode (Дополнительно)

OpenClaw поддерживает изолированный режим для non-main сессий:

```
Main Session → Полный доступ к хосту
Other Sessions → Docker sandbox контейнер
```

**Конфигурация:**

```json
{
  "sandbox": {
    "enabled": true,
    "image": "openclaw/sandbox:latest",
    "allowlist": ["bash", "read", "write"],
    "denylist": ["browser", "canvas"]
  }
}
```

---

## 📊 Мониторинг

```bash
# Health
curl http://localhost:18790/health

# Метрики
curl http://localhost:18791/metrics

# Статистика Docker
docker stats openclaw-gateway openclaw-ollama
```

---

## 🔄 Production

### Registry

```bash
docker tag openclaw/gateway registry.example.com/openclaw:1.0.0
docker push registry.example.com/openclaw:1.0.0
```

### Swarm

```yaml
deploy:
  mode: replicated
  replicas: 1
  restart_policy:
    condition: on-failure
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openclaw
spec:
  replicas: 1
  selector:
    matchLabels:
      app: openclaw
```

---

## 📚 См. Также

- [🦞 OpenClaw README](../README.md)
- [🎯 Workspace](../workspace/README.md)
- [🤖 Agents](../workspace/AGENTS.md)

---

## 📝 Лицензия

MIT License

---

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🐳 Docker](#)
