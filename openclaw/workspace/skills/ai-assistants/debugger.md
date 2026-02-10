# 🔬 Skill: Debugger (AI Assistant)

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🤖 AI Assistant Skills](#)

---

## Description

Специализированный AI-агент для глубокой отладки кода, анализа ошибок и поиска решений сложных проблем. Работает в изолированном sandbox режиме для безопасной отладки.

---

## 🎯 Capabilities

### 🔍 Deep Code Analysis

**Использование:**
```
👤 "Отладь эту функцию"
👤 "Найди почему падает авторизация"
👤 "Анализируй stack trace"
```

**Действия:**
```bash
1. Читает файл с ошибкой
2. Анализирует код статически
3. Выполняет код в sandbox (если разрешено)
4. Ищет причины ошибки
5. Предлагает исправления
6. Созда repro test case
```

---

### 🧪 Sandbox Debugging

**Изолированное окружение для отладки:**

```yaml
Debugger Agent:
  mode: sandbox
  allow:
    - read:*        # Чтение любого кода
    - write:debug/  # Запись только в debug/
    - exec:test     # Выполнение тестов
    - exec:debug    # Выполнение в отладочном режиме
  deny:
    - write:src/    # Нельзя менять исходный код
    - exec:prod     # Нельзя выполнять prod команды
```

**Возможности sandbox:**
- Запуск кода без влияния на продакшн
- Мокирование внешних зависимостей
- Изолированная база данных
- Виртуальная файловая система

---

### 🎯 Root Cause Analysis

**Методики анализа:**

#### 1. Stack Trace Analysis

```javascript
// Stack trace:
Error: Cannot read property 'user' of undefined
    at UserService.getById (src/services/user.js:45:15)
    at AuthController.login (src/controllers/auth.js:23:20)
    at async Layer.handle [as handle_request]

🤖 Debugger Agent:
    1. 📖 Reading auth.js:23...
    2. 🔍 Found: req.user accessed without validation
    3. 💡 Root cause: Missing authentication middleware
    4. 🔧 Solution: Add ensureAuth() middleware
    5. 📝 Creating repro test...
```

#### 2. Data Flow Tracing

```javascript
// Трассировка потока данных
👤 "Почему user.id становится undefined?"

🤖 Debugger Agent:
    1. 📊 Tracing data flow:
       Database → Repository → Service → Controller → API

    2. 🔍 Found issue in Repository:
       function getUser(id) {
         return db.query('SELECT * FROM users WHERE id = $1', [id])
         // Returns Promise, not user!
       }

    3. 💡 Solution: Add await or return raw.rows[0]

    4. 📝 Creating fix...
```

#### 3. Memory Leak Detection

```javascript
👤 "Память постоянно растет"

🤖 Debugger Agent:
    1. 📊 Analysing memory profile...
    2. 🔍 Found leaks:
       - Global array never cleared
       - Event listeners not removed
       - Cached data without TTL
    3. 💡 Recommendations:
       - Add weak references
       - Implement cleanup on disconnect
       - Use LRU cache with max size
    4. 📝 Creating patches...
```

---

## 🔧 Debugging Techniques

### 1. Logging Analysis

```javascript
// Инъекция логов для трассировки
👤 "Добавь логи в этот модуль"

🤖 Debugger Agent:
    📝 Adding structured logs:

    function processPayment(order) {
+     logger.debug('payment.start', { orderId: order.id, amount: order.total });
      const result = await gateway.charge(order);
+     logger.debug('payment.gateway_response', { success: result.success });
      if (result.success) {
+       logger.debug('payment.success', { transactionId: result.id });
        return { status: 'paid', transactionId: result.id };
      }
+     logger.warn('payment.failed', { error: result.error });
      return { status: 'failed', error: result.error };
    }

    ✅ Logs added at key decision points
```

### 2. Breakpoint Simulation

```javascript
// Виртуальные breakpoint'ы
👤 "Где поставить breakpoint?"

🤖 Debugger Agent:
    💡 Recommended breakpoints:

    1. src/auth/login.js:15  — Before password check
    2. src/auth/login.js:23  — After token generation
    3. src/auth/login.js:31  — Before response

    🔍 At each breakpoint, inspect:
       - req.body.credentials
       - userFromDb
       - generatedToken
       - responsePayload
```

### 3. Repro Case Generation

```javascript
// Автоматическое создание repro
👤 "Создай тест для этого бага"

🤖 Debugger Agent:
    📝 Creating repro test:

    describe('Bug: Login fails with special chars', () => {
      test('should handle email with + sign', async () => {
        // This was the failing case
        const result = await login({
          email: 'user+tag@example.com',
          password: 'Password123!'
        });

        expect(result.success).toBe(true); // Was: false
        expect(result.token).toBeDefined(); // Was: undefined
      });
    });

    ✅ Repro test created
    📝 Run with: npm test -- --testNamePattern="Bug:"
```

---

## 🐛 Common Bug Patterns

### Pattern 1: Async Race Condition

**Проблема:**
```javascript
// ❌ Race condition
let user;

async function init() {
  loadConfig();
  await connectDB();
  user = await getCurrentUser(); // May be undefined!
}

init();
console.log(user.name); // CRASH!
```

**Решение:**
```javascript
// ✅ Fixed
async function init() {
  await loadConfig();
  await connectDB();
  user = await getCurrentUser();
}

await init();
console.log(user.name); // Works!
```

---

### Pattern 2: Null Reference

**Проблема:**
```javascript
// ❌ Crashes if user not found
const user = users.find(u => u.id === id);
return user.profile.settings.theme; // CRASH!
```

**Решение:**
```javascript
// ✅ Safe with optional chaining
const user = users.find(u => u.id === id);
return user?.profile?.settings?.theme ?? 'default';
```

---

### Pattern 3: Promise Memory Leak

**Проблема:**
```javascript
// ❌ Leaks - promises never resolve
const cache = new Map();

function getData(key) {
  if (!cache.has(key)) {
    cache.set(key, fetch(url)); // Promise!
  }
  return cache.get(key);
}
```

**Решение:**
```javascript
// ✅ Cache results, not promises
const cache = new Map();

async function getData(key) {
  if (cache.has(key)) {
    return cache.get(key);
  }
  const data = await fetch(url);
  cache.set(key, data);
  return data;
}
```

---

## 🔬 Advanced Debugging

### 1. Differential Debugging

```
👤 "Работало вчера, сегодня сломалось"

🤖 Debugger Agent:
    1. 📊 Comparing states...

       Yesterday (working):
       - Node.js v18.17.0
       - Package: package-a@2.1.0
       - Config: DEBUG=false

       Today (broken):
       - Node.js v18.17.0
       - Package: package-a@2.2.0 ← UPDATED
       - Config: DEBUG=false

    2. 🔍 Found breaking change in package-a@2.2.0
    3. 💡 Solutions:
       a) Downgrade to 2.1.0
       b) Update code for 2.2.0 API
    4. 📝 Creating patches...
```

### 2. State Snapshots

```javascript
// Снимки состояния
👤 "Создай snapshot состояния"

🤖 Debugger Agent:
    📸 State snapshot at auth.js:45:

    {
      request: {
        method: 'POST',
        url: '/api/auth/login',
        body: { email: '...', password: '...' },
        headers: { 'content-type': 'application/json' }
      },
      user: null,  // ← Problem: Should be object
      session: { authenticated: false, attempts: 0 },
      environment: {
        NODE_ENV: 'production',
        JWT_SECRET: '[hidden]',
        DB_HOST: 'postgres:5432'
      }
    }

    💡 Issue: user is null when expected to have value
    🔍 Trace: Check previous function calls
```

### 3. Hypothesis Testing

```
👤 "Проверю гипотезу: это проблема сети"

🤖 Debugger Agent:
    🧪 Testing hypothesis...

    Hypothesis: Network timeout causes failure

    Test 1: Check network connectivity
    Result: ✅ Connection to DB successful (5ms)

    Test 2: Check query timeout
    Result: ❌ Query takes 30s, timeout is 10s

    Test 3: Check missing index
    Result: ❌ No index on queried column

    Conclusion: ❌ Hypothesis rejected
    Real cause: Missing database index

    💡 Solution: CREATE INDEX ON users(email)
```

---

## 🧪 Debug Workflow

```
┌─────────────────────────────────────────────────────┐
│ 1. ❌ Ошибка обнаружена                              │
│    ↓                                                │
│ 2. 📊 Сбор информации                               │
│    ├── Stack trace                                  │
│    ├── Logs                                         │
│    ├── Environment state                            │
│    └── Repro steps                                  │
│    ↓                                                │
│ 3. 🔍 Анализ                                        │
│    ├── Data flow tracing                            │
│    ├── Root cause identification                   │
│    └── Hypothesis generation                        │
│    ↓                                                │
│ 4. 🧪 Проверка гипотез                              │
│    ├── Execute in sandbox                          │
│    ├── Run repro tests                              │
│    └── Validate fix                                 │
│    ↓                                                │
│ 5. 🔧 Исправление                                   │
│    ├── Apply fix                                    │
│    ├── Add regression test                          │
│    └── Update docs                                  │
└─────────────────────────────────────────────────────┘
```

---

## 📝 Usage Examples

### Сценарий 1: Неявная ошибка

```
👤 "Функция возвращает undefined вместо объекта"

🤖 Debugger Agent:
    1. 📖 Reading function...
    2. 🔍 Analysis:
       function getUser(id) {
         const user = db.find(id);
         return user.profile; // ← Undefined if user not found!
       }
    3. 💡 Issue: No validation before accessing nested property
    4. 🔧 Fix:
       function getUser(id) {
         const user = db.find(id);
         if (!user) return null;
         return user.profile;
       }
    5. 📝 Regression test created
    6. ✅ Issue resolved
```

### Сценарий 2: Сложный баг

```
👤 "Запросы к API падают случайным образом"

🤖 Debugger Agent:
    1. 📊 Collecting data...
    2. 🧪 Running repro in sandbox...
    3. 🔍 Found: Race condition in connection pool
    4. 📝 Sequence:
       - Request 1 acquires connection
       - Request 2 waits
       - Request 1 times out (30s)
       - Request 2 gets stale connection
       - Request 2 fails
    5. 💡 Solution: Add connection validation
    6. 🔧 Fix applied:
       pool.on('acquire', (connection) => {
         connection.ping(); // Validate before use
       });
    7. ✅ Race condition eliminated
```

### Сценарий 3: Voice Command

```
🗣️ "Найди почему падает продакшн"

🤖 Debugger Agent:
    1. 📋 Reading production logs...
    2. 🔍 Pattern detected:
       - 10:23:45 - Error: Out of memory
       - 10:23:40 - Memory: 1.8GB / 2GB
       - 10:23:35 - Memory: 1.6GB / 2GB
    3. 📊 Memory leak detected!
    4. 🔍 Source: Image processing queue never cleared
    5. 💡 Quick fix: Restart service (manual)
    6. 🔧 Permanent fix: Add queue limit and cleanup
    7. ✅ Patch deployed
```

---

## 🔗 Integration with Tools

Использует инструменты:
- **read** — чтение кода и логов
- **write** — создание исправлений и тестов
- **bash** — выполнение в sandbox
- **docker** — изолированное выполнение

---

## 🔗 Voice Commands

| Голосовая команда | Действие |
|-------------------|----------|
| "Отладь функцию..." | Глубокая отладка |
| "Найди баг в..." | Поиск багов |
| "Создай repro тест" | Генерация repro case |
| "Трассируй данные" | Data flow tracing |
| "Проверь гипотезу..." | Hypothesis testing |

---

## 🛡️ Safety Rules

### Sandbox Execution

```yaml
Разрешено:
  - Чтение любого кода
  - Запуск тестов
  - Запуск в debug режиме
  - Запись в debug/ и test/

Запрещено:
  - Изменение исходного кода без разрешения
  - Запуск prod команд
  - Удаление файлов
  - Отправка данных во внешние API
```

### Approval Required

```yaml
Требует подтверждения:
  - Изменения в src/
  - Удаление любых файлов
  - Запуск миграций БД
  - Деплой на staging/production
```

---

## 📚 См. Также

- [🤖 AI Assistant Skills Index](../README.md)
- [🐛 Debugging Skill](../development/debugging.md)
- [🔄 Code Review](../development/code-review.md)
- [🎯 Workspace](../README.md)
- [🤖 Agents](../AGENTS.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🔬 Debugger AI](#)
