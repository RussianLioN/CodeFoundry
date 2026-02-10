# 💻 Skill: Code Generator

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🤖 AI Assistant Skills](#)
---

## Description

Быстрая генерация кода по шаблонам для различных языков и фреймворков.

---

## 🎯 Capabilities

### 🔧 Code Generation

**Использование:**
```
👤 "Создай CRUD для User entity"
👤 "Сгенерируй API endpoint для логина"
👤 "Напиши boilerplate для React компонента"
👤 "Создай SQL запрос для выборки с фильтрацией"
```

**Языки и фреймворки:**
- JavaScript (Node.js, Express)
- Python (FastAPI, Django)
- SQL (PostgreSQL, MySQL)
- Go (Gin, Echo)
- React, Vue, Angular
- TypeScript
- Ruby on Rails
- Java Spring

---

### 📦 Boilerplate Generation

**Шаблоны:**

```
CRUD Generator:
  - Model
  - Repository
  - Controller
  - Service
  - Tests

API Generator:
  - Endpoint
  - Request/Response DTOs
  - Validation
  - Documentation

Full Stack:
  - Backend + Frontend
  - Docker configuration
  - Environment setup
```

---

## 🎯 Code Patterns

### 1. CRUD Pattern

**Node.js/TypeScript:**

```typescript
interface User {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
  updatedAt: Date;
}

class UserService {
  async findAll(): Promise<User[]> { }
  async findById(id: string): Promise<User | null> { }
  async create(data: CreateUserDto): Promise<User> { }
  async update(id: string, data: UpdateUserDto): Promise<User> { }
  async delete(id: string): Promise<void> { }
}
```

### 2. API Endpoint Pattern

**Python/FastAPI:**

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

class UserCreate(BaseModel):
    email: str
    password: str
    name: str

@app.post("/api/users")
async def create_user(data: UserCreate):
    """Create new user"""
    user = await service.create(data)
    return {"id": user.id, "email": user.email}
```

### 3. Database Query Pattern

**SQL Generator:**

```sql
-- SELECT with pagination
SELECT *
FROM users
WHERE deleted_at IS NULL
ORDER BY created_at DESC
LIMIT {page_size} OFFSET {(page - 1) * page_size};
```

---

## 🧪 Test Generation

```
👤 "Напиши тесты для функции calculateTotal"

🤖 Code Generator Skill:
    1. 📖 Reading function...
    2. 🧪 Generated tests:
       - ✓ Valid input returns number
       - ✓ Empty array returns 0
       - ✓ Invalid input throws error
    3. 📝 Tests created in tests/ directory
```

---

## 🔗 Integration with Tools

Использует:
- **write** — создание файлов
- **read** — чтение существующего кода
- **bash** — запуск генераторов

---

## 📝 Usage Examples

### Сценарий 1: CRUD Generation

```
👤 "Создай полный CRUD для Product entity"

🤖 Code Generator Skill:
    1. 🎯 Generating for Node.js + TypeScript
    2. 📦 Generated files:
       - models/Product.ts
       - repositories/ProductRepository.ts
       - services/ProductService.ts
       - controllers/ProductController.ts
       - routes/products.ts
       - tests/ProductService.test.ts
    3. ✅ CRUD complete with validation
```

### Сценарий 2: API Endpoint

```
👤 "Создай POST /api/orders endpoint"

🤖 Code Generator Skill:
    1. 🎯 Generating for FastAPI + PostgreSQL
    2. 📦 Generated:
       - routers/orders.py
       - schemas/order.py
       - services/order_service.py
       - repositories/order_repository.py
    3. ✅ API endpoint with validation
```

### Сценарий 3: Voice Command

```
🗣️ "Создай boilerplate для React компонента"

🤖 Code Generator Skill:
    1. 🎤 Voice analyzed: "Create React component template"
    2. ⚡ Generating...
    3. 📦 Generated:
       - Component.tsx
       - Component.test.tsx
       - hooks/useComponent.ts
    4. ✅ React component ready
```

---

## 🎨 Supported Languages & Frameworks

| Язык | Фреймворк | Шаблоны |
|------|----------|---------|
| **JavaScript** | Node.js/Express | CRUD, API, CLI |
| **TypeScript** | FastAPI, NestJS | Typed CRUD, DTOs |
| **Python** | Django, FastAPI | Django models, views, serializers |
| **Go** | Gin, Echo | Handlers, models, middleware |
| **Ruby** | Rails | Controllers, models, routes |
| **SQL** | PostgreSQL | Queries, migrations |
| **React** | React | Components, hooks, tests |
| **Vue** | Vue.js | Components, composables |
| **Java** | Spring Boot | Entities, repositories, services |

---

## 🔧 Configuration

### Генераторы по умолчанию

```json
{
  "codeGenerator": {
    "defaultLanguage": "typescript",
    "defaultFramework": "fastapi",
    "outputPath": "generated/",
    "includeTests": true,
    "includeDocs": true,
    "style": "standard"
  }
}
```

### Языковые стандарты

```json
{
  "codeGenerator": {
    "standards": {
      "javascript": "airbnb-base",
      "python": "pep8",
      "go": "standard",
      "sql": "convention"
    }
  }
}
```

---

## 📊 Code Quality Checks

Генерируемый код включает:

✅ **Type Safety** — TypeScript интерфейсы, типизация
✅ **Error Handling** — try/catch блоки, error classes
✅ **Input Validation** — Pydantic модели, Joi схемы
✅ **Logging** — Winston, Pino, structured logs
✅ **Documentation** — JSDoc, docstrings
✅ **Tests** — Jest, pytest, integration tests

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────┐
│ 1. Анализ требований                     │
│    ↓                                        │
│ 2. Выбор языка/фреймворка                  │
│    ↓                                        │
│ 3. Генерация кода:                         │
│    ├── Models (сущности)                   │
│    ├── Repositories                     │
│    ├── Services                          │
│    ├── Controllers/Handlers              │
│    ├── DTOs/Schemas                     │
│    └── Tests                             │
│    ↓                                        │
│ 4. Валидация качества                    │
│    ↓                                        │
│ 5. Доставка результата                   │
└─────────────────────────────────────────────────────┘
```

---

## 🛡️ Advanced Features

### Microservice Generator

```
👤 "Создай микросервис для пользователей"

🤖 Code Generator Skill:
    1. 🏗️ Microservice template:
       - Dockerfile
       - docker-compose.yml
       - Kubernetes manifests
       - Helm chart
    2. 📦 Generated 8 files:
       - main.go / main.go
       - handler.go
       - repository.go
       - service.go
       - Dockerfile
       - docker-compose.yml
       - deployment.yaml
       - Chart/ (templates)
    3. ✅ Microservice ready for deployment
```

### CI/CD Pipeline Generator

```
👤 "Создай CI pipeline для этого проекта"

🤖 Code Generator Skill:
    1. 🔧 Analyzing project...
    2. 📦 Generated:
       - .github/workflows/ci.yml
       - .github/workflows/cd.yml
       - .github/workflows/test.yml
    3. ✅ CI/CD configured
```

---

## 🔗 Voice Commands

| Голосовая команда | Действие |
|-------------------|----------|
| "Создай CRUD для..." | CRUD generation |
| "Напиши API endpoint для..." | API generation |
| "Сгенерируй модель данных..." | Model generation |
| "Создай компонент React..." | Component generation |
| "Напиши SQL запрос..." | SQL query generation |

---

## 📚 См. Также

- [📖 Prompt Generation](../../../../instructions/prompt-generation.md)
- [📋 Block Reference](../../../../instructions/blocks-reference.md)
- [🎨 Workspace](../README.md)
- [🤖 AI Assistants](../README.md)
- [🤖 Agents](../AGENTS.md)

---

## 🔄 История Изменений

| Веция | Дата | Изменения |
|-------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [💻 Code Generator](#)
