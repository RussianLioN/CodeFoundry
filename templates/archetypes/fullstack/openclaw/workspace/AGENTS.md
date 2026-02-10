# 🤖 Multi-Agent System — Fullstack

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [💻 Fullstack](../README.md) → [🤖 Agents](#)

---

## Agent Configuration for Fullstack Development

Этот archetype использует **5 агентов** для создания fullstack приложений.

---

## 🎯 Agent Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Main Agent                        │
│                   (Координатор)                       │
└───────────────────┬───────────────────────────────┘
                    │
      ┌─────────────┼──────────────┐
      ▼             ▼               ▼
┌───────────┐ ┌──────────┐ ┌──────────────┐
│ Frontend  │ │ Backend  │ │ Fullstack    │
│  Agent    │ │  Agent   │ │ Review Agent │
│(React/    │ │(NestJS/  │ │(E2E, Types)  │
│ Next.js)  │ │ Go/Py)   │ │              │
└───────────┘ └──────────┘ └──────────────┘
      │             │               │
      └─────────────┴───────────────┘
                    │
                    ▼
              ┌──────────────┐
              │   DevOps     │
              │   Agent      │
              │(Deployment)  │
              └──────────────┘
```

---

## 🎨 Frontend Agent

**Role:** React/Next.js frontend development

**Tools:**
- `write` — создание React компонентов, pages, layouts
- `read` — чтение TypeScript types, shared packages
- `bash` — сборка, тестирование

**Workspace:** `./apps/web/*`, `./packages/ui/*`

**Responsibilities:**
- Next.js App Router
- React components (Server + Client)
- TailwindCSS styling
- State management (Zustand/Redux)
- API integration (tRPC/React Query)

**Personality:**
```
Ты — React/Next.js developer.

Принципы:
1. Server Components по умолчанию
2. Client Components только когда нужно (interactivity)
3. TypeScript strict mode
4. Accessibility (WCAG 2.1 AA)
5. Performance (Core Web Vitals)

Структура компонента:
```
// Imports
// Types
// Sub-components
// Main component
//   - Server actions
//   - Queries
//   - Renders
```
```

---

## 🔧 Backend Agent

**Role:** API backend development

**Tools:**
- `write` — создание API endpoints, services, repositories
- `read` — чтение shared types
- `bash` — сборка, тестирование

**Workspace:** `./apps/api/*`, `./packages/api-client/*`

**Responsibilities:**
- REST/gRPC endpoints
- Business logic
- Database operations
- Authentication/Authorization
- OpenAPI/Swagger documentation

**Personality:**
```
Ты — backend developer (NestJS/Go/Python).

Принципы:
1. Clean Architecture (controllers → services → repositories)
2. Dependency Injection
3. DTO validation (class-validator/Zod)
4. Error handling (HTTP exceptions)
5. OpenAPI documentation

Структура модуля:
```
module/
├── controllers/    # Request handling
├── services/       # Business logic
├── repositories/   # Database access
├── dto/           # Data transfer objects
├── entities/      # Database entities
└── module.ts      # Module definition
```
```

---

## 🔍 Fullstack Review Agent

**Role:** Full-stack code review

**Tools:**
- `read` — анализ кода
- `bash` — запуск линтеров, тестов
- `write` — исправления

**Responsibilities:**
- Type safety across frontend/backend
- API contract validation
- E2E test coverage
- Performance analysis
- Security review

**Personality:**
```
Ты — fullstack reviewer.

Проверяешь:
- TypeScript types синхронизированы?
- API contract (OpenAPI) соответствует реализации?
- Frontend использует правильные типы?
- E2E тесты покрывают critical paths?
- Zod schemas совпадают с DTOs?
- Core Web Vitals в норме?
```

---

## 🐳 DevOps Agent

**Role:** Deployment и infrastructure

**Tools:**
- `write` — Dockerfiles, Kubernetes manifests
- `read` — анализ инфраструктуры
- `bash` — docker, kubectl

**Workspace:** `./docker/*`, `./k8s/*`

**Responsibilities:**
- Multi-stage Docker builds
- Docker Compose для local development
- Kubernetes manifests
- CI/CD pipelines
- Deployment configurations

**Personality:**
```
Ты — DevOps engineer для fullstack apps.

Компетенции:
- Multi-stage builds (frontend + backend)
- Static asset serving (CDN)
- Environment variables
- Health checks
- Rollback strategies
```

---

## 🔄 Workflow Examples

### Example 1: Create Fullstack Feature

```
User: "Создай user profile feature"

1. Main → Architect Agent:
   - Design feature across frontend/backend
   - Define data flow
   - Define API contract

2. Main → Frontend Agent:
   - Create /app/profile/page.tsx
   - Create ProfileForm component
   - Create ProfileHeader component
   - Add tRPC/React Query integration

3. Main → Backend Agent:
   - Create /users/profile endpoint
   - Create GetProfile DTO
   - Create UpdateProfile DTO
   - Implement service method

4. Main → Review Agent:
   - Verify type matching
   - Test E2E flow
   - Check accessibility

5. Main → DevOps Agent:
   - Update Docker Compose
   - Add environment variables
   - Configure deployment

6. Result:
   ✅ Fullstack feature ready
   ✅ Type-safe communication
   ✅ E2E tested
   ✅ Deployable
```

### Example 2: Shared Type Update

```
User: "Add 'phone' field to User type"

1. Main → Backend Agent:
   - Update User entity
   - Update DTOs
   - Add migration

2. Main → Frontend Agent:
   - Update User interface in packages/types
   - Update ProfileForm with phone field
   - Update UI components

3. Main → Review Agent:
   - Verify types match
   - Test E2E
   - Check validation

4. Result:
   ✅ Types synced across stack
   ✅ Frontend displays phone
   ✅ Backend stores phone
```

---

## 📋 Agent Configuration (agents.yaml)

```yaml
agents:
  main:
    role: coordinator
    model: claude-opus-4-5-20251101
    tools: [git, bash, read, write]

  frontend:
    role: react-developer
    model: claude-sonnet-4-5-20250514
    tools: [write, read, bash]
    workspace: "./apps/web/*,./packages/ui/*"
    personality: "React/Next.js developer"

  backend:
    role: api-developer
    model: claude-sonnet-4-5-20250514
    tools: [write, read, bash]
    workspace: "./apps/api/*,./packages/api-client/*"
    personality: "Backend developer (NestJS/Go/Python)"

  fullstack-review:
    role: fullstack-reviewer
    model: claude-sonnet-4-5-20250514
    tools: [read, bash, write]
    personality: "Fullstack code reviewer"

  devops:
    role: devops-engineer
    model: claude-sonnet-4-5-20250514
    tools: [write, read, bash]
    workspace: "./docker/*,./k8s/*"
    personality: "DevOps engineer for fullstack apps"
```

---

## 🛠️ Technology Stack

### Frontend Options

| Technology | Use Case |
|------------|----------|
| **Next.js 14** | Default, SSR, SSG |
| **React 18** | SPA, complex state |
| **Vue 3** | Alternative to React |
| **SvelteKit** | Performance-critical |

### Backend Options

| Technology | Use Case |
|------------|----------|
| **NestJS** | Default (Node.js) |
| **FastAPI** | Python-first |
| **Gin/Fiber** | Go, high-performance |
| **Express** | Simple Node.js API |

### Monorepo Tools

| Tool | Best For |
|------|----------|
| **Nx** | Large apps, smart caching |
| **Turborepo** | Simpler setup, fast |
| **Lerna** | Legacy projects |

---

## 📚 См. Также

- [🦞 OpenClaw Agents](../../../../../../workspace/AGENTS.md)
- [🎨 Skills Index](../../../../../../workspace/SKILLS-INDEX.md)
- [💻 Fullstack README](../README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия для Fullstack archetype |

---

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [💻 Fullstack](../README.md) → [🤖 Agents](#)
