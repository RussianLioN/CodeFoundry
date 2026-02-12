# 📊 Analysis Documentation Index

> [🏠 Главная](../../README.md) → [📋 Docs](../INDEX.md) → **Analysis Docs**

---

## 📋 Quick Navigation

| Категория | Документ | Назначение |
|-----------|----------|-----------|
| **Architecture** | [OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md) | OpenClaw Architecture v2.0.1 |
| **Token Limits** | [agent-token-limits-consilium.md](2026-02-11-agent-token-limits-consilium.md) | Expert Consilium on Token Guidelines |
| **Auto Routing** | [auto-routing-analysis.md](2026-02-11-auto-routing-analysis.md) | Analysis of auto-routing rules |
| **GLM Rate Limits** | [zai-glm-rate-limit-analysis.md](2026-02-11-zai-glm-rate-limit-analysis.md) | Rate limit analysis for GLM models |
| **Subagents** | [../openclaw-subagent-architecture.md](../openclaw-subagent-architecture.md) | Subagent Architecture Proposal |

---

## 📖 Documents

### OpenClaw Orchestrator Architecture

**OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md**
- **Обновлён:** 2026-02-11 (v2.0.1 with AI Intent Classifier)
- **Содержание:**
  - Layer descriptions (UI, Orchestration, Development, CLI Bridge)
  - **Intent Classifier (v2.0.1 — NEW)** — критический фикс ORCH-007.5
    - Проблема keyword matching
    - Решение с AI-powered классификацией
    - 5 intents с confidence scoring
  - Request Format v1.1 с intent_confidence
  - **Гибридная Архитектура (Phase 2 — NEW)**:
    - Стратегическое решение (comparative table)
    - Трёхфазная эволюция (Phase 1/2/3)
    - Routing Logic diagram
    - Component Map (Phase 1/2/3)
  - Full workflow с примерами

### Agent Teams Integration

#### Token Guidelines Consilium
**agent-token-limits-consilium.md**
- **Дата:** 2026-02-11
- **Тема:** Agent Token Limits Consilium
- **Консенсус:** MODERATE (64.5%) — "Guided Modularity"
- **Результат:** Token guideline advisory (не блокирующий)
- **Связи:**
  - [Expert Consilium v2.0 Report](../analysis/2026-02-11-openclaw-expert-consilium-report.md)
  - [Agent Token Limits Consilium Report](../../MEMORY.md#agent-token-limits-consilium)

#### Auto-Routing Analysis
**auto-routing-analysis.md**
- **Дата:** 2026-02-11
- **Тема:** Анализ правил авто-маршрутизации
- **Результаты:**
  - ✅ NO phantom agents (все 18 агентов имеют routing rules)
  - ⚠️ 2 orphan agents (files exist, no routing rules)
  - **Рекомендация:** Добавить routing rules для orphan agents
  - **Orphan agents:** tasks-sync, ollama-gemini-researcher

#### GLM Rate Limit Analysis
**zai-glm-rate-limit-analysis.md**
- **Дата:** 2026-02-11
- **Тема:** Анализ rate limits для Zhipu AI GLM-4.7-Flash
- **Проблема:** 100 RPM limit (1.67 requests/second)
- **Решение:** Batch processing + retry logic

### Subagent Architecture

**openclaw-subagent-architecture.md**
- **Статус:** PROPOSAL (for future Phase 16)
- **Содержание:**
  - Agent Registry (AGENTS-INDEX.json)
  - Core Subagents (Intent Parser, Command Resolver, Executor, Router)
  - Development Subagents (Code Generator, Debugger, Test Generator)
  - Agent Lifecycle Management
  - Self-Improving Loop

### Implementation Plans

#### FINAL Artifact Migration Plan
**FINAL-artifact-migration-plan.md** (утверждённая версия)
- **Версия:** 2.1.0
- **Три фазы:**
  - **P0 (Production Fix)** — Intent Classifier + CLI Bridge + TASKS.md (90% ready)
  - **P1 (Documentation Update)** — Architecture + Protocol + Command Generator (95% ready)
  - **P2 (Subagent System)** — Agent Framework + Self-Improving (100% expansion)
- **Матрица зависимостей:** Полная карта всех артефактов с приоритетами
- **Checklists:** Phase 1/2/3 completion criteria

**artifact-migration-plan.md** (предварительный, заменён)
- Предшественник FINAL версии
- Draft версия плана миграции

---

## 🔗 Кросс-ссылки

### Из Analysis Docs

```markdown
<!-- В analysis документах использовать эти ссылки: -->

[@ref: ../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
[@ref: agent-token-limits-consilium.md](agent-token-limits-consilium.md)
[@ref: auto-routing-analysis.md](auto-routing-analysis.md)
[@ref: zai-glm-rate-limit-analysis.md](zai-glm-rate-limit-analysis.md)
[@ref: openclaw-subagent-architecture.md](../openclaw-subagent-architecture.md)
[@ref: FINAL-artifact-migration-plan.md](FINAL-artifact-migration-plan.md)
[@ref: artifact-migration-plan.md](artifact-migration-plan.md)
```

### Из Plans Docs

```markdown
<!-- В plan документх использовать эти ссылки: -->

[@ref: FINAL-artifact-migration-plan.md](../plans/FINAL-artifact-migration-plan.md)
[@ref: artifact-migration-plan.md](../plans/artifact-migration-plan.md)
[@ref: agent-teams-integration-plan.md](../reference/agent-teams-integration-plan.md)
```

---

**Последнее обновление:** 2026-02-11
**Версия архитектуры:** v2.0.1
