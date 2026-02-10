# 🐛 Skill: Debugging

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [👨‍💻 Development Skills](#)

---

## Description

Автоматический поиск и исправление ошибок в коде с использованием AI анализа.

---

## 🎯 Capabilities

### 🔍 Bug Detection

**Использование:**
```
👤 "Найди баг в коде"
👤 "Почему эта функция не работает?"
👤 "Отладь ошибку авторизации"
```

**Действия:**
```bash
1. Анализирует stack trace или ошибку
2. Читает соответствующий код
3. Ищет причину проблемы
4. Предлагает исправление
5. Применяет исправление (если одобрено)
```

**Пример:**
```
👤 "Функция calculateTotal возвращает NaN"

🤖 Debugging Skill:
    1. 🔍 Analyzing calculateTotal function...
    2. 📋 Found issue: Array.map returns strings instead of numbers
    3. 💡 Solution: Add Number() conversion
    4. ✅ Fixed:
       const total = array.map(Number).reduce((a, b) => a + b, 0);
```

---

### 🧪 Error Analysis

**Типы ошибок:**

| Тип | Описание | Пример |
|-----|----------|--------|
| **ReferenceError** | Переменная не определена | `undefined is not a function` |
| **TypeError** | Неверный тип операции | `Cannot read property 'x' of undefined` |
| **SyntaxError** | Синтаксическая ошибка | `Unexpected token` |
| **LogicError** | Логическая ошибка | Infinite loop |
| **AsyncError** | Асинхронная ошибка | Promise rejected |

---

### 📊 Root Cause Analysis

**Использование:**
```
👤 "Найди корневую причину ошибки"
👤 "Почему падает API?"
```

**Процесс анализа:**
```
1. 📥 Получение stack trace
2. 📖 Чтение файла с ошибкой
3. 🔍 Поиск связанных вызов
4. 💡 Определение root cause
5. 💬 Предложение исправления
```

**Пример:**
```javascript
// Stack trace:
Error: Cannot read property 'user' of undefined
    at UserService.getById (services/user.js:45)
    at AuthController.login (controllers/auth.js:23)

🤖 Debugging Skill:
    1. 🔍 Analyzing stack trace...
    2. 📖 Reading auth.js:23
    3. 💡 Found: User object not validated before passing to service
    4. 🔍 Root cause: Missing validation in controller
    5. 💬 Fix: Add check: if (!user) throw new Error('Invalid user')
```

---

### 🛠️ Auto-Fix

**Некоторые ошибки могут быть исправлены автоматически:**

```
👤 "Исправь эту ошибку автоматически"

🤖 Debugging Skill:
    1. 🔍 Analyzing error...
    2. 🔧 Applied fix:
       - Added null check: `if (!result) return null`
       - Fixed destructuring: `const { data } = result || {}`
    3. ✅ Fixed successfully
    4. 💬 Review changes before committing
```

---

## 🔧 Debugging Techniques

### 1. Logging Strategy

```
👤 "Добавь логи для отладки"

🤖 Debugging Skill:
    1. 📖 Reading file...
    2. 🔍 Adding logging at key points:
       - Function entry: `console.log('functionName called with:', args)`
       - Decision points: `console.log('Branch taken: X')`
       - Error points: `console.error('Error occurred:', error)`
    3. ✅ Logging added
```

### 2. Breakpoint Strategy

```
👤 "Где поставить breakpoint?"

🤖 Debugging Skill:
    1. 🔍 Analyzing code flow...
    2. 💡 Recommended breakpoints:
       - Line 15: Before API call
       - Line 23: After data transformation
       - Line 31: Inside error handler
```

### 3. Rubber Ducking

```
👤 "Объясни код построчно"

🤖 Debugging Skill:
    1. 📖 Reading code line by line...
    2. 💬 Explaining:
       - Линия 10: Создаём переменную counter
       - Линия 15: Увеличиваем counter
       - Линия 20: Возвращаем результат
    3. 🎯 Understanding complete!
```

---

## 📝 Debugging Workflow

```
1. 🐛 Ошибка обнаружена
   ↓
2. 🔍 Анализ проблемы
   ↓
3. 💡 Предложение решения
   ↓
4. 🔧 Применение исправления
   ↓
5. ✅ Проверка исправления
   ↓
6. 📝 Добавление теста (чтобы не повторилось)
```

---

## 🔗 Error Patterns

### Common Bug Patterns

#### Pattern 1: Null Reference

**Проблема:**
```javascript
const user = users.find(u => u.id === id);
return user.name; // ❌ Crash if user not found
```

**Решение:**
```javascript
const user = users.find(u => u.id === id);
return user?.name || 'Unknown'; // ✅ Safe
```

---

#### Pattern 2: Async/Await Error

**Проблема:**
```javascript
const result = await fetch(url);
const data = result.json(); // ❌ Crashes if not JSON
```

**Решение:**
```javascript
const response = await fetch(url);
const data = await response.json().catch(() => ({})); // ✅ Safe
```

---

#### Pattern 3: Race Condition

**Проблема:**
```javascript
let counter = 0;
function increment() {
  counter++; // ❌ Race condition!
}
```

**Решение:**
```javascript
import { atomic } from 'node:stream/promises';

let counter = 0;
async function increment() {
  counter = await atomic(() => counter + 1)();
}
```

---

## 🧪 Test Reproduction

**Использование:**
```
👤 "Воспроизведи баг"
👤 "Создай тест для этого бага"
```

**Действия:**
```bash
1. Созда reproduction case в тестовом файле
2. Добавляет assertions для expected поведения
3. Запускает тест
4. Фиксит, когда тест проходит
```

**Пример:**
```javascript
// Воспроизведение бага:
describe('Bug: CalculateTotal NaN Regression', () => {
  test('should handle empty array', () => {
    expect(calculateTotal([])).toBe(0); // Was: NaN
  });

  test('should handle array with strings', () => {
    expect(calculateTotal(['1', '2'])).toBe(3); // Was: NaN
  });
});
```

---

## 🔗 Tools Integration

Использует инструменты:
- **read** — чтение файлов кода
- **write** — создание исправленных версий
- **bash** — выполнение команд отладки
- **git** — история изменений для поиска

---

## 📝 Usage Examples

### Сценарий 1: Анализ ошибки

```
👤 "Анализируй ошибку в auth/login.js"

🤖 Debugging Skill:
    1. 📖 Reading auth/login.js...
    2. 🔍 Error occurred at line 45:
       TypeError: Cannot read property 'token' of undefined
    3. 🔍 Root cause: jwt.verify() returned null
    4. 💡 Solution: Add token validation before verify
    5. 🔧 Applied fix
    6. ✅ Bug fixed
```

### Сценарий 2: System Debugging

```
👤 "Почему API отвечает медленно?"

🤖 Debugging Skill:
    1. 🔍 Analyzing API performance...
    2. 📊 Found issues:
       - N+1 queries in loop (cart items)
       - No caching for user data
       - Missing database indexes
    3. 💡 Recommendations:
       - Implement batching
       - Add Redis cache
       - Add indexes on user_id, product_id
    4. ✅ Optimization plan provided
```

### Сценарий 3: Voice Command

```
🗣️ "Исправь ошибку в сервисе оплаты"

🤖 Debugging Skill:
    1. 🔍 Checking payment service logs...
    2. 📋 Found error: Payment gateway timeout
    3. 💡 Quick fix: Increase timeout in config
    4. 🔧 Applied: TIMEOUT_MS increased from 5000 → 10000
    5. ✅ Issue resolved
```

---

## 🛡️ Prevention Strategies

### 1. TypeScript/Typescript

```
// ❌ Небезопасно
function processOrder(order: any) { }

// ✅ Безопасно
interface Order {
  id: string;
  items: OrderItem[];
  total: number;
}
function processOrder(order: Order) { }
```

### 2. Input Validation

```
// ❌ Нет валидации
function createUser(email: string, password: string) {
  db.users.create({ email, password });
}

// ✅ С валидацией
function createUser(email: string, password: string) {
  if (!email || !password) throw new Error('Required fields missing');
  if (!isValidEmail(email)) throw new Error('Invalid email');
  // ... creation logic
}
```

### 3. Error Boundaries

```
// ❌ Необработанные ошибки
async function fetchData() {
  const response = await fetch(url);
  return await response.json();
}

// ✅ С обработкой ошибок
async function fetchData() {
  try {
    const response = await fetch(url);
    return await response.json();
  } catch (error) {
    logger.error('Fetch failed:', error);
    return null;
  }
}
```

---

## 📚 См. Также

- [👨‍💻 Development Skills Index](../README.md)
- [🔄 Git Workflow](git-workflow.md)
- [🔍 Code Review](code-review.md)
- [🧪 Testing Strategy](testing-strategy.md)
- [🎯 Workspace](../README.md)
- [🤖 Agents](../AGENTS.md)

---

## 🔄 История Изменений

| Веция | Дата | Изменения |
|-------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🐛 Debugging](#)
