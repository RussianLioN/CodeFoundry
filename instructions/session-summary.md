# Session Summary

> **When:** User requests session summary or at session closure
> **Triggers:** "сделай саммери", "расскажи о сессии", "что сделано?", "суммаризируй"

---

## Purpose

Create structured session summary artifact and update SESSION.md for continuity.

---

## 🔴 P0: Mandatory Steps

### При запуске НОВОЙ сессии:

1. **Читать SESSION.md** → получить контекст предыдущей работы
2. **Саммаризировать предыдущую сессию** → краткий отчёт:
   - Что делалось?
   - Что достигнуто?
   - Что осталось незавершённым?
3. **Обновить SESSION.md** → записать саммаризацию как "Previous Session"
4. **Артефакт** (опционально) → создать `docs/sessions/session-summary-YYYY-MM-DD.md`

### При завершении текущей сессии:

1. **Собрать данные** → достижения, решения, проблемы
2. **Обновить SESSION.md** → записать в "Current Context"
3. **Создать архив** → `sessions/archive/sessions-XX.md`
4. **Git commit** → сохранить изменения

---

## Format саммаризации

### В SESSION.md (Previous Session):

```markdown
## 📌 Current Context

**Current Session:** #21 (2026-02-11)
**Focus:** OpenClaw analysis + implementation plan
**Progress:** Variant A approved, Quick Start created

**Previous Session (#20, 2026-02-11):**
- ✅ Expert Consilium v2.0: 13 experts, 92% consensus
- ✅ P0 Implementation: 100% complete
- 📋 Саммаризация: [link to session-summary-2026-02-11.md] (если есть)
```

### Артефакт (опционально):

`docs/sessions/session-summary-2026-02-11.md`:

```markdown
# 📊 Session Summary: Session #20

**Дата:** 2026-02-11
**Фокус:** Expert Consilium v2 + P0 Implementation

## ✅ Achievements
- Expert Consilium v2.0 запущен (13 экспертов)
- P0 Implementation: 100% (10.5 часов работы)
- Quality gates: 8 blocking + 8 info
- GitOps automation + crontab backups

## 📁 Files Changed
- 7 commits
- 67 files changed
- +8485 lines added

## 🔧 Key Decisions
1. Layered defense для quality gates
2. Automated lesson extraction
3. Daily/weekly/monthly backup strategy

## 🐛 Issues
- Token budget превышен на некоторых P1 файлах
- 3 shell syntax errors в скриптах

## 📈 Next Steps
1. Fix token budgets (P1)
2. Phase 11: OpenClaw Orchestrator
3. Phase 15: Agent Teams Integration

## 📚 Документы
- [Expert Consilium Report](../analysis/2026-02-11-openclaw-expert-consilium-report.md)
- [Implementation Plan](../analysis/2026-02-11-implementation-plan-variant-a.md)
```

---

## Workflow

### Input → Output:

```
User request "сделай саммери"
  ↓
1. Прочитать SESSION.md
2. Прочитать archive последней сессии
3. Собрать данные (TASKS.md, git log, память)
4. Создать саммаризацию
5. Обновить SESSION.md
6. Создать артефакт (если нужно)
  ↓
Отчёт готов
```

---

## Validation

✅ **Проверки перед завершением:**
- [ ] SESSION.md обновлён
- [ ] Archive создан/обновлён
- [ ] Ссылки обновлены (SESSION.md ↔ Archive ↔ INDEX.md)
- [ ] Git commit сделан

---

**Версия:** 1.0
**Статус:** ACTIVE
**Связано:** [@ref: instructions/session-init.md](session-init.md), [@ref: instructions/session-closure.md](session-closure.md)
