# 🎨 Skill: Testing Strategy

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [👨‍💻 Development Skills](#)

---

## Description

Стратегия тестирования программного обеспечения с автоматизацией через AI агента.

---

## 🎯 Capabilities

### 🧪 Unit Test Generation

**Использование:**
```
👤 "Напиши тесты для функции login"
👤 "Покрой тестами модуль auth"
👤 "Создай unit tests для User model"
```

**Действия:**
```bash
1. Анализирует код функции/метода
2. Определяет граничные случаи
3. Генерирует тестовые сценарии
4. Создаёт test файл с тестами
5. Следует_best_practices фреймворка
```

**Пример вывода:**
```javascript
// auth/login.test.js
describe('Login Function', () => {
  test('should login with valid credentials', async () => {
    const result = await login('user@example.com', 'password123');
    expect(result.success).toBe(true);
    expect(result.token).toBeDefined();
  });

  test('should reject invalid credentials', async () => {
    const result = await login('user@example.com', 'wrong');
    expect(result.error).toBe('Invalid credentials');
  });

  test('should handle edge cases', async () => {
    // Empty credentials
    await expect(login('', '')).rejectstoThrow('Credentials required');
  });
});
```

---

### 🔍 Coverage Analysis

**Использование:**
```
👤 "Покрой тестами этот модуль"
👤 "Какой процент покрытия тестами?"
👤 "Найди непокрытый код"
```

**Действия:**
```bash
1. Запускает coverage tool (jest --coverage, pytest --cov)
2. Анализирует результаты
3. Находит непокрытые строки
4. Рекомендует недостающие тесты
```

---

### 🎯 TDD Workflow

**Test-Driven Development подход:**

```
👤 "Реализуй функцию отправки email через TDD"

🤖 Testing Strategy Skill:
    1. 📝 Пишем тест СНАЧА (Red)
    2. ✅ Запускаем тест — FAILS
    3. 💻 Пишем минимальный код — PASSES
    4. ♻️ Рефакторим — STILL PASSES
    5. 🔄 Повторяем до готовности
```

**Пример TDD сессии:**
```
👤 "Создай функцию валидации email через TDD"

🤖 Testing Strategy Skill:

Шаг 1: Red (пишем тест)
describe('EmailValidator', () => {
  test('should validate correct email', () => {
    expect(validateEmail('user@domain.com')).toBe(true);
  });
});

👤 "Окей, тест готов"

Шаг 2: Run — FAILS (функции нет)
👤 "Пиши код"

Шаг 3: Green (минимальная реализация)
function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

👤 "Тест прошёл"

Шаг 4: Refactor (улучшаем, сохраняя green)
function validateEmail(email) {
  if (!email || typeof email !== 'string') return false;
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email.trim().toLowerCase());
}
```

---

### 🔧 Integration Tests

**Использование:**
```
👤 "Напиши integration тест для API endpoint"
👤 "Создай тест для авторизации через API"
```

**Действия:**
```bash
1. Создаёт test file (e.g., api/auth.integration.test.js)
2. Добавляет setup/teardown
3. Создаёт mock серверы если нужно
4. Пишет тестовые сценарии
5. Добавляет assertions
```

**Пример:**
```javascript
describe('Auth API Integration Tests', () => {
  let server;

  beforeAll(async () => {
    server = await startTestServer();
  });

  afterAll(async () => {
    await server.close();
  });

  test('POST /api/auth/login - should return token', async () => {
    const response = await request(server)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'pass123' });

    expect(response.status).toBe(200);
    expect(response.body.token).toBeDefined();
  });
});
```

---

### 🎯 Testing Frameworks

**Автоматическое определение фреймворка:**

| Тип проекта | Фреймворк | Файл |
|------------|-----------|------|
| Node.js (Jest) | jest | `*.test.js` |
| Node.js (Mocha) | mocha | `*.test.js` |
| Python (pytest) | pytest | `test_*.py` |
| Python (unittest) | unittest | `test_*.py` |
| Go (testing) | go test | `*_test.go` |
| Rust (cargo) | cargo test | `*_test.rs` |

---

## 🔗 Integration with Instructions

Этот skill использует:
- [blocks-reference.md](../../../../instructions/blocks-reference.md) — для структуры тестов
- [quality-framework.md](../../../../instructions/quality-framework.md) — для валидации тестов

---

## 📝 Usage Examples

### Сценарий 1: Full Test Suite

```
👤 "Создай полный набор тестов для модуля пользователей"

🤖 Testing Strategy Skill:
    1. 📋 Analysing user module...
    2. ✅ Found: User model, validation, repository
    3. 📝 Creating test suite:
       - Unit tests for User model
       - Unit tests for validation
       - Integration tests for repository
    4. 🧪 Running coverage...
    5. 📊 Coverage: 87%
    6. 📝 Test files created:
       - models/user/user.test.js
       - validation/validation.test.js
       - repositories/user.repository.integration.test.js
```

### Сценарий 2: Missing Tests

```
👤 "Найди и покрой непокрытые функции"

🤖 Testing Strategy Skill:
    1. 📊 Running coverage...
    2. 📉 Coverage: 65%
    3. 🔍 Uncovered functions:
       - UserService.deleteUser() - ❌ Not tested
       - EmailService.sendPasswordReset() - ❌ Not tested
    4. 📝 Creating tests for missing functions...
    5. ✅ Tests added
    6. 📊 New coverage: 92%
```

### Сценарий 3: TDD Session

```
👤 "Реализуй через TDD: функцию форматирования даты"

🤖 Testing Strategy Skill (TDD Mode):

    📝 Step 1: Red (Write failing test)
    ══════════════════════════════════════════════════════════════════
    describe('DateFormatter', () => {
      test('should format date as DD.MM.YYYY', () => {
        expect(formatDate('2025-11-05')).toBe('05.11.2025');
      });
    });

    👤 "Запусти тест"

    📝 Step 2: Green (Minimal implementation)
    function formatDate(date) {
      const d = new Date(date);
      return `${d.getDate()}.${d.getMonth()+1}.${d.getFullYear()}`;
    }

    👤 "Тест прошёл!"

    📝 Step 3: Refactor (Improve while green)
    function formatDate(date) {
      if (!date) return '';
      const d = new Date(date);
      const day = String(d.getDate()).padStart(2, '0');
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const year = d.getFullYear();
      return `${day}.${month}.${year}`;
    }

    👤 "Готово! Код рефакторин, тесты проходят"
```

---

## 🔧 Configuration

### Test Framework Defaults

```json
{
  "testing": {
    "framework": "auto",
    "runner": "npm test",
    "coverage": {
      "threshold": 80,
      "reporter": "text"
    },
    "defaults": {
      "assertionStyle": "expect",
      "mocking": "auto"
    }
  }
}
```

### Language-Specific Settings

**Node.js (Jest):**
```json
{
  "jest": {
    "testEnvironment": "node",
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80
      }
    }
  }
}
```

**Python (pytest):**
```yaml
# pytest.ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
addopts = --cov=src --cov-report=html --cov-fail-under=80
```

---

## 📋 Test Templates

### Unit Test Template

```javascript
describe('[ModuleName]', () => {
  describe('[FunctionName]', () => {
    test('should [expected behavior]', () => {
      // Arrange
      const input = ...;
      const expected = ...;

      // Act
      const result = functionName(input);

      // Assert
      expect(result).toEqual(expected);
    });
  });
});
```

### Integration Test Template

```javascript
describe('[Feature] Integration Tests', () => {
  let app;

  beforeAll(async () => {
    app = await createTestApp();
  });

  afterAll(async () => {
    await app.close();
  });

  test('should [full scenario]', async () => {
    // Scenario steps
    const response = await request(app)
      .post('/endpoint')
      .send({ data: 'value' });

    expect(response.status).toBe(200);
  });
});
```

---

## 🔗 Voice Commands

| Голосовая команда | Действие |
|-------------------|----------|
| "Напиши тесты для..." | Генерация тестов |
| "Покрой тестами модуль" | Coverage анализ |
| "Создай integration тест" | Integration тесты |
| "Запусти тесты" | Выполнение npm test |
| "Покажи coverage" | Отчёт о покрытии |

---

## 🛡️ Best Practices

### 1. Тестовая Пирамида

```
        ┌─────────────────────┐
        │   Unit Tests        │
        │  (изолировано)      │
        └─────────────────────┘
                  ↓
        ┌─────────────────────┐
        │  Integration Tests  │
        │  (через API)       │
        └─────────────────────┘
                  ↓
        ┌─────────────────────┐
        │   E2E Tests         │
        │  (через UI)        │
        └─────────────────────┘
```

### 2. AAA Pattern (Arrange-Act-Assert)

```
Arrange: Настройка данных
    Act: Выполнение действия
    Assert: Проверка результата
```

### 3. Given-When-Then (BDD)

```javascript
describe('User Authentication', () => {
  given('a registered user', () => {
    // Setup
  });

  when('user logs in with valid credentials', () => {
    // Action
  });

  then('user should be authenticated', () => {
    // Assert
  });
});
```

---

## 📚 См. Также

- [👨‍💻 Development Skills Index](../README.md)
- [🔄 Git Workflow](git-workflow.md)
- [🔍 Code Review](code-review.md)
- [🐛 Debugging](debugging.md)
- [🎯 Workspace](../README.md)
- [🤖 Agents](../AGENTS.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🧪 Testing Strategy](#)
