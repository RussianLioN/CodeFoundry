# 🎨 IDE Support

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../../README.md) → [🎯 Workspace](../README.md) → [🎨 IDE Support](#)

---

## Description

OpenClaw поддерживает интеграцию с популярными AI IDE и редакторами кода. Вы можете использовать один и тот же набор системных промптов и инструкций в разных IDE.

---

## 🎯 Поддерживаемые IDE

| IDE | Статус | Файл | Особенности |
|-----|--------|------|-------------|
| **Claude Code** | ✅ Полная | [claude/README.md](claude/README.md) | Native Claude интеграция, CLI |
| **Cursor** | ✅ Полная | [cursor/README.md](cursor/README.md) | Файл `.cursorrules`, AI команды |
| **Qoder** | ✅ Полная | [qoder/README.md](qoder/README.md) | Папка `.qoder/rules/` |
| **QWEN Code** | ✅ Полная | [qwen/README.md](qwen/README.md) | Файл `QWEN.md` |
| **VS Code + Cline** | ✅ Полная | [vscode/README.md](vscode/README.md) | Файл `.clinerules` |

---

## 🔄 Как Это Работает

```
┌─────────────────────────────────────────────────────┐
│                  Единственный источник               │
│              /openclaw/workspace/                     │
│                  ├── SYSTEM.md                        │
│                  ├── SOUL.md                          │
│                  ├── AGENTS.md                        │
│                  └── skills/                          │
└─────────────────────────────────────────────────────┘
                        ↓
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Claude Code │ │   Cursor     │ │   Qoder      │
│  CLAUDE.md   │ │ .cursorrules │ │ QODER.md     │
└──────────────┘ └──────────────┘ └──────────────┘
        ↓               ↓               ↓
    OpenClaw работает во всех IDE одновременно!
```

**Принцип:**
1. **Единый источник истины** — все промпты в `/openclaw/workspace/`
2. **Специфичные копии** — IDE-specific файлы для каждого редактора
3. **Синхронизация** — изменения propagate через скрипт `sync-ide-rules.sh`

---

## 📦 Сценарии Использования

### Сценарий 1: Разработка в Cursor

```
1. Клонируете проект
2. Открываете в Cursor
3. .cursorrules автоматически загружает OpenClaw промпты
4. Работаете с AI ассистентом
5. Все команды routed через OpenClaw агентов
```

### Сценарий 2: CLI с Claude Code

```
1. Устанавливаете Claude Code CLI
2. Открываете проект в терминале
3. CLAUDE.md загружает OpenClaw промпты
4. Работаете через голос или текст
5. GitHub интеграция, git операции
```

### Сценарий 3: Qoder для быстрого прототипирования

```
1. Открываете проект в Qoder IDE
2. .qoder/rules/QODER.md загружает OpenClaw
3. Быстрая генерация кода
4. Автоматическое форматирование
5. Коммиты через AI
```

---

## 🔧 Синхронизация Промптов

### Скрипт `sync-ide-rules.sh`

```bash
#!/bin/bash
# openclaw/scripts/sync-ide-rules.sh

SOURCE_DIR="/opt/openclaw/workspace"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

echo "🔄 Syncing OpenClaw prompts to IDE-specific files..."

# Claude Code (CLAUDE.md)
echo "  → CLAUDE.md"
cat "$SOURCE_DIR/SYSTEM.md" > "$PROJECT_ROOT/CLAUDE.md"
echo "" >> "$PROJECT_ROOT/CLAUDE.md"
cat "$SOURCE_DIR/SOUL.md" >> "$PROJECT_ROOT/CLAUDE.md"

# Cursor (.cursorrules)
echo "  → .cursorrules"
cat "$SOURCE_DIR/SYSTEM.md" > "$PROJECT_ROOT/.cursorrules"
echo "" >> "$PROJECT_ROOT/.cursorrules"
cat "$SOURCE_DIR/SOUL.md" >> "$PROJECT_ROOT/.cursorrules"

# Qoder (.qoder/rules/QODER.md)
mkdir -p "$PROJECT_ROOT/.qoder/rules"
echo "  → .qoder/rules/QODER.md"
cat "$SOURCE_DIR/SYSTEM.md" > "$PROJECT_ROOT/.qoder/rules/QODER.md"
echo "" >> "$PROJECT_ROOT/.qoder/rules/QODER.md"
cat "$SOURCE_DIR/SOUL.md" >> "$PROJECT_ROOT/.qoder/rules/QODER.md"

# QWEN (QWEN.md)
echo "  → QWEN.md"
cat "$SOURCE_DIR/SYSTEM.md" > "$PROJECT_ROOT/QWEN.md"
echo "" >> "$PROJECT_ROOT/QWEN.md"
cat "$SOURCE_DIR/SOUL.md" >> "$PROJECT_ROOT/QWEN.md"

# VS Code + Cline (.clinerules)
echo "  → .clinerules"
cat "$SOURCE_DIR/SYSTEM.md" > "$PROJECT_ROOT/.clinerules"
echo "" >> "$PROJECT_ROOT/.clinerules"
cat "$SOURCE_DIR/SOUL.md" >> "$PROJECT_ROOT/.clinerules"

echo "✅ Done! OpenClaw prompts synced to all IDEs."
```

### Использование

```bash
# После каждого изменения в workspace/
cd /opt/openclaw
./scripts/sync-ide-rules.sh

# Или автоматический sync при коммите
git hook pre-commit → sync-ide-rules.sh
```

---

## 🎨 Конфигурация IDE

### Общие Принципы

Для всех IDE:

1. **Файл промпта** в корне проекта
2. **Автозагрузка** при открытии проекта
3. **Доступ к workspace/** skills
4. **Routing** к соответствующим агентам

### IDE-Specific Features

| Feature | Claude Code | Cursor | Qoder | QWEN |
|---------|-------------|--------|-------|------|
| Voice commands | ✅ | ❌ | ❌ | ❌ |
| Git integration | ✅ | ✅ | ✅ | ✅ |
| Multi-file edit | ✅ | ✅ | ✅ | ✅ |
| CLI mode | ✅ | ❌ | ❌ | ✅ |
| Remote execution | ✅ | ❌ | ❌ | ❌ |

---

## 📝 Usage Examples

### Пример 1: Создание компонента в Cursor

```
👤 "Создай React компонент для формы логина"

🤖 OpenClaw (через .cursorrules):
    1. 🎯 Routing to Development Agent
    2. 📦 Using skill: code-generator
    3. 📝 Creating component...
    4. ✅ Component created
```

### Пример 2: Git операции через Claude Code CLI

```
👤 "Создай коммит и запуши"

🤖 OpenClaw (через CLAUDE.md):
    1. 🎯 Routing to Development Agent
    2. 📦 Using skill: git-workflow
    3. 📝 Commit message generated
    4. ✅ Pushed to origin/main
```

### Пример 3: Code Review в Qoder

```
👤 "Сделай ревью этого PR"

🤖 OpenClaw (через QODER.md):
    1. 🎯 Routing to Development Agent
    2. 📦 Using skill: code-review
    3. 📊 Review generated
    4. 💬 Recommendations provided
```

---

## 🔗 Интеграция с OpenClaw VDS

### Локальная Разработка

```
Local IDE (Cursor/Claude/Qoder)
    ↓
Использует OpenClaw промпты
    ↓
Код пишется локально
    ↓
Коммит в Git
```

### VDS Разработка (через Telegram)

```
Telegram Bot (текст/голос)
    ↓
OpenClaw на VDS
    ↓
Редактирование файлов
    ↓
Автокоммит
```

### Гибридный Режим

```
Local IDE ←→ OpenClaw VDS
    ↓              ↓
  Промпты      Выполнение
    ↓              ↓
  Синхронизация через Git
```

---

## 🛡️ Безопасность

### Локальные IDE

- ✅ Полный доступ к файловой системе
- ✅ Выполнение любых команд
- ✅ Локальный git operations

### OpenClaw VDS

- ⚠️ Только разрешённые команды
- ⚠️ Работа в sandbox режиме (для non-main агентов)
- ✅ Изолированное окружение

### Рекомендации

```yaml
Локальная разработка:
  - Используйте: Claude Code, Cursor, Qoder
  - Доступ: Полный
  - Для: Быстрой разработки, экспериментов

VDS разработка:
  - Используйте: Telegram + OpenClaw
  - Доступ: Ограниченный
  - Для: Production задач, деплоя, мониторинга
```

---

## 📚 См. Также

### IDE-Specific Документация

- [🤖 Claude Code](claude/README.md) - Claude Code CLI интеграция
- [🖱️ Cursor](cursor/README.md) - Cursor AI IDE
- [🎨 Qoder](qoder/README.md) - Qoder IDE
- [🐉 QWEN](qwen/README.md) - QWEN Code CLI
- [📦 VS Code](vscode/README.md) - VS Code + Cline

### OpenClaw Core

- [🎯 Workspace](../README.md) - Рабочее пространство
- [🤖 Agents](../AGENTS.md) - Агенты
- [📋 Skills Index](../SKILLS-INDEX.md) - Навыки
- [🔧 Config](../config/README.md) - Конфигурация

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия |

---

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../../README.md) → [🎯 Workspace](../README.md) → [🎨 IDE Support](#)
