# Session #18 - Expert Consilium v2.0 + Claude Code Skills Lessons

> [Sessions Archive](./) → **Session #18**

> **Дата:** 2026-02-10
> **Длительность:** ~2 часа
> **Прогресс:** Expert Consilium v2.0 production ready
> **Коммиты:** TBD

---

## 📊 Executive Summary

| Метрика | Значение |
|---------|----------|
| **Коммитов** | 0 (изменения в staging) |
| **Файлов изменено** | ~10 файлов |
| **Экспертов** | 13 (v1.2.0) → 4 domains (v2.0) |
| **Token budget** | ~13K (v1.2.0) → ~81K (v2.0) |
| **Agent Teams** | ❌ → ✅ |
| **Multi-round debates** | ❌ → ✅ |

---

## 🎯 Достигнуто

### 1. Expert Consilium v2.0 Implemented ✅

**Архитектура:**
- **Agent Teams** вместо subagents
- **Multi-round debates:** Cross-examination → Adversarial → Red team
- **Position evolution tracking**
- **Inter-agent messaging via `SendMessage`**

**Expert Domains:**
| Domain | Experts | Focus |
|--------|---------|-------|
| Infrastructure (5) | Docker, Unix, IaC, Backup, SRE | Container architecture |
| Delivery (3) | DevOps, CI/CD, GitOps | Automation, pipelines |
| Quality (2) | TDD, UAT | Testing, UX validation |
| AI (2) | AI IDE, Prompt Engineer | Token efficiency |
| Solution Architect (1, 1.5x) | — | Final synthesis |

**Тестирование:**
- Test 1: MAKE (confidence: 0.83, STRONG_MAJORITY)
- Test 2: MAKE (confidence: 0.85, STRONG_MAJORITY)
- **Воспроизводимость подтверждена!** (Δ = 0.02)

---

### 2. Claude Code Skills vs Commands Lessons ✅

**Проблема:** `/expert-consilium-v2` не появлялся в autocomplete

**Корневые причины найдены:**

| Проблема | Решение |
|----------|---------|
| Skills как файлы, не директории | `skills/name/SKILL.md` (директория) |
| Нет YAML frontmatter | Добавлен `name`, `description` |
| Дублирование: Skills + Commands | Удалены `.claude/skills/expert-consilium*` |
| Неправильный shutdown | Убран `type="shutdown_request"` |
| TaskOutput с числовыми ID | Исправлен на строковые |
| Write без Read | Добавлен Read перед Write |

**Документация:** [@ref: docs/lessons/claude-code-skills-vs-commands.md](../../docs/lessons/claude-code-skills-vs-commands.md)

---

## 🚨 Извлечённые уроки — 6 системных ошибок

### Урок #1: Skills должны быть в директориях

**❌ ПЛОХО:**
```
.claude/skills/expert-consilium.md  (файл)
```

**✅ ХОРОШО:**
```
.claude/skills/expert-consilium/SKILL.md  (директория)
```

---

### Урок #2: YAML frontmatter обязателен для Skills

**❌ ПЛОХО:**
```markdown
# Skill: Expert Consilium v2.0
...
```

**✅ ХОРОШО:**
```markdown
---
name: expert-consilium-v2
description: Multi-round debate system...
---

# Skill: Expert Consilium v2.0
...
```

---

### Урок #3: Не создавайте Skill + Command с одинаковым именем

**❌ ПЛОХО:**
```
.claude/
├── commands/expert-consilium.md      → /expert-consilium
└── skills/expert-consilium/SKILL.md  → /expert-consilium (ДУБЛЬ!)
```

**Результат в `/exp`:**
```
  /expert-consilium        Expert Consilium with 13 virtual experts...
  /expert-consilium        Command: /expert-consilium  ← ДУБЛЬ!
```

**✅ ХОРОШО:**
```
.claude/
├── commands/expert-consilium.md      → /expert-consilium ✅
└── agents/expert-consilium.md        (reference)
```

---

### Урок #4: SendMessage shutdown

**❌ ПЛОХО:**
```python
SendMessage(
    type="shutdown_request",  # InputValidationError!
    recipient="teammate",
    content="..."
)
```

**✅ ХОРОШО:**
```python
SendMessage(
    recipient="teammate",
    content="Analysis complete. You may shutdown now."
)
```

---

### Урок #5: TaskOutput ID type

**❌ ПЛОХО:**
```python
TaskOutput(task_id=9)  # Task IDs are strings!
```

**✅ ХОРОШО:**
```python
TaskOutput(task_id="1")  # String ID
```

---

### Урок #6: Write требует Read

**❌ ПЛОХО:**
```python
Write(file_path="docs/report.md", content="...")
```

**✅ ХОРОШО:**
```python
Read(file_path="docs/report.md")
Write(file_path="docs/report.md", content="...")
```

---

## 📚 Справочник: Skills vs Commands

| Характеристика | **Commands** (`.claude/commands/`) | **Skills** (`.claude/skills/`) |
|----------------|-----------------------------------|-------------------------------|
| **Формат** | Файл: `command-name.md` | Директория: `command-name/SKILL.md` |
| **Создаёт** | `/command-name` | Auto-discovered capability |
| **Когда использовать** | Явные команды `/...` | Claude решает когда применить |
| **YAML frontmatter** | Опционально | Обязательно |
| **user-invocable** | N/A (всегда true) | Может быть `false` |

---

## ✅ Финальная Структура

```
.claude/
├── commands/
│   ├── expert-consilium.md         → /expert-consilium ✅
│   └── expert-consilium-v2.md      → /expert-consilium-v2 ✅
├── agents/
│   ├── expert-consilium.md         (agent v1.2.0)
│   └── expert-consilium-v2.md      (agent v2.0)
└── schemas/
    └── auto-routing-rules.schema.json (enum обновлён)
```

---

## 🎯 Decision Tree

```
Нужна новая capability?
│
├─ Пользователь вводит `/command`?
│  └─ ДА → .claude/commands/command-name.md
│
├─ Claude должен применять автоматически?
│  └─ ДА → .claude/skills/skill-name/SKILL.md
│
└─ Специализированный subagent?
   └─ ДА → .claude/agents/agent-name.md
```

---

## 📖 Полезные Ресурсы

- **Официальная документация:** [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- **Alex Op's Guide:** [CLAUDE.md, Slash Commands, Skills, and Subagents](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- **Lessons Learned:** [@ref: docs/lessons/claude-code-skills-vs-commands.md](../../docs/lessons/claude-code-skills-vs-commands.md)

---

## 🎓 Ключевые выводы

### Что сработало хорошо:
1. **Официальная документация** — нашёл решение через web-search
2. **Структурированный подход** — Lessons Learned документ создан
3. **Cross-references** — CLAUDE.md и SESSION.md обновлены

### Что нужно улучшить:
1. **Больше тестов сразу** — первое "решение" было неправильным
2. **Читать документацию раньше** — сэкономило бы ~1 час

### Процесс улучшен:
- ❌ "Предположим как работает" → ✅ "Прочитаем официальную документацию"
- ❌ "Пробуем разные варианты" → ✅ "Следуем patterns из документации"

---

> [Archive #14-17](sessions-17.md) | [↑ Sessions index](../index.md)
