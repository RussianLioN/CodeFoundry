# Documentation Monitor Skill

> **Stateless skill** для мониторинга документации
> **Dependencies:** scripts/validate-docs.py, scripts/check-refs.py
> **Input:** mode (quick|full|report)
> **Output:** validation results + recommendations

---

## Справка (Quick Reference)

### Запуск

```bash
# Quick check (refs only)
make doc-refs

# Full validation (all checks)
make doc-check

# Report only
make doc-report

# Individual checks
make doc-stale
make doc-orphans
make doc-tokens
make doc-coverage
```

### Direct Python

```bash
# All checks
python3 scripts/validate-docs.py --all

# Specific check
python3 scripts/validate-docs.py --ref-check
python3 scripts/validate-docs.py --stale-check --stale-days 60
```

---

## Проверки

| Check | Описание | Команда |
|-------|----------|---------|
| **ref-check** | @ref ссылки валидны | `make doc-refs` |
| **stale-check** | Файлы не обновлявшиеся >30 дней | `make doc-stale` |
| **orphan-check** | .md без входящих ссылок | `make doc-orphans` |
| **token-check** | Файлы в рамках токенов | `make doc-tokens` |
| **coverage** | Агенты/скрипты имеют доки | `make doc-coverage` |

---

## Выход

**0:** Все проверки прошли
**1:** Одна или более проверок не прошли

---

## Рекомендации по устранению проблем

### Broken @ref links
1. Найти файл с битой ссылкой: `scripts/check-refs.py`
2. Исправить путь или удалить битую ссылку
3. Или создать недостающий файл

### Stale documentation
1. Найти файлы: `make doc-stale`
2. Обновить содержимое или переместить в archive
3. Добавить changelog запись

### Orphaned files
1. Найти файлы: `make doc-orphans`
2. Добавить ссылку в INDEX.md или другой файл
3. Или удалить, если не нужен

### Token budget exceeded
1. Найти файл: `make doc-tokens` или `scripts/quality-gates.sh`
2. Разбить на меньшие файлы (@ref extraction)
3. Переместить содержимое в archive/

---

*Version: 1.0.0 | Phase 14: Documentation Agent MVP*
