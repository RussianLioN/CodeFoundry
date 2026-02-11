# Expert Consilium v2.0 — OpenClaw Analysis Report

> **Дата:** 2026-02-11
> **Метод:** Agent Teams (4 агента: architect, researcher, debugger, coordinator)
> **Фокус:** Анализ статуса OpenClaw Orchestrator v2.0 и план реализации

---

## Executive Summary

**Проблема:** Проанализировать текущий статус OpenClaw и предложить дальнейшие шаги для реализации.

**Консенсус команды:** **OpenClaw готов на 75%, требуется исправление критического бага ORCH-007.5**

**Время до production-ready:** **1-2 дня** после fix

---

## 📊 Статус проекта по данным от 4 экспертов

| Эксперт | Фокус | Ключевой вывод |
|---------|-------|----------------|
| **architect-analyst** | Архитектура | 75% готовности, CLI Bridge 100% |
| **researcher-analyst** | Prod-реализации | 4 эталонных источника, gap analysis |
| **debugger-analyst** | Баг ORCH-007.5 | Рекомендация: Вариант D (AI Intent Classifier) |
| **coordinator-analyst** | Синтез | Приоритизированный план действий |

---

## 🔴 КРИТИЧЕСКАЯ ПРОБЛЕМА: ORCH-007.5

### Суть бага

**Commit:** `1d4a1aa` — Intent Pre-Classifier

```
Цель: 50% faster responses ✅
Side effect: keyword matching REPLACES AI NLP ❌
```

**Сломанные запросы:**
- "Создай приложение" → chat (вместо create_project)
- "Хочу новый бот" → chat (вместо create_project)
- "Покажи статус" → chat (вместо status)

### Локация бага

`openclaw/gateway/src/gateway.ts:370-411`

```typescript
// Проблемный код:
const COMMAND_KEYWORDS = ['create', 'new', 'созда', ...];
const hasCommandIntent = COMMAND_KEYWORDS.some(kw => lowerContent.includes(kw));

if (!hasCommandIntent) {
  // BUG: Обходит AI-powered Command Generator!
  const response = await this.ollama.chat(chatMessages);
  return { type: 'complete', ... };
}
```

### Рекомендуемое решение: **Вариант D — AI Intent Classifier**

```typescript
// Создать новый модуль intent-classifier.ts
class IntentClassifier {
  async classify(message: string): Promise<Intent> {
    // Fast AI call to gemini-3-flash-preview
    // Returns: { intent: 'create_project'|'status'|'chat', confidence }
  }
}

// В gateway.ts заменить keyword matching на:
const intent = await this.intentClassifier.classify(content);
```

**Преимущества:**
- ✅ Сохраняет AI-first архитектуру
- ✅ Оптимизация (1 AI call)
- ✅ Масштабируется

---

## 📊 Статус компонентов (от architect-analyst)

| Компонент | Файл | Статус | Готовность | Проблемы |
|-----------|------|--------|------------|----------|
| **Gateway v2.0** | `gateway/src/gateway.ts` | ⚠️ С багом | 70% | ORCH-007.5 Intent Pre-Classifier |
| **Command Generator** | `command-generator.ts` | ⚠️ Требует доработки | 80% | System prompt для NLP |
| **Command Executor** | `command-executor.ts` | ✅ Работает | 95% | - |
| **CLI Bridge** | `server/scripts/claude-wrapper.sh` | ✅ Протестирован | 100% | 4/4 tests passed |
| **Telegram Bot** | `telegram-bot/src/bot.ts` | ✅ MVP готов | 85% | Enhanced commands |
| **Docker Stack** | `docker-compose.orchestrator.yml` | ⚠️ Частично | 75% | claude-code-runner образ |

### Уровень готовности к production: **75%**

```
Gateway v2.0        ████████████░░░░░ 70%  (bug fix needed)
Command Generator   ████████████░░░░░ 80%  (prompt improvement)
Command Executor    ███████████████░░ 95%  (nearly perfect)
CLI Bridge          █████████████████ 100% (fully tested)
Telegram Bot MVP    █████████████░░░░ 85%  (MVP complete)
Docker Stack        ███████████░░░░░░ 75%  (runner issue)
```

### Критический путь к production

| Задача | Время | Блокирует |
|--------|-------|-----------|
| Fix ORCH-007.5 (Intent Pre-Classifier) | 2-4 hours | ORCH-009, ORCH-010 |
| Fix claude-code-runner Docker image | 1 hour | Production deployment |
| Deploy OLLAMA_API_KEY | 30 min | E2E testing |
| E2E testing | 2-4 hours | Production release |

**Estimated time to 90% production ready: 1-2 days**

---

## 📚 Prod-реализации (от researcher-analyst)

### Найдено 4 эталонных источника:

| # | Источник | Стек | Ключевые особенности |
|---|----------|------|---------------------|
| 1 | **docs/reference/openclaw-ollama-gemini-telegram-system.md** | Ollama v0.3.12+ + gemini-3-flash:cloud | WebSocket Client HC, security hardening |
| 2 | **docker-compose.prod.yml** | Full stack + Redis + Monitoring | Resource limits, log rotation |
| 3 | **orchestrator.yml** | Gateway v2.0 + CLI Bridge | Command Protocol v1.0 |
| 4 | **ARCHITECTURE.md** | v2.0 Orchestrator pattern | 2-layer architecture |

### Gap Analysis vs Текущий Проект

| Аспект | Найдено | Текущий проект | Gap |
|--------|---------|----------------|-----|
| **Ollama Cloud** | ✅ Есть | ❌ Нет | **HIGH** |
| **WebSocket Client HC** | ✅ Правильный | ⚠️ Неправильный | **HIGH** |
| **Monitoring** | ✅ Prometheus+Grafana | ❌ Нет | **MEDIUM** |
| **Security hardening** | ✅ Есть | ⚠️ Частичный | **MEDIUM** |
| **Resource limits** | ✅ Есть | ⚠️ Базовые | **LOW** |

---

## 📋 Приоритизированный план действий

### 🔴 P0 — КРИТИЧНО (4-6 часов → 90% ready)

| # | Задача | Время | Ожидаемый результат | Блокирует |
|---|--------|-------|---------------------|-----------|
| **1** | **Исправить ORCH-007.5** | 2-4h | AI-powered intent recognition | ORCH-009, ORCH-010 |
| **2** | **Получить OLLAMA_API_KEY** | 30min | Cloud API доступен | E2E testing |
| **3** | **Fix claude-code-runner образ** | 1h | Правильный Docker образ | Production |
| **4** | **Исправить health checks** | 30min | Правильный WebSocket HC | Monitoring |

### 🟡 P1 — ВАЖНО (~1 неделя → 95% ready)

| # | Задача | Время | Ожидаемый результат |
|---|--------|-------|---------------------|
| **5** | Enhanced commands | 1-2 дня | /deploy, /logs, /test, /agents |
| **6** | Session persistence | 1 день | Redis/File storage |
| **7** | Prometheus+Grafana | 2-3 дня | Monitoring setup |
| **8** | Security hardening | 1 день | UFW, fail2ban, non-root |

### 🟢 P2 — ЖЕЛАТЕЛЬНО

| # | Задача | Время | Ожидаемый результат |
|---|--------|-------|---------------------|
| **9** | Multi-user RBAC | 2-3 дня | Авторизация пользователей |
| **10** | Rate limiting | 1 день | Защита от abuse |
| **11** | Auto-backups | 1 день | Disaster recovery |

---

## 🚀 План внедрения ORCH-007.5 fix

### Шаг 1: Создать `intent-classifier.ts`

```typescript
// openclaw/gateway/src/intent-classifier.ts
import { OllamaClient } from './ollama-client';

export interface IntentResult {
  intent: 'create_project' | 'status' | 'help' | 'deploy' | 'chat';
  confidence: number;
  parameters?: Record<string, any>;
}

export class IntentClassifier {
  constructor(private ollama: OllamaClient) {}

  async classify(message: string): Promise<IntentResult> {
    const response = await this.ollama.chat([
      {
        role: 'system',
        content: `You are an intent classifier. Analyze user messages and return JSON:
        {
          "intent": "create_project|status|help|deploy|chat",
          "confidence": 0-1,
          "parameters": {...}
        }

        Examples:
        "Создай приложение" -> {"intent": "create_project", "confidence": 0.95}
        "Какой статус?" -> {"intent": "status", "confidence": 0.9}
        "Привет" -> {"intent": "chat", "confidence": 0.8}`
      },
      { role: 'user', content: message }
    ], { temperature: 0.1 });

    return JSON.parse(response.message.content);
  }
}
```

### Шаг 2: Интегрировать в `gateway.ts`

```typescript
// Заменить keyword matching (строки 370-411) на:
const intentResult = await this.intentClassifier.classify(content);

switch (intentResult.intent) {
  case 'create_project':
  case 'status':
  case 'help':
  case 'deploy':
    return await this.commandGenerator.generate(content, session);
  case 'chat':
    const response = await this.ollama.chat(chatMessages);
    return { type: 'complete', content: response.message.content };
}
```

### Шаг 3: Тестирование

```bash
# Unit tests
npm test -- intent-classifier.test.ts

# Integration tests
curl -X POST http://localhost:18789/chat \
  -d '{"content": "Создай проект my-app"}'

# E2E tests (Telegram)
```

---

## 📚 Best Lessons от прод-реализаций

### 1. WebSocket Client Health Check

```yaml
# ❌ НЕПРАВИЛЬНО
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]

# ✅ ПРАВИЛЬНО
healthcheck:
  test: ["CMD", "sh", "-c", "pgrep -f 'node.*bot.js' > /dev/null && netstat -tn | grep -q ':18789.*ESTABLISHED' || exit 1"]
```

### 2. Ollama Cloud API Configuration

```bash
# .env
OLLAMA_API_KEY=your_key_here  # Get from https://ollama.com/settings/keys
OLLAMA_BASE_URL=https://api.ollama.cloud
OLLAMA_MODEL=gemini-3-flash-preview:cloud
```

### 3. Models.json Format (КРИТИЧНО!)

```json
{
  "providers": {
    "ollama": {
      "api": "openai-completions",  // ← ОБЯЗАТЕЛЬНО!
      "baseUrl": "http://ollama:11434/v1",
      "models": [{"id": "gemini-3-flash-preview:cloud"}]
    }
  }
}
```

### 4. Resource Limits (Production)

```yaml
deploy:
  resources:
    limits:
      cpus: "2"
      memory: 4G
    reservations:
      cpus: "0.5"
      memory: 1G
```

---

## 📈 Production Roadmap

```
Phase 1 (1-2 days):   Fix ORCH-007.5 → 90% production ready
Phase 2 (1 week):     Enhanced commands + Monitoring → 95%
Phase 3 (2-3 weeks):  Multi-user + Hardening → 100%
```

---

## 💪 Сильные стороны архитектуры

1. **Модульность**: Clean separation of concerns
2. **Protocol-based**: Command Protocol v1.0
3. **Flexibility**: LLM-agnostic через Ollama
4. **WebSocket**: Real-time communication
5. **Production-ready Docker**: Health checks, resource limits

---

## ✅ Заключение

OpenClaw Orchestrator v2.0 имеет **солидный фундамент** с отличной модульной архитектурой, но **критический баг в Intent Pre-Classifier** нарушает основную идею v2.0 - AI-powered оркестрацию команд.

После исправления ORCH-007.5 система будет готова к production deployment в течение **1-2 дней**.

---

## 🔗 Связанные документы

- **Архитектура:** [@ref: docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
- **Эталонная реализация:** [@ref: docs/reference/openclaw-ollama-gemini-telegram-system.md](../reference/openclaw-ollama-gemini-telegram-system.md)
- **Уроки:** [@ref: docs/lessons/websocket-client-health-check.md](../lessons/websocket-client-health-check.md)
- **Задачи:** [@ref: TASKS.md](../../TASKS.md) (Фаза 11)

---

**Expert Consilium v2.0 завершён.** 🎉

*Agent Team: openclaw-analysis (architect-analyst, researcher-analyst, debugger-analyst, coordinator-analyst)*
*Дата: 2026-02-11*
