# 🤖 Руководство по созданию AI-агентов для Claude Code CLI

> 🏠 [Главная](../README.md) → [📚 Документация](index.md) → **🤖 Создание агентов**

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
**Status:** 🟢 ACTUAL (ЕДИНОГЛАСНЫЙ КОНСЕНСУС 13 экспертов)
**Confidence:** 9.2/10

---

## 📋 Содержание

- [Почему это важно](#почему-это-важно)
- [Структура документации агента](#структура-документации-агента)
- [Шаблон агента](#шаблон-агента)
- [Best Practices](#best-practices)
- [Чеклист создания](#чеклист-создания)

---

## 🎯 Почему это важно

### Проблема: "Всё в одном файле"

```
❌ Плохо (текущий подход для многих агентов):

.claude/agents/my-agent.md  # 450+ строк
├── Инструкции для AI
├── Документация для людей
├── Примеры использования
├── Troubleshooting
└── Installation guide

Проблемы:
- AI тратит токены на чтение лишней документации
- Люди видят смешанный контент
- Переносимость = копировать 450+ строк
- Поддержка = менять agent файл при обновлении docs
```

### Решение: Progressive Disclosure

```
✅ Хорошо (рекомендуется):

.claude/agents/
├── my-agent.md              # 150 строк — CORE для AI
├── my-agent.quick.md        # 50 строк — 5-minute setup
├── my-agent.usage.md        # 200 строк — полная документация
├── my-agent.trouble.md      # 100 строк — troubleshooting
├── my-agent.examples.md     # 100 строк — примеры
└── my-agent.changelog.md    # 50 строк — история версий

Преимущества:
- ✅ AI получает только инструкции (экономия токенов)
- ✅ Люди получают отдельную документацию
- ✅ Переносимость: копируешь только core + quick
- ✅ Поддержка: docs независимы от agent
- ✅ Обнаруживаемость: quick start за 5 минут
```

---

## 📐 Структура документации агента

### Уровень 1: Core Agent (`.claude/agents/NAME.md`)

**Назначение:** Инструкции для AI + минимальная документация

**Размер:** 130-170 строк (максимум 200)

**Аудитория:** AI (Claude Code) + разработчики (краткая справка)

**Обязательная структура:**

```markdown
---
# YAML Frontmatter (machine-readable для IDE)
name: agent-name
version: 1.0.0
description: >
  One-line description of what agent does.

tools: [Read, Write, Bash, Grep, Glob]
model: inherit
category: automation|research|development|testing|documentation
tags: [tag1, tag2, tag3]

requires:
  - tool-name >= version
  - another-tool

documentation:
  quick: agents/NAME.quick.md
  usage: agents/NAME.usage.md
  troubleshooting: agents/NAME.trouble.md
  examples: agents/NAME.examples.md
  changelog: agents/NAME.changelog.md

repository: https://github.com/org/repo
author: Your Name
license: MIT
---

# CORE PROMPT (AI-readable)

## Role (2-3 sentences)
You are a [specialization] responsible for [main tasks].

## Critical Rules (MUST FOLLOW)
1. **Safety first:** Always [precaution]
2. **Validation:** Always [check] before [action]
3. **Error handling:** On error, [recovery strategy]

## Algorithm (step-by-step)
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Commands Reference
| Command | Description | Example |
|---------|-------------|---------|
| /agent-cmd | One-line desc | /agent-cmd --flag |
| /another | Another desc | /another |

## Input/Output Format
**Input:** [What agent expects]
**Output:** [What agent produces]

## Error Handling
- Error 1: [recovery]
- Error 2: [recovery]

## @see-also
- [Quick Start](agents/NAME.quick.md) — 5-minute setup
- [Full Usage](agents/NAME.usage.md) — Complete documentation
- [Troubleshooting](agents/NAME.trouble.md) — Common issues
- [Examples](agents/NAME.examples.md) — Usage examples

---
*Version: {version} | Last updated: {date} | @see [changelog](agents/NAME.changelog.md)*
```

### Уровень 2: Quick Start (`agents/NAME.quick.md`)

**Назначение:** Начать работу за 5 минут

**Размер:** 30-50 строк

**Аудитория:** Новые пользователи

**Обязательная структура:**

```markdown
# {Agent Name} — Quick Start

> Get started in 5 minutes

## Prerequisites

- [ ] Tool 1 installed: `command --version`
- [ ] Tool 2 installed: `command --version`
- [ ] File X exists: `ls file`

## 3 Steps to Start

### 1. Configure
```bash
cp config.example.yaml config.yaml
nano config.yaml
```

### 2. Test (dry-run)
```bash
/agent-name --dry-run
```

### 3. Run
```bash
/agent-name --action
```

## Verify

```bash
# Should see:
✓ Success message
```

## Next Steps

- [Full Usage](NAME.usage.md) — All options
- [Examples](NAME.examples.md) — Common workflows

---
*Need help? Check [Troubleshooting](NAME.troubleshooting.md)*
```

### Уровень 3: Full Usage (`agents/NAME.usage.md`)

**Назначение:** Полная документация всех сценариев

**Размер:** 150-250 строк

**Аудитория:** Пользователи, интегрирующие агент

**Обязательная структура:**

```markdown
# {Agent Name} — Full Usage Guide

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Commands](#commands)
5. [Workflows](#workflows)
6. [Integration](#integration)

## Overview
[What agent does, use cases, architecture]

## Installation
### Step 1: Install dependencies
### Step 2: Configure
### Step 3: Verify

## Configuration
[All config options]

## Commands
### Command 1
**Description:** [What it does]
**Usage:** `/agent-cmd [options]`
**Options:** [All flags]
**Example:** [Concrete example]
**Output:** [Expected output]

### Command 2
[...]

## Workflows
### Workflow 1: Common task
**Goal:** [What you achieve]
**Steps:**
1. Command 1
2. Command 2
3. Command 3

### Workflow 2: [Another task]
[...]

## Integration
### With Git
[Hooks, commit messages]

### With CI/CD
[Pipeline integration]

### With other agents
[Agent composition]

---
*Back to [Quick Start](NAME.quick.md) | [Troubleshooting](NAME.trouble.md)*
```

### Уровень 4: Troubleshooting (`agents/NAME.trouble.md`)

**Назначение:** Решение проблем

**Размер:** 80-120 строк

**Аудитория:** Пользователи с проблемами

**Обязательная структура:**

```markdown
# {Agent Name} — Troubleshooting

## Quick Diagnostics

```bash
# Run diagnostics
/agent-name --diagnose

# Check logs
tail -f logs/agent.log
```

## Common Issues

### Issue: "Error message"
**Symptoms:** [What you see]
**Cause:** [Why it happens]
**Solution:**
```bash
# Step 1
command
# Step 2
command
```
**Prevention:** [How to avoid]

### Issue: "Another error"
[...]

## Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| E001 | Description | Fix |
| E002 | Description | Fix |

## Getting Help

1. Check [Full Usage](NAME.usage.md)
2. Search [Issues](link to GitHub issues)
3. Create [New Issue](link to new issue)

## Recovery

If everything fails:
```bash
# Restore from backup
cp backup.file original.file
```

---
*Still stuck? [Open an issue](link)*
```

### Уровень 5: Examples (`agents/NAME.examples.md`)

**Назначение:** Конкретные примеры использования

**Размер:** 100-150 строк

**Аудитория:** Пользователи, изучающие агент

**Обязательная структура:**

```markdown
# {Agent Name} — Usage Examples

## Example 1: Basic Usage

**Scenario:** First time using agent

```
User: /agent-name start

Agent: Found 10 tasks. Process? (y/n)
User: y

Agent: ✓ Processed 10 tasks
       ✓ Created output
```

## Example 2: With Options

**Scenario:** Using flags

```
User: /agent-name start --verbose --dry-run

Agent: [DRY RUN] Would process 10 tasks
       [DRY RUN] Would create output
```

## Example 3: Error Recovery

**Scenario:** Handling errors

```
User: /agent-name start

Agent: ✗ Error: missing config

User: /agent-name init

Agent: ✓ Created config file
       ✓ Ready to start
```

## Example 4: Integration

**Scenario:** Using with other tools

```bash
# With git
git commit -m "feat: done" && /agent-name sync

# With make
make sync-agents
```

---
*See [Full Usage](NAME.usage.md) for all options*
```

### Уровень 6: Changelog (`agents/NAME.changelog.md`)

**Назначение:** История версий

**Размер:** 50-100 строк

**Обязательная структура:**

```markdown
# Changelog — {Agent Name}

All notable changes to this agent will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- TBA

### Changed
- TBA

### Deprecated
- TBA

### Removed
- TBA

### Fixed
- TBA

### Security
- TBA

## [1.0.0] - 2025-02-03

### Added
- Initial release
- Core sync functionality
- Dry-run mode
- Automatic backup

---
*If you need help, check [Troubleshooting](NAME.trouble.md)*
```

---

## 🎨 Шаблон агента

### Полный шаблон для копирования:

```markdown
---
name: agent-name
version: 1.0.0
description: >
  One-line description of what agent does.

tools: [Read, Write, Bash]
model: inherit
category: automation
tags: [automation, sync, git]

requires:
  - tool-name >= version

documentation:
  quick: docs/agents/agent-name.quick.md
  usage: docs/agents/agent-name.usage.md
  troubleshooting: docs/agents/agent-name.trouble.md
  examples: docs/agents/agent-name.examples.md
  changelog: docs/agents/agent-name.changelog.md

repository: https://github.com/org/repo
author: Your Name <email@example.com>
license: MIT
---

# Role

You are a [specialization] responsible for [main tasks].

## Critical Rules (MUST FOLLOW)

1. **Safety first:** Always [precaution]
2. **Validation:** Always [check] before [action]
3. **Error handling:** On error, [recovery strategy]

## Algorithm

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| /agent-cmd | One-line desc | /agent-cmd --flag |
| /another | Another desc | /another |

## Input/Output Format

**Input:** [What agent expects]

**Output:** [What agent produces]

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| Error 1 | [Cause] | [Solution] |
| Error 2 | [Cause] | [Solution] |

## @see-also

- [Quick Start](docs/agents/agent-name.quick.md) — 5-minute setup
- [Full Usage](docs/agents/agent-name.usage.md) — Complete documentation
- [Troubleshooting](docs/agents/agent-name.trouble.md) — Common issues
- [Examples](docs/agents/agent-name.examples.md) — Usage examples
- [Changelog](docs/agents/agent-name.changelog.md) — Version history

---
*Version: 1.0.0 | Last updated: 2025-02-03*
```

---

## 📚 Best Practices

### 1. Минимизация зависимостей

```yaml
# ❌ Плохо: много зависимостей
requires:
  - python >= 3.11
  - gh-cli >= 2.0
  - docker >= 20.0
  - make
  - jq
  - custom-tool

# ✅ Хорошо: минимальные зависимости
requires:
  - python >= 3.9
  - gh-cli # optional (warn if missing)
```

### 2. Проект-agnostic дизайн

```markdown
# ❌ Плохо: жестко привязан к проекту
## Role
You are a CodeFoundry specialist for remote server infrastructure...

# ✅ Хорошо: переиспользуемый
## Role
You are a TASKS.md to GitHub Issues synchronization specialist.
Works with any project using TASKS.md format.
```

### 3. Конфигурация через переменные

```python
# ❌ Плохо: хардкод
REPO_PATH = "/Users/s060874gmail.com/coding/projects/system-prompts"

# ✅ Хорошо: конфигурируемо
REPO_PATH = os.environ.get("TASKS_SYNC_REPO", ".")
TASKS_FILE = os.environ.get("TASKS_SYNC_FILE", "TASKS.md")
```

### 4. Валидация окружения

```markdown
## Environment Check

Before running, verify:
```bash
# Check required tools
gh --version
python --version

# Check files exist
ls TASKS.md

# If any check fails, run:
/agent-name doctor
```
```

### 5. Хлебные крошки (Breadcrumb navigation)

```markdown
# В каждом файле документации:

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📙 {Agent Name}**

# В конце каждого файла:

---
*← [Back to Agents Index](index.md) | [Quick Start](agent-name.quick.md) →*
```

---

## ✅ Чеклист создания агента

### Phase 1: Planning

- [ ] Define agent purpose (1 sentence)
- [ ] Identify target audience (AI, humans, both?)
- [ ] List required tools (Read, Write, Bash, etc.)
- [ ] Identify dependencies (external tools)
- [ ] Define input/output format
- [ ] Plan error handling strategy

### Phase 2: Core Agent

- [ ] Create `.claude/agents/NAME.md`
- [ ] Add YAML frontmatter (metadata)
- [ ] Write Role (2-3 sentences)
- [ ] List Critical Rules (3-7 items)
- [ ] Document Algorithm (step-by-step)
- [ ] Create Commands Reference table
- [ ] Add Error Handling section
- [ ] Add @see-also links to docs
- [ ] Keep under 200 lines!

### Phase 3: Documentation

- [ ] Create `docs/agents/NAME.quick.md` (30-50 lines)
- [ ] Create `docs/agents/NAME.usage.md` (150-250 lines)
- [ ] Create `docs/agents/NAME.trouble.md` (80-120 lines)
- [ ] Create `docs/agents/NAME.examples.md` (100-150 lines)
- [ ] Create `docs/agents/NAME.changelog.md` (50-100 lines)
- [ ] Add breadcrumb navigation to all files
- [ ] Add cross-links between files

### Phase 4: Integration

- [ ] Update `.claude/AGENTS.md` (index of all agents)
- [ ] Update `CLAUDE.md` (if agent is important)
- [ ] Add agent to `README.md` (if user-facing)
- [ ] Test agent discovery: can user find in 3 clicks?

### Phase 5: Testing

- [ ] Test agent in dry-run mode
- [ ] Test error handling
- [ ] Test all commands
- [ ] Verify documentation accuracy
- [ ] Test portability (copy to another project)

---

## 🔗 Related Documents

- [Claude Code Official Docs](https://code.claude.com/docs/en/sub-agents) — Официальная документация
- [agents.md](../../.claude/AGENTS.md) — Индекс агентов проекта
- [CLAUDE.md](../../CLAUDE.md) — Центральный hub файла

---

## 📖 Примеры агентов в этом проекте

- [tasks-sync](../../.claude/agents/tasks-sync.md) — TASKS.md ↔ GitHub Issues sync
- [ollama-gemini-researcher](../../.claude/agents/ollama-gemini-researcher.md) — Ollama + Gemini research
- [project-initializer](../../openclaw/workspace/agents/project-initializer.md) — Project initialization

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
**Next Review:** После создания 3-5 агентов по этому шаблону

---

*Этот документ основан на консенсусе 13 экспертов: Solution Architect, DevOps Engineer, GitOps Specialist, IaC Expert, SRE, AI IDE Expert, Prompt Engineer, TDD Expert, UAT Engineer, и др.*
