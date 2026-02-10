# 🏗️ CodeFoundry Remote Testing - Architecture

> Техническая архитектура remote testing infrastructure на ainetic.tech

---

## 📋 Обзор

Remote Testing Infrastructure предназначена для безопасного и изолированного тестирования Telegram бота и других компонентов CodeFoundry на удалённом сервере.

### Ключевые принципы

1. **Ephemeral** — контейнеры существуют только во время тестирования
2. **Isolated** — каждая сессия изолирована override-файлами
3. **Observable** — полная видимость через метрики и логи
4. **Safe** — Git-based workflow без прямого доступа к продакшену

---

## 🔄 Workflow

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Local Machine  │ ──▶ │   GitHub Repo   │ ──▶ │  ainetic.tech    │
│  (Development)  │     │   (git push)    │     │  (VPS Server)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │  Manual Sync    │
                                               │  (ssh + make)    │
                                               └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │  Project Dir    │
                                               │  /workspace      │
                                               └─────────────────┘
                                                        │
                                      ┌─────────────────┴─────────────────┐
                                      ▼                                   ▼
                             ┌─────────────────┐               ┌─────────────────┐
                             │  Test Stack     │               │  Monitor Stack  │
                             │  (ephemeral)    │               │  (long-running) │
                             └─────────────────┘               └─────────────────┘
                                      │                                   │
                    ┌─────────────────┼─────────────────┐              │
                    ▼                 ▼                 ▼              │
             ┌────────────┐  ┌────────────┐  ┌────────────┐             │
             │  Gateway   │  │ Bot        │  │Test Runner │             │
             │  :18789    │  │            │  │            │             │
             └────────────┘  └────────────┘  └────────────┘             │
                    │                                                   │
                    └───────────────────────────────────────────────────┘
                                                   │
                                                   ▼
                                         ┌─────────────────┐
                                         │  Telegram API   │
                                         │  (real testing) │
                                         └─────────────────┘
```

---

## 🐳 Container Architecture

### Test Stack (Ephemeral)

```
codefoundry-test-net (bridge network)
├── gateway           :18789 (WS) :18790 (health)
├── telegram-bot      → gateway
└── test-runner       → gateway
```

**Lifecycle:**
- Создаётся: `make start-test`
- Удаляется: `make stop-test`
- Session-based: `container-manager.sh start-session <name>`

### Monitor Stack (Long-running)

```
codefoundry-monitoring (bridge network)
├── prometheus        :9090
├── grafana           :3000
├── cadvisor          :8080
├── node-exporter     :9100
└── vector            :8686 (API) :9598 (metrics)
```

**Lifecycle:**
- Создаётся: `docker-compose -f docker-compose.monitoring.yml up -d`
- Работает постоянно
- Собирает метрики со всех контейнеров

---

## 📁 Directory Structure

```
server/
├── setup.sh                    # Initial setup script
├── sync.sh                     # GitHub sync script
├── Makefile                    # 30+ management commands
├── container-manager.sh        # Session lifecycle manager
├── test-telegram.sh            # Test runner
├── telegram-test-session.sh    # Session test manager
│
├── docker-compose.test.yml     # Test stack definition
├── docker-compose.monitoring.yml  # Monitor stack definition
│
├── .env.test                   # Active configuration (gitignored)
├── .env.test.example           # Configuration template
│
├── prometheus/
│   ├── prometheus.yml          # Metrics configuration
│   └── alerts/
│       └── testing-alerts.yml  # Alert rules
│
├── grafana/
│   ├── dashboards/
│   │   └── testing.json        # Testing dashboard
│   └── provisioning/
│       ├── datasources/        # Auto-provision datasources
│       └── dashboards/         # Auto-provision dashboards
│
├── vector/
│   └── vector.toml             # Log aggregation config
│
└── monitoring/
    └── README.md               # Monitoring documentation
```

---

## 🔌 Communication Flow

### Telegram Bot → Gateway

```
Telegram API
    ↓
Telegram Bot Container
    ↓ WebSocket
Gateway Container
    ↓
Ollama (optional) or Direct response
    ↓
Telegram Bot Container
    ↓
Telegram API
    ↓
User
```

### Metrics Flow

```
Containers → cAdvisor → Prometheus → Grafana
                ↓
            Node Exporter → Prometheus → Grafana
                ↓
            Vector (metrics) → Prometheus → Grafana
```

### Log Flow

```
Containers → Docker logs → Vector → Parse/Filter → File sinks
                                                 ↓
                                            /var/log/codefoundry/
                                            ├── all-YYYY-MM-DD.log
                                            ├── errors-YYYY-MM-DD.log
                                            ├── gateway-YYYY-MM-DD.log
                                            ├── bot-YYYY-MM-DD.log
                                            └── tests-YYYY-MM-DD.log
```

---

## 🔐 Security Model

### Git-Based Deployment

```
Local → GitHub → ainetic.tech (pull) → Test
```

**Преимущества:**
- Полный аудит в Git history
- Rollback через `git revert`
- Нет прямого SSH доступа к продакшену
- Pull requests для review

### User Authorization

```bash
# .env.test configuration
AUTHORIZED_USER_IDS=123456789,987654321
```

**Проверка в боте:**
```typescript
if (!AUTHORIZED_USER_IDS.includes(userId)) {
  return "Unauthorized";
}
```

### Sensitive Data Protection

**Vector filters:**
```toml
del(.TELEGRAM_BOT_TOKEN)
del(.AUTHORIZED_USER_IDS)
del(.password)
del(.api_key)
```

---

## 🧪 Testing Architecture

### Test Scenarios

| Scenario | Description | Check |
|----------|-------------|-------|
| start | /start command | Welcome message sent |
| new | /new project | Gateway forwarded |
| status | /status command | System status returned |
| help | /help command | Help text sent |
| webhook | WebSocket | Gateway healthy |
| reconnect | Gateway restart | Bot reconnects |
| auth | User check | Authorization validated |
| session | Session mgmt | Session created/managed |
| error | Invalid command | Error handled gracefully |

### Test Execution

```bash
test-telegram.sh
    ├── check_dependencies()
    ├── check_bot_running()
    ├── check_gateway_running()
    ├── check_bot_token()
    │
    └── run_all_tests()
        ├── test_websocket_connection()
        ├── test_user_authorization()
        ├── test_session_management()
        ├── test_start_command()
        ├── test_status_command()
        ├── test_help_command()
        ├── test_new_command()
        ├── test_auto_reconnect()
        └── test_error_handling()
```

### Results

```
════════════════════════════════════════════════════════════
  Test Results
════════════════════════════════════════════════════════════
  Total:  9
  Passed: 8
  Failed: 1
  Pass Rate: 88%

✗ Some tests failed
```

---

## 📊 Monitoring Architecture

### Metrics Hierarchy

```
Prometheus (9090)
    ├── Container Metrics (cAdvisor)
    │   ├── CPU usage
    │   ├── Memory usage
    │   ├── Network I/O
    │   └── Disk I/O
    │
    ├── System Metrics (Node Exporter)
    │   ├── Load average
    │   ├── Memory (free/used/cached)
    │   ├── Disk usage
    │   └── Network traffic
    │
    └── Application Metrics (custom)
        ├── Gateway requests
        ├── Bot API calls
        ├── Test execution time
        └── Error rates
```

### Alert Hierarchy

```
Alertmanager (optional)
    ├── Critical alerts
    │   ├── Gateway down
    │   ├── Bot down
    │   └── Disk space < 10%
    │
    ├── Warning alerts
    │   ├── High memory (>90%)
    │   ├── High CPU (>80%)
    │   └── Test failure rate >30%
    │
    └── Info alerts
        ├── No test execution (1h)
        └── No Telegram activity (2h)
```

---

## 🔄 Session Management

### Session Lifecycle

```
create → start → running → (attach/exec) → stop → removed
```

### State Tracking

```
/tmp/codefoundry-sessions/sessions.json
{
  "sessions": {
    "test-1706980000": {
      "name": "test-1706980000",
      "started": "2025-02-03T10:00:00Z",
      "compose_file": "/tmp/codefoundry-test-test-1706980000.yml",
      "status": "running"
    }
  }
}
```

### Override Isolation

```yaml
# /tmp/codefoundry-test-test-1706980000.yml
name: codefoundry-test-test-1706980000

services:
  gateway:
    container_name: codefoundry-test-test-1706980000-gateway
    environment:
      - SESSION_NAME=test-1706980000
```

---

## 🚀 Scaling Considerations

### Current Limits

- Максимальных сессий: 10 (configurable)
- Максимальный возраст: 24 часа (configurable)
- Память на сессию: ~1GB

### Scaling Path

1. **Horizontal:** Запуск на нескольких VPS
2. **Resource:** Увеличение RAM/CPU на ainetic.tech
3. **Optimization:** Lazy loading контейнеров
4. **Kubernetes:** Миграция на K8s для production

---

## 📚 Component Specs

### Gateway

**Port:** 18789 (WebSocket), 18790 (Health)

**Endpoints:**
- `/health` — Health check
- `/metrics` — Prometheus metrics

**Tech:** Node.js + ws + express

### Telegram Bot

**Port:** 3000 (internal)

**Tech:** Node.js + node-telegram-bot-api

**Features:**
- Command routing
- WebSocket client
- Session management
- Auto-reconnect

### Test Runner

**Port:** None (CLI only)

**Tech:** Node.js / Bash

**Purpose:** Manual testing and debugging

---

## 🔗 Related Documentation

- [QUICKSTART.md](QUICKSTART.md) — Быстрый старт
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Решение проблем
- [../server/README.md](../server/README.md) — Server docs
- [../../PROJECT.md](../../PROJECT.md) — Проектная архитектура

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
