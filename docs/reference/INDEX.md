# 📚 Reference Documentation Index

> [🏠 Главная](../../README.md) → [📋 Docs](../INDEX.md) → **Reference Docs**

---

## 📋 Quick Navigation

| Категория | Документ | Назначение |
|-----------|----------|-----------|
| **Architecture** | [OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md](OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md) | OpenClaw v2.0/v2.0.1 Architecture |
| **Commands** | [../commands/PROTOCOL-v1.md](../commands/PROTOCOL-v1.md) | Command Protocol v1.0/v1.1 |
| **Systems** | — | System integration docs (TODO) |

---

## 📖 Documents

### Architecture & Design

**OpenClaw Orchestrator Architecture v2.0.1**
- **Файл:** [`OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md`](OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
- **Обновлён:** 2026-02-11 (v2.0.1 with AI Intent Classifier)
- **Содержание:**
  - Executive Summary
  - Ключевые изменения (v1.0 → v2.0)
  - Полный workflow
  - **Intent Classifier (v2.0.1 — NEW)**
  - Layer descriptions (UI, Orchestration, Development, CLI Bridge)
  - Request/Response Formats
  - **Гибридная Архитектура (Phase 2 — NEW)**
  - Roadmap (Phase 1/2/3)
  - Priority P0 tasks

### Command Protocol

**Command Protocol v1.1 (с Subagent Protocol v2.0 Preview)**
- **Файл:** [`../commands/PROTOCOL-v1.md`](../commands/PROTOCOL-v1.md)
- **Обновлён:** 2026-02-11 (v1.1 + intent_confidence + Subagent Protocol)
- **Содержание:**
  - Обзор протокола
  - **Request Format v1.1** — с полем `intent_confidence`
  - Response Format
  - Поддерживаемые команды (create_project, status, help, deploy)
  - **Subagent Communication Protocol v2.0 (Preview — NEW)**
  - Agent Handoff Format
  - Примеры workflow (sequential, parallel)

---

## 🔗 Связи с другими документами

### Analysis Docs ([@ref: ../analysis/INDEX.md](../analysis/INDEX.md))
- **Agent Token Limits Consilium** — [@ref: ../analysis/2026-02-11-agent-token-limits-consilium.md](../analysis/2026-02-11-agent-token-limits-consilium.md)
- **Auto-Routing Analysis** — [@ref: ../analysis/2026-02-11-auto-routing-analysis.md](../analysis/2026-02-11-auto-routing-analysis.md)
- **AI GLM Rate Limit Analysis** — [@ref: ../analysis/2026-02-11-zai-glm-rate-limit-analysis.md](../analysis/2026-02-11-zai-glm-rate-limit-analysis.md)

### Plans ([@ref: ../plans/INDEX.md](../plans/INDEX.md))
- **FINAL Artifact Migration Plan** — [@ref: ../plans/2026-02-11-FINAL-artifact-migration-plan.md](../plans/2026-02-11-FINAL-artifact-migration-plan.md)
  - P0: Critical fixes (ORCH-007.5)
  - P1: Documentation updates
  - P2: Subagent system (Phase 16)

### Session Documentation ([@ref: ../../sessions/index.md](../../sessions/index.md))
- **Session #21 Summary** — [@ref: ../../sessions/session-summary-2026-02-11-s21.md](../../sessions/session-summary-2026-02-11-s21.md)
  - P0: ORCH-007.5 fix (Intent Classifier)
  - P1: Architecture + Protocol updates
  - ORCH-009: Unit tests (40+ cases)

---

## 📝 Заметки

- Все reference документы должны использовать [@ref](../../SYNTAX.md#ref-syntax) ссылки
- При обновлении связанных документов — обновлять INDEX.md
- Название reference docs должно начинаться с `OPENCLAW-` для консистентности

---

**Последнее обновление:** 2026-02-11
**Версия архитектуры:** v2.0.1
