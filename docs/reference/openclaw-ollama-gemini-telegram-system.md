# OpenClaw + Ollama + Gemini 3 Flash + Telegram: Reference Architecture

> **Эталонный документ** по построению агентной системы на удалённом VDS сервере.
> Основан на исследовании 15+ актуальных источников (февраль 2026).
>
> **Дата:** 2026-02-06
> **Статус:** REFERENCE (эталон)
> **Консилиум:** 13 экспертов (единогласное одобрение, 8.1/10)

---

## 1. Executive Summary

### Целевая система

Агентная система для удалённой разработки:
- **OpenClaw** — AI-агент в Docker-контейнере (orchestration layer)
- **Ollama** — прокси/шлюз для облачной LLM модели
- **Gemini 3 Flash Preview** — облачная модель Google через Ollama Cloud
- **Telegram** — пользовательский интерфейс (бот)
- **VDS** — удалённый сервер (ainetic.tech)

### Ключевые выводы

| Аспект | Рекомендация |
|--------|-------------|
| **Архитектура** | OpenClaw (Docker) + Ollama (Docker, v0.3.12+) + `gemini-3-flash-preview:cloud` |
| **Модель** | Облачная через Ollama Cloud (не локальная — VDS слишком слабый) |
| **Контейнеры** | 3 сервиса: ollama, gateway, telegram-bot + bridge network |
| **Аутентификация** | `OLLAMA_API_KEY` (обязателен для cloud моделей) |
| **Health Check** | WebSocket client pattern (pgrep + netstat), НЕ HTTP endpoint |
| **Рейтинг экспертов** | 8.1/10 — РЕКОМЕНДУЕТСЯ К РЕАЛИЗАЦИИ |

---

## 2. Architecture Overview

### Рекомендуемая архитектура: Ollama Cloud Proxy

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Telegram       │     │   OpenClaw        │     │   Ollama         │
│   Bot            │────>│   Gateway         │────>│   (Docker)       │
│   (WebSocket     │     │   :18789/:18790   │     │   :11434         │
│    client)       │     │                   │     │                  │
└─────────────────┘     └──────────────────┘     └────────┬─────────┘
                                │                          │
                                v                          v
                        ┌──────────────┐          ┌───────────────┐
                        │   Workspace   │          │ Ollama Cloud   │
                        │   /workspace  │          │ (Google Gemini │
                        │              │          │  3 Flash)      │
                        └──────────────┘          └───────────────┘
```

**Поток данных:**
1. Пользователь отправляет сообщение в Telegram
2. Telegram Bot подключается к OpenClaw Gateway через WebSocket (`ws://gateway:18789`)
3. Gateway обрабатывает запрос и отправляет его в Ollama API (`http://ollama:11434/v1`)
4. Ollama маршрутизирует запрос к облачной модели `gemini-3-flash-preview:cloud` через Ollama Cloud
5. Ответ возвращается по обратному пути в Telegram

### Альтернативная архитектура: Google proxy-to-gemini

```
Telegram --> OpenClaw --> proxy-to-gemini (Docker) --> Google Gemini API
```

Google предоставляет официальный proxy-sidecar ([google-gemini/proxy-to-gemini](https://github.com/google-gemini/proxy-to-gemini)):
```bash
docker run -p 5555:5555 \
  -e GEMINI_API_KEY=$GEMINI_API_KEY \
  googlegemini/proxy-to-gemini -api=ollama
```

**Сравнение:**

| Критерий | Ollama Cloud | proxy-to-gemini |
|----------|-------------|-----------------|
| Простота | Проще (1 контейнер Ollama) | Сложнее (доп. контейнер) |
| Авторизация | OLLAMA_API_KEY | GEMINI_API_KEY (Google) |
| Контроль | Через Ollama | Прямой к Google API |
| Стоимость | Ollama pricing | Google API pricing (free tier) |
| Рекомендация | **РЕКОМЕНДУЕТСЯ** | Альтернатива |

---

## 3. Component Details

### 3.1 OpenClaw

**Описание:** Open-source AI agent framework (бывш. Clawdbot, затем Moltbot, переименован из-за торговых марок Anthropic).

| Свойство | Значение |
|----------|---------|
| **GitHub** | [github.com/openclaw/openclaw](https://github.com/openclaw/openclaw) |
| **Docs** | [docs.openclaw.ai](https://docs.openclaw.ai) |
| **Порты** | 18789 (Gateway WebSocket), 18790 (Bridge HTTP) |
| **Volumes** | `~/.openclaw` (config), `~/openclaw/workspace` (files) |
| **Install** | `npm install -g openclaw@latest` или Docker |

#### Архитектура OpenClaw (4 слоя)

1. **Brain (LLM Layer)** — Model-agnostic. Подключается к Claude, OpenAI, Gemini через API или локально через Ollama
2. **Sandbox (Containerized Execution)** — Изолированное выполнение в Docker
3. **Skills (Extensibility)** — 100+ предустановленных AgentSkills
4. **Messaging Gateway** — Telegram, WhatsApp, Discord, Signal, Slack, iMessage и др.

#### Конфигурация модели (models.json)

**КРИТИЧЕСКИ ВАЖНО:** Поле `api` обязательно! Без него ошибка: `"No API provider registered for api: undefined"`

```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://ollama-service:11434/v1",
      "apiKey": "ollama-local",
      "api": "openai-completions",
      "models": [
        {
          "id": "gemini-3-flash-preview:cloud",
          "name": "Gemini 3 Flash Preview (Cloud)",
          "contextWindow": 1000000
        }
      ]
    }
  }
}
```

**Путь файла:** `~/.openclaw/agents/<agentId>/models.json`

#### Telegram интеграция

1. Создать бота через `@BotFather` в Telegram (команда `/newbot`)
2. Запустить `openclaw onboard` и выбрать "Telegram (Bot API)"
3. Ввести токен бота
4. Отправить сообщение боту для получения кода сопряжения
5. Запустить команду сопряжения в терминале

**Docs:** [docs.openclaw.ai/channels/telegram](https://docs.openclaw.ai/channels/telegram)

#### Дополнительные mount-точки

```bash
# Дополнительные директории хоста
OPENCLAW_EXTRA_MOUNTS="/home/user/projects,/var/log/app"

# Persistent home volume
OPENCLAW_HOME_VOLUME=openclaw_home
```

### 3.2 Ollama

**Описание:** Платформа для запуска LLM моделей (локально и в облаке).

| Свойство | Значение |
|----------|---------|
| **Docker Image** | `ollama/ollama:latest` |
| **Порт** | 11434 |
| **Cloud URL** | `https://api.ollama.cloud` |
| **Минимальная версия** | **v0.3.12+** (для cloud models) |
| **OpenAI совместимость** | `http://localhost:11434/v1/` (с v0.13.3) |

#### Ollama Cloud Models

Ollama Cloud запущен в декабре 2025. Облачные модели выполняются на GPU-серверах Ollama.

**Ключевые факты:**
- Cloud models ведут себя как обычные — `ls`, `run`, `pull`, `cp`
- Требуют Ollama **v0.3.12+**
- Требуют аккаунт на ollama.com и API key
- Тег `:cloud` обозначает облачное выполнение

**Настройка:**
```bash
# 1. Создать API key: https://ollama.com/settings/keys
# 2. Установить переменную
export OLLAMA_API_KEY=your_api_key

# 3. Запустить cloud model
ollama run gemini-3-flash-preview:cloud
```

#### Аутентификация

```bash
# Создание API key
# Перейти на https://ollama.com/settings/keys → "Generate API Key"

# Установка
export OLLAMA_API_KEY=your_api_key

# Использование в API
curl https://api.ollama.cloud/api/chat \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -d '{"model": "gemini-3-flash-preview:cloud", "messages": [...]}'
```

**Безопасность:** API key не истекает, но можно отозвать в любой момент. Не хранить в коде — использовать Docker secrets или `.env`.

#### Docker Deployment

```bash
# CPU-only
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama

# С NVIDIA GPU
docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

#### Предзагрузка модели при старте

```bash
#!/bin/bash
# entrypoint.sh — custom entrypoint для автоматической загрузки модели

# Запуск Ollama сервера в фоне
ollama serve &

# Ожидание готовности
until curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; do
  echo "Waiting for Ollama to start..."
  sleep 2
done

# Загрузка модели (если ещё не загружена)
if ! ollama list | grep -q "gemini-3-flash-preview"; then
  echo "Pulling gemini-3-flash-preview:cloud..."
  ollama pull gemini-3-flash-preview:cloud
fi

# Предзагрузка модели в память (пустой запрос)
curl -s http://localhost:11434/api/generate \
  -d '{"model": "gemini-3-flash-preview:cloud", "prompt": ""}' > /dev/null

echo "Model ready!"

# Ожидание завершения serve
wait
```

#### Переменные окружения Ollama

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_HOST` | `127.0.0.1` | Bind address |
| `OLLAMA_PORT` | `11434` | API port |
| `OLLAMA_API_KEY` | — | API key для cloud моделей |
| `OLLAMA_KEEP_ALIVE` | `5m` | Время хранения модели в памяти |
| `OLLAMA_NUM_PARALLEL` | `1` | Параллельные запросы |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Максимум загруженных моделей |
| `OLLAMA_MAX_QUEUE` | `512` | Размер очереди запросов |

### 3.3 Gemini 3 Flash Preview

**Описание:** Высокоскоростная thinking-модель Google для агентных workflow.

| Свойство | Значение |
|----------|---------|
| **Context Window** | 1,000,000 tokens (input) |
| **Max Output** | 64,000 tokens |
| **Input Types** | Text, images, audio, video, PDFs (multimodal) |
| **Output** | Text |
| **Thinking Levels** | minimal, low, medium, high (default: high) |
| **Tool Use** | Supported (Function Calling) |
| **Context Caching** | Automatic |
| **Batch API** | Supported |

#### Thinking Level (Configurable Reasoning)

```json
{
  "model": "gemini-3-flash-preview",
  "thinking_level": "medium",
  "messages": [{"role": "user", "content": "Analyze this code..."}]
}
```

| Level | Описание | Использование |
|-------|---------|---------------|
| `minimal` | Минимальное рассуждение | Простые запросы, быстрый ответ |
| `low` | Неглубокое рассуждение | Стандартные задачи |
| `medium` | Среднее рассуждение | Анализ кода, архитектура |
| `high` | Глубокое рассуждение (default) | Сложные задачи, debugging |

#### Бенчмарки

| Benchmark | Score |
|-----------|-------|
| GPQA Diamond | 90.4% |
| Humanity's Last Exam | 33.7% (без tools) |
| MMMU Pro | 81.2% |

*Превосходит Gemini 2.5 Pro при 3x скорости.*

#### Pricing (Ollama Cloud)

| Metric | Price (USD) |
|--------|------------|
| Input tokens | $0.50 / 1M |
| Output tokens | $3.00 / 1M |
| Free tier | Доступен (ежедневное использование) |

#### Pricing (Google API Direct)

| Tier | Input / 1M | Output / 1M |
|------|-----------|-------------|
| Free | $0 | $0 |
| Paid | ~$0.50 | ~$3.00 |

#### Rate Limits (Google API)

| Tier | RPM | TPM | RPD |
|------|-----|-----|-----|
| Free | 5-15 | 250,000 | ~1,000 |
| Paid | Higher | Higher | Higher |

#### Agentic Vision (новая фича)

Gemini 3 Flash поддерживает **Agentic Vision** — способность визуально анализировать UI и выполнять действия. Позволяет агенту "видеть" экран и взаимодействовать с интерфейсами.

### 3.4 Telegram Bot

**Описание:** Интерфейс пользователя через Telegram Bot API.

#### Telegram Bot API (актуальное состояние, 2025-2026)

**Новые возможности (2025):**
- Transactions с чатами, реакции на сервисные сообщения
- Business Accounts — полная кастомизация бренда (имя, username, bio, аватар)
- Paid Gifts — конвертации, трансферы, апгрейды
- Star балансы, Direct Messages в каналах
- Checklists — `sendChecklist`, `editMessageChecklist`
- Suggested Posts в каналах
- До 12 вариантов в polls (было 10)
- `getMyStarBalance` для баланса Stars

**API Reference:** [core.telegram.org/bots/api](https://core.telegram.org/bots/api)

#### Health Check (КРИТИЧЕСКИ ВАЖНО!)

Telegram Bot — это **WebSocket CLIENT** (не HTTP сервер). Стандартный HTTP health check НЕКОРРЕКТЕН.

```yaml
# НЕПРАВИЛЬНО (ORCH-011 инцидент):
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  # Ошибка: ECONNREFUSED — бот не слушает HTTP

# НЕПРАВИЛЬНО (текущий docker-compose.yml):
healthcheck:
  test: ["CMD", "node", "-e", "console.log('healthy')"]
  # Ошибка: всегда healthy, не проверяет реальное подключение

# ПРАВИЛЬНО:
healthcheck:
  test: ["CMD", "sh", "-c", "pgrep -f 'node.*bot.js' > /dev/null && netstat -tn | grep -q ':18789.*ESTABLISHED' || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

**Что проверяется:**
1. `pgrep -f 'node.*bot.js'` — процесс бота работает
2. `netstat -tn | grep -q ':18789.*ESTABLISHED'` — WebSocket подключение к Gateway активно

#### Health Check Patterns по типу сервиса

| Тип сервиса | Стратегия |
|-------------|-----------|
| HTTP Server | `curl -f http://localhost:PORT/health` |
| WebSocket Server | `netstat -l \| grep :PORT` |
| **WebSocket Client** | `pgrep + netstat ESTABLISHED` |
| Worker/Cron | `pgrep + log check` |

---

## 4. Docker Deployment Guide

### 4.1 Production docker-compose.yml

```yaml
version: "3.8"

services:
  # ============================================================
  # Ollama — AI Model Runtime (Cloud Proxy)
  # ============================================================
  ollama-service:
    image: ollama/ollama:latest
    container_name: openclaw-ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    volumes:
      - ollama_models:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_PORT=11434
      - OLLAMA_API_KEY=${OLLAMA_API_KEY}
      - OLLAMA_KEEP_ALIVE=30m
      - OLLAMA_NUM_PARALLEL=4
      - OLLAMA_MAX_QUEUE=10
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:11434/api/tags"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - openclaw-network
    deploy:
      resources:
        limits:
          cpus: "2"
          memory: 4G
        reservations:
          cpus: "0.5"
          memory: 1G

  # ============================================================
  # OpenClaw Gateway — Agent Orchestration
  # ============================================================
  openclaw-gateway:
    image: openclaw/openclaw:latest
    container_name: openclaw-gateway
    restart: unless-stopped
    ports:
      - "${OPENCLAW_GATEWAY_PORT:-18789}:18789"
      - "${OPENCLAW_BRIDGE_PORT:-18790}:18790"
    volumes:
      - ${OPENCLAW_CONFIG_DIR:-./config}:/home/node/.openclaw
      - ${OPENCLAW_WORKSPACE_DIR:-./workspace}:/home/node/.openclaw/workspace
    environment:
      - NODE_ENV=production
      - OLLAMA_BASE_URL=http://ollama-service:11434
      - OLLAMA_MODEL=gemini-3-flash-preview:cloud
      - GATEWAY_PORT=18789
      - GATEWAY_HOST=0.0.0.0
      - AI_PROVIDER=ollama
      - AI_TEMPERATURE=0.7
      - AI_MAX_TOKENS=4096
      - LOG_LEVEL=info
    depends_on:
      ollama-service:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-sf", "http://localhost:18790/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    networks:
      - openclaw-network
    deploy:
      resources:
        limits:
          cpus: "2"
          memory: 2G
        reservations:
          cpus: "0.5"
          memory: 512M

  # ============================================================
  # Telegram Bot — User Interface (WebSocket CLIENT)
  # ============================================================
  telegram-bot:
    image: openclaw/openclaw:latest
    container_name: openclaw-telegram-bot
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
      - AUTHORIZED_USER_IDS=${AUTHORIZED_USER_IDS}
      - GATEWAY_URL=ws://openclaw-gateway:18789
      - GATEWAY_RECONNECT_INTERVAL=5000
      - GATEWAY_MAX_RECONNECT=10
      - SESSION_TIMEOUT=3600000
      - LOG_LEVEL=info
    depends_on:
      openclaw-gateway:
        condition: service_healthy
    # ВАЖНО: Telegram Bot — WebSocket CLIENT (не HTTP сервер!)
    # Health check проверяет процесс + WebSocket connection
    healthcheck:
      test: ["CMD", "sh", "-c", "pgrep -f 'node.*bot.js' > /dev/null && netstat -tn | grep -q ':18789.*ESTABLISHED' || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - openclaw-network
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 512M
        reservations:
          cpus: "0.25"
          memory: 128M

volumes:
  ollama_models:
    driver: local

networks:
  openclaw-network:
    driver: bridge
```

### 4.2 Environment Variables (.env)

```bash
# === Ollama Configuration ===
OLLAMA_API_KEY=your_ollama_api_key_here    # REQUIRED for cloud models
# Get key: https://ollama.com/settings/keys

# === OpenClaw Configuration ===
OPENCLAW_CONFIG_DIR=./config
OPENCLAW_WORKSPACE_DIR=./workspace
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_BRIDGE_PORT=18790

# === Telegram Bot Configuration ===
TELEGRAM_BOT_TOKEN=your_telegram_bot_token  # Get from @BotFather
AUTHORIZED_USER_IDS=123456789               # Comma-separated Telegram user IDs

# === Optional: Extra mounts ===
# OPENCLAW_EXTRA_MOUNTS=/home/user/projects,/var/data
```

### 4.3 Model Preloading Strategy

Для предотвращения медленного первого запроса:

```yaml
# В docker-compose.yml добавить init-контейнер:
  model-init:
    image: ollama/ollama:latest
    container_name: openclaw-model-init
    entrypoint: ["/bin/sh", "-c"]
    command:
      - |
        until curl -sf http://ollama-service:11434/api/tags > /dev/null 2>&1; do
          echo "Waiting for Ollama..."
          sleep 2
        done
        echo "Pulling model..."
        OLLAMA_HOST=http://ollama-service:11434 ollama pull gemini-3-flash-preview:cloud
        echo "Model ready!"
    environment:
      - OLLAMA_API_KEY=${OLLAMA_API_KEY}
    depends_on:
      ollama-service:
        condition: service_healthy
    networks:
      - openclaw-network
    restart: "no"
```

### 4.4 Docker Networking

Все сервисы в одной bridge-сети `openclaw-network`:
- Telegram Bot -> Gateway: `ws://openclaw-gateway:18789`
- Gateway -> Ollama: `http://ollama-service:11434`
- Ollama -> Cloud: `https://api.ollama.cloud` (внешний трафик)

**Не открывайте порты, которые не нужны снаружи.** В production убрать `ports` для ollama-service (доступ только изнутри сети).

### 4.5 Security Best Practices

```yaml
# В каждый сервис:
security_opt:
  - no-new-privileges:true

# Для telegram-bot:
read_only: true
tmpfs:
  - /tmp

# Non-root user (в Dockerfile):
# RUN adduser -D -u 1001 botuser
# USER botuser

# Capabilities:
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

---

## 5. VDS Server Requirements

### 5.1 Hardware

| Component | Minimum (cloud model) | Recommended | Local model (7B) |
|-----------|----------------------|-------------|-------------------|
| **CPU** | 2 cores | 4+ cores | 8+ cores |
| **RAM** | 4 GB | 8 GB | 32 GB+ |
| **Disk** | 20 GB SSD | 50 GB NVMe | 100 GB+ SSD |
| **Network** | 10 Mbps | 100 Mbps | — |
| **GPU** | Не требуется | Не требуется | 6+ GB VRAM |

**Примечание:** Сервер ainetic.tech имеет 2 ядра — достаточно для cloud-режима (модель выполняется на серверах Ollama Cloud), но недостаточно для локального запуска моделей.

### 5.2 OS Configuration

```bash
# Ubuntu 22.04/24.04 (рекомендуется)

# Обновление системы
sudo apt update && sudo apt upgrade -y

# Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Docker Compose (v2+)
sudo apt install -y docker-compose-plugin

# Verify
docker --version    # >= 24.0
docker compose version  # >= 2.20
```

### 5.3 Security Hardening

```bash
# 1. SSH hardening
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 2. Firewall (UFW)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp       # SSH
sudo ufw allow 18789/tcp    # OpenClaw Gateway (если нужен извне)
# НЕ открывать 11434 (Ollama) — только внутренний доступ
sudo ufw enable

# 3. Fail2Ban
sudo apt install -y fail2ban
sudo systemctl enable fail2ban

# 4. Automatic updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

---

## 6. Step-by-Step Deployment Guide

### 6.1 Server Preparation

```bash
# SSH на сервер
ssh user@ainetic.tech

# Проверка ресурсов
free -h        # RAM
nproc          # CPU cores
df -h          # Disk space
docker --version  # Docker installed?
```

### 6.2 Docker Setup

```bash
# Если Docker не установлен
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Перелогиниться для применения группы

# Создать рабочую директорию
sudo mkdir -p /opt/openclaw
sudo chown $USER:$USER /opt/openclaw
cd /opt/openclaw
```

### 6.3 OpenClaw Installation

```bash
# Вариант A: Через docker-setup.sh (рекомендуется)
git clone https://github.com/openclaw/openclaw.git
cd openclaw
./docker-setup.sh
# Следовать интерактивному мастеру

# Вариант B: Через docker-compose.yml (ручная настройка)
mkdir -p /opt/openclaw/{config,workspace}
# Скопировать docker-compose.yml из раздела 4.1
# Скопировать .env из раздела 4.2
```

### 6.4 Ollama + Gemini Configuration

```bash
# 1. Создать API key на https://ollama.com/settings/keys

# 2. Записать в .env
echo "OLLAMA_API_KEY=your_key_here" >> .env

# 3. Запустить Ollama
docker compose up -d ollama-service

# 4. Дождаться ready (health check)
docker compose logs -f ollama-service
# Ждать: "Listening on 0.0.0.0:11434"

# 5. Загрузить модель
docker exec openclaw-ollama ollama pull gemini-3-flash-preview:cloud

# 6. Проверить
docker exec openclaw-ollama ollama list
# Должна быть: gemini-3-flash-preview:cloud

# 7. Тест
curl http://localhost:11434/api/chat \
  -d '{"model": "gemini-3-flash-preview:cloud", "messages": [{"role": "user", "content": "Hello!"}]}'
```

### 6.5 Telegram Bot Setup

```bash
# 1. Создать бота через @BotFather
#    - Отправить /newbot
#    - Указать имя и username
#    - Скопировать токен

# 2. Записать токен
echo "TELEGRAM_BOT_TOKEN=123456:ABC-DEF..." >> .env

# 3. Получить свой Telegram ID
#    - Отправить /start боту @userinfobot
echo "AUTHORIZED_USER_IDS=your_telegram_id" >> .env

# 4. Настроить OpenClaw models.json
mkdir -p config/agents/default
cat > config/agents/default/models.json <<'EOF'
{
  "providers": {
    "ollama": {
      "baseUrl": "http://ollama-service:11434/v1",
      "apiKey": "ollama-local",
      "api": "openai-completions",
      "models": [
        {
          "id": "gemini-3-flash-preview:cloud",
          "name": "Gemini 3 Flash Preview",
          "contextWindow": 1000000
        }
      ]
    }
  }
}
EOF

# 5. Запустить все сервисы
docker compose up -d

# 6. Проверить статус
docker compose ps
```

### 6.6 Verification Checklist

```bash
# 1. Все контейнеры healthy
docker compose ps
# Expected: ollama-service (healthy), openclaw-gateway (healthy), telegram-bot (healthy)

# 2. Ollama API работает
curl -sf http://localhost:11434/api/tags | jq '.models[].name'
# Expected: gemini-3-flash-preview:cloud

# 3. Gateway health
curl -sf http://localhost:18790/health
# Expected: {"status":"ok",...}

# 4. Telegram Bot подключён
docker exec openclaw-telegram-bot sh -c \
  'pgrep -f "node.*bot.js" && netstat -tn | grep -q ":18789.*ESTABLISHED" && echo "HEALTHY" || echo "UNHEALTHY"'
# Expected: HEALTHY

# 5. End-to-end тест
# Отправить сообщение боту в Telegram → получить ответ от Gemini 3 Flash

# 6. Логи без ошибок
docker compose logs --tail 20
```

---

## 7. Monitoring & Operations

### 7.1 Health Check Patterns

| Сервис | Тип | Health Check |
|--------|-----|-------------|
| **Ollama** | HTTP Server | `curl -sf http://localhost:11434/api/tags` |
| **Gateway** | HTTP Server | `curl -sf http://localhost:18790/health` |
| **Telegram Bot** | WebSocket Client | `pgrep + netstat ESTABLISHED` |

### 7.2 Logging

```bash
# Все логи
docker compose logs -f

# Конкретный сервис
docker compose logs -f telegram-bot

# Последние N строк
docker compose logs --tail 100 ollama-service

# Формат JSON (для централизованного логирования)
# В docker-compose.yml:
logging:
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"
```

### 7.3 Alerting

```bash
#!/bin/bash
# scripts/check-health.sh — запускать через cron каждые 5 минут

SERVICES=("ollama-service" "openclaw-gateway" "openclaw-telegram-bot")

for svc in "${SERVICES[@]}"; do
  status=$(docker inspect --format='{{.State.Health.Status}}' "$svc" 2>/dev/null)
  if [ "$status" != "healthy" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d "chat_id=${ADMIN_CHAT_ID}" \
      -d "text=ALERT: $svc is $status"
  fi
done
```

```bash
# Crontab
*/5 * * * * /opt/openclaw/scripts/check-health.sh
```

### 7.4 Backup & DR

```bash
#!/bin/bash
# scripts/backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/opt/backups/openclaw

mkdir -p "$BACKUP_DIR"

# 1. Workspace (проекты)
tar -czf "$BACKUP_DIR/workspace_${DATE}.tar.gz" /opt/openclaw/workspace/

# 2. Config (настройки, models.json)
tar -czf "$BACKUP_DIR/config_${DATE}.tar.gz" /opt/openclaw/config/

# 3. Git sync (основной бэкап)
cd /opt/openclaw/workspace && git add -A && git commit -m "auto-backup ${DATE}" && git push

# 4. Cleanup (30 дней)
find "$BACKUP_DIR" -mtime +30 -delete

echo "Backup complete: $DATE"
```

```bash
# Crontab — ежедневный бэкап в 03:00
0 3 * * * /opt/openclaw/scripts/backup.sh >> /var/log/openclaw-backup.log 2>&1
```

---

## 8. Expert Opinions Summary (13 Experts)

### Консенсус: **8.1/10 — РЕКОМЕНДУЕТСЯ К РЕАЛИЗАЦИИ** (единогласно)

| # | Эксперт | Рейтинг | Ключевая рекомендация |
|---|---------|---------|----------------------|
| 1 | Архитектор решения | 8.5/10 | Session Manager + User Auth + File Bridge. MVP first |
| 2 | Senior Docker Engineer | 9.0/10 | Docker Compose + resource limits + non-root user |
| 3 | Unix Script Expert | 7.0/10 | `set -euo pipefail`, validation scripts, hook scripts |
| 4 | DevOps Engineer | 9.0/10 | Deploy/rollback from chat, auto-notifications |
| 5 | CI/CD Architect | 8.0/10 | Bot as UI for manual approvals, не основная точка для pipelines |
| 6 | GitOps Specialist | 7.0/10 | Bot = UI для GitOps, каждое действие = git commit/PR |
| 7 | IaC Expert | 9.0/10 | Всё как код: инфраструктура, конфигурация, деплой |
| 8 | Backup & DR Specialist | 6.0/10 | Git sync после каждой операции, daily бэкапы, Redis AOF |
| 9 | SRE | 8.0/10 | Prometheus + Grafana + AlertManager, SLA 99.5% |
| 10 | AI IDE Expert | 9.0/10 | IDE для глубокой работы, Telegram для quick actions |
| 11 | Prompt Engineer | 8.0/10 | Concise, visual, action-oriented промпты для Telegram |
| 12 | TDD Expert | 7.0/10 | Test first, unit tests для bot commands |
| 13 | UAT Engineer | 8.0/10 | Alpha → Beta (5-10 users) → Public, feedback через inline buttons |

### MVP Phases

| Phase | Scope | Timeline |
|-------|-------|----------|
| **Phase 1: MVP** | Базовый бот, Gateway, /new + /status + /help, 1 user | 1-2 недели |
| **Phase 2: Enhanced** | Multi-user, /deploy + /logs + /code, файлы, Git, мониторинг | 2-3 недели |
| **Phase 3: Production** | CI/CD, Prometheus+Grafana, auto-backups, DR, multi-project | 3-4 недели |

---

## 9. Troubleshooting Guide

| # | Проблема | Причина | Решение |
|---|----------|---------|---------|
| 1 | `"model requires more system memory"` | Недостаточно RAM для локальной модели | Использовать cloud mode (`:cloud` тег) |
| 2 | `"pull model manifest: file does not exist"` | Неверное имя модели | Использовать точное имя: `gemini-3-flash-preview:cloud` |
| 3 | `"No API provider registered for api: undefined"` | Отсутствует поле `api` в models.json | Добавить `"api": "openai-completions"` |
| 4 | `ECONNREFUSED 127.0.0.1:3000` в health check | HTTP health check для WebSocket client | Заменить на `pgrep + netstat ESTABLISHED` |
| 5 | Authentication error при pull | Отсутствует OLLAMA_API_KEY | Создать key на ollama.com/settings/keys |
| 6 | Gateway connection refused | Ollama ещё не готов | Использовать `depends_on: condition: service_healthy` |
| 7 | Медленный первый запрос | Модель не предзагружена | Добавить model-init контейнер (раздел 4.3) |
| 8 | Telegram Bot не подключается | Gateway ещё не ready | Увеличить `start_period` в health check |
| 9 | Docker out of disk | Накопление слоёв/моделей | `docker system prune -f`, увеличить диск |
| 10 | Ollama v0.3.11 не видит cloud models | Старая версия | Обновить до v0.3.12+: `docker pull ollama/ollama:latest` |

---

## 10. Sources

### Tier 1: Official Documentation

| # | Title | URL | Date |
|---|-------|-----|------|
| 1 | OpenClaw GitHub | https://github.com/openclaw/openclaw | 2025-2026 |
| 2 | OpenClaw Docs — Docker | https://docs.openclaw.ai/install/docker | 2026 |
| 3 | OpenClaw Docs — Ollama | https://docs.openclaw.ai/providers/ollama | 2026 |
| 4 | OpenClaw Docs — Telegram | https://docs.openclaw.ai/channels/telegram | 2026 |
| 5 | OpenClaw Docs — Models CLI | https://docs.openclaw.ai/concepts/models | 2026 |
| 6 | Gemini 3 Developer Guide | https://ai.google.dev/gemini-api/docs/gemini-3 | 2025-2026 |
| 7 | Gemini 3 Flash — Vertex AI | https://docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/3-flash | 2025-2026 |
| 8 | Ollama Cloud Docs | https://docs.ollama.com/cloud | 2025-2026 |
| 9 | Ollama OpenAI Compatibility | https://docs.ollama.com/api/openai-compatibility | 2025-2026 |
| 10 | Ollama Authentication | https://docs.ollama.com/api/authentication | 2025-2026 |
| 11 | Ollama Docker Docs | https://docs.ollama.com/docker | 2025-2026 |
| 12 | Telegram Bot API | https://core.telegram.org/bots/api | 2025-2026 |

### Tier 2: Authoritative Guides

| # | Title | URL | Date |
|---|-------|-----|------|
| 13 | Google proxy-to-gemini | https://github.com/google-gemini/proxy-to-gemini | 2025-2026 |
| 14 | Docker Compose for Agents | https://github.com/docker/compose-for-agents | 2025-2026 |
| 15 | Ollama Production Docker | https://dasroot.net/posts/2025/12/running-ollama-production-docker-kubernetes-scaling/ | Dec 2025 |
| 16 | Docker AI Agent Platform | https://www.docker.com/solutions/docker-ai/ | 2025-2026 |
| 17 | Telegram Bot API Changelog | https://core.telegram.org/bots/api-changelog | 2025-2026 |

### Tier 3: Community & Tutorials

| # | Title | URL | Date |
|---|-------|-----|------|
| 18 | Ollama Cloud Announcement | https://pbseven.medium.com/ollama-cloud-inference-api-is-now-ready-f7adf6b8ef3e | Dec 2025 |
| 19 | Running OpenClaw in Docker (Simon Willison) | https://til.simonwillison.net/llms/openclaw-docker | Feb 2026 |
| 20 | OpenClaw + Ollama Setup Guide | https://codersera.com/blog/openclaw-ollama-setup-guide-run-local-ai-agents-2026 | 2026 |
| 21 | Vultr: Deploy OpenClaw | https://docs.vultr.com/how-to-deploy-openclaw-autonomous-ai-agent-platform | 2026 |
| 22 | Codecademy: OpenClaw Tutorial | https://www.codecademy.com/article/open-claw-tutorial-installation-to-first-chat-setup | 2026 |
| 23 | Gemini 3 Flash (Google Blog) | https://blog.google/products/gemini/gemini-3-flash/ | 2025-2026 |
| 24 | Ollama Docker Hub | https://hub.docker.com/r/ollama/ollama | Ongoing |
| 25 | Ollama Telegram Bot (GitHub) | https://github.com/rikkichy/ollama-telegram | 2025 |

---

## Appendix A: Gap Analysis vs Existing Documentation

### Сравнение с `docs/research/ollama-gemini3-flash-deployment.md`

| # | Тема | Existing Doc | Reference Doc | Gap |
|---|------|-------------|---------------|-----|
| 1 | OpenClaw models.json format | Не описан | Полный формат с `api` field | **HIGH** |
| 2 | Ollama v0.3.12 requirement | Не упоминается | Задокументировано | **HIGH** |
| 3 | `:cloud` tag детали | Упоминается, но неточно | Полное описание | **MEDIUM** |
| 4 | proxy-to-gemini | Отсутствует | Альтернативная архитектура | **MEDIUM** |
| 5 | thinking_level parameter | Упоминается кратко | 4 уровня описаны | **MEDIUM** |
| 6 | Model preloading | Отсутствует | Entrypoint script | **MEDIUM** |
| 7 | Pricing | Есть | Обновлено | Minor |
| 8 | Sources count | 35 | 25 (более качественных) | Adequate |

### Сравнение с `docs/experts-opinions-telegram-bot.md`

| # | Тема | Existing Doc | Reference Doc | Gap |
|---|------|-------------|---------------|-----|
| 1 | Health check pattern | HTTP endpoint (неправильный!) | WebSocket client pattern | **HIGH** |
| 2 | Docker Compose | Схематичный пример | Production-ready YAML | **MEDIUM** |
| 3 | models.json | Отсутствует | Полная конфигурация | **HIGH** |
| 4 | Telegram API 2025 features | Не описаны | Ключевые новшества | **LOW** |
| 5 | Deployment steps | Абстрактные фазы | Конкретные команды | **MEDIUM** |
| 6 | Expert opinions | 13 экспертов, подробно | Сводка, актуализирована | Adequate |

### Сравнение с `openclaw/docker/docker-compose.yml`

| # | Тема | Existing YAML | Reference YAML | Gap |
|---|------|-------------|----------------|-----|
| 1 | Telegram Bot health check | `node -e "console.log('healthy')"` (НЕВЕРНО) | `pgrep + netstat ESTABLISHED` | **HIGH** |
| 2 | Model name | `gemini-3-flash` (без :cloud) | `gemini-3-flash-preview:cloud` | **MEDIUM** |
| 3 | OLLAMA_API_KEY | Отсутствует | Присутствует | **HIGH** |
| 4 | Model preloading | Отсутствует | init-контейнер | **MEDIUM** |
| 5 | Security options | Отсутствуют | security_opt, cap_drop | **LOW** |

### Вывод: Разница ЗНАЧИТЕЛЬНАЯ

Обнаружено **10 значительных пробелов**, из которых **3 критических** (HIGH severity), блокирующих успешный деплой. **Рекомендация:** создать backlog для проработки существующей документации.

---

*Документ создан: 2026-02-06*
*Основа: Параллельное исследование 3 агентов, 15+ web-поисков, 10+ файлов проекта*
*Статус: REFERENCE (эталон)*
