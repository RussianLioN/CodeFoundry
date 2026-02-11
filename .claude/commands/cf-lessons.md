# Command: /cf-lessons

> **Lessons Learned Management** — View and manage extracted lessons

## Description

Показывает уроки, извлечённые из повторяющихся ошибок. Когда ошибка происходит 3+ раз, система автоматически:

1. Извлекает урок в LESSONS.md
2. Создаёт валидатор
3. Предлагает автоматизацию

## Usage

```
/cf-lessons
```

## Examples

**Показать все уроки:**
```
/cf-lessons
```

**Показать статистику:**
```bash
make lessons-stats
```

**Зарегистрировать новую ошибку:**
```bash
make lessons-log TYPE=token_exceeded LOC=CLAUDE.md
```

## Related Commands

- `/cf-health` — Full health check including lessons
- `/cf-optimize` — Token optimization based on lessons
- `/cf-agents` — Agent workflow improvements

## Files

- `LESSONS.md` — Auto-generated knowledge base
- `scripts/lesson-learned-tracker.py` — Core tracking system
- `.tracking/error_log.json` — Error occurrence log
