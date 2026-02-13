# 📋 Трекер Задач - System Prompts Meta-Generator

> [🏠 Главная](README.md) → [📋 TASKS.md](#)
> **Архив завершённых фаз:** [@ref: tasks/archive/phases-01-10.md](tasks/archive/phases-01-10.md)
> **📚 Все документы:** [@ref: docs/INDEX.md](docs/INDEX.md)

---

## Статус Проекта: 🔄 В РАЗРАБОТКЕ

**Версия:** 1.5.0
**Текущий фокус:** Phase 8.5, 9, 15 — Активные задачи
**Общий Прогресс:** 96%
**Новая фаза:** Phase 15 — Agent Teams Integration [@ref: plan](docs/reference/agent-teams-integration-plan.md)

---

## 📊 Сводка Прогресса

| Фаза | Статус | Прогресс |
|------|--------|----------|
| **Фазы 1-10, 13:** | ✅ Завершены | 100% [@ref: archive](tasks/archive/phases-01-10.md) |
| **Фаза 8.5:** Telegram Bot | 🔄 В работе | 30% |
| **Фаза 9:** Documentation Agent | 🔄 MVP done | 80% |
| **Фаза 11:** Orchestrator Architecture | ⏸️ PAUSED | 85% |
| **Фаза 12:** Documentation Review | ⏳ Бэклог | 0% |
| **Фаза 14:** Housekeeping + Doc Agent | ✅ Завершена | 100% |
| **Фаза 15:** Agent Teams Integration | ⏳ Бэклог | 0% [@ref: plan](docs/reference/agent-teams-integration-plan.md) |

---

## 🤖 Фаза 8.5: Telegram Bot Integration (25%)

### TELEBOT-001: Telegram Bot MVP ✅
- **Статус:** ВЫПОЛНЕНО
- **Файлы:** `openclaw/telegram-bot/src/` (bot.ts, types.ts, session-manager.ts, gateway-client.ts)
- **Команды:** /start, /help, /new, /status
- **Завершено:** 2025-02-02

### TELEBOT-002: Bot Testing & Validation ✅
- **Статус:** ВЫПОЛНЕНО
- **Протестировано:** /start, /status, /help, /new
- **Завершено:** 2025-02-05

### TELEBOT-003: Enhanced Commands ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Команды:** /deploy, /logs, /agents, /projects

### TELEBOT-004: Production Hardening ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Задачи:** Redis session persistence, rate limiting, enhanced error handling

### TELEBOT-005: Setup Telegram Webhook ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** 🟡 СРЕДНИЙ (P1)
- **Описание:** Настройка Telegram webhook вместо polling mode для production стабильности
- **Диагностика:** `curl -s 'https://api.telegram.org/bot<TOKEN>/getWebhookInfo'` → `"url": ""`
- **Текущее состояние:** Бот работает в polling mode (ОК для MVP, но webhook надёжнее)
- **Требования:**
  - HTTPS endpoint через Traefik
  - Webhook URL: `https://ainetic.tech/telegram/webhook`
  - Webhook secret для верификации
- **Файлы:**
  - `openclaw/docker/docker-compose.orchestrator.yml` (Traefik labels)
  - `openclaw/telegram-bot/src/bot.ts` (webhook handler)
  - `server/.env.orchestrator` (TELEGRAM_WEBHOOK_URL, TELEGRAM_WEBHOOK_SECRET)
- **Зависимости:** Traefik уже настроен на сервере

---

## 📚 Фаза 9: Documentation Agent MVP (80%)

> **Статус:** MVP завершён через Phase 14. Оставшееся: DOCAGENT-003 (Best Practices)

### DOCAGENT-001: Documentation Agent Template ✅
- **Статус:** ВЫПОЛНЕНО (Phase 14 → DOC-001)
- **Файл:** `.claude/agents/documentation-agent.md` (77 строк)
- **Завершено:** 2026-02-09

### DOCAGENT-002: Documentation Monitoring Skill ✅
- **Статус:** ВЫПОЛНЕНО (Phase 14 → DOC-005)
- **Файл:** `.claude/skills/documentation-monitor.md` (87 строк)
- **Завершено:** 2026-02-09

### DOCAGENT-003: Documentation Best Practices ⏳
- **Статус:** ЗАПЛАНИРОВАНО

### DOCAGENT-004: Auto-Documentation Scripts ✅
- **Статус:** ВЫПОЛНЕНО (Phase 14 → DOC-002)
- **Файл:** `scripts/validate-docs.py` (324 строки)
- **Завершено:** 2026-02-09

### DOCAGENT-005: Documentation Agent Integration ✅
- **Статус:** ВЫПОЛНЕНО (Phase 14 → DOC-003, DOC-004)
- **Результат:** routing rules + schema + Makefile targets
- **Завершено:** 2026-02-09

---

## 🧹 Фаза 14: Housekeeping + Documentation Agent MVP (100%) ✅

> **План:** [docs/plans/phase-14-housekeeping-doc-agent.md](docs/plans/phase-14-housekeeping-doc-agent.md)
> **Результат:** TASKS.md -87% (лучше плана -73%), Doc Agent MVP полностью реализован

### HK-001: Создать структуру `tasks/` (A1-A4) ✅
- **Статус:** ВЫПОЛНЕНО
- **Файлы:**
  - ✅ `tasks/index.md`
  - ✅ `tasks/archive/README.md`
  - ✅ `tasks/archive/phases-01-10.md`
- **Завершено:** 2026-02-09

### HK-002: Переписать `TASKS.md` (A5) ✅
- **Статус:** ВЫПОЛНЕНО
- **Результат:** 1900+ → 247 строк (-87%, лучше плана -73%)
- **Завершено:** 2026-02-09

### HK-003: Обновить `SESSION.md` (A6-A9) ✅
- **Статус:** ВЫПОЛНЕНО
- **Результат:** SESSION.md (~118 строк), sessions/archive/sessions-12-13.md, index/README обновлены
- **Завершено:** 2026-02-09

### HK-004: Обновить cross-references (A10) ✅
- **Статус:** ВЫПОЛНЕНО
- **Результат:** docs/INDEX.md (дата, история), docs/WORKFLOW-GUIDE.md (описание фаз), @ref check PASS
- **Завершено:** 2026-02-09

### DOC-001: Создать `documentation-agent.md` (B1) ✅
- **Статус:** ВЫПОЛНЕНО
- **Файл:** `.claude/agents/documentation-agent.md` (77 строк)
- **Завершено:** 2026-02-09

### DOC-002: Создать `validate-docs.py` (B2) ✅
- **Статус:** ВЫПОЛНЕНО
- **Файл:** `scripts/validate-docs.py` (324 строки, Python вместо Bash)
- **Завершено:** 2026-02-09

### DOC-003: Обновить routing rules (B3-B4) ✅
- **Статус:** ВЫПОЛНЕНО
- **Результат:** `documentation-agent` добавлен в routing rules + schema enum
- **Завершено:** 2026-02-09

### DOC-004: Обновить Makefile (B5) ✅
- **Статус:** ВЫПОЛНЕНО
- **Результат:** 7 doc-целей (doc-check, doc-report, doc-refs, doc-stale, doc-orphans, doc-tokens, doc-coverage)
- **Завершено:** 2026-02-09

### DOC-005: Создать skill `documentation-monitor` (B6) ✅
- **Статус:** ВЫПОЛНЕНО
- **Файл:** `.claude/skills/documentation-monitor.md` (87 строк)
- **Завершено:** 2026-02-09

---

## 🔀 Фаза 15: Agent Teams Integration (BACKLOG)

> **Источник:** Консилиум 13 экспертов, Session #17 (2026-02-10)
> **План:** [@ref: docs/reference/agent-teams-integration-plan.md](docs/reference/agent-teams-integration-plan.md)
> **Консенсус:** 11/13 поддерживают, 2/13 осторожны → ПРИНЯТО

### AT-001: Agent Teams Routing Rules ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Файлы:** `.claude/auto-routing-rules.json`, `.claude/schemas/auto-routing-rules.schema.json`

### AT-002: Backup Coordinator Agent ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ (критически важно для безопасности)
- **Файлы:** `.claude/agents/backup-coordinator.md`, `scripts/backup-coordinator.sh`

### AT-003: Quality Gates Parallelization ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Файлы:** `scripts/quality-gates.sh`, `Makefile`

### AT-004: Create Agent Teams Skills ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Файлы:** `.claude/skills/agent-teams-parallel.md`, `.claude/skills/agent-teams-sequential.md`, `.claude/skills/agent-teams-safe-mode.md`

### AT-005: Documentation Update Team Skill ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ
- **Файлы:** `.claude/skills/doc-update-team.md`

### AT-006: GitOps 2.0 Workflow ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Файлы:** `.github/workflows/agent-teams-review.yml`, `.github/workflows/agent-teams-docs.yml`

### AT-007: Project Generation Enhancement ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Файлы:** `scripts/new-project.sh`, `templates/archetypes/*/openclaw/workspace/AGENTS.md`

### AT-008: CLAUDE.md Integration Section ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Файлы:** `CLAUDE.md`

### AT-009: Health Check System ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Файлы:** `.claude/commands/agents-health.md`, `scripts/check-agent-health.sh`

### AT-010: Token Budget Monitoring ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Файлы:** `scripts/monitor-token-usage.sh`, `.claude/skills/token-monitor.md`

### AT-011: Agent Teams Test Suite ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Файлы:** `tests/agent-teams/test-*.sh`

### AT-012: Multi-Persona Testing ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ
- **Файлы:** `tests/agent-teams/persona-tests/*.yml`

### AT-013: Agent Teams Documentation ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** НОРМАЛЬНЫЙ
- **Файлы:** `docs/agents/agent-teams.md`, `docs/agents/agent-teams.quick.md`, `docs/agents/agent-teams.examples.md`

### AT-014: Launch Announcement ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** НОРМАЛЬНЫЙ
- **Файлы:** `SESSION.md`, `CHANGELOG.md`

### AT-015: Rate Limit Compatibility ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ (P0 для Agent Teams)
- **Источник:** [@ref: docs/analysis/2026-02-11-zai-glm-rate-limit-analysis.md](docs/analysis/2026-02-11-zai-glm-rate-limit-analysis.md)
- **Содержание:**
  - Update Expert Consilium v2: batch size 4→2
  - Add rate limit monitoring (429 errors)
  - Implement retry logic with exponential backoff
  - Test with parallel agent spawning

### AT-016: Orphan Agents Routing Rules ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ (P1)
- **Источник:** [@ref: docs/analysis/2026-02-11-auto-routing-analysis.md](docs/analysis/2026-02-11-auto-routing-analysis.md)
- **Содержание:**
  - Add routing rule for tasks-sync (keywords: "sync tasks", "github issues")
  - Add routing rule for ollama-gemini-researcher (keywords: "ollama", "gemini")
  - Update auto-routing-rules.json
  - Test routing with sample queries

### AT-017: Token Guidelines Quality Gates Update ⏳
- **Статус:** ЧАСТИЧНО ВЫПОЛНЕНО
- **Приоритет:** НИЗКИЙ (P2)
- **Источник:** [@ref: docs/analysis/2026-02-11-agent-token-limits-consilium.md](docs/analysis/2026-02-11-agent-token-limits-consilium.md)
- **Содержание:**
  - Adaptive warning при >2× guideline
  - Modular-first validation (@ref priority)
  - Auto-compaction suggestions
  - Quarterly review cycle

---

## 🔀 Фаза 16: Subagent Framework Integration (BACKLOG)

> **Источник:** Expert Consilium v2.0 + architect-comparative + subagent-architect
> **Стратегия:** Гибридный подход — v2.0 для production + подготовка инфраструктуры для субагентов
> **План:** [@ref: docs/plans/2026-02-11-FINAL-artifact-migration-plan.md](docs/plans/2026-02-11-FINAL-artifact-migration-plan.md)
> **Анализ приоритетов:** [@ref: docs/analysis/2026-02-12-expert-consilium-priority-review.md](docs/analysis/2026-02-12-expert-consilium-priority-review.md)

### SUB-001: Subagent Framework Core ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ (P0)
- **Файлы:**
  - `openclaw/subagent-framework/core/agent-registry.ts`
  - `openclaw/subagent-framework/core/agent-lifecycle-manager.ts`
- **Компоненты:**
  - Agent Registry (AGENTS-INDEX.json)
  - Agent Router (Intent → Subagent)
  - Agent Lifecycle Manager

### SUB-002: Core Subagents (MVP) ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ (P0)
- **Субагенты:**
  - Intent Parser (agents/core/intent-parser.md)
  - Command Resolver (agents/core/command-resolver.md)
  - Command Executor (agents/core/command-executor.md)
  - Agent Router (agents/core/agent-router.md)
- **Файлы:** `/opt/openclaw/workspace/agents/core/*.md`

### SUB-003: Development Subagents ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ (P1)
- **Субагенты:**
  - Code Generator (agents/development/code-generator.md)
  - Debugger (agents/development/debugger.md)
  - Test Generator (agents/development/test-generator.md)
- **Файлы:** `/opt/openclaw/workspace/agents/development/*.md`

### SUB-004: AGENTS-INDEX.json ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ (P0)
- **Файл:** `/opt/openclaw/workspace/AGENTS-INDEX.json`
- **Формат:** Machine-readable registry всех агентов с capabilities, triggers, models

### SUB-005: AGENTS.md Registry ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** ВЫСОКИЙ (P0)
- **Файл:** `/opt/openclaw/workspace/AGENTS.md`
- **Формат:** Human-readable registry всех агентов

### SUB-006: AGENTS-SCHEMA.json ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ (P1)
- **Файл:** `/opt/openclaw/workspace/AGENTS-SCHEMA.json`
- **Формат:** JSON Schema validation для AGENTS-INDEX.json

### SUB-007: Hybrid Routing Logic ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** КРИТИЧЕСКИЙ (P0)
- **Логика:**
  - Simple tasks → OpenClaw v2.0 (gemini-3-flash)
  - Complex tasks → Claude Code (glm-4.7)
  - Specialized → Subagents (domain-specific)
- **Файл:** `openclaw/subagent-framework/core/hybrid-router.ts`

### SUB-008: Agent Handoff Protocol ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** СРЕДНИЙ (P1)
- **Формат:** Стандартизированный формат передачи контекста между агентами
- **Пример:** Agent Handoff Format (markdown template)

### SUB-009: Self-Improving Loop ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** НИЗКИЙ (P2)
- **Компоненты:**
  - Gap Detection Logic
  - Agent Generation Workflow
  - Validation Framework
- **Цель:** Автоматическое создание агентов для обнаруженных gaps

---

## 📝 Фаза 12: Documentation Review & Update (BACKLOG)

> **Источник:** Консилиум 13 экспертов, Session #14 (2026-02-06)
> **Эталонный документ:** `docs/reference/openclaw-ollama-gemini-telegram-system.md`

### DOCFIX-001: Fix models.json — Add Required `api` Field 🔴
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** 🔴 КРИТИЧЕСКИЙ

### DOCFIX-002: Fix Telegram Bot Health Check 🔴
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** 🔴 КРИТИЧЕСКИЙ

### DOCFIX-003: Document Ollama v0.3.12+ Requirement 🔴
- **Статус:** ЗАПЛАНИРОВАНО
- **Приоритет:** 🔴 КРИТИЧЕСКИЙ

### DOCFIX-004: Document proxy-to-gemini Alternative 🟡
- **Статус:** ЗАПЛАНИРОВАНО

### DOCFIX-005: Document Gemini 3 Flash thinking_level 🟡
- **Статус:** ЗАПЛАНИРОВАНО

### DOCFIX-006: Add Model Preloading Entrypoint Script 🟡
- **Статус:** ЗАПЛАНИРОВАНО

### DOCFIX-007: Update Ollama Cloud Tag Documentation 🟡
- **Статус:** ЗАПЛАНИРОВАНО

### DOCFIX-008: Update Expert Opinions with 2026 Findings 🟢
- **Статус:** ЗАПЛАНИРОВАНО

### DOCFIX-009: Document Telegram Bot API 2025 Features 🟢
- **Статус:** ЗАПЛАНИРОВАНО

### DOCFIX-010: Document Docker MCP Gateway Pattern 🟢
- **Статус:** ЗАПЛАНИРОВАНО

---

## ⏸️ Фаза 11: OpenClaw Orchestrator Architecture — PAUSED (85%)

> **🚨 ПРИОСТАНОВЛЕНО (2026-02-13)**
>
> **Решение:** Expert Consilium (consensus: 0.76) — временно отключить OpenClaw на сервере, освободить Docker ресурсы.
> **Причина:** Фокус на приоритетных задачах, освобождение дискового пространства (~3GB).
> **Восстановление:** `git pull && make deploy` (GitOps).
>
> OpenClaw = Orchestrator/UI Layer, Claude Code = Developer.

### ORCH-001: Expert Review & Architecture Design ✅
- **Статус:** ВЫПОЛНЕНО
- **Консенсус:** **8.8/10** — ОТЛИЧНО, РЕАЛИЗУЙТЕ
- **Файлы:** `docs/experts-opinions-openclaw-orchestrator.md`, `docs/OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md`
- **Завершено:** 2025-02-05

### ORCH-002: Ollama Cloud Research ✅
- **Статус:** ВЫПОЛНЕНО
- gemini-3-flash-preview: FREE или $0.5/1M tokens, 1M context window
- **Завершено:** 2025-02-05

### ORCH-003: Command Protocol v1.0 Definition ✅
- **Статус:** ВЫПОЛНЕНО
- **Файлы:** `docs/commands/PROTOCOL-v1.md` — полный spec (320+ строк)
- **MVP Commands:** create_project, status, help
- **Завершено:** 2025-02-05

### ORCH-004: CLI Bridge Implementation ✅
- **Статус:** ВЫПОЛНЕНО + ПРОТЕСТИРОВАНО
- **Файлы:** `server/scripts/claude-wrapper.sh` (320+ строк), `server/scripts/test-commands.sh`
- **Тесты:** ✅ 4/4 PASSED (ainetic.tech validation)
- **Завершено:** 2025-02-05

### ORCH-005: OpenClaw Gateway Update ✅
- **Статус:** ВЫПОЛНЕНО
- **Модули:** ollama-client.ts, command-generator.ts, command-executor.ts
- **Завершено:** 2025-02-05

### ORCH-006: Documentation Updates ⏳
- **Статус:** ЗАПЛАНИРОВАНО (PAUSED)
- **Приоритет:** 🟡 СРЕДНИЙ (P1)
- **Файлы:** PROJECT.md, README.md, docs/INDEX.md, docs/ARCHITECTURE-ANALYSIS.md

### ORCH-007: Telegram Bot MVP (Orchestrator) ⏳
- **Статус:** ЗАПЛАНИРОВАНО (PAUSED)
- **Приоритет:** 🟡 СРЕДНИЙ (P1)
- **Команды:** /new, /status, /help

### ORCH-007.5: AI Intent Classifier Implementation ✅
- **Статус:** ВЫПОЛНЕНО (Session #21, 2026-02-11)
- **Приоритет:** 🟡 СРЕДНИЙ (P1) — РЕШЕНО
- **Проблема:** Intent Pre-Classifier (commit `1d4a1aa`) обходит OpenClaw для свободных сообщений
- **Решение:** Вариант D — AI Intent Classifier
- **Файлы:**
  - ✅ `openclaw/gateway/src/intent-classifier.ts` (новый модуль, 320+ строк)
  - ✅ `openclaw/gateway/src/gateway.ts` (интеграция Intent Classifier)
  - ✅ `server/scripts/claude-wrapper.sh` (обновлён: команда `deploy`, логирование confidence)
- **Функциональность:**
  - AI-powered классификация intent (gemini-3-flash-preview)
  - Confidence scoring с threshold (0.7 по умолчанию)
  - Extraction параметров из естественного языка
  - Fallback на keyword matching при ошибках AI
- **Intents:** create_project, status, help, deploy, chat
- **Тесты:** ✅ 40+ unit tests PASSED
- **Завершено:** 2026-02-11
- **Analysis:** [@ref: docs/plans/2026-02-11-FINAL-artifact-migration-plan.md](docs/plans/2026-02-11-FINAL-artifact-migration-plan.md)

### ORCH-008: Docker Compose Update ✅
- **Статус:** ВЫПОЛНЕНО
- **Файлы:** `openclaw/docker/docker-compose.orchestrator.yml`, `server/docker-compose.orchestrator.yml`
- **Завершено:** 2025-02-05

### ORCH-009: Testing & Validation 🔄
- **Статус:** Unit tests ✅, E2E ⏳ (PAUSED)
- **Unit:** 21/21 PASSED (local + remote)
- **E2E:** Gateway ready, awaits API key deployment

### ORCH-010: Deployment to ainetic.tech ✅
- **Статус:** ВЫПОЛНЕНО (Session #22, 2026-02-12)
- **E2E Tests:** 4/4 PASSED
  - ✅ Gateway Health Check
  - ✅ CLI Bridge: status command
  - ✅ CLI Bridge: help command
  - ✅ Gateway WebSocket Connection
- **Services:**
  - ✅ Gateway v2.0.1: healthy (uptime: 44h)
  - ✅ Telegram-bot: connected (4 commands registered)
  - ✅ Claude-runner: healthy (CLI Bridge operational)
- **Report:** [@ref: docs/analysis/2026-02-12-ORCH-010-E2E-testing-report.md](docs/analysis/2026-02-12-ORCH-010-E2E-testing-report.md)
- **Known Issues:** Docker socket permission (non-critical)
- **Завершено:** 2026-02-12

### ORCH-011: GLM-4.7-Flash Production Testing ✅
- **Статус:** ВЫПОЛНЕНО
- **Файлы:** `containers/claude-code-runner/Dockerfile`, `docs/lessons/websocket-client-health-check.md`
- **All containers:** ✅ healthy
- **Завершено:** 2025-02-05

### ORCH-012: Install Claude CLI in Runner ⏳
- **Статус:** ЗАПЛАНИРОВАНО (PAUSED)
- **Приоритет:** 🟡 СРЕДНИЙ (P1)
- **Описание:** Установка Claude CLI в контейнер `openclaw-orchestrator-claude-runner` для работы CLI Bridge
- **Файлы:**
  - `server/containers/claude-code-runner/Dockerfile`
  - `openclaw/docker/docker-compose.orchestrator.yml`
- **Зависимости:** ORCH-013 (openclaw.json)

### ORCH-013: Create openclaw.json Configuration ⏳
- **Статус:** ЗАПЛАНИРОВАНО (PAUSED)
- **Приоритет:** 🟡 СРЕДНИЙ (P1)
- **Описание:** Создание конфигурационного файла `openclaw.json` для корректной работы OpenClaw
- **Файлы:**
  - `openclaw/config/openclaw.json`
  - `openclaw/docker/docker-compose.orchestrator.yml` (volume mount)
- **Содержимое:** Model config, Gateway settings, Workspace paths, Channel configs

---

## 📋 Легенда Статусов

- ⏳ **ОЖИДАЕТ** - Еще не начато
- 🔄 **В РАБОТЕ** - Сейчас работаем над этим
- ✅ **ВЫПОЛНЕНО** - Успешно завершено
- ❌ **ЗАБЛОКИРОВАНО** - Ожидание зависимости
- 🔴 **КРИТИЧЕСКИЙ** - Высокий приоритет
- 🟡 **СРЕДНИЙ** - Обычный приоритет
- 🟢 **НИЗКИЙ** - Низкий приоритет

---

> [🏠 Главная](README.md) → [📋 TASKS.md](#)
