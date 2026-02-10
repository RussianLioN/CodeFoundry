# ═════════════════════════════════════════════════════════════════════════════
# 🎨 Project Archetypes — CodeFoundry Templates
# ═══════════════════════════════════════════════════════════════════════════════

> [🏠 Главная](../../README.md) → [🎨 Archetypes](#)

---

## Overview

**CodeFoundry Archetypes** — готовые шаблоны для быстрого старта **любого ИТ проекта** одной командой.

Все архетипы включают:
- 🐳 Docker + Kubernetes (Kustomize)
- 🚀 CI/CD pipelines (GitHub Actions)
- 📊 Monitoring (Prometheus + Grafana)
- 🤖 OpenClaw multi-agent конфигурацию
- 📚 Документацию

---

## 📋 Доступные Архетипы

| Архетип | Описание | Files | Статус |
|---------|----------|-------|--------|
| [🌐 Web Service](./web-service/README.md) | REST/GraphQL API, Microservices | 19 | ✅ |
| [🤖 AI Agent](./ai-agent/README.md) | AI assistant, RAG, LLM | 10 | ✅ |
| [📊 Data Pipeline](./data-pipeline/README.md) | ETL/ELT, Airflow, dbt | 3 | ✅ |
| [📱 Telegram Bot](./telegram-bot/README.md) | aiogram, FSM, Webhook | 8 | ✅ |
| [📽️ Presentation](./presentation/README.md) | Markdown, Reveal.js, Mermaid | 6 | ✅ |
| [🖥️ CLI Tool](./cli-tool/README.md) | Go/Rust/Python CLI, Rich output | 10 | ✅ |
| [🏗️ Microservices](./microservices/README.md) | Distributed systems, Istio, gRPC | 14 | ✅ |
| [💻 Fullstack](./fullstack/README.md) | Next.js + NestJS, Nx monorepo | 14 | ✅ |

---

## 🌐 Web Service

**Stack:** Node.js/Python/Go, Express/FastAPI/Gin, PostgreSQL, Redis

**Файлы:** 19
- Docker multi-stage build
- Kubernetes (Kustomize) с HPA, PDB
- CI/CD (lint, test, security scan, deploy)
- Monitoring (Prometheus, Grafana, alerts)

**Когда использовать:**
- REST/GraphQL API
- Microservices backend
- SaaS platform

```
templates/archetypes/web-service/
├── docker/Dockerfile
├── k8s/base/deployment.yaml
├── k8s/base/service.yaml
├── k8s/overlays/staging/kustomization.yaml
├── ci/.github/workflows/ci.yml
└── ...
```

---

## 🤖 AI Agent

**Stack:** Python, FastAPI, OpenAI/Anthropic, PostgreSQL+pgvector, Qdrant, Redis

**Файлы:** 10
- RAG система (vector DB)
- Prompt versioning
- A/B testing prompts
- Streaming responses
- Cost tracking

**Когда использовать:**
- AI чат-боты
- RAG приложения
- AI assistants
- Prompt engineering platform

```
templates/archetypes/ai-agent/
├── docker/docker-compose.yml
├── src/prompts/              # Prompt templates
├── src/vector_store/         # Qdrant integration
├── .env.example              # 40+ variables
└── ...
```

---

## 📊 Data Pipeline

**Stack:** Apache Airflow, dbt, PostgreSQL, Redis, Celery

**Файлы:** 3
- Airflow DAGs
- dbt models
- Data Quality checks

**Когда использовать:**
- ETL/ELT pipelines
- Data warehouse
- Analytics platform
- Batch processing

```
templates/archetypes/data-pipeline/
├── dags/                     # Airflow DAGs
├── dbt/models/              # dbt models
├── docker/docker-compose.yml
└── ...
```

---

## 📱 Telegram Bot

**Stack:** Python, aiogram 3.x, FSM, PostgreSQL, Redis

**Файлы:** 8
- FSM state machine
- Inline keyboards
- Callback handling
- Webhook + polling modes

**Когда использовать:**
- Telegram боты
- Chatbots
- Notifications
- User engagement

```
templates/archetypes/telegram-bot/
├── src/handlers/             # Command handlers
├── src/fsm/                  # FSM states
├── src/keyboards/            # Inline keyboards
└── ...
```

---

## 📽️ Presentation

**Stack:** Markdown, Reveal.js, Mermaid, PlantUML

**Файлы:** 6
- Markdown слайды
- Reveal.js HTML template
- Mermaid diagrams
- Speaker notes

**Когда использовать:**
- Технические презентации
- Documentation as slides
- Training materials
- Conference talks

```
templates/archetypes/presentation/
├── slides/                   # Markdown слайды
├── index.html               # Reveal.js template
├── themes/                  # Custom CSS themes
└── ...
```

---

## 🖥️ CLI Tool

**Stack:** Go (Cobra, Viper) / Rust (Clap) / Python (Typer, Rich)

**Файлы:** 10
- Command structure (Cobra pattern)
- Shell completion (bash, zsh, fish, powershell)
- Rich output (tables, progress bars)
- Multi-platform builds

**Когда использовать:**
- Developer tools
- DevOps utilities
- System administration
- Automation scripts

```
templates/archetypes/cli-tool/
├── src/cmd/                  # Cobra commands
├── src/pkg/                  # Library code
├── docker/Dockerfile         # Minimal container
├── Makefile                  # Build automation
└── ...
```

---

## 🏗️ Microservices

**Stack:** Go (gRPC/micro) / Python (FastAPI), Istio, Kong, NATS/Kafka, OpenTelemetry

**Файлы:** 14
- Istio service mesh (VirtualService, DestinationRule, mTLS)
- Kong API Gateway с JWT auth, rate limiting, ACL
- gRPC proto definitions с валидацией
- Docker Compose для local development
- Kubernetes manifests с HPA, PDB, ServiceMonitor
- OpenTelemetry tracing (Jaeger)
- Circuit breakers и outlier detection

**Когда использовать:**
- Large distributed systems
- Enterprise architecture
- High-scale applications
- Multi-team development

```
templates/archetypes/microservices/
├── services/                 # Микросервисы
│   ├── auth-service/        # Authentication
│   ├── user-service/        # User management
│   ├── order-service/       # Order processing
│   ├── payment-service/     # Payments
│   ├── notification-service/ # Notifications
│   └── analytics-service/   # Analytics
├── shared/                   # Общий код
│   ├── proto/               # gRPC definitions
│   └── pkg/                 # Go packages
├── service-mesh/            # Istio config
│   ├── base/                # VirtualService, DestinationRule
│   └── policies/            # Security policies
├── api-gateway/             # Kong configuration
├── k8s/                     # Kubernetes manifests
├── observability/           # Monitoring
└── docker-compose.yml       # Local development
```

---

## 💻 Fullstack

**Stack:** Next.js 14 (React) + NestJS (Node.js) / Go / Python, Nx/Turborepo

**Файлы:** 14
- Nx monorepo configuration
- Next.js App Router (Server Components)
- NestJS backend with modular architecture
- Shared TypeScript types
- Zod validators
- E2E tests (Playwright)
- Multi-stage Docker builds

**Когда использовать:**
- SaaS приложения
- Web platforms
- Admin dashboards
- Progressive Web Apps (PWA)
- Real-time applications

```
templates/archetypes/fullstack/
├── apps/
│   ├── web/                # Next.js frontend
│   │   ├── app/            # App Router
│   │   ├── components/     # React components
│   │   └── lib/            # Utilities
│   ├── api/                # NestJS backend
│   │   └── src/
│   │       ├── modules/    # Feature modules
│   │       ├── common/     # Shared code
│   │       └── main.ts
│   └── mobile/             # (Optional) React Native
├── packages/
│   ├── ui/                 # Shared UI components
│   ├── types/              # Shared TypeScript types
│   ├── api-client/         # Generated API client
│   └── validators/         # Zod schemas
├── tools/
│   └── playwright/         # E2E tests
├── docker/                 # Multi-stage builds
├── k8s/                    # Kubernetes manifests
└── nx.json                 # Monorepo config
```

---

## 📚 Все Архетипы Завершены!

**🎉 Поздравляем! Все 8 архетипов готовы к использованию:**

1. ✅ Web Service — REST/GraphQL API
2. ✅ AI Agent — AI assistant, RAG
3. ✅ Data Pipeline — ETL/ELT, Airflow, dbt
4. ✅ Telegram Bot — aiogram, FSM
5. ✅ Presentation — Markdown, Reveal.js
6. ✅ CLI Tool — Go/Rust/Python
7. ✅ Microservices — Istio, gRPC, Kong
8. ✅ Fullstack — Next.js + NestJS

**Stack:** React/Vue/Next.js + Web Service backend

**Планируемые файлы:**
- Frontend + backend
- Monorepo structure
- Shared types
- E2E testing

**Когда использовать:**
- Web applications
- SaaS products
- Platform development

---

## 🚀 Использование Архетипов

### Способ A: Через CodeFoundry (Рекомендуется)

```bash
# 1. Перейти в CodeFoundry
cd CodeFoundry
# или: cd system-prompts  # работает через symlink

# 2. Создать проект из архетипа
make new ARCHETYPE=<archetype-name> NAME=my-project

# 3. Перейти в проект
cd my-project

# 4. Настроить окружение
cp .env.example .env
nano .env

# 5. Установить зависимости
make install

# 6. Запустить разработку
make dev
```

### Способ B: Вручную

```bash
# 1. Скопировать архетип
cp -r templates/archetypes/<archetype-name> /path/to/new-project

# 2. Инициализировать Git
cd /path/to/new-project
git init

# 3. Настроить окружение
cp .env.example .env
nano .env

# 4. Установить зависимости
make install

# 5. Запустить разработку
make dev
```

---

## 🤖 OpenClaw Integration

Все архетипы включают `openclaw/workspace/AGENTS.md` с конфигурацией multi-agent системы для AI-ассистированной разработки:

**Общие агенты:**
- **Main Agent** — координатор
- **Dev Agent** — разработка
- **Review Agent** — code review
- **DevOps Agent** — deployment

**Специфичные агенты:**
- AI Agent: **Prompt Agent**, **ML Agent**
- Presentation: **ContentGenerator**, **SlideDesigner**
- Data Pipeline: **DataEngineer**, **MLEngine**

---

## 📁 Универсальная Структура

```
<archetype>/
├── src/                     # Исходный код
├── docker/                  # Dockerfile, docker-compose
├── k8s/                     # Kubernetes manifests
│   ├── base/               # Базовая конфигурация
│   └── overlays/           # Environment-specific
├── ci/                      # CI/CD pipelines
│   └── .github/workflows/
├── monitoring/              # Observability
│   ├── prometheus/
│   ├── grafana/
│   └── alerts/
├── docs/                    # Документация
├── openclaw/                # OpenClaw конфиг
│   └── workspace/
│       ├── AGENTS.md
│       └── SKILLS-INDEX.md
├── Makefile                 # Build automation
├── .env.example             # Environment variables
└── README.md
```

---

## 📊 Статистика

| Метрика | Значение |
|---------|----------|
| Всего архетипов | 8 |
| Готовых (100%) | 8 |
| В разработке | 0 |
| Средний размер | ~11 файлов/архетип |

**🎉 Фаза 3 завершена на 100%!**

---

## 📚 См. Также

- [🏠 Главная CodeFoundry](../../README.md) — Главная документация проекта
- [🚀 Quick Start](../../QUICKSTART.md) — Быстрый старт с CodeFoundry
- [🦞 OpenClaw](../../openclaw/README.md) — AI-ассистент для разработки
- [🎯 OpenClaw Workspace](../../openclaw/workspace/README.md) — Workspace агентов
- [🤖 OpenClaw Agents](../../openclaw/workspace/AGENTS.md) — Конфигурация агентов
- [🎨 OpenClaw Skills](../../openclaw/workspace/SKILLS-INDEX.md) — Индекс навыков

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.2.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs |
| 1.1.0 | 2025-11-05 | Added CLI Tool archetype |
| 1.0.0 | 2025-11-05 | Initial 8 archetypes |

---

> [🏠 Главная](../../README.md) → [🎨 Archetypes](#)
