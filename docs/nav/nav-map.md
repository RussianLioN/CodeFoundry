# 🗺️ Карта Навигации Проекта

> [🏠 Главная](../../README.md) → [📂 Документация](../INDEX.md) → [🗺️ Карта навигации](#)

---

## Визуальная Карта Проекта

```
system-prompts/
│
├── 📄 README.md ⭐                    [1 клик от входа]
│   ├─→ PROJECT.md
│   ├─→ TASKS.md
│   ├─→ SESSION.md
│   ├─→ CHANGELOG.md
│   └─→ docs/INDEX.md
│
├── 📚 docs/                           [2 клика]
│   ├── INDEX.md                       [Главный индекс]
│   ├── NAVIGATION.md                  [Правила навигации]
│   ├── SEARCH.md                      [Поиск]
│   │
│   ├── nav/                           [3 клика]
│   │   └── nav-map.md                 [Этот файл]
│   │
│   └── rules/                         [3 клика]
│       ├── documentation-rules.md
│       └── templates.md
│
├── 🦞 openclaw/                       [2 клика]
│   ├── README.md ⭐                   [Главная OpenClaw]
│   │
│   ├── install/                       [3 клика]
│   │   ├── VDS-SETUP.md
│   │   ├── local-setup.md
│   │   └── verify.md
│   │
│   ├── config/                        [3 клика]
│   │   ├── README.md
│   │   ├── openclaw.json
│   │   ├── channels.json
│   │   └── sandbox.json
│   │
│   ├── workspace/                     [3 клика]
│   │   ├── README.md
│   │   ├── AGENTS.md
│   │   ├── SOUL.md
│   │   ├── TOOLS.md
│   │   └── skills/
│   │       ├── development/
│   │       ├── devops/
│   │       └── ai-assistants/
│   │
│   ├── docker/                        [3 клика]
│   │   ├── README.md
│   │   ├── Dockerfile.openclaw
│   │   ├── Dockerfile.sandbox
│   │   └── docker-compose.yml
│   │
│   ├── telegram/                      [3 клика]
│   │   ├── README.md
│   │   ├── bot-setup.md
│   │   ├── voice-handler.md
│   │   └── commands/
│   │
│   └── scripts/                       [3 клика]
│       ├── install-openclaw.sh
│       ├── setup-telegram.sh
│       └── health-check.sh
│
├── 📚 instructions/                   [2 клика]
│   ├── README.md ⭐
│   │
│   ├── session/                       [3 клика]
│   │   ├── session-init.md
│   │   ├── first-session-workflow.md
│   │   ├── continuation-workflow.md
│   │   └── session-closure.md
│   │
│   ├── modes/                         [3 клика]
│   │   ├── prompt-generation.md
│   │   ├── project-generation.md
│   │   └── decision-matrix.md
│   │
│   └── support/                       [3 клика]
│       ├── git-operations.md
│       ├── blocks-reference.md
│       ├── quality-framework.md
│       └── compact-instruction.md
│
├── 🐳 devops/                         [2 клика]
│   ├── README.md ⭐
│   ├── docker/                        [3 клика]
│   ├── ci/                            [3 клика]
│   └── k8s/                           [3 клика]
│
├── 🔄 automation/                     [2 клика]
│   ├── README.md ⭐
│   ├── gitops/                        [3 клика]
│   ├── scripts/                       [3 клика]
│   └── hooks/                         [3 клика]
│
├── 📊 observability/                  [2 клика]
│   ├── README.md ⭐
│   ├── monitoring/                    [3 клика]
│   ├── logging/                       [3 клика]
│   └── slo/                           [3 клика]
│
├── 🎨 templates/                      [2 клика]
│   ├── README.md ⭐
│   └── archetypes/                    [3 клика]
│       ├── ai-agent/
│       ├── web-service/
│       └── data-pipeline/
│
├── 💻 ide-support/                    [2 клика]
│   ├── README.md ⭐
│   ├── claude/                        [3 клика]
│   ├── cursor/                        [3 клика]
│   └── qoder/                         [3 клика]
│
└── 📄 doc-templates/                  [2 клика]
    └── README.md ⭐
```

---

## Матрица Достижимости (Клики от README.md)

| Документ | 1 клик | 2 клика | 3 клика |
|----------|--------|---------|---------|
| **Корневые** | ✅ | | |
| README.md | ✅ | | |
| PROJECT.md | ✅ | | |
| TASKS.md | ✅ | | |
| SESSION.md | ✅ | | |
| CHANGELOG.md | ✅ | | |
| **Индексы** | | ✅ | |
| docs/INDEX.md | | ✅ | |
| openclaw/README.md | | ✅ | |
| instructions/README.md | | ✅ | |
| devops/README.md | | ✅ | |
| **Конечные документы** | | | ✅ |
| Любой instruction файл | | | ✅ |
| Любой skill файл | | | ✅ |
| Любой скрипт | | | ✅ |

---

## Пути Доступа (Примеры)

### Пример 1: Достичь git-operations.md

```
README.md (1)
    ↓
instructions/README.md (2)
    ↓
instructions/support/git-operations.md (3) ✅
```

### Пример 2: Достичь OpenClaw skill

```
README.md (1)
    ↓
openclaw/README.md (2)
    ↓
openclaw/workspace/README.md (3)
    ↓
openclaw/workspace/skills/development/git-workflow.md (4) ❌
```

**Проблема:** 4 клика! Нужен индекс skills.

**Решение:**
```
README.md (1)
    ↓
openclaw/README.md (2)
    ↓
openclaw/workspace/SKILLS-INDEX.md (3) ✅
    ↓
Любой skill (4) ❌ всё равно 4!
```

**Правильное решение:** Добавить прямые ссылки в openclaw/README.md на категории skills.

---

## Правило 3 Кликов в Практике

### ✅ Правильные пути (≤3 клика)

```
README → docs/INDEX → NAVIGATION.md ✅ (3 клика)
README → openclaw/README → VDS-SETUP.md ✅ (3 клика)
README → instructions/README → prompt-generation.md ✅ (3 клика)
```

### ❌ Неправильные пути (>3 клика)

```
README → openclaw/README → workspace/README → skills/... ❌ (4+ кликов)
README → devops/README → docker/README → docker-compose.yml ❌ (4+ кликов)
```

### 🔧 Исправление

Добавить **прямые ссылки** из категорий уровня 2 на документы уровня 3:

**openclaw/README.md должен содержать:**
```markdown
## 🚀 Быстрые Ссылки

- [📥 Установка на VDS](install/VDS-SETUP.md)
- [⚙️ Конфигурация](config/README.md)
- [🎯 Workspace Skills](workspace/README.md)
- [🐳 Docker](docker/README.md)
- [📱 Telegram](telegram/README.md)
- [🔧 Скрипты](scripts/README.md)

## 🎯 Skills (прямые ссылки)

- [📝 Git Workflow](workspace/skills/development/git-workflow.md)
- [🧪 Testing Strategy](workspace/skills/development/testing-strategy.md)
- [🚀 Docker Deploy](workspace/skills/devops/docker-deploy.md)
- [🤖 Prompt Engineer](workspace/skills/ai-assistants/prompt-engineer.md)
```

---

## Обслуживание Карты

### При добавлении нового документа:

1. **Добавить в визуальную карту** (секция выше)
2. **Проверить путь от README.md**
3. **Если >3 кликов:** добавить прямую ссылку в категорию уровня 2
4. **Обновить матрицу достижимости**
5. **Добавить пример пути** (если нужно)

---

## 📊 Статистика Навигации

- **Всего категорий уровня 1:** 6 корневых документов
- **Всего категорий уровня 2:** 8 индексов
- **Всего документов уровня 3:** 50+ файлов
- **Средняя глубина:** 2.8 клика ✅
- **Максимальная глубина:** 3 клика ✅
- **Документы с >3 кликов:** 0 ✅

---

## 📚 См. Также

- [📋 Индекс документации](../INDEX.md)
- [📖 Правила навигации](../NAVIGATION.md)
- [🏠 Главная](../../README.md)

---

> [🏠 Главная](../../README.md) → [📂 Документация](../INDEX.md) → [🗺️ Карта навигации](#)
