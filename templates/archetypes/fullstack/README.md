# ═════════════════════════════════════════════════════════════════════════════
# 💻 Fullstack Archetype
# ═══════════════════════════════════════════════════════════════════════════════

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [💻 Fullstack](#)

---

## Overview

Архетип для fullstack приложений с monorepo структурой.

**Stack:**
- **Frontend:** Next.js 14 (React Server Components, TypeScript, TailwindCSS)
- **Backend:** Node.js (NestJS) / Go / Python (FastAPI)
- **Monorepo:** Nx / Turborepo
- **Shared:** TypeScript types, openapi-generator

---

## 🎯 Когда Использовать

✅ **Подходит для:**
- SaaS приложения
- Web platforms
- Admin dashboards
- Progressive Web Apps (PWA)
- Real-time applications

❌ **Не подходит для:**
- Только API → Web Service Archetype
- Только frontend → Frontend-only подход
- Mobile apps → Mobile Archetype (если есть)

---

## 📁 Структура Проекта (Monorepo)

```
fullstack/
├── apps/
│   ├── web/                    # Frontend (Next.js)
│   │   ├── app/               # App Router
│   │   ├── components/        # React components
│   │   ├── lib/               # Utilities
│   │   ├── styles/            # Global styles
│   │   └── public/            # Static assets
│   ├── api/                   # Backend (NestJS/Go/Python)
│   │   ├── src/
│   │   │   ├── modules/       # Feature modules
│   │   │   ├── common/        # Shared code
│   │   │   ├── config/        # Configuration
│   │   │   └── main.ts
│   │   └── test/
│   └── mobile/                # (Optional) React Native / Expo
├── packages/
│   ├── ui/                    # Shared UI components
│   ├── types/                 # Shared TypeScript types
│   ├── api-client/            # Generated API client
│   ├── config/                # Shared ESLint, TSConfig
│   └── validators/            # Zod schemas
├── tools/
│   ├── playwright/            # E2E tests
│   └── scripts/               # Build scripts
├── docker/                    # Multi-stage builds
├── k8s/                       # Kubernetes manifests
├── openclaw/                  # OpenClaw configuration
│   └── workspace/AGENTS.md
├── nx.json / turbo.json       # Monorepo config
├── docker-compose.yml         # Local development
├── package.json               # Root package.json
└── README.md
```

---

## 🚀 Quick Start

**Через CodeFoundry (рекомендуется):**
```bash
cd CodeFoundry
make new ARCHETYPE=fullstack NAME=my-saas
cd my-saas
```

**Вручную:**
```bash
cp -r /path/to/CodeFoundry/templates/archetypes/fullstack ~/projects/my-saas
cd ~/projects/my-saas
git init
```

---

## 🏗️ Monorepo Configuration

### Nx (Recommended for large apps)

```json
{
  "name": "fullstack-workspace",
  "version": 2,
  "cli": "nx",
  "implicitDependencies": {
    "package.json": "*"
  },
  "tasksRunnerOptions": {
    "default": {
      "runner": "nx/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "lint", "test", "e2e"]
      }
    }
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "inputs": ["production", "^production"]
    },
    "test": {
      "inputs": ["default", "^production", "{workspaceRoot}/jest.preset.js"]
    },
    "e2e": {
      "inputs": ["default", "^production"]
    }
  },
  "generators": {
    "@nx/react": {
      "application": {
        "bundler": "vite",
        "style": "tailwind",
        "routing": true
      }
    }
  }
}
```

### Turborepo (Simpler alternative)

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "outputs": []
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    },
    "e2e": {
      "dependsOn": ["build"],
      "outputs": ["playwright-report/**"]
    }
  }
}
```

---

## 🎨 Frontend (Next.js 14)

### App Router Structure

```
apps/web/app/
├── (auth)/                  # Auth route group
│   ├── login/
│   ├── register/
│   └── layout.tsx           # Auth layout
├── (dashboard)/             # Dashboard route group
│   ├── dashboard/
│   ├── settings/
│   └── layout.tsx           # Dashboard layout (protected)
├── api/                     # API routes (BFF pattern)
│   └── trpc/[...].ts        # tRPC handler
├── layout.tsx               # Root layout
└── page.tsx                 # Home page
```

### Server Component Example

```tsx
// apps/web/app/dashboard/page.tsx
import { Suspense } from 'react'
import { getUsers } from '@fullstack/api-client'

export default async function DashboardPage() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold">Dashboard</h1>

      <Suspense fallback={<UsersSkeleton />}>
        <UsersList />
      </Suspense>
    </div>
  )
}

async function UsersList() {
  const users = await getUsers()

  return (
    <ul className="space-y-2">
      {users.map(user => (
        <li key={user.id}>{user.email}</li>
      ))}
    </ul>
  )
}
```

### tRPC (Type-safe API)

```tsx
// apps/web/app/api/trpc/[trpc].ts
import { createNextApiHandler } from '@trpc/server/adapters/next'
import { createContext } from '@fullstack/api-server/lib/context'
import { appRouter } from '@fullstack/api-server/src/router'

export default createNextApiHandler({
  router: appRouter,
  createContext,
})

// Usage in component
import { api } from '@fullstack/api-client'
import { trpc } from '@/lib/trpc'

function UserProfile({ userId }: { userId: string }) {
  const { data } = trpc.users.getById.useQuery(userId)

  return <div>{data?.email}</div>
}
```

---

## 🔧 Backend (NestJS)

### Module Structure

```
apps/api/src/
├── modules/
│   ├── users/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.repository.ts
│   │   ├── users.module.ts
│   │   ├── dto/
│   │   └── entities/
│   ├── auth/
│   └── common/
├── config/
├── database/
├── shared/
└── main.ts
```

### Controller Example

```typescript
// apps/api/src/modules/users/users.controller.ts
import { Controller, Get, Param, UseGuards } from '@nestjs/common'
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger'
import { UsersService } from './users.service'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.usersService.findOne(id)
  }

  @Get()
  async findAll() {
    return this.usersService.findAll()
  }
}
```

---

## 🔄 Type Sharing

### OpenAPI Codegen

```json
{
  "scripts": {
    "openapi:generate": "openapi-generator-cli generate -i apps/api/swagger.yaml -o packages/api-client -g typescript-axios"
  }
}
```

### Shared Types Package

```typescript
// packages/types/src/user.ts
export interface User {
  id: string
  email: string
  username: string
  createdAt: Date
  updatedAt: Date
}

export interface CreateUserDto {
  email: string
  username: string
  password: string
}

export interface UpdateUserDto {
  email?: string
  username?: string
}
```

### Zod Validators

```typescript
// packages/validators/src/user.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  email: z.string().email(),
  username: z.string().min(3).max(50),
  password: z.string().min(8),
})

export const updateUserSchema = createUserSchema.partial()

export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
```

---

## 🧪 Testing Strategy

### Unit Tests (Jest + React Testing Library)

```tsx
// apps/web/src/components/__tests__/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { Button } from '../Button'

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)

    screen.getByText('Click me').click()
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### E2E Tests (Playwright)

```typescript
// tools/playwright/tests/auth.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('user can login', async ({ page }) => {
    await page.goto('/login')

    await page.fill('[name="email"]', 'user@example.com')
    await page.fill('[name="password"]', 'password123')
    await page.click('button[type="submit"]')

    await expect(page).toHaveURL('/dashboard')
    await expect(page.locator('h1')).toContainText('Dashboard')
  })

  test('redirects to login when unauthenticated', async ({ page }) => {
    await page.goto('/dashboard')

    await expect(page).toHaveURL('/login')
  })
})
```

---

## 🐳 Docker Configuration

### Multi-stage Build

```dockerfile
# docker/docker-compose.web.yml
services:
  web:
    build:
      context: .
      dockerfile: docker/Dockerfile.web
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://api:8000

  api:
    build:
      context: .
      dockerfile: docker/Dockerfile.api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/app
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_DB=app
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
```

---

## 🤖 OpenClaw Integration

См. [🤖 Agents](openclaw/workspace/AGENTS.md) для multi-agent конфигурации:

**5 агентов:**
- **Main Agent** — координатор
- **Frontend Agent** — React/Next.js components
- **Backend Agent** — NestJS/Go/Python API
- **Fullstack Review Agent** — Full-stack code review
- **DevOps Agent** — deployment

---

## 📋 Nx Commands

| Команда | Описание |
|---------|----------|
| `nx serve web` | Запустить frontend |
| `nx serve api` | Запустить backend |
| `nx run-many --target=serve --all` | Запустить все приложения |
| `nx build web` | Собрать frontend (production) |
| `nx build api` | Собрать backend |
| `nx affected --target=build` | Собрать только изменённые |
| `nx run web:e2e` | Запустить E2E тесты |
| `nx graph` | Визуализировать dependency graph |

---

## 🚀 Deployment

### Vercel (Frontend)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

### Railway/Render (Fullstack)

```bash
# Deploy both apps
railway up
```

### Kubernetes

```yaml
# k8s/web-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: web:latest
        ports:
        - containerPort: 3000
        env:
        - name: NEXT_PUBLIC_API_URL
          value: "http://api:8000"
```

---

## 📚 См. Также

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)
- [📋 Все Архетипы](../README.md)

### OpenClaw Integration
- [🦞 OpenClaw README](../../../openclaw/README.md)
- [🎯 Workspace](../../../openclaw/workspace/README.md)
- [🤖 Agents](../../../openclaw/workspace/AGENTS.md)
- [🎨 Skills Index](../../../openclaw/workspace/SKILLS-INDEX.md)

### Related Archetypes
- [🌐 Web Service Archetype](../web-service/README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.1.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs, quick start |
| 1.0.0 | 2025-11-05 | Первая версия Fullstack archetype |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [💻 Fullstack](#)
