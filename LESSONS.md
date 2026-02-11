# Lessons Learned

> Автоматически извлечённые уроки из повторяющихся ошибок.
>
> Когда ошибка происходит 3+ раз, система автоматически:
> 1. Извлекает урок
> 2. Документирует здесь
> 3. Создаёт валидатор
> 4. Предлагает автоматизацию

---

## Как это работает

```
Ошибка происходит → Логируется в .tracking/error_log.json
                     ↓
                  Счётчик +1
                     ↓
          Если >= 3 → Авто-извлечение урока
                     ↓
          Добавляется в LESSONS.md
          Создаётся валидатор
          Обновляется документация
```

---

## Поиск уроков

**По ошибке:**
```bash
# Найти уроки по типу ошибки
grep "invalid_json" LESSONS.md

# Найти уроки по файлу
grep "settings.local.json" LESSONS.md
```

**По команде:**
```bash
# Показать все уроки
less LESSONS.md

# Показать статистику
python3 scripts/lesson-learned-tracker.py stats
```

---

## Автоматизация

```bash
# Зарегистрировать ошибку (обычно вызывается автоматически)
python3 scripts/lesson-learned-tracker.py log \
  --type "invalid_json" \
  --location ".claude/settings.local.json" \
  --context '{"pattern": "heredoc"}'

# Извлечь уроки для повторяющихся ошибок
python3 scripts/lesson-learned-tracker.py extract

# Показать статистику
python3 scripts/lesson-learned-tracker.py stats
```

---

## Уроки

*(Автоматически добавляется при достижении порога 3+ повторений)*

---

**Generated:** 2026-02-11
**System:** Lesson Learned Tracker v1.0

## invalid_json_settings

**Location:** `.claude/settings.local.json`
**Occurrences:** 3 (since 2026-02-11)
**Pattern:** `Patterns: heredoc in permissions`

### Lesson

Repeated error 'invalid_json_settings' at .claude/settings.local.json (3 occurrences). Pattern: Patterns: heredoc in permissions

### Prevention

- Add validation check for this error type
- Create automated test case
- Update CLAUDE.md with prevention instructions

### Automation

- `Create scripts/fix-invalid_json_settings.py`
- `Add to quality gates`

---

*Auto-extracted: 2026-02-11*
