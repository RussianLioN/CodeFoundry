# 🎨 Skill: Git Workflow Automation

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [👨‍💻 Development Skills](#)

---

## Description

Автоматизирует Git операции через Telegram команды и voice messages.

---

## Capabilities

### 🔄 Auto-Commit

Анализирует изменения и создаёт осмысленный коммит.

**Использование:**
```
👤 "Создай коммит для текущих изменений"
👤 "Закоммить это"
```

**Действия:**
```bash
1. git status                      # Проверяем статус
2. git diff                        # Анализируем изменения
3. → AI анализирует через AGENTS.md
4. Генерирует commit message
5. git add -A
6. git commit -m "[AI] feat: описание"
```

**Пример commit message:**
```
[AI] feat: implemented user authentication

- Added JWT token generation
- Created login/logout endpoints
- Added password hashing with bcrypt
- Wrote unit tests for auth module

Files: 5 changed, 120 insertions(+), 15 deletions(-)
```

---

### 🚀 Smart Push

Пушит с автоматическим resolution конфликтов.

**Использование:**
```
👤 "Запушь в репу"
👤 "Синхронизируй с GitHub"
```

**Действия:**
```bash
1. git fetch origin                # Получаем изменения
2. git rebase origin/main          # Ребейз
3. → Auto-resolve conflicts
4. → AI merge strategy
5. git push origin main           # Пушим
```

**Стратегия resolution:**
- **Documentation files:** Prefer remote (их_updated)
- **Code files:** Prefer local (мои_изменения)
- **TASKS.md:** Merge both
- **SESSION.md:** Append local to remote

---

### 🌿 Branch Management

Создаёт ветки по naming convention.

**Использование:**
```
👤 "Создай ветку для фичи логина"
👤 "Создай feature branch"
```

**Действия:**
```bash
# Анализирует запрос
# → Определяет тип задачи
# → Создаёт ветку по конвенции

git checkout -b feature/login-auth
# или
git checkout -b bugfix/payment-error
# или
git checkout -b hotfix/security-patch
```

**Конвенции命名:**
| Тип | Префикс | Пример |
|-----|---------|--------|
| Feature | `feature/` | `feature/login-auth` |
| Bugfix | `bugfix/` | `bugfix/payment-error` |
| Hotfix | `hotfix/` | `hotfix/security-patch` |
| Release | `release/` | `release/v1.2.0` |
| Refactor | `refactor/` | `refactor/user-model` |

---

### 📊 Status & History

Показывает статус и историю изменений.

**Использование:**
```
👤 "Что изменилось?"
👤 "Покажи статус"
👤 "История коммитов"
```

**Действия:**
```bash
# Status → git status + git diff
# History → git log --oneline -10
# Diff → git diff HEAD~1
```

**Формат ответа:**
```
📊 Git Status

📁 Изменённые файлы:
  ✅ src/auth/login.js          (modified)
  ✅ src/auth/logout.js         (new)
  ✅ tests/auth.test.js         (modified)

📝 Статистика:
  +120 строк добавлено
  - 15 строк удалено

💬 Последние коммиты:
  a1b2c3d [AI] feat: implemented user auth
  d4e5f6g fix: corrected validation error
  ...
```

---

### ↩️ Rollback

Откат изменений различными способами.

**Использование:**
```
👤 "Отмени последний коммит"
👤 "Сбрось до коммита abc123"
👤 "Отмени всё, что я натворил"
```

**Действия:**
```bash
# Мягкий откат (сохраняет изменения)
git reset --soft HEAD~1

# Жёсткий откат (теряет изменения)
git reset --hard HEAD~1

# Откат к конкретному коммиту
git reset --hard abc1234

# Откат конкретного файла
git checkout HEAD~1 -- path/to/file
```

---

## 🎯 Integration with Instructions

Этот skill использует [instructions/git-operations.md](../../../../instructions/git-operations.md) как базу.

**Дополнительные возможности:**
- Voice команды через Telegram
- Автоматический анализ изменений
- Умное разрешение конфликтов
- AI-генерируемые commit messages

---

## 🔧 Configuration

### Commit Message Template

```json
{
  "git": {
    "commitMessage": {
      "prefix": "[AI]",
      "format": "<type>: <description>\n\n- <change1>\n- <change2>\n\nFiles: <stats>",
      "types": {
        "feature": "feat",
        "bugfix": "fix",
        "refactor": "refactor",
        "docs": "docs",
        "test": "test",
        "chore": "chore"
      }
    }
  }
}
```

### Branch Naming

```json
{
  "git": {
    "branchNaming": {
      "convention": "conventional",
      "separator": "-",
      "maxLength": 50
    }
  }
}
```

---

## 📝 Usage Examples

### Сценарий 1: Полный Workflow

```
👤 "Создай коммит и запушь"

🤖 Git Workflow Skill:
    1. Анализирую изменения...
    2. Создаю коммит: "[AI] feat: added user profile"
    3. Запушиваю в репозиторий...
    ✅ Готово! Changes pushed to origin/main
```

### Сценарий 2: Работа с ветками

```
👤 "Создай ветку для задачи, запиши код, запушь"

🤖 Git Workflow Skill:
    1. Создаю ветку: feature/user-profile
    2. Переключаюсь на ветку...
    3. Жду код от вас...
    4. [код получен]
    5. Коммичу: "[AI] feat: user profile implementation"
    6. Запушиваю в feature/user-profile
    ✅ Готово! Branch pushed.
```

### Сценарий 3: Разрешение конфликтов

```
👤 "Запушь, но если конфликты — разреши"

🤖 Git Workflow Skill:
    1. Достаю изменения с remote...
    2. Обнаружен конфликт в: TASKS.md
    3. Анализирую конфликты...
    4. Применяю стратегию merge...
    5. Конфликты разрешены!
    6. Запушиваю...
    ✅ Готово!
```

---

## 🔗 Commands Mapping

| Voice Command | Git Action |
|---------------|------------|
| "Что изменилось?" | `git status + git diff` |
| "Создай коммит" | Auto commit + AI message |
| "Запушь" | Smart push with resolution |
| "История коммитов" | `git log --oneline -10` |
| "Создай ветку для..." | Create branch with naming |
| "Отмени последний коммит" | `git reset --soft HEAD~1` |
| "Сбрось всё" | `git reset --hard HEAD` |
| "Смержи в main" | `git merge main` |
| "Покажи ветки" | `git branch -a` |

---

## 🛡️ Safety Features

### 1. Confirmation Required

Деструктивные операции требуют подтверждения:

```
👤 "Сбрось всё"
🤖 Это удалит все незакоммиченные изменения. Подтверждаете? (да/нет)
👤 "да"
🤖 Выполняю git reset --hard HEAD...
```

### 2. Dry Run Mode

Показывает что будет сделано без выполнения:

```
👤 "Покажи что сделает коммит (dry run)"
🤖 [Dry Run] Будет выполнено:
    git add src/
    git commit -m "[AI] feat: user authentication"
    5 файлов будет закоммичено
```

### 3. Backup Before Destructive

Автоматический stash перед жёсткими операциями:

```bash
git stash save "Auto-backup before reset"
# Выполняется операция
# stash можно восстановить: git stash pop
```

---

## 📚 См. Также

- [📖 Git Operations Instruction](../../../../instructions/git-operations.md)
- [👨‍💻 Development Skills Index](../README.md)
- [🎯 Workspace](../README.md)
- [🤖 Agents](../AGENTS.md)

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [👨‍💻 Git Workflow Skill](#)
