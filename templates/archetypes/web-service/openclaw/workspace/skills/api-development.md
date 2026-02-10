# 🌐 Skill: API Development (Web Service)

> [🏠 Главная](../../../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../../../README.md) → [🎨 Archetypes](../../../../../../README.md) → [🌐 Web Service](../../../../README.md) → [🎨 Skills](#)

---

## Description

Специализированный skill для разработки REST/GraphQL API сервисов. Используется Dev Agent при работе с web-service archetype.

---

## 🎯 Capabilities

### 📦 CRUD Endpoint Generation

**Использование:**
```
👤 "Создай CRUD endpoints для User entity"
👤 "Добавь GET /api/products"
👤 "Создай POST /api/orders с валидацией"
```

**Действия:**
```bash
1. Создаёт route (routes/)
2. Создаёт controller (controllers/)
3. Создаёт service (services/)
4. Создаёт модель/схему (models/)
5. Добавляет request validation
6. Добавляет OpenAPI документацию
7. Создаёт unit тесты
8. Обновляет API index
```

**Пример вывода:**
```typescript
// routes/users.ts
import { Router } from 'express';
import { UserController } from '../controllers/userController';
import { validateRequest } from '../middleware/validateRequest';
import { userCreateSchema, userUpdateSchema } from '../models/user.schema';

const router = Router();
const controller = new UserController();

/**
 * @openapi
 * /api/users:
 *   get:
 *     summary: List all users
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: List of users
 */
router.get('/', controller.list);

/**
 * @openapi
 * /api/users/{id}:
 *   get:
 *     summary: Get user by ID
 *     tags: [Users]
 *     parameters:
 *       - $ref: '#/parameters/userId'
 *     responses:
 *       200:
 *         description: User object
 *       404:
 *         description: User not found
 */
router.get('/:id', controller.getById);

/**
 * @openapi
 * /api/users:
 *   post:
 *     summary: Create new user
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UserCreate'
 *     responses:
 *       201:
 *         description: User created
 *       400:
 *         description: Validation error
 */
router.post '/',
  validateRequest(userCreateSchema),
  controller.create
);

router.put('/:id',
  validateRequest(userUpdateSchema),
  controller.update
);

router.delete('/:id', controller.delete);

export default router;
```

---

### ✅ Request/Response Validation

**Node.js + Zod:**
```typescript
import { z } from 'zod';

export const userCreateSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  name: z.string().min(2, 'Name must be at least 2 characters'),
  role: z.enum(['user', 'admin']).default('user'),
});

export type UserCreate = z.infer<typeof userCreateSchema>;
```

**Python + Pydantic:**
```python
from pydantic import BaseModel, EmailStr, Field
from enum import Enum

class UserRole(str, Enum):
    USER = "user"
    ADMIN = "admin"

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, description="Password must be at least 8 characters")
    name: str = Field(min_length=2, description="Name must be at least 2 characters")
    role: UserRole = UserRole.USER
```

**Go + go-playground:**
```go
type UserCreate struct {
    Email    string `json:"email" validate:"required,email"`
    Password string `json:"password" validate:"required,min=8"`
    Name     string `json:"name" validate:"required,min=2"`
    Role     string `json:"role" validate:"oneof=user admin"`
}
```

---

### 🛡️ Error Handling

**Унифицированный формат ошибок:**
```typescript
// middleware/errorHandler.ts
export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public code?: string,
    public details?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      error: {
        message: err.message,
        code: err.code,
        details: err.details,
      },
    });
  }

  // Log unexpected errors
  console.error(err);

  res.status(500).json({
    error: {
      message: 'Internal server error',
      code: 'INTERNAL_ERROR',
    },
  });
};

// Usage
throw new ApiError(404, 'User not found', 'USER_NOT_FOUND', { userId: id });
```

---

### 📝 OpenAPI Documentation

**Автоматическая генерация:**
```typescript
// swagger.ts
import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'My API',
      version: '1.0.0',
      description: 'API documentation',
    },
    components: {
      schemas: {
        User: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            email: { type: 'string', format: 'email' },
            name: { type: 'string' },
            role: { type: 'string', enum: ['user', 'admin'] },
          },
        },
        Error: {
          type: 'object',
          properties: {
            message: { type: 'string' },
            code: { type: 'string' },
            details: { type: 'object' },
          },
        },
      },
    },
  },
  apis: ['./src/routes/*.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);
```

---

### 🔐 Authentication Middleware

**JWT Validation:**
```typescript
// middleware/auth.ts
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';

export interface AuthRequest extends Request {
  userId?: string;
  userRole?: string;
}

export const authenticate = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({
      error: { message: 'Authentication required', code: 'AUTH_REQUIRED' },
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
      userId: string;
      role: string;
    };
    req.userId = decoded.userId;
    req.userRole = decoded.role;
    next();
  } catch (err) {
    return res.status(401).json({
      error: { message: 'Invalid token', code: 'INVALID_TOKEN' },
    });
  }
};

export const authorize = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.userId || !roles.includes(req.userRole!)) {
      return res.status(403).json({
        error: { message: 'Insufficient permissions', code: 'FORBIDDEN' },
      });
    }
    next();
  };
};

// Usage
router.post('/admin',
  authenticate,
  authorize('admin'),
  adminController.action
);
```

---

### ⚡ Rate Limiting

```typescript
// middleware/rateLimit.ts
import rateLimit from 'express-rate-limit';

export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: {
    error: { message: 'Too many requests', code: 'RATE_LIMIT_EXCEEDED' },
  },
  standardHeaders: true,
  legacyHeaders: false,
});

export const strictRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // 5 requests per window
  message: {
    error: { message: 'Too many attempts', code: 'RATE_LIMIT_EXCEEDED' },
  },
});

// Usage
router.post('/auth/login',
  strictRateLimiter,
  authController.login
);

router.use('/api/', rateLimiter);
```

---

### 🧪 Testing Patterns

**Unit Test (Controller):**
```typescript
// tests/unit/userController.test.ts
import { UserController } from '../../controllers/userController';
import { UserService } from '../../services/userService';

jest.mock('../../services/userService');

describe('UserController', () => {
  let controller: UserController;
  let mockService: jest.Mocked<UserService>;

  beforeEach(() => {
    mockService = new UserService() as jest.Mocked<UserService>;
    controller = new UserController(mockService);
  });

  describe('getById', () => {
    it('should return user when found', async () => {
      const mockUser = { id: '1', email: 'test@example.com', name: 'Test' };
      mockService.findById.mockResolvedValue(mockUser);

      const req = { params: { id: '1' } } as any;
      const res = {
        json: jest.fn().mockReturnThis(),
        status: jest.fn().mockReturnThis(),
      } as any;

      await controller.getById(req, res);

      expect(res.status).toHaveBeenCalledWith(200);
    });

    it('should return 404 when user not found', async () => {
      mockService.findById.mockResolvedValue(null);

      const req = { params: { id: '999' } } as any;
      const res = {
        json: jest.fn().mockReturnThis(),
        status: jest.fn().mockReturnThis(),
      } as any;

      await controller.getById(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
    });
  });
});
```

**Integration Test:**
```typescript
// tests/integration/users.test.ts
import request from 'supertest';
import { app } from '../../app';

describe('Users API Integration Tests', () => {
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    // Setup test database
    await setupTestDb();

    // Create auth token
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'admin@test.com', password: 'password' });
    authToken = response.body.token;
  });

  describe('POST /api/users', () => {
    it('should create user', async () => {
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          email: 'new@example.com',
          password: 'password123',
          name: 'New User',
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id');
      userId = response.body.id;
    });

    it('should validate email format', async () => {
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          email: 'invalid-email',
          password: 'password123',
          name: 'Test',
        });

      expect(response.status).toBe(400);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });
  });
});
```

---

## 📝 API Development Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Определить endpoint                                       │
│    ├── HTTP метод (GET/POST/PUT/DELETE)                    │
│    ├── Путь (/api/resource)                                 │
│    ├── Параметры (path/query/body)                          │
│    └── Ответ (success/error)                                │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Создать validation schema                                │
│    ├── Request validation (Zod/Pydantic)                   │
│    ├── Response schema                                      │
│    └── Error cases                                          │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Написать тест СНАЧАЛА (TDD)                              │
│    ├── Success cases                                       │
│    ├── Validation errors                                   │
│    ├── Not found cases                                     │
│    └── Permission checks                                   │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Реализовать endpoint                                     │
│    ├── Route (routes/)                                     │
│    ├── Controller (controllers/)                           │
│    ├── Service (services/)                                 │
│    └── Model (models/)                                     │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Добавить OpenAPI документацию                            │
│    ├── Summary                                             │
│    ├── Parameters                                         │
│    ├── Request body schemas                                │
│    └── Response schemas                                    │
└─────────────────────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. Запустить тесты                                          │
│    └── npm test / go test / pytest                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Integration with Tools

Использует инструменты:
- **write** — создание endpoint файлов
- **read** — чтение существующего кода для контекста
- **bash** — запуск тестов, линтеров
- **test-runner** — выполнение unit/integration тестов

---

## 🔗 Voice Commands

| Голосовая команда | Действие |
|-------------------|----------|
| "Создай GET /api/users" | Создать endpoint |
| "Добавь валидацию email" | Добавить validation |
| "Напиши тесты для..." | Создать тесты |
| "Добавь OpenAPI доку" | Добавить документацию |
| "Рефактори контроллер" | Рефакторинг |

---

## 📚 См. Также

- [🎨 Skills Index](../../../../../../../workspace/SKILLS-INDEX.md)
- [🧪 Testing Strategy](../../../../../../../workspace/skills/development/testing-strategy.md)
- [🔍 Code Review](../../../../../../../workspace/skills/development/code-review.md)
- [🌐 Web Service Archetype](../../../../README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../../../README.md) → [🎨 Archetypes](../../../../../../README.md) → [🌐 Web Service](../../../../README.md) → [🎨 Skills](#)
