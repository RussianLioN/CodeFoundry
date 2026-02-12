# ФИНАЛЬНЫЙ План миграции артефактов — CodeFoundry → Agent Teams Integration

> **Дата:** 2026-02-11
> **Задача:** #4 — План миграции артефактов (ФИНАЛЬНАЯ ВЕРСИЯ)
> **Статус:** FINAL
> **Источник:** Expert Consilium v2.0 + architect-comparative + subagent-architect

---

## Executive Summary

На основе результатов анализа от **architect-comparative** (Сравнительный анализ архитектур) и **subagent-architect** (Архитектура системы субагентов) составлен финальный приоритизированный план обновления артефактов.

**Ключевое решение:** Гибридный подход — сохранить OpenClaw v2.0 для production + подготовить инфраструктуру для субагентов (Phase 2).

**Консенсус экспертов:**
- architect-comparative: **Рекомендация** → Краткосрочно: v2.0, Среднесрочно: гибрид, Долгосрочно: полная миграция
- subagent-architect: **Рекомендация** → MVP: Core agents + Code Generator, Phase 2-3: Self-improving loop

---

## 🎯 Стратегическое решение: Гибридная архитектура

### Решение основано на анализе

| Критерий | v2.0 (текущая) | Новая (субагенты) | Решение |
|----------|----------------|-------------------|---------|
| **Время до MVP** | ✅ Реализовано | ❌ 2-3 недели | **v2.0 для production** |
| **Качество кода** | glm-4.7 (лучший) | gemini-3-flash (хороший) | **Claude Code для quality** |
| **Self-improving** | ❌ Нет | ✅ Да | **Добавить в Phase 2** |
| **Стоимость** | Низкая + Средняя | Низкая | **Гибрид: оптимально** |

### Гибридная архитектура (рекомендация)

```
┌─────────────────────────────────────────────────────────────┐
│                 ГИБРИДНАЯ АРХИТЕКТУРА                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Phase 1 (Production NOW):                                  │
│    OpenClaw v2.0 + AI Intent Classifier + Claude Code       │
│                                                              │
│  Phase 2 (1-2 месяца):                                       │
│    Добавить фреймворк субагентов + гибридная маршрутизация   │
│                                                              │
│  Phase 3 (3-6 месяцев):                                      │
│    Self-improving loop + A/B тестирование                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔴 P0: КРИТИЧЕСКИЕ ИЗМЕНЕНИЯ (4-6 часов → 90% ready)

### 1. ORCH-007.5: Fix Intent Pre-Classifier Bug

**Артефакт:** `openclaw/gateway/src/gateway.ts`

**Источник:** Expert Consilium v2.0 Report (ORCH-007.5)

**Текущая проблема:**
```typescript
// строки 370-411: keyword matching обходит AI-powered Command Generator
const COMMAND_KEYWORDS = ['create', 'new', 'созда', ...];
const hasCommandIntent = COMMAND_KEYWORDS.some(kw => lowerContent.includes(kw));

if (!hasCommandIntent) {
  // BUG: Direct chat, минуя command generation!
  const response = await this.ollama.chat(chatMessages);
}
```

**Требуемое изменение:**
```typescript
// Новый файл: openclaw/gateway/src/intent-classifier.ts
export class IntentClassifier {
  async classify(message: string): Promise<IntentResult> {
    const response = await this.ollama.chat([
      {
        role: 'system',
        content: `You are an intent classifier. Return JSON:
        {
          "intent": "create_project|status|help|deploy|chat",
          "confidence": 0-1,
          "parameters": {...}
        }`
      },
      { role: 'user', content: message }
    ], { temperature: 0.1 });

    return JSON.parse(response.message.content);
  }
}

// В gateway.ts: заменить keyword matching
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

**Затраты времени:** 2-4 часа

**Зависимости:** Нет

**Блокирует:** ORCH-009, ORCH-010

---

### 2. CLI Bridge: Update claude-wrapper.sh

**Артефакт:** `server/scripts/claude-wrapper.sh`

**Источник:** architect-comparative (Component Analysis)

**Текущее состояние:** 320+ строк, 4/4 тестов passed

**Требуемые изменения:**
- Добавить поддержку нового Intent Classifier
- Обновить обработку ошибок от AI intent classification
- Добавить логирование intent confidence

**Затраты времени:** 1 час

**Зависимости:** Зависит от #1 (Intent Classifier)

---

### 3. TASKS.md: Актуализация Phase 11 + Добавить Phase 16

**Артефакт:** `TASKS.md`

**Источник:** subagent-architect (MVP Recommendations)

**Текущее состояние:** ORCH-007.5 помечен как критический баг

**Требуемые изменения:**

**Phase 11 updates:**
- Обновить статус ORCH-007.5 после fix
- Актуализировать зависимости между задачами

**Phase 16 (NEW): Subagent Framework**
```markdown
## 🔀 Фаза 16: Subagent Framework Integration (BACKLOG)

> **Источник:** architect-comparative + subagent-architect
> **Стратегия:** Гибридный подход — v2.0 для production + субагенты для expansion

### SUB-001: Subagent Framework Core ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Файлы:** `openclaw/subagent-framework/core/`
- **Компоненты:**
  - Agent Registry (AGENTS-INDEX.json)
  - Agent Router (Intent → Subagent)
  - Agent Lifecycle Manager

### SUB-002: Core Subagents (MVP) ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Субагенты:**
  - Intent Parser (agents/core/intent-parser.md)
  - Command Resolver (agents/core/command-resolver.md)
  - Command Executor (agents/core/command-executor.md)
  - Agent Router (agents/core/agent-router.md)

### SUB-003: Development Subagents ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Субагенты:**
  - Code Generator (agents/development/code-generator.md)
  - Debugger (agents/development/debugger.md)
  - Test Generator (agents/development/test-generator.md)

### SUB-004: Hybrid Routing Logic ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** КРИТИЧЕСКИЙ
- **Логика:**
  - Simple tasks → OpenClaw v2.0 (gemini-3-flash)
  - Complex tasks → Claude Code (glm-4.7)
  - Specialized → Subagents (domain-specific)
```

**Затраты времени:** 30 минут

**Зависимости:** Зависит от #1, #2

---

## 🟡 P1: ВАЖНЫЕ ИЗМЕНЕНИЯ (~1 неделя → 95% ready)

### 4. OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md: Обновить v2.0 + Добавить Hybrid Architecture

**Артефакт:** `docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md`

**Источник:** architect-comparative (Architecture Comparison)

**Текущее состояние:** Описывает v2.0 без учёта ORCH-007.5 fix + без гибридного подхода

**Требуемые изменения:**

1. **Добавить раздел:** Intent Classifier Architecture (v2.0.1)
2. **Добавить раздел:** Гибридная архитектура (Phase 2)
3. **Обновить workflow** с учётом hybrid routing
4. **Добавить диаграмму** гибридного потока данных

**Содержание для добавления:**
```markdown
## Intent Classifier (NEW in v2.0.1)

### Расположение
`openclaw/gateway/src/intent-classifier.ts`

### Назначение
AI-powered классификация намерений пользователя с использованием gemini-3-flash.

### Преимущества перед keyword matching
- ✅ Естественный язык (не только keywords)
- ✅ Confidence scoring
- ✅ Extraction параметров
- ✅ Масштабируется

### Algorithm
1. User message → IntentClassifier.classify()
2. gemini-3-flash → JSON: { intent, confidence, parameters }
3. Router → Command Generator OR Chat

---

## Гибридная архитектура (Phase 2)

### Стратегия
Сохранить v2.0 для production + добавить фреймворк субагентов для expansion.

### Routing Logic
```
User Request
    │
    ▼
Intent Classifier
    │
    ├── Simple (gemini-3-flash) ──▶ OpenClaw v2.0 ──▶ Result
    │
    ├── Complex (glm-4.7) ────────▶ Claude Code ────▶ Result
    │
    └── Specialized ────────────────▶ Subagents ─────▶ Result
```

### Преимущества
- ✅ Production-ready сейчас (v2.0)
- ✅ Quality code (glm-4.7 для сложных задач)
- ✅ Scalability (субагенты для специализации)
- ✅ Cost optimization (gemini для простых задач)
```

**Затраты времени:** 2-3 часа

**Зависимости:** Зависит от #1 (Intent Classifier implementation)

---

### 5. PROTOCOL-v1.md: Обновить Command Protocol + Добавить Subagent Protocol

**Артефакт:** `docs/commands/PROTOCOL-v1.md`

**Источник:** subagent-architect (Meta-protocol)

**Текущее состояние:** 320+ строк, полный spec v1.0

**Требуемые изменения:**

1. **Обновить Request Format** (v1.1):
   ```json
   {
     "version": "1.1",
     "intent": { "name": "create_project", "confidence": 0.95 },
     "parameters": {...}
   }
   ```

2. **Добавить раздел:** Subagent Communication Protocol (v2.0)
   ```json
   {
     "version": "2.0",
     "timestamp": "2026-02-11T12:00:00Z",
     "request_id": "req-abc123",
     "task": {
       "type": "code_generation",
       "description": "Generate CRUD for User model",
       "parameters": {...},
       "constraints": {...}
     },
     "context": {
       "cwd": "/workspace/my-project",
       "git_branch": "feature/users-api"
     }
   }
   ```

3. **Добавить примеры** с AI-powered intent classification

**Затраты времени:** 2-3 часа

**Зависимости:** Нет (может быть параллельно с #1)

---

### 6. openclaw/gateway/src/command-generator.ts: Оптимизация

**Артефакт:** `openclaw/gateway/src/command-generator.ts`

**Источник:** architect-comparative (Component Changes)

**Текущее состояние:** 80% готовности, требуется улучшение system prompt для NLP

**Требуемые изменения:**
1. **Обновить system prompt** для работы с Intent Classifier
2. **Добавить обработку** low confidence intents
3. **Интегрировать** с Intent Classifier для parameter extraction

**Примечание:** В Phase 2 (субагенты) этот компонент будет заменён на Agent Router

**Затраты времени:** 2-4 часа

**Зависимости:** Зависит от #1 (Intent Classifier)

---

### 7. openclaw-ollama-gemini-telegram-system.md: Актуализация

**Артефакт:** `docs/reference/openclaw-ollama-gemini-telegram-system.md`

**Источник:** Expert Consilium v2.0 (Best Lessons)

**Текущее состояние:** Эталонный документ, основан на исследовании 15+ источников

**Требуемые изменения:**
1. **Добавить раздел:** Intent Classifier vs Keyword Matching
2. **Обновить best practices** с учётом AI-powered intent classification
3. **Добавить WebSocket Client Health Check** правильный паттерн
4. **Обновить models.json** с обязательным полем `api`

**Затраты времени:** 2-3 часа

**Зависимости:** Нет

---

## 🟢 P2: СУБАГЕНТНАЯ СИСТЕМА (2-3 недели → 100% + Expansion)

> **Источник:** subagent-architect (детальные спецификации)
>
> **Обновление v2.1.0:** Добавлены детальные спецификации для каждого артефакта

### 8. Создание структуры агентов (P0)

**Артефакты:**
```
/opt/openclaw/workspace/agents/
├── core/                        # P0: 4 агента (baseline)
│   ├── intent-parser.md
│   ├── command-resolver.md
│   ├── command-executor.md
│   └── agent-router.md
├── development/                 # P1: 4 агента
│   ├── code-generator.md
│   ├── debugger.md
│   ├── test-generator.md
│   └── code-reviewer.md
├── devops/                      # P1: 2 агента
│   ├── docker-deploy.md
│   └── ci-pipeline.md
├── ai-assistants/               # P1: 2 агента
│   ├── prompt-engineer.md
│   └── documentation.md
└── generated/                   # P2: Self-improving output
    └── (auto-generated agents)
```

**Затраты времени:** 2 часа (core/), 3 часа (development/), 2 часа (devops/)

**Зависимости:** Нет

---

### 9. AGENTS-INDEX.json (P0)

**Артефакт:** `/opt/openclaw/workspace/AGENTS-INDEX.json`

**Источник:** subagent-architect (Machine-readable index)

**Текущее состояние:** Не существует

**Формат:**
```json
{
  "$schema": "AGENTS-SCHEMA.json",
  "version": "1.0.0",
  "last_updated": "2026-02-11T12:00:00Z",
  "agents": {
    "intent-parser": {
      "file": "agents/core/intent-parser.md",
      "category": "core",
      "model": "sonnet",
      "tools": ["read"],
      "triggers": {
        "keywords": ["parse", "intent", "understand"],
        "patterns": ["what do you mean|parse (.+)"]
      },
      "capabilities": ["intent_parsing", "parameter_extraction"]
    },
    "code-generator": {
      "file": "agents/development/code-generator.md",
      "category": "development",
      "model": "sonnet",
      "tools": ["read", "write", "edit"],
      "triggers": {
        "keywords": ["generate", "create", "boilerplate"],
        "patterns": ["generate (.+) (code|crud|api)"]
      },
      "capabilities": ["crud_generation", "api_generation", "test_generation"]
    }
  },
  "routing": {
    "default_agent": "main",
    "confidence_threshold": 0.7,
    "max_agents_per_request": 3
  }
}
```

**Затраты времени:** 1 час

**Зависимости:** Зависит от #8 (agents/*/)

---

### 10. AGENTS.md Registry (P0)

**Артефакт:** `/opt/openclaw/workspace/AGENTS.md`

**Источник:** subagent-architect (Human-readable registry)

**Формат:**
```markdown
# OpenClaw Agents Registry

## Core Agents

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| Intent Parser | agents/core/intent-parser.md | Parse user input | Sonnet |
| Command Resolver | agents/core/command-resolver.md | Resolve to commands | Haiku |
| Command Executor | agents/core/command-executor.md | Execute with progress | N/A |
| Agent Router | agents/core/agent-router.md | Route to subagents | Sonnet |

## Development Agents

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| Code Generator | agents/development/code-generator.md | Generate boilerplate | Sonnet |
| Debugger | agents/development/debugger.md | Debug and fix bugs | Opus |
| Test Generator | agents/development/test-generator.md | Generate tests | Sonnet |
| Code Reviewer | agents/development/code-reviewer.md | Review quality | Opus |

## DevOps Agents

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| Docker Deploy | agents/devops/docker-deploy.md | Deploy to Docker | Sonnet |
| CI Pipeline | agents/devops/ci-pipeline.md | Generate CI/CD | Sonnet |

## AI Assistants

| Agent | File | Purpose | Model |
|-------|------|---------|-------|
| Prompt Engineer | agents/ai-assistants/prompt-engineer.md | Optimize prompts | Opus |
| Documentation | agents/ai-assistants/documentation.md | Generate docs | Sonnet |
```

**Затраты времени:** 30 минут

**Зависимости:** Зависит от #8, #9

---

### 11. AGENTS-SCHEMA.json (P1)

**Артефакт:** `/opt/openclaw/workspace/AGENTS-SCHEMA.json`

**Источник:** subagent-architect (Validation schema)

**Формат:**
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "OpenClaw Agent Definition Schema",
  "type": "object",
  "required": ["name", "version", "description", "model", "category"],
  "properties": {
    "name": { "type": "string", "pattern": "^[a-z-]+$" },
    "version": { "type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$" },
    "description": { "type": "string", "minLength": 10, "maxLength": 200 },
    "model": { "enum": ["haiku", "sonnet", "opus"] },
    "category": { "enum": ["core", "development", "devops", "ai-assistants"] },
    "tools": { "type": "array", "items": { "type": "string" } },
    "tags": { "type": "array", "items": { "type": "string" } },
    "timeout_ms": { "type": "number", "minimum": 1000, "maximum": 300000 }
  }
}
```

**Затраты времени:** 3 часа

**Зависимости:** Зависит от #9 (AGENTS-INDEX.json)

---

### 12. Agent Router Implementation (P0)

**Артефакт:** `openclaw/subagent-framework/core/agent-router.ts`

**Источник:** subagent-architect (Routing logic)

**Функциональность:**
```typescript
class AgentRouter {
  async route(message: string, intent: Intent): Promise<string> {
    // 1. Check AGENTS-INDEX.json for matching agent
    // 2. Apply confidence threshold
    // 3. Return agent name or "main"
  }

  async selectSubagents(task: Task): Promise<string[]> {
    // 1. Parse task requirements
    // 2. Match against agent capabilities
    // 3. Return list of agents for parallel execution
  }
}
```

**Затраты времени:** 4 часа

**Зависимости:** Зависит от #9 (AGENTS-INDEX.json), #8 (agents/core/)

---

### 13. Self-Improving Loop (P1)

**Артефакты:**
- Gap Detection Logic
- Agent Generation Workflow
- Validation Framework

**Источник:** subagent-architect (Self-Improving Loop)

**Компоненты:**

**13.1 Gap Detection (P1):**
```typescript
class GapDetector {
  async detectGap(request: string): Promise<boolean> {
    // 1. Search AGENTS-INDEX.json for matching agent
    // 2. If no match → gap detected
    // 3. Trigger agent generation
  }
}
```

**13.2 Agent Generation (P1):**
```typescript
class AgentGenerator {
  async generateAgent(requirements: AgentRequirements): Promise<string> {
    // 1. Use Prompt Engineer agent
    // 2. Generate agent definition (MD + Frontmatter)
    // 3. Save to agents/generated/{name}-{timestamp}.md
    // 4. Update AGENTS-INDEX.json
  }
}
```

**13.3 Validation Framework (P2):**
```typescript
class AgentValidator {
  async validate(agentPath: string): Promise<ValidationResult> {
    // 1. Check frontmatter completeness
    // 2. Validate against AGENTS-SCHEMA.json
    // 3. Test with sample task
    // 4. If fails: fix and retry
  }
}
```

**Затраты времени:** 8 часов (Gap Detection: 2h, Agent Generation: 4h, Validation: 2h)

**Зависимости:** Зависит от #9, #11, #12

---

### 14. Agent Handoff Protocol (P1)

**Артефакт:** Стандартизированный формат передачи контекста

**Источник:** subagent-architect (Handoff Protocol)

**Формат:**
```markdown
## Agent Handoff

**From:** code-generator
**To:** code-reviewer
**Reason:** Generated code requires review

---

### Context

Generated FastAPI CRUD for User model with 5 endpoints.

### Files Involved

- src/api/routes/users.py (new)
- src/services/user_service.py (new)
- tests/test_users.py (new)

### Task

Review for:
- Code quality
- Security vulnerabilities
- Best practices
- Test coverage

---

**Continue from here.**
```

**Затраты времени:** 4 часа

**Зависимости:** Зависит от всех предыдущих

**Формат агента:**
```markdown
---
name: intent-parser
version: 1.0.0
description: Parse user input into structured intents
model: sonnet
temperature: 0.3
tools: [read]
category: core
tags: [parsing, nlu, intent]
---

# Intent Parser Agent

## Role
You are an Intent Parser — specializes in parsing user input.

## Workflow
1. Analyze user message
2. Extract intent
3. Extract parameters
4. Return structured JSON
```

**Затраты времени:** 2-3 дня

**Зависимости:** Зависит от #8 (Subagent Framework)

---

### 10. Agent Teams Skills Integration

**Артефакт:** `.claude/skills/agent-teams-*.md`

**Источник:** Agent Teams Integration Plan (Phase 15)

**Текущее состояние:** Запланированы в Phase 15

**Требуемые изменения:**
1. **Создать 3 skills:**
   - `agent-teams-parallel.md` (~40 lines)
   - `agent-teams-sequential.md` (~35 lines)
   - `agent-teams-safe-mode.md` (~45 lines)
2. **Интегрировать** с OpenClaw Gateway для multi-agent coordination
3. **Добавить token monitoring** для параллельных операций

**Затраты времени:** 1-2 дня

**Зависимости:** Зависит от #9 (Core Subagents)

---

### 11. Documentation Updates

**Артефакты:**
- `PROJECT.md`
- `README.md`
- `docs/INDEX.md`
- `docs/ARCHITECTURE-ANALYSIS.md`

**Источник:** Все анализы

**Требуемые изменения:**
1. **Добавить Hybrid Architecture Section**
2. **Добавить Subagent Framework Section**
3. **Обновить @ref ссылки** на новые артефакты
4. **Добавить примеры** использования гибридной маршрутизации
5. **Обновить workflow diagrams**

**Затраты времени:** 2-3 дня

**Зависимости:** Зависит от всех предыдущих

---

## 📊 Матрица зависимостей (v2.1.0 — ОБНОВЛЁННАЯ)

```
P0 (Критические — OpenClaw v2.0 Production) → 90% ready
├── #1 Intent Classifier ─────────────────────┐
├── #2 CLI Bridge ────────────────────────────┤──> Блокирует: ORCH-009, ORCH-010
└── #3 TASKS.md (Phase 11 fix + Phase 16) ────┘

P1 (Важные — Документация + Протоколы) → 95% ready
├── #4 Architecture.md (v2.0 + Hybrid) ──────────┐──> После #1
├── #5 PROTOCOL-v1.md (v1.1 + v2.0) ─────────────┤──> Параллельно с P0
├── #6 command-generator.ts ──────────────────────┤──> После #1
└── #7 openclaw-ollama-gemini... ─────────────────┘──> Параллельно

P2 (Субагентная система — Expansion) → 100% + Self-Improving
├── #8 Agent Structure (core/ + development/) ────┐
├── #9 AGENTS-INDEX.json ─────────────────────────┤──> После #8
├── #10 AGENTS.md Registry ───────────────────────┤──> После #9
├── #11 AGENTS-SCHEMA.json ────────────────────────┤──> После #9
├── #12 Agent Router ──────────────────────────────┤──> После #8, #9
├── #13 Self-Improving Loop ───────────────────────┤──> После #11, #12
├── #14 Agent Handoff Protocol ────────────────────┤──> После всех
└── #15 Documentation Updates ─────────────────────┘──> После всех
```

### Детальная матрица зависимостей (subagent-architect)

```
┌────────────────────┬────────────────────────────────┬─────────┐
│ Артефакт           │ Зависит от                    │ Priority│
├────────────────────┼────────────────────────────────┼─────────┤
│ agents/core/       │ — (baseline)                  │ P0      │
│ agents/development/│ core/                         │ P1      │
│ AGENTS-INDEX.json  │ Agent definitions (MD files)   │ P0      │
│ AGENTS.md          │ AGENTS-INDEX.json             │ P0      │
│ AGENTS-SCHEMA.json │ AGENTS-INDEX.json             │ P1      │
│ Agent Router       │ AGENTS-INDEX.json, core/      │ P0      │
│ Self-Improving     │ Prompt Engineer, SCHEMA       │ P1      │
│ Handoff Protocol   │ Все agent implementations      │ P1      │
└────────────────────┴────────────────────────────────┴─────────┘
```

---

## 🚀 План реализации (3 фазы — v2.1.0)

### Phase 1: Production Fix (Day 1-2) → 90% ready

**Цель:** Fix ORCH-007.5 + подготовить к production

- [ ] Fix ORCH-007.5 (#1) — Intent Classifier
- [ ] Update CLI Bridge (#2)
- [ ] Актуализировать TASKS.md (#3) — Phase 11 fix + Phase 16 (Subagent Framework)

**Ожидаемый результат:** OpenClaw v2.0 production-ready

---

### Phase 2: Architecture Update (Week 1) → 95% ready

**Цель:** Обновить документацию под v2.0.1 + подготовить гибридную архитектуру

- [ ] Update OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md (#4) — v2.0 + Hybrid
- [ ] Update PROTOCOL-v1.md (#5) — v1.1 + v2.0 (Subagent Protocol)
- [ ] Optimize command-generator.ts (#6)
- [ ] Актуализировать reference docs (#7)

**Ожидаемый результат:** Документация актуальна, гибридная архитектура задокументирована

---

### Phase 3: Subagent System (Week 2-3) → 100% + Self-Improving

**Цель:** Реализовать субагентную систему + Self-Improving Loop

**P0 Subagent Framework:**
- [ ] Agent Structure (#8) — core/ + development/ + devops/ + ai-assistants/
- [ ] AGENTS-INDEX.json (#9) — machine-readable registry
- [ ] AGENTS.md Registry (#10) — human-readable registry
- [ ] Agent Router (#12) — routing logic

**P1 Advanced Features:**
- [ ] AGENTS-SCHEMA.json (#11) — validation schema
- [ ] Self-Improving Loop (#13) — Gap Detection + Agent Generation
- [ ] Agent Handoff Protocol (#14) — standardized handoff format

**P2 Documentation:**
- [ ] Documentation Updates (#15) — comprehensive updates

**Ожидаемый результат:** Субагентная система реализована, self-improving loop operational

---

## 📋 Проверочные списки (v2.1.0)

### Phase 1 Checklist (P0 — Production Fix)
- [ ] Intent Classifier реализован и протестирован
- [ ] CLI Bridge работает с новыми intent
- [ ] TASKS.md отражает текущий статус + Phase 16 добавлена
- [ ] Quality gates pass
- [ ] OpenClaw v2.0 production-ready (90%)

### Phase 2 Checklist (P1 — Documentation Update)
- [ ] OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md обновлена (v2.0 + Hybrid)
- [ ] PROTOCOL-v1.md обновлена (v1.1 + v2.0 Subagent Protocol)
- [ ] Command Generator использует Intent Classifier
- [ ] Reference docs актуальны
- [ ] Гибридная архитектура задокументирована (95%)

### Phase 3 Checklist (P2 — Subagent System)

**P0 Subagent Framework:**
- [ ] agents/core/ создан (4 агента: intent-parser, command-resolver, command-executor, agent-router)
- [ ] agents/development/ создан (4 агента: code-generator, debugger, test-generator, code-reviewer)
- [ ] AGENTS-INDEX.json создан и валиден
- [ ] AGENTS.md registry создан
- [ ] Agent Router реализован и протестирован

**P1 Advanced Features:**
- [ ] agents/devops/ создан (2 агента: docker-deploy, ci-pipeline)
- [ ] agents/ai-assistants/ создан (2 агента: prompt-engineer, documentation)
- [ ] AGENTS-SCHEMA.json создан
- [ ] Gap Detection реализован
- [ ] Agent Generation (через Prompt Engineer) работает
- [ ] Agent Handoff Protocol стандартизирован

**P2 Documentation:**
- [ ] Все architecture docs обновлены
- [ ] Примеры использования субагентов добавлены
- [ ] @ref ссылки валидны
- [ ] Self-Improving Loop задокументирован

**Total:** 100% + Subagent System + Self-Improving Capability

---

## 🔗 Связанные документы

### Source Analyses
- **Expert Consilium:** [@ref: docs/analysis/2026-02-11-openclaw-expert-consilium-report.md](../analysis/2026-02-11-openclaw-expert-consilium-report.md)
- **Architecture Comparison:** [@ref: docs/analysis/OPENCLAW-ARCHITECTURE-COMPARISON.md](../analysis/OPENCLAW-ARCHITECTURE-COMPARISON.md)
- **Subagent Architecture:** [@ref: docs/openclaw-subagent-architecture.md](../openclaw-subagent-architecture.md)

### Related Plans
- **Agent Teams Plan:** [@ref: docs/reference/agent-teams-integration-plan.md](../reference/agent-teams-integration-plan.md)
- **Task Tracker:** [@ref: TASKS.md](../../TASKS.md)

### Artifacts
- **Architecture:** [@ref: docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
- **Protocol:** [@ref: docs/commands/PROTOCOL-v1.md](../commands/PROTOCOL-v1.md)
- **Reference:** [@ref: docs/reference/openclaw-ollama-gemini-telegram-system.md](../reference/openclaw-ollama-gemini-telegram-system.md)

---

## 📊 Ключевые решения

### Решение #1: Гибридная архитектура

**Обоснование:** architect-comparative показал, что полная миграция на субагентов требует 2-3 недели и теряет качество кода (glm-4.7 vs gemini-3-flash).

**Решение:** Сохранить v2.0 для production + добавить фреймворк субагентов для expansion.

### Решение #2: MVP Core Subagents

**Обоснование:** subagent-architect рекомендует начать с 4 core agents для MVP.

**Решение:** Реализовать Intent Parser, Command Resolver, Command Executor, Agent Router в Phase 3.

### Решение #3: Three-Phase Implementation

**Обоснование:** architect-comparative рекомендует краткосрочно v2.0, среднесрочно гибрид, долгосрочно полную миграцию.

**Решение:** Phase 1 (P0) → production fix, Phase 2 (P1) → docs update, Phase 3 (P2) → subagents.

---

**Версия:** 2.1.0 (FINAL + subagent-architect integration)
**Статус:** FINAL
**Дата:** 2026-02-11
**Автор:** migration-coordinator agent

**Основано на:**
- Expert Consilium v2.0 Report
- architect-comparative (Сравнительный анализ архитектур)
- subagent-architect (Архитектура системы субагентов) — **ИНТЕГРИРОВАНО**
- Agent Teams Integration Plan

---

## 🆕 Обновление v2.1.0: Интеграция subagent-architect

### Новые артефакты от subagent-architect

**Отсутствует в CodeFoundry, нужно создать:**
```
/opt/openclaw/workspace/
├── agents/
│   ├── core/                    # P0: Intent Parser, Command Resolver, Executor, Router
│   ├── development/             # P1: Code Generator, Debugger, Test Generator
│   ├── devops/                  # P1: Docker Deploy, CI Pipeline
│   ├── ai-assistants/           # P1: Prompt Engineer, Code Reviewer
│   └── generated/               # P2: Self-improving output
├── AGENTS-INDEX.json            # P0: Machine-readable index
├── AGENTS-SCHEMA.json           # P1: Validation schema
└── AGENTS.md                    # P0: Agent registry
```

### Обновлённая матрица зависимостей (subagent-architect)

```
┌────────────────────┬────────────────────────────────┐
│ Артефакт           │ Зависит от                    │
├────────────────────┼────────────────────────────────┤
│ agents/core/       │ — (baseline)                  │
│ agents/development/│ core/                         │
│ AGENTS-INDEX.json  │ Agent definitions (MD files)   │
│ Agent Router       │ AGENTS-INDEX.json              │
│ AGENTS-SCHEMA.json │ AGENTS-INDEX.json              │
│ Self-Improving     │ Prompt Engineer + Schema       │
│ Handoff Protocol   │ Все agent implementations      │
└────────────────────┴────────────────────────────────┘
```

### Agent Handoff Protocol (новый формат)

**Стандартизированный формат передачи контекста между агентами:**
```markdown
## Agent Handoff
**From:** {source_agent}
**To:** {target_agent}
**Reason:** {handoff_reason}
---
### Context
{summary_of_work_done}
### Files Involved
{list_of_files}
### Task
{task_description}
---
**Continue from here.**
```

---

*Финальный план готов к реализации с интеграцией subagent-architect рекомендаций.*
