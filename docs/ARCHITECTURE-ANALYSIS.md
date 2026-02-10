> [🏠 Главная](../README.md) → **🏗️ Architecture Analysis**

---
# 🏗️ Полный Анализ Архитектуры CodeFoundry

> **Артефакт из сессии 2025-02-05** — Комплексный анализ архитектуры с инфографикой
>
> **Создано:** 2025-02-05
> **Цель:** Полное описание архитектуры проекта с визуализациями и детальными объяснениями

---

## 📋 Содержание

1. [Обзор Проекта](#1-обзор-проекта)
2. [Архитектура Remote Testing](#2-архитектура-remote-testing)
3. [Token Optimization Strategy](#3-token-optimization-strategy)
4. [Компоненты Системы](#4-компоненты-системы)
5. [Потоки Данных](#5-потоки-данных)
6. [Безопасность](#6-безопасность)
7. [Deployment Workflow](#7-deployment-workflow)

---

## 1. Обзор Проекта

### Что Такое CodeFoundry

**CodeFoundry** — это промышленная система генерации проектов, создающая полные production-ready IT-приложения любой сложности.

```
┌─────────────────────────────────────────────────────────────────┐
│                     CodeFoundry Platform                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  8 Archetype│  │  Generation │  │  OpenClaw   │            │
│  │   Templates │  │   Scripts   │  │ Integration │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   CI/CD     │  │Observability│  │  AI Agents  │            │
│  │  Pipelines  │  │   Stack     │  │   System    │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

### Базовые Возможности

| Компонент | Описание | Покрытие |
|-----------|----------|----------|
| **8 Архетипов** | Шаблоны проектов | 95% IT use cases |
| **Generation Scripts** | Создание одной командой | `make new` |
| **OpenClaw** | AI-ассистент разработки | WebSocket Gateway |
| **CI/CD** | Автоматический pipeline | GitHub Actions |
| **Observability** | Мониторинг и логи | Prometheus + Grafana |

---

## 2. Архитектура Remote Testing

### Назначение

Remote Testing Infrastructure предназначена для безопасного и изолированного тестирования Telegram бота и других компонентов CodeFoundry на удалённом сервере **ainetic.tech**.

### Ключевые Принципы

```
┌──────────────────────────────────────────────────────────────┐
│  1. EPHEMERAL      ──►  Контейнеры живут только во время теста │
│  2. ISOLATED       ──►  Каждая сессия изолирована override-файлами│
│  3. OBSERVABLE     ──►  Полная видимость через метрики и логи   │
│  4. SAFE           ──►  Git-based workflow без доступа к prod  │
└──────────────────────────────────────────────────────────────┘
```

### Полный Workflow

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

## 3. Token Optimization Strategy

### Проблема Монолитических Промптов

```
┌─────────────────────────────────────────────────────────────┐
│          Single Monolithic Prompt (5000+ tokens)            │
├─────────────────────────────────────────────────────────────┤
│  ❌ All loaded always                                       │
│  ❌ Wasted context on irrelevant sections                    │
│  ❌ Expensive for every interaction                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│          Hub + Modular System (500 + 800 tokens)            │
├─────────────────────────────────────────────────────────────┤
│  ✅ Hub loaded once (500 tokens)                            │
│  ✅ Modules loaded on-demand (800 tokens each)              │
│  ✅ 60-80% token savings                                     │
└─────────────────────────────────────────────────────────────┘
```

### File Loading Logic

Центральный хаб (`CLAUDE.md`) содержит логику решений:

```
User asks about architecture
    → Hub recognizes "@ref: PROJECT.md"
    → Loads PROJECT.md (architecture section)
    → User gets answer WITHOUT loading entire system

User asks about project generation
    → Hub recognizes "create new project"
    → Loads @ref: instructions/project-generation.md
    → Loads @ref: templates/README.md
    → Generation happens WITHOUT unrelated modules
```

### Progressive Loading Pattern

```
┌─────────────────────────────────────────────────────────────┐
│  1️⃣ Start: Hub only (500 tokens)                            │
│                                                              │
│  2️⃣ User asks specific question:                            │
│     → Load ONE relevant module (800 tokens)                  │
│     → Answer question                                       │
│     → Unload module if not needed                            │
│                                                              │
│  3️⃣ Next question:                                          │
│     → Load DIFFERENT module if needed                        │
│     → Never keep more than 2-3 modules active               │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Компоненты Системы

### Container Architecture

#### Test Stack (Ephemeral)

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

#### Monitor Stack (Long-running)

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

### Directory Structure

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

## 5. Потоки Данных

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

## 6. Безопасность

### Git-Based Deployment

```
Local → GitHub → ainetic.tech (pull) → Test
```

**Преимущества:**
- ✅ Полный аудит в Git history
- ✅ Rollback через `git revert`
- ✅ Нет прямого SSH доступа к продакшену
- ✅ Pull requests для review

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

## 7. Deployment Workflow

### GitOps Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│  Git = Single Source of Truth                               │
│  Remote server reconciles desired state                     │
│  Docker commands are implementation detail                  │
└─────────────────────────────────────────────────────────────┘
```

### Intent → Command Mapping

| User Intent | ❌ FORBIDDEN | ✅ CORRECT |
|-------------|-------------|------------|
| "Restart service" | `docker-compose restart` | `git commit --allow-empty -m "deploy: restart" && git push` |
| "Update image" | `docker pull` | Edit docker-compose.yml → git commit → git push |
| "Deploy version" | `docker build && push` | Bump version in compose.yml → git push |
| "Check status" | `docker ps` | `ssh ainetic.tech "docker ps"` |
| "View logs" | `docker logs` | `ssh ainetic.tech "docker logs -f"` |

### Mandatory Workflow

```
1. Edit IaC file locally (docker-compose.yml, etc.)
2. Validate syntax (docker-compose config --dry-run if available)
3. Git commit with descriptive message: "deploy: [description]"
4. Git push
5. Remote server detects change → applies new state
6. Verify via SSH logs
```

---

## 📊 Метрики и Мониторинг

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

## 🔗 Связанные Документы

| Документ | Описание |
|----------|----------|
| [PROJECT.md](../PROJECT.md) | Полное описание проекта |
| [TASKS.md](../TASKS.md) | Трекер задач |
| [SESSION.md](../SESSION.md) | История сессий |
| [docs/remote-testing/ARCHITECTURE.md](./remote-testing/ARCHITECTURE.md) | Remote Testing архитектура |
| [docs/INDEX.md](./INDEX.md) | Индекс документации |

---

**Версия:** 1.0.0
**Дата создания:** 2025-02-05
**Автор:** Claude Code (Session f505c529-b41f-4b5b-88fb-ecd3ca5cbe3d)
**Статус:** Артефакт из прерванной сессии
