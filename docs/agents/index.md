# 🤖 Индекс агентов CodeFoundry

> 🏠 [Главная](../README.md) → [📚 Документация](index.md) → **🤖 Агенты**

---

**Last Updated:** 2025-02-03

---

## 📋 Содержание

- [Что такое агенты](#что-такое-агенты)
- [Агенты проекта](#агенты-проекта)
- [Создание новых агентов](#создание-новых-агентов)
- [Best Practices](#best-practices)

---

## 🎯 Что такое агенты?

AI-агенты (sub-agents) — это специализированные AI-ассистенты для конкретных задач. Они вызываются из Claude Code CLI через `/agent <name>` команду.

**Преимущества:**
- 🎯 Специализация на конкретной задаче
- 🔄 Переиспользуемость между проектами
- 📦 Модульность (комбинируй агенты)
- 🚀 Оптимизация токенов (загружай только нужное)

---

## 📦 Агенты проекта

### Активные агенты

| Агент | Описание | Категория | Документация |
|-------|----------|-----------|--------------|
| **tasks-sync** | TASKS.md ↔ GitHub Issues sync | automation | [Core](../../.claude/agents/tasks-sync.md) \| [Quick](tasks-sync.quick.md) \| [Usage](tasks-sync.usage.md) |
| **ollama-gemini-researcher** | Ollama + gemini-3-flash-preview research | research | [Core](../../.claude/agents/ollama-gemini-researcher.md) |
| **token-optimizer** | Token usage auditor & optimizer | automation | [Core](../../.claude/agents/token-optimizer.md) \| [Quick](token-optimizer.quick.md) \| [Usage](token-optimizer.usage.md) |
| **project-initializer** | Project initialization & scaffolding | development | [Core](../../openclaw/workspace/agents/project-initializer.md) |
| **agent-teams** | Agent Teams functionality (Opus 4.6) | development | [Full](agent-teams.md) \| [Quick](agent-teams.quick.md) |

### Планируемые агенты

| Агент | Описание | Статус | Приоритет |
|-------|----------|--------|-----------|
| **docs-generator** | Автоматическая генерация документации | ⏳ Planned | Medium |
| **test-runner** | Запуск и анализ тестов | ⏳ Planned | High |
| **code-reviewer** | Автоматический code review | ⏳ Planned | Medium |

---

## 🛠️ Создание новых агентов

**ОБЯЗАТЕЛЬНО ПРОЧИТАЙТЕ:** [AGENT-CREATION-GUIDE.md](AGENT-CREATION-GUIDE.md)

Это руководство основано на консенсусе 13 экспертов и содержит:
- ✅ Структуру документации (6 уровней)
- ✅ Шаблон агента
- ✅ Best Practices
- ✅ Чеклист создания

**Краткая версия:**

1. **Core agent** (`.claude/agents/NAME.md`) — 150 строк max
2. **Quick start** (`docs/agents/NAME.quick.md`) — 50 строк
3. **Full usage** (`docs/agents/NAME.usage.md`) — 200 строк
4. **Troubleshooting** (`docs/agents/NAME.trouble.md`) — 100 строк
5. **Examples** (`docs/agents/NAME.examples.md`) — 100 строк
6. **Changelog** (`docs/agents/NAME.changelog.md`) — 50 строк

---

## 📚 Best Practices

### 1. Progressive Disclosure

```
Core Agent (AI)
    ↓
Quick Start (5 minutes)
    ↓
Full Usage (complete docs)
    ↓
Troubleshooting (when problems)
```

### 2. Audience Separation

- **YAML frontmatter** → Для IDE (маршрутизация)
- **Instructions** → Для AI (как выполнять)
- **Documentation** → Для людей (как использовать)

### 3. Cross-link Navigation

Каждый файл должен иметь:
- 🍞 Хлебные крошки (вверху)
- 🔗 Cross-links (внизу)

```markdown
> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📙 {Agent Name}**

---

*← [Back to Agents Index](index.md) | [Quick Start](agent-name.quick.md) →*
```

### 4. Обнаруживаемость (3 clicks rule)

Любой агент должен быть найден за 3 клика:
1. CLAUDE.md (central hub)
2. AGENTS.md или docs/agents/index.md
3. Агент или его документация

---

## 🔗 Related Documents

- [AGENT-CREATION-GUIDE.md](AGENT-CREATION-GUIDE.md) — Полное руководство по созданию
- [Claude Code Official Docs](https://code.claude.com/docs/en/sub-agents) — Официальная документация
- [CLAUDE.md](../../CLAUDE.md) — Центральный hub проекта

---

**Last Updated:** 2025-02-03
**Maintained by:** CodeFoundry Team
