# 🎯 OpenClaw Workspace

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](#)

---

## Обзор

**Workspace** — это рабочее пространство OpenClaw, содержащее:
- **AGENTS.md** — Определение multi-agent системы
- **SOUL.md** — Личность и характер ассистента
- **TOOLS.md** — Манифест доступных инструментов
- **USER.md** — Пользовательские предпочтения
- **skills/** — Переиспользуемые навыки агентов

---

## 📂 Структура Workspace

```
/opt/openclaw/workspace/
│
├── 📄 AGENTS.md                      # 🤖 Определение агентов
├── 📄 SOUL.md                        # 👤 Личность ассистента
├── 📄 TOOLS.md                       # 🔧 Инструменты
├── 📄 USER.md                        # 👤 Пользовательские настройки
├── 📄 SKILLS-INDEX.md                # 📋 Индекс навыков
│
└── 🎨 skills/                        # 🎨 Custom Skills
    │
    ├── development/                  # 👨‍💻 Skills для разработки
    │   ├── git-workflow.md           # Автоматизация Git
    │   ├── testing-strategy.md       # Стратегия тестирования
    │   ├── code-review.md            # Ревью кода
    │   └── debugging.md              # Отладка
    │
    ├── devops/                       # 🚀 Skills для DevOps
    │   ├── docker-deploy.md          # Docker деплой
    │   ├── ci-pipeline.md            # CI/CD пайплайны
    │   ├── monitoring.md             # Мониторинг
    │   └── rollback.md               # Откат изменений
    │
    └── ai-assistants/                # 🤖 Skills для AI ассистентов
        ├── prompt-engineer.md        # Промпт-инжиниринг
        ├── code-generator.md         # Генерация кода
        └── debugger.md               # Отладка с AI
```

---

## 🚀 Быстрые Ссылки

### Основные файлы
- [🤖 Агенты (AGENTS.md)](AGENTS.md)
- [👤 Личность (SOUL.md)](SOUL.md)
- [🔧 Инструменты (TOOLS.md)](TOOLS.md)
- [👤 Пользователь (USER.md)](USER.md)

### Индексы
- [📋 Skills Index](SKILLS-INDEX.md)
- [🎨 Development Skills](skills/development/README.md)
- [🚀 DevOps Skills](skills/devops/README.md)
- [🤖 AI Assistant Skills](skills/ai-assistants/README.md)

### Конфигурация
- [⚙️ OpenClaw Config](../config/README.md)
- [🐳 Docker Config](../docker/README.md)
- [📱 Telegram Config](../telegram/README.md)

---

## 🔧 Работа с Workspace

### Путь к Workspace

```bash
# По умолчанию
/opt/openclaw/workspace

# Может быть настроен в ~/.openclaw/openclaw.json
{
  "agent": {
    "defaults": {
      "workspace": "/путь/к/workspace"
    }
  }
}
```

### Редактирование Файлов

```bash
# Переход в workspace
cd /opt/openclaw/workspace

# Редактирование AGENTS.md
nano AGENTS.md

# Редактирование SOUL.md
nano SOUL.md

# После редактирования перезапустите OpenClaw
systemctl restart openclaw
```

### Создание Новых Skills

```bash
# Создаём новый skill
cd /opt/openclaw/workspace/skills/development

# Создаём файл skill
nano new-skill.md

# Обновляем индекс
cd /opt/openclaw/workspace
nano SKILLS-INDEX.md

# Перезапускаем OpenClaw
systemctl restart openclaw
```

---

## 📋 AGENTS.md

Определяет multi-agent систему OpenClaw.

**Содержит:**
- Определения всех агентов
- Правила маршрутизации
- Инструменты каждого агента
- Skills каждого агента

**Подробнее:** [🤖 AGENTS.md](AGENTS.md)

**Пример:**
```markdown
## Main Agent
Обрабатывает личные сообщения владельца.

## Development Agent
Специализирован на написании кода.

## DevOps Agent
Специализирован на деплое.
```

---

## 👤 SOUL.md

Определяет личность и характер ассистента.

**Содержит:**
- Имя и роль ассистента
- Стиль общения
- Тон и голос
- Ценности и принципы

**Пример:**
```markdown
# Личность Ассистента

## Имя
Clawd

## Роль
Senior AI Developer и DevOps Engineer

## Стиль
- Профессиональный, но дружелюбный
- Технически точный
- Использует эмодзи для акцентов

## Ценности
- Качество кода > скорость
- Безопасность > удобство
- Автоматизация > ручной труд
```

---

## 🔧 TOOLS.md

Манифест доступных инструментов.

**Содержит:**
- Список всех инструментов
- Описание каждого инструмента
- Правила использования
- Ограничения безопасности

**Пример:**
```markdown
# Инструменты

## Bash
Выполнение команд в терминале.

## Read
Чтение файлов.

## Write
Запись файлов.

## Git
Контроль версий.
```

---

## 🎨 Skills System

### Что такое Skill?

**Skill** — это переиспользуемый набор инструкций для агента OpenClaw. Аналог функциями в программировании.

### Структура Skill

```markdown
# Skill: [Название]

## Description
Краткое описание.

## Capabilities
Что умеет делать skill.

## Usage Examples
Примеры использования.

## Configuration
Конфигурация (если нужна).

## Integration
Как интегрировать с агентами.
```

### Категории Skills

#### Development Skills
- [Git Workflow](skills/development/git-workflow.md) — Автоматизация Git
- [Testing Strategy](skills/development/testing-strategy.md) — Стратегия тестирования
- [Code Review](skills/development/code-review.md) — Ревью кода

#### DevOps Skills
- [Docker Deploy](skills/devops/docker-deploy.md) — Docker деплой
- [CI Pipeline](skills/devops/ci-pipeline.md) — CI/CD пайплайны
- [Monitoring](skills/devops/monitoring.md) — Мониторинг

#### AI Assistant Skills
- [Prompt Engineer](skills/ai-assistants/prompt-engineer.md) — Промпт-инжиниринг
- [Code Generator](skills/ai-assistants/code-generator.md) — Генерация кода
- [Debugger](skills/ai-assistants/debugger.md) — Отладка

**Подробнее:** [📋 Skills Index](SKILLS-INDEX.md)

---

## 🔄 Интеграция с system-prompts

Workspace интегрирован с проектом system-prompts:

```
system-prompts/
├── openclaw/workspace/
│   ├── skills/                    # OpenClaw skills
│   └── AGENTS.md                  # Multi-agent конфигурация
│
└── instructions/                  # Базовые инструкции
    ├── prompt-generation.md       # Используется Prompt Agent
    ├── project-generation.md      # Используется Main Agent
    └── git-operations.md          # Используется Dev Agent
```

### Связь Skills ↔ Instructions

| OpenClaw Skill | Использует Instruction |
|----------------|----------------------|
| `prompt-engineer` | [instructions/prompt-generation.md](../../instructions/prompt-generation.md) |
| `git-workflow` | [instructions/git-operations.md](../../instructions/git-operations.md) |
| `code-review` | [instructions/quality-framework.md](../../instructions/quality-framework.md) |

---

## 🔧 Настройка Workspace

### Изменение Пути Workspace

```bash
# Редактируем конфиг
nano ~/.openclaw/openclaw.json

# Меняем путь
{
  "agent": {
    "defaults": {
      "workspace": "/новый/путь/workspace"
    }
  }
}

# Перезапускаем
systemctl restart openclaw
```

### Копирование Workspace из Репозитория

```bash
# Клонируем репозиторий
git clone https://github.com/RussianLioN/CodeFoundry.git

# Копируем workspace
cp -r CodeFoundry/openclaw/workspace/* /opt/openclaw/workspace/

# Перезапускаем
systemctl restart openclaw
```

---

## ✅ Проверка Workspace

```bash
# Проверка загруженного workspace
curl http://localhost:18789/workspace

# Ожидаемый ответ:
# {
#   "agents": ["main", "dev", "devops", ...],
#   "skills": ["git-workflow", "docker-deploy", ...],
#   "workspace": "/opt/openclaw/workspace"
# }
```

---

## 📚 См. Также

- [🤖 Агенты](AGENTS.md)
- [👤 Личность](SOUL.md)
- [🔧 Инструменты](TOOLS.md)
- [📋 Skills Index](SKILLS-INDEX.md)
- [⚙️ Конфигурация](../config/README.md)

---

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](#)
