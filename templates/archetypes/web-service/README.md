# 🌐 Web Service Archetype

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🌐 Web Service](#)

---

## Description

Шаблон для создания REST/GraphQL API сервисов с полной DevOps инфраструктурой.

---

## 🎯 Характеристики

### Tech Stack Options

| Компонент | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| **Runtime** | Node.js 20 LTS | Python 3.11+ | Go 1.21+ |
| **Framework** | Express/Fastify | FastAPI | Gin/Echo |
| **Language** | TypeScript | Python | Go |
| **Database** | PostgreSQL 16 | PostgreSQL 16 | PostgreSQL 16 |
| **Cache** | Redis 7 | Redis 7 | Redis 7 |
| **Queue** | BullMQ | Celery | RabbitMQ |

### Features Out-of-the-Box

✅ **OpenAPI/Swagger** — автодокументация API
✅ **JWT Authentication** — с refresh tokens
✅ **Request Validation** — Pydantic/Zod schemas
✅ **Structured Logging** — JSON логи с correlation ID
✅ **Error Handling** — унифицированные ошибки
✅ **Health Checks** — /health, /ready, /metrics endpoints
✅ **Rate Limiting** — per-IP и per-user
✅ **CORS** — настроен для production
✅ **Docker** — multi-stage builds
✅ **Kubernetes** — Helm charts + Kustomize
✅ **CI/CD** — GitHub Actions + GitOps
✅ **Monitoring** — Prometheus + Grafana
✅ **Tracing** — OpenTelemetry

---

## 🚀 Quick Start

### 1. Создание проекта

**Через CodeFoundry (рекомендуется):**
```bash
# Из директории CodeFoundry
cd CodeFoundry
make new ARCHETYPE=web-service NAME=my-api
cd my-api
```

**Вручную:**
```bash
# Клонируйте archetype
cp -r /path/to/CodeFoundry/templates/archetypes/web-service ~/projects/my-api
cd ~/projects/my-api

# Инициализируйте Git
git init

# Выберите стек
./scripts/select-stack.sh  # nodejs | python | go
```

### 2. Конфигурация

```bash
# Скопируйте .env.example
cp .env.example .env

# Отредактируйте конфигурацию
nano .env
```

### 3. Запуск локально

```bash
# Docker Compose
make dev

# Или локально (Node.js)
npm install
npm run dev

# (Python)
poetry install
poetry run uvicorn app.main:app --reload

# (Go)
go mod download
go run cmd/server/main.go
```

### 4. Проверка

```bash
# Health check
curl http://localhost:3000/health

# API docs
open http://localhost:3000/docs

# Metrics
curl http://localhost:3000/metrics
```

---

## 📂 Структура Проекта

```
web-service/
├── 📋 docs/
│   ├── PROJECT.md              # Описание проекта
│   ├── ARCHITECTURE.md         # Архитектура
│   ├── API.md                  # API документация
│   └── DEPLOYMENT.md           # Деплой гайд
│
├── 🐳 docker/
│   ├── Dockerfile              # Multi-stage build
│   ├── Dockerfile.dev          # Development build
│   └── docker-compose.yml      # Local development
│
├── ☸️ k8s/
│   ├── base/                   # Kustomize base
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── staging/            # Staging overrides
│       └── production/         # Production overrides
│
├── 🔄 ci/
│   └── .github/workflows/
│       ├── ci.yml              # Continuous Integration
│       ├── cd.yml              # Continuous Deployment
│       └── release.yml         # Release automation
│
├── 📊 monitoring/
│   ├── prometheus/
│   │   └── alerts.yml          # Alert rules
│   ├── grafana/
│   │   └── dashboards/         # Grafana dashboards
│   └── opentelemetry/          # OTEL config
│
├── 🤖 openclaw/
│   ├── workspace/
│   │   ├── AGENTS.md           # Multi-agent config
│   │   ├── SOUL.md             # Agent personality
│   │   └── skills/
│   │       └── api-development.md
│   └── config/
│       └── agents.yaml
│
├── 📝 src/
│   ├── app/
│   │   ├── main.ts             # Entry point
│   │   ├── routes/             # API routes
│   │   ├── controllers/        # Controllers
│   │   ├── services/           # Business logic
│   │   ├── models/             # Data models
│   │   ├── middleware/         # Express middleware
│   │   ├── utils/              # Utilities
│   │   └── config/             # Config
│   ├── tests/
│   │   ├── unit/               # Unit tests
│   │   ├── integration/        # Integration tests
│   │   └── e2e/                # E2E tests
│   └── migrations/             # DB migrations
│
├── 🔧 scripts/
│   ├── select-stack.sh         # Stack selection
│   ├── setup-project.sh        # Project setup
│   ├── db-migrate.sh           # DB migrations
│   └── deploy.sh               # Deploy script
│
├── 📄 .env.example             # Environment variables template
├── 📄 .gitignore
├── 📄 Makefile                 # Convenient commands
└── 📄 README.md                # This file
```

---

## 🤖 OpenClaw Integration

### Agent Configuration

Этот archetype использует **3 агента** для разработки:

```
┌─────────────────────────────────────────────────────────────┐
│                     Main Agent (Координатор)                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Dev Agent │  │Review Agent │  │DevOps Agent │        │
│  │  (Код)      │  │ (Ревью)     │  │  (Деплой)   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

**Agent Routing:**
```
User Request → Main Agent
                 ├─→ "создай endpoint" → Dev Agent
                 ├─→ "сделай ревью" → Review Agent
                 └─→ "задеплой" → DevOps Agent
```

**Loaded Skills:**
- `@workspace/skills/git-workflow.md`
- `@workspace/skills/testing-strategy.md`
- `@workspace/skills/code-review.md`
- `@workspace/skills/api-development.md` (archetype-specific)

### Usage Examples

```
👤 "Создай GET /api/users endpoint"

🤖 OpenClaw [Main → Dev]:
    1. 📦 Loading skill: api-development
    2. 📝 Creating:
       - src/routes/users.ts
       - src/controllers/userController.ts
       - src/services/userService.ts
       - tests/unit/userService.test.ts
    3. ✅ Endpoint created with:
       - Request validation
       - Error handling
       - OpenAPI documentation
       - Unit tests
```

---

## 🔧 Makefile Commands

```bash
make help          # Show all commands
make init          # Initialize project
make dev           # Start development environment
make build         # Build Docker image
make test          # Run tests
make test-unit     # Run unit tests only
make test-integration # Run integration tests
make lint          # Run linter
make format        # Format code
make migrate       # Run database migrations
make migrate-rollback # Rollback last migration
make deploy-staging # Deploy to staging
make deploy-prod   # Deploy to production
make logs          # Show application logs
make logs-staging  # Show staging logs
make logs-prod     # Show production logs
```

---

## 🐳 Docker

### Build

```bash
# Production image
make build
# или
docker build -t my-api:latest -f docker/Dockerfile .

# Development image
docker build -t my-api:dev -f docker/Dockerfile.dev .
```

### Run

```bash
# With docker-compose
make dev
# или
docker-compose -f docker/docker-compose.yml up

# Individual container
docker run -p 3000:3000 --env-file .env my-api:latest
```

---

## ☸️ Kubernetes

### Deploy to Staging

```bash
kubectl apply -k k8s/overlays/staging
```

### Deploy to Production

```bash
kubectl apply -k k8s/overlays/production
```

### Rollback

```bash
kubectl rollout undo deployment/my-api -n production
```

---

## 📊 Monitoring

### Metrics (Prometheus)

```bash
# Access metrics
curl http://localhost:3000/metrics

# Available metrics:
# - http_requests_total
# - http_request_duration_seconds
# - active_connections
# - cache_hits_total
```

### Logs (Structured JSON)

```json
{
  "level": "info",
  "timestamp": "2025-11-05T10:30:00Z",
  "correlationId": "abc-123",
  "message": "User created",
  "userId": "user_123",
  "duration": "45ms"
}
```

### Health Checks

```bash
curl http://localhost:3000/health
# {"status":"healthy","timestamp":"2025-11-05T10:30:00Z"}

curl http://localhost:3000/ready
# {"status":"ready","checks":{"db":"up","redis":"up","queue":"up"}}
```

---

## 🔒 Security Best Practices

### Environment Variables

```bash
# .env (never commit)
DATABASE_URL=postgresql://user:pass@localhost:5432/db
JWT_SECRET=your-secret-key-min-32-chars
REDIS_URL=redis://localhost:6379
```

### Secrets (Kubernetes)

```yaml
# k8s/base/secrets.yaml (gitignored)
apiVersion: v1
kind: Secret
metadata:
  name: my-api-secrets
type: Opaque
stringData:
  database-url: "postgresql://..."
  jwt-secret: "..."
```

### Security Headers

```typescript
// Helmet.js middleware (Node.js)
app.use(helmet({
  hsts: { maxAge: 31536000 },
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
    }
  }
}));
```

---

## 📝 API Documentation

### Swagger UI

```
http://localhost:3000/docs
http://localhost:3000/redoc
```

### OpenAPI Spec

```bash
curl http://localhost:3000/openapi.json > openapi.json
```

---

## 🧪 Testing

### Unit Tests

```bash
make test-unit
# Node.js: npm run test:unit
# Python: pytest tests/unit/
# Go: go test ./...
```

### Integration Tests

```bash
make test-integration
# Requires: docker-compose up -d
```

### E2E Tests

```bash
make test-e2e
# Playwright/Cypress tests
```

### Coverage

```bash
make coverage
# Target: >80%
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions

```yaml
# ci/.github/workflows/ci.yml
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - checkout
      - setup Node.js/Python/Go
      - install dependencies
      - run lint
      - run tests
      - upload coverage
```

### GitOps (ArgoCD)

```yaml
# Application auto-sync on Git push
# Staging: auto-sync
# Production: manual sync
```

---

## 📚 Additional Resources

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)
- [📋 Все Архетипы](../README.md)
- [🔄 GitOps 2.0](../README.md)

### OpenClaw Integration
- [🦞 OpenClaw README](../../../openclaw/README.md)
- [🤖 Agents](../../../openclaw/workspace/AGENTS.md)
- [🎨 Skills Index](../../../openclaw/workspace/SKILLS-INDEX.md)

### Kubernetes Documentation
- [📖 K8s Docs](https://kubernetes.io/docs/home/)
- [🐳 Docker Docs](https://docs.docker.com/)
- [🚀 ArgoCD Docs](https://argocd.readthedocs.io/)

### Development Guides
- [📖 REST API Design](https://restfulapi.net/)
- [🏗️ Microservices Patterns](https://microservices.io/patterns/)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.2.0 | 2025-01-31 | GitOps 2.0 добавлен, исправлены сломанные ссылки |
| 1.1.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs |
| 1.0.0 | 2025-11-05 | Первая версия archetype |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🌐 Web Service](#)
