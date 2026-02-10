# Phase 14: Housekeeping + Documentation Agent MVP

> **Статус:** ЗАПЛАНИРОВАНО
> **Приоритет:** 🔴 P0-BLOCKING (следующая задача)
> **Дата создания:** 2026-02-09
> **Ожидаемое сокращение:** TASKS.md -73%, SESSION.md обновлён

---

## Контекст

- TASKS.md — 1784 строки (~18,500 токенов), из них 10 из 13 фаз завершены на 100%
- SESSION.md — отстаёт на 3 сессии (#14-16 не отражены)
- Архивный паттерн для `sessions/` уже работает (`sessions/archive/`), нужно применить к `tasks/`
- Phase 9 (Documentation Agent) — ~40% уже существует (template, quality gates, check-refs.py), нужен MVP

---

## Часть A: Housekeeping (10 шагов)

### A1. Создать структуру `tasks/`

```
tasks/
  index.md           # навигация по задачам
  archive/
    README.md        # правила архивации
    phases-01-10.md  # завершённые фазы
```

### A2. Создать `tasks/archive/phases-01-10.md` (~700 строк)

Перенести из TASKS.md все завершённые на 100% фазы:
- Phase 1: Реструктуризация
- Phase 2: OpenClaw Integration
- Phase 3: Project Templates
- Phase 4: DevOps Инфраструктура
- Phase 5: Observability
- Phase 6: Automation
- Phase 7: Agent Inheritance
- Phase 8: AI-First Interface
- Phase 10: Remote Testing Infra
- Phase 13: Orchestrator Profiles

**Формат:** сохранить полное содержимое каждой фазы как есть (для истории).

### A3. Создать `tasks/archive/README.md` (~30 строк)

```markdown
# Архив задач

Завершённые фазы перемещены сюда для уменьшения токенов в TASKS.md.

## Файлы
| Файл | Содержимое |
|------|-----------|
| phases-01-10.md | Фазы 1-10,13 (завершены 100%) |

## Правила архивации
1. Фаза архивируется когда достигает 100%
2. Формат сохраняется как есть
3. TASKS.md ссылается на архив через @ref
```

### A4. Создать `tasks/index.md` (~45 строк)

```markdown
# Навигация по задачам

## Активные
- [TASKS.md](../TASKS.md) — текущие задачи

## Архив
- [tasks/archive/](archive/) — завершённые фазы
```

### A5. Переписать `TASKS.md` (~480 строк, -73%)

**Оставить:**
- Шапку и сводку прогресса (обновлённую)
- Phase 8.5: Telegram Bot (25%)
- Phase 9: Documentation Agent (обновить до "MVP in progress")
- Phase 11: Orchestrator Architecture (75%)
- Phase 12: Documentation Review (0%)
- Phase 14: Housekeeping + Doc Agent MVP (NEW)
- Легенду статусов

**Убрать:**
- Все завершённые фазы → `@ref: tasks/archive/phases-01-10.md`
- Фаза 13 (100%) → архив

### A6. Создать `sessions/archive/sessions-12-13.md` (~80 строк)

Перенести сессии #12-13 из SESSION.md в архив.

### A7. Переписать `SESSION.md` (~100 строк)

**Содержимое:**
- Current Context → Session #16
- Session #16 (текущая, 2026-02-09): Housekeeping + Doc Agent MVP plan
- Session #15 (2026-02-06): Phase 12-13 Quality Gates, Skills, Orchestrator Profiles
- Session #14 (2026-02-06): Configuration Drift Fix, Quality Gates framework
- Ссылки на архивы: sessions-01-11.md, sessions-12-13.md

### A8. Обновить `sessions/archive/README.md`

Добавить запись о `sessions-12-13.md`.

### A9. Обновить `sessions/index.md`

Добавить ссылку на `sessions-12-13.md`.

### A10. Обновить cross-references

Проверить и обновить ссылки в:
- `CLAUDE.md` (Quick Reference)
- `docs/INDEX.md`
- `docs/WORKFLOW-GUIDE.md`
- Любые другие файлы со ссылками на TASKS.md или SESSION.md

---

## Часть B: Documentation Agent MVP (6 шагов)

### B1. Создать `.claude/agents/documentation-agent.md` (~120 строк)

**Назначение:** Автоматический мониторинг и валидация документации.

**Capabilities:**
- Проверка @ref целостности
- Мониторинг token budget
- Обнаружение устаревшей документации (stale docs)
- Генерация отчётов о состоянии документации

**Triggers:**
- `doc-check` / `doc-review` / `documentation` в сообщении
- Запуск через `/cf-health --docs`

**Формат:** следовать паттерну из `AGENT-CREATION-GUIDE.md`.

### B2. Создать `scripts/validate-docs.sh` (~280 строк)

**Функции:**
1. **ref-check** — вызов `scripts/check-refs.py`
2. **stale-check** — файлы не обновлявшиеся > 30 дней с кодовыми изменениями
3. **orphan-check** — .md файлы без входящих ссылок
4. **token-check** — бюджеты токенов (делегация к quality-gates.sh)
5. **coverage-check** — каждый агент/скрипт имеет документацию
6. **report** — сводный отчёт в формате markdown

**Выход:** JSON + human-readable summary

### B3. Обновить `.claude/auto-routing-rules.json`

Добавить маршрут для `documentation-agent`:
```json
{
  "pattern": "doc-check|doc-review|documentation|validate docs|stale docs",
  "agent": "documentation-agent",
  "priority": 5
}
```

### B4. Обновить `.claude/schemas/auto-routing-rules.schema.json`

Добавить `documentation-agent` в enum агентов.

### B5. Обновить `Makefile`

Добавить цели:
```makefile
doc-check:     ## Validate documentation (refs, stale, orphans)
	bash scripts/validate-docs.sh --all

doc-report:    ## Generate documentation health report
	bash scripts/validate-docs.sh --report
```

### B6. Создать `.claude/skills/documentation-monitor.md` (~35 строк)

**Skill contract:**
- **Input:** mode (quick|full|report)
- **Output:** validation results + recommendations
- **Stateless:** да
- **Dependencies:** scripts/validate-docs.sh, scripts/check-refs.py

---

## Критерии завершения

### Часть A:
- [ ] `tasks/` структура создана
- [ ] TASKS.md < 500 строк
- [ ] SESSION.md актуален (session #16)
- [ ] Все cross-references валидны (`make gate-blocking` passes)

### Часть B:
- [ ] `documentation-agent.md` создан и следует AGENT-CREATION-GUIDE
- [ ] `validate-docs.sh` работает и проходит `bash -n`
- [ ] Routing rules обновлены и валидны
- [ ] `make doc-check` работает
- [ ] Quality gates проходят (`make gate-blocking`)

---

## Зависимости

- Часть A не зависит от Part B (можно делать параллельно)
- B3 зависит от B1 (агент должен существовать до маршрута)
- B5 зависит от B2 (скрипт должен существовать до Makefile target)

---

## Оценка объёма

| Часть | Файлов | Строк кода | Сложность |
|-------|--------|------------|-----------|
| A: Housekeeping | ~8 файлов | ~1400 строк | Низкая (перенос + рефакторинг) |
| B: Doc Agent MVP | ~5 файлов | ~500 строк | Средняя (новый код) |
| **Итого** | **~13 файлов** | **~1900 строк** | **Средняя** |
