# Claude Code: Skills vs Commands — Lessons Learned

> **Date:** 2026-02-10
> **Context:** Expert Consilium v2.0 implementation
> **Status:** ✅ Resolved with key insights

---

## 🎯 Краткий Вывод

**Правило золотое:** Для `/` команд используйте **только** `.claude/commands/<name>.md`

Skills (`.claude/skills/<name>/SKILL.md`) создавайте только для **auto-discovered capabilities**, не для slash команд.

---

## ❌ Допущенные Ошибки

### Ошибка 1: Skills как файлы, не директории

**Было:**
```
.claude/skills/expert-consilium.md  ← ФАЙЛ (неправильно!)
```

**Стало:**
```
.claude/skills/expert-consilium/SKILL.md  ← ДИРЕКТОРИЯ (правильно)
```

**Урок:** Skills всегда должны быть в **директориях** с файлом `SKILL.md` внутри.

**🚨 КРИТИЧЕСКИ:** Неправильная структура файлов в `.claude/skills/` ломает **ВСЕ** `/` команды!

**Было (ломает всё):**
```
.claude/skills/
├── agent-teams-parallel.md       ← ФАЙЛ (ломает / команды!)
├── agent-teams-safe-mode.md      ← ФАЙЛ (ломает / команды!)
└── ...
```

**Стало (работает):**
```
.claude/skills/
├── agent-teams-parallel/
│   └── SKILL.md                   ← ДИРЕКТОРИЯ ✅
├── agent-teams-safe-mode/
│   └── SKILL.md                   ← ДИРЕКТОРИЯ ✅
└── ...
```

**Симптомы:** `/` показывает пустой список или не показывает команды вообще.

---

### Ошибка 2: Отсутствие YAML frontmatter

**Было:**
```markdown
# Skill: Expert Consilium v2.0

## Contract
...
```

**Стало:**
```markdown
---
name: expert-consilium-v2
description: Multi-round debate system...
---

# Skill: Expert Consilium v2.0
...
```

**Урок:** YAML frontmatter обязателен для skills. Без него `name` берётся из имени директории, а `description` из первого параграфа.

---

### Ошибка 3: Дублирование — Skills + Commands

**Было:**
```
.claude/
├── commands/expert-consilium.md      → /expert-consilium
└── skills/expert-consilium/SKILL.md  → /expert-consilium (дубль!)
```

**Результат в `/exp`:**
```
  /expert-consilium        Expert Consilium with 13 virtual experts...
  /expert-consilium        Command: /expert-consilium  ← ДУБЛЬ!
```

**Стало:**
```
.claude/
├── commands/expert-consilium.md      → /expert-consilium ✅
└── agents/expert-consilium.md        (reference)
```

**Урок:** Не создавайте skill и command с одинаковым именем. Используйте **только** `.claude/commands/` для slash команд.

---

### Ошибка 4: Неправильный shutdown в SendMessage

**Было:**
```python
SendMessage(
    type="shutdown_request",  # ❌ Вызывало InputValidationError
    recipient="teammate",
    content="..."
)
```

**Стало:**
```python
SendMessage(
    recipient="teammate",
    content="Analysis complete. You may shutdown now."  # ✅ Правильно
)
```

**Урок:** Не используйте `type="shutdown_request"`. Просто отправьте сообщение о завершении.

---

### Ошибка 5: TaskOutput с неверными ID

**Было:**
```python
TaskOutput(task_id=9)  # ❌ Task IDs are strings!
```

**Стало:**
```python
TaskOutput(task_id="1")  # ✅ String ID
```

**Урок:** Task IDs всегда **строки**, даже если выглядят как числа.

---

### Ошибка 6: Write без Read

**Было:**
```python
Write(file_path="docs/report.md", content="...")  # ❌
```

**Стало:**
```python
Read(file_path="docs/report.md")  # ✅ Сначала читать
Write(file_path="docs/report.md", content="...")
```

**Урок:** Всегда вызывайте `Read()` перед `Write()` для существующих файлов.

---

## 📚 Справочник: Skills vs Commands

| Характеристика | **Commands** (`.claude/commands/`) | **Skills** (`.claude/skills/`) |
|----------------|-----------------------------------|-------------------------------|
| **Формат** | Файл: `command-name.md` | Директория: `command-name/SKILL.md` |
| **Создаёт** | `/command-name` | Auto-discovered capability |
| **Когда использовать** | Явные команды пользователя | Claude решает когда применить |
| **YAML frontmatter** | Опционально | Обязательно |
| **Описание** | Из documentation | Из `description` field |
| **user-invocable** | N/A (всегда true) | Может быть `false` |

---

## ✅ Правильная Структура

### Для Slash Commands (`/command`):

```
.claude/
└── commands/
    └── my-command.md  # Содержит документацию команды
```

### Для Auto-Discovered Skills:

```
.claude/
└── skills/
    └── my-skill/
        ├── SKILL.md              # Основное определение (с YAML)
        ├── reference.md          # Дополнительная документация
        └── scripts/
            └── helper.py         # Вспомогательные скрипты
```

### Для Agents (специализированные subagents):

```
.claude/
└── agents/
    └── my-agent.md  # Определение агента с YAML frontmatter
```

---

## 🔧 YAML Frontmatter Reference

### Для Skills (`SKILL.md`):

```yaml
---
name: my-skill                    # Опционально (из директории если нет)
description: What this skill does # Рекомендуется
user-invocable: false             # Скрывает из `/` меню
disable-model-invocation: true    # Только ручной запуск
allowed-tools: Read, Grep         # Разрешённые инструменты
model: sonnet                     # Модель для этого skill
context: fork                     # Запустить в subagent
agent: Explore                    # Тип subagent
---
```

### Для Agents (`agent.md`):

```yaml
---
name: my-agent
version: 1.0.0
description: Agent description
model: sonnet
tools: [Task, Read, Write, Bash]
category: analysis
tags: [expert, specialized]
---
```

---

## 🎯 Decision Tree

```
Нужна новая capability?
│
├─ Пользователь вводит `/command`?
│  └─ ДА → Создайте .claude/commands/command-name.md
│
├─ Claude должен применять автоматически?
│  └─ ДА → Создайте .claude/skills/skill-name/SKILL.md
│
└─ Специализированный subagent?
   └─ ДА → Создайте .claude/agents/agent-name.md
```

---

## 📖 Полезные Ресурсы

- **Официальная документация:** [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- **Alex Op's Guide:** [CLAUDE.md, Slash Commands, Skills, and Subagents](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- **Agent Skills Open Standard:** [GitHub Repository](https://github.com/anthropics/agent-skills)

---

## 📝 Changelog

### v1.1.0 (2026-02-10)

**🚨 КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ:** Добавлено предупреждение о ломающей структуре

- **Проблема:** `.claude/skills/*.md` файлы (не в директориях) ломают **ВСЕ** `/` команды
- **Симптомы:** `/` показывает пустой список, slash commands не работают
- **Решение:** Все skill файлы должны быть в директориях `<name>/SKILL.md`
- **Миграция:** `mv skills/file.md skills/file/SKILL.md`

**Исправлено:**
```bash
# Было (ломает всё):
.claude/skills/agent-teams-parallel.md

# Стало (работает):
.claude/skills/agent-teams-parallel/SKILL.md
```

---

**Version:** 1.1.0
**Last Updated:** 2026-02-10
**Status:** ✅ Production Ready
**Changes:** Критическое предупреждение о структуре skills
