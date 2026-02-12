# План миграции артефактов — CodeFoundry → Agent Teams Integration

> **Дата:** 2026-02-11
> **Задача:** #4 — План миграции артефактов
> **Статус:** DRAFT (ожидает результатов от других агентов)
> **Источник:** Expert Consilium v2.0 + Agent Teams Integration Plan

---

## Executive Summary

На основе анализа от **architect-comparative**, **subagent-architect** и **integration-analyst** составлен приоритизированный план обновления артефактов для интеграции Agent Teams в архитектуру CodeFoundry.

**Ключевые изменения:**
- OpenClaw → Orchestrator v2.0 с AI Intent Classifier
- Command Protocol v1.0 → актуализация под Claude Code
- Agent Teams → гибридная архитектура (@ref + parallel agents)

---

## 🔴 P0: КРИТИЧЕСКИЕ ИЗМЕНЕНИЯ (4-6 часов)

### 1. ORCH-007.5: Fix Intent Pre-Classifier Bug

**Артефакт:** `openclaw/gateway/src/gateway.ts`

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
class IntentClassifier {
  async classify(message: string): Promise<Intent> {
    // AI-powered intent classification via gemini-3-flash
    // Returns: { intent: 'create_project'|'status'|'chat', confidence }
  }
}

// В gateway.ts: заменить keyword matching на AI classification
const intent = await this.intentClassifier.classify(content);
```

**Затраты времени:** 2-4 часа

**Зависимости:** Нет

**Блокирует:** ORCH-009, ORCH-010

---

### 2. CLI Bridge: Update claude-wrapper.sh

**Артефакт:** `server/scripts/claude-wrapper.sh`

**Текущее состояние:** 320+ строк, 4/4 тестов passed

**Требуемые изменения:**
- Добавить поддержку нового Intent Classifier
- Обновить обработку ошибок от AI intent classification
- Добавить логирование intent confidence

**Затраты времени:** 1 час

**Зависимости:** Зависит от #1 (Intent Classifier)

---

### 3. TASKS.md: Актуализация Phase 11

**Артефакт:** `TASKS.md`

**Текущее состояние:** ORCH-007.5 помечен как критический баг

**Требуемые изменения:**
- Обновить статус ORCH-007.5 после fix
- Добавить новые задачи для Agent Teams Integration (Phase 15)
- Актуализировать зависимости между задачами

**Затраты времени:** 30 минут

**Зависимости:** Зависит от #1, #2

---

## 🟡 P1: ВАЖНЫЕ ИЗМЕНЕНИЯ (~1 неделя)

### 4. OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md: Обновить v2.0

**Артефакт:** `docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md`

**Текущее состояние:** Описывает v2.0 без учёта ORCH-007.5 fix

**Требуемые изменения:**
1. **Добавить раздел:** Intent Classifier Architecture
2. **Обновить workflow:**
   - Было: User → Keywords → Chat/Command
   - Стало: User → AI Intent Classification → Command Generation
3. **Обновить Command Protocol section** с учётом Intent Classifier
4. **Добавить диаграмму** нового потока данных

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
```

**Затраты времени:** 2-3 часа

**Зависимости:** Зависит от #1 (Intent Classifier implementation)

---

### 5. PROTOCOL-v1.md: Обновить Command Protocol

**Артефакт:** `docs/commands/PROTOCOL-v1.md`

**Текущее состояние:** 320+ строк, полный spec v1.0

**Требуемые изменения:**
1. **Добавить раздел:** Intent Classification Protocol
2. **Обновить Request Format:**
   ```json
   {
     "version": "1.1",
     "intent": { "name": "create_project", "confidence": 0.95 },
     "parameters": {...}
   }
   ```
3. **Добавить примеры** с AI-powered intent classification
4. **Обновить Error Handling** для low confidence scenarios

**Затраты времени:** 2-3 часа

**Зависимости:** Нет (может быть параллельно с #1)

---

### 6. openclaw/gateway/src/command-generator.ts: Оптимизация

**Артефакт:** `openclaw/gateway/src/command-generator.ts`

**Текущее состояние:** 80% готовности, требуется улучшение system prompt для NLP

**Требуемые изменения:**
1. **Обновить system prompt** для работы с Intent Classifier
2. **Добавить обработку** low confidence intents
3. **Интегрировать** с Intent Classifier для parameter extraction

**Затраты времени:** 2-4 часа

**Зависимости:** Зависит от #1 (Intent Classifier)

---

### 7. openclaw-ollama-gemini-telegram-system.md: Актуализация

**Артефакт:** `docs/reference/openclaw-ollama-gemini-telegram-system.md`

**Текущее состояние:** Эталонный документ, основан на исследовании 15+ источников

**Требуемые изменения:**
1. **Добавить раздел:** Intent Classifier vs Keyword Matching
2. **Обновить best practices** с учётом AI-powered intent classification
3. **Добавить WebSocket Client Health Check** правильный паттерн
4. **Обновить models.json** с обязательным полем `api`

**Затраты времени:** 2-3 часа

**Зависимости:** Нет

---

## 🟢 P2: ЖЕЛАТЕЛЬНЫЕ ИЗМЕНЕНИЯ (2-3 недели)

### 8. Agent Teams Skills Integration

**Артефакт:** `.claude/skills/agent-teams-*.md`

**Текущее состояние:** Запланированы в Phase 15

**Требуемые изменения:**
1. **Создать 3 skills:**
   - `agent-teams-parallel.md` (~40 lines)
   - `agent-teams-sequential.md` (~35 lines)
   - `agent-teams-safe-mode.md` (~45 lines)
2. **Интегрировать** с OpenClaw Gateway для multi-agent coordination
3. **Добавить token monitoring** для параллельных операций

**Затраты времени:** 1-2 дня

**Зависимости:** Зависит от P0-P1 completion

---

### 9. Backup Coordinator Agent

**Артефакт:** `.claude/agents/backup-coordinator.md`

**Текущее состояние:** Запланирован в Phase 15 (AT-002)

**Требуемые изменения:**
1. **Создать agent file** (~150 lines)
2. **Создать script** `scripts/backup-coordinator.sh` (~200 lines)
3. **Интегрировать** с quality gates для pre-work backup

**Затраты времени:** 1-2 дня

**Зависимости:** Зависит от Agent Teams Skills

---

### 10. Quality Gates Parallelization

**Артефакт:** `scripts/quality-gates.sh`, `Makefile`

**Текущее состояние:** Последовательное выполнение

**Требуемые изменения:**
1. **Рефакторинг** для parallel execution с GNU parallel или make -j
2. **Добавить target** `make quality-parallel`
3. **Агрегация результатов** из параллельных gate

**Затраты времени:** 3-4 часа

**Зависимости:** Зависит от Backup Coordinator

---

### 11. Documentation Updates

**Артефакты:**
- `PROJECT.md`
- `README.md`
- `docs/INDEX.md`
- `docs/ARCHITECTURE-ANALYSIS.md`

**Требуемые изменения:**
1. **Добавить Agent Sections** для всех агентов
2. **Обновить @ref ссылки** на новые артефакты
3. **Добавить примеры** использования Agent Teams
4. **Обновить workflow diagrams**

**Затраты времени:** 2-3 дня

**Зависимости:** Зависит от всех предыдущих

---

## 📊 Матрица зависимостей

```
P0 (Критические)
├── #1 Intent Classifier ────────┐
├── #2 CLI Bridge ───────────────┤
├── #3 TASKS.md ─────────────────┤
└── #4 Architecture.md ───────────┤──> Блокирует: ORCH-009, ORCH-010

P1 (Важные)
├── #5 PROTOCOL-v1.md ────────────┤──> Параллельно с P0
├── #6 command-generator.ts ──────┤──> После #1
└── #7 openclaw-ollama-gemini... ─┤──> Параллельно

P2 (Желательные)
├── #8 Agent Teams Skills ────────┤──> После P1
├── #9 Backup Coordinator ────────┤──> После #8
├── #10 Quality Gates ────────────┤──> После #9
└── #11 Documentation ────────────┘──> После всех
```

---

## 🚀 План реализации

### Phase 1: P0 (Day 1-2)
- [ ] Fix ORCH-007.5 (#1)
- [ ] Update CLI Bridge (#2)
- [ ] Актуализировать TASKS.md (#3)

**Ожидаемый результат:** 90% production ready

### Phase 2: P1 (Week 1)
- [ ] Update OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md (#4)
- [ ] Update PROTOCOL-v1.md (#5)
- [ ] Optimize command-generator.ts (#6)
- [ ] Актуализировать reference docs (#7)

**Ожидаемый результат:** 95% production ready

### Phase 3: P2 (Week 2-3)
- [ ] Agent Teams Skills (#8)
- [ ] Backup Coordinator (#9)
- [ ] Quality Gates Parallelization (#10)
- [ ] Documentation Updates (#11)

**Ожидаемый результат:** 100% production ready + Agent Teams integration

---

## 📋 Проверочные списки

### P0 Checklist
- [ ] Intent Classifier реализован и протестирован
- [ ] CLI Bridge работает с новыми intent
- [ ] TASKS.md отражает текущий статус
- [ ] Quality gates pass

### P1 Checklist
- [ ] Все architecture docs обновлены
- [ ] PROTOCOL-v1.md отражает v1.1 changes
- [ ] Command Generator использует Intent Classifier
- [ ] Reference docs актуальны

### P2 Checklist
- [ ] Agent Teams skills functional
- [ ] Backup coordinator operational
- [ ] Quality gates работают в parallel mode
- [ ] Документация полная и актуальная

---

## 🔗 Связанные документы

- **Expert Consilium:** [@ref: docs/analysis/2026-02-11-openclaw-expert-consilium-report.md](../analysis/2026-02-11-openclaw-expert-consilium-report.md)
- **Agent Teams Plan:** [@ref: docs/reference/agent-teams-integration-plan.md](../reference/agent-teams-integration-plan.md)
- **Task Tracker:** [@ref: TASKS.md](../../TASKS.md)
- **Architecture:** [@ref: docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)

---

**Версия:** 1.0.0
**Статус:** DRAFT (ожидает подтверждения от других агентов)
**Дата:** 2026-02-11
**Автор:** migration-coordinator agent

---

*Этот план будет обновлён после получения результатов от architect-comparative, subagent-architect и integration-analyst.*
