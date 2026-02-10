# 📋 Skills Index

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../../README.md) → [🎯 Workspace](README.md) → [📋 Skills Index](#)

---

## Обзор

Полный индекс всех навыков (skills) агентов OpenClaw.

---

## 🎯 Что Такое Skill?

**Skill** — это переиспользуемый набор инструкций для агента OpenClaw.

```
Аналогия:
  Skill    = Функция в программировании
  Agent    = Класс/Модуль
  Workspace= Пакет/Библиотека
```

---

## 📂 Категории Skills

### 🤖 Core Skills (NEW!)

Основные навыки для работы OpenClaw.

| Skill | Описание | Агенты |
|-------|----------|--------|
| [Intent Parser](skills/intent-parser.md) | Парсинг естественного языка | All |
| [Command Resolver](skills/command-resolver.md) | Резолвинг команд | All |
| [Command Executor](skills/command-executor.md) | Исполнение команд | All |

**Категория:** [🤖 Core Skills](skills/README.md)

---

### 👨‍💻 Development Skills

Навыки для разработки программного обеспечения.

| Skill | Описание | Агенты |
|-------|----------|--------|
| [Git Workflow](skills/development/git-workflow.md) | Автоматизация Git операций | Dev, Main |
| [Testing Strategy](skills/development/testing-strategy.md) | Стратегия тестирования | Dev |
| [Code Review](skills/development/code-review.md) | Ревью кода | Dev, Main |
| [Debugging](skills/development/debugging.md) | Отладка и исправление ошибок | Dev |

**Категория:** [👨‍💻 Development Skills](skills/development/README.md)

---

### 🚀 DevOps Skills

Навыки для DevOps и эксплуатации.

| Skill | Описание | Агенты |
|-------|----------|--------|
| [Docker Deploy](skills/devops/docker-deploy.md) | Docker деплой | DevOps |
| [CI Pipeline](skills/devops/ci-pipeline.md) | CI/CD пайплайны | DevOps |
| [Monitoring](skills/devops/monitoring.md) | Мониторинг и алерты | DevOps |
| [Rollback](skills/devops/rollback.md) | Откат изменений | DevOps |

**Категория:** [🚀 DevOps Skills](skills/devops/README.md)

---

### 🤖 AI Assistant Skills

Навыки для AI ассистентов.

| Skill | Описание | Агенты |
|-------|----------|--------|
| [Prompt Engineer](skills/ai-assistants/prompt-engineer.md) | Промпт-инжиниринг | Prompt |
| [Code Generator](skills/ai-assistants/code-generator.md) | Генерация кода | CodeGen |
| [Debugger](skills/ai-assistants/debugger.md) | Отладка с AI | Debugger |

**Категория:** [🤖 AI Assistant Skills](skills/ai-assistants/README.md)

---

## 📋 Полный Список

### Core Skills (NEW!)

#### 🎯 Intent Parser

**Файл:** [skills/intent-parser.md](skills/intent-parser.md)

**Возможности:**
- Парсинг естественного языка
- Определение категории интента
- Извлечение параметров
- Определение ambiguities

**Использование:**
```
"Создай проект telegram-bot" → create_project intent
"Задеплой на staging" → deploy intent
```

**Агенты:** All (уровень роутинга)

---

#### 🔧 Command Resolver

**Файл:** [skills/command-resolver.md](skills/command-resolver.md)

**Возможности:**
- Преобразование интента в команды
- Валидация параметров
- Генерация Make targets
- Pre-flight проверки

**Использование:**
```
create_project intent → make new ARCHETYPE=...
generate_agents intent → make generate-agents NAME=...
```

**Агенты:** All

---

#### ⚡ Command Executor

**Файл:** [skills/command-executor.md](skills/command-executor.md)

**Возможности:**
- Исполнение команд
- Progress indicators
- Error handling
- Rollback mechanism

**Использование:**
```
Streaming output for long commands
Error recovery with suggestions
Automatic rollback on failure
```

**Агенты:** All

---

### Development Skills

#### 🔄 Git Workflow

**Файл:** [skills/development/git-workflow.md](skills/development/git-workflow.md)

**Возможности:**
- Auto-Commit с AI генерацией сообщений
- Smart Push с resolution конфликтов
- Branch Management с naming conventions
- Status & History
- Rollback операций

**Использование:**
```
"Создай коммит"
"Запушь в репу"
"Создай ветку для фичи"
```

**Агенты:** Dev, Main

---

#### 🧪 Testing Strategy

**Файл:** [skills/development/testing-strategy.md](skills/development/testing-strategy.md)

**Возможности:**
- Генерация unit тестов
- Генерация integration тестов
- TDD подход
- Тестовое покрытие

**Использование:**
```
"Напиши тесты для функции login"
"Покрой тестами модуль auth"
```

**Агенты:** Dev

---

#### 🔍 Code Review

**Файл:** [skills/development/code-review.md](skills/development/code-review.md)

**Возможности:**
- Автоматическое ревью PR
- Проверка code style
- Поиск потенциальных багов
- Рекомендации по улучшению

**Использование:**
```
"Сделай ревью кода"
"Проверь pull request"
```

**Агенты:** Dev, Main

---

#### 🐛 Debugging

**Файл:** [skills/development/debugging.md](skills/development/debugging.md)

**Возможности:**
- Анализ ошибок
- Поиск багов
- Исправление кода
- Логирование

**Использование:**
```
"Найди ошибку в коде"
"Отладь функцию auth"
```

**Агенты:** Dev, Debugger

---

### DevOps Skills

#### 🐳 Docker Deploy

**Файл:** [skills/devops/docker-deploy.md](skills/devops/docker-deploy.md)

**Возможности:**
- Сборка Docker образов
- Запуск контейнеров
- Docker Compose операции
- Управление томами

**Использование:**
```
"Собери docker image"
"Запусти контейнеры"
"Перезапусти сервис"
```

**Агенты:** DevOps

---

#### 🔄 CI Pipeline

**Файл:** [skills/devops/ci-pipeline.md](skills/devops/ci-pipeline.md)

**Возможности:**
- Создание CI/CD пайплайнов
- GitHub Actions workflows
- GitLab CI конфигурации
- Jenkins pipelines

**Использование:**
```
"Создай CI pipeline"
"Добавь шаг тестирования"
```

**Агенты:** DevOps

---

#### 📊 Monitoring

**Файл:** [skills/devops/monitoring.md](skills/devops/monitoring.md)

**Возможности:**
- Настройка Prometheus
- Grafana дашборды
- Алерты и уведомления
- Health checks

**Использование:**
```
"Проверь статус сервисов"
"Добавь мониторинг"
```

**Агенты:** DevOps

---

#### ↩️ Rollback

**Файл:** [skills/devops/rollback.md](skills/devops/rollback.md)

**Возможности:**
- Откат деплоя
- Восстановление из бэкапа
- Emergency procedures

**Использование:**
```
"Откати последний деплой"
"Восстанови из бэкапа"
```

**Агенты:** DevOps

---

### AI Assistant Skills

#### ✨ Prompt Engineer

**Файл:** [skills/ai-assistants/prompt-engineer.md](skills/ai-assistants/prompt-engineer.md)

**Возможности:**
- Создание системных промптов
- Оптимизация промптов
- A/B тестирование промптов
- Блочная архитектура

**Использование:**
```
"Создай промпт для чат-бота"
"Оптимизируй системный промпт"
```

**Агенты:** Prompt

**Интеграция:** Использует [instructions/prompt-generation.md](../../../instructions/prompt-generation.md)

---

#### 💻 Code Generator

**Файл:** [skills/ai-assistants/code-generator.md](skills/ai-assistants/code-generator.md)

**Возможности:**
- Генерация boilerplate кода
- Генерация по шаблону
- Мультиязычная генерация

**Использование:**
```
"Сгенерируй CRUD для users"
"Создай boilerplate для API"
```

**Агенты:** CodeGen

---

#### 🔧 Debugger

**Файл:** [skills/ai-assistants/debugger.md](skills/ai-assistants/debugger.md)

**Возможности:**
- AI-отладка кода
- Анализ stack traces
- Исправление ошибок

**Использование:**
```
"Найди баг в коде"
"Исправь ошибку"
```

**Агенты:** Debugger

---

## 🔗 Создание Нового Skill

### Шаблон

```markdown
# Skill: [Название]

> [Хлебные крошки]

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

## See Also
Связанные документы.
```

### Процесс

1. **Создать файл** в соответствующей категории:
   ```bash
   touch /opt/openclaw/workspace/skills/development/new-skill.md
   ```

2. **Наполнить содержимым** по шаблону

3. **Обновить этот индекс** (SKILLS-INDEX.md)

4. **Добавить в агент** (AGENTS.md):
   ```markdown
   ## New Agent
   Skills:
   - [new-skill](skills/development/new-skill.md)
   ```

5. **Перезапустить OpenClaw:**
   ```bash
   systemctl restart openclaw
   ```

---

## 📊 Статистика Skills

| Категория | Всего Skills | Активных | В разработке |
|-----------|--------------|----------|--------------|
| Core | 3 | 3 | 0 |
| Development | 4 | 4 | 0 |
| DevOps | 4 | 4 | 0 |
| AI Assistants | 3 | 3 | 0 |
| **ИТОГО** | **14** | **14** | **0** |

---

## 🔗 Быстрые Ссылки

### По Категориям
- [👨‍💻 Development Skills](skills/development/README.md)
- [🚀 DevOps Skills](skills/devops/README.md)
- [🤖 AI Assistant Skills](skills/ai-assistants/README.md)

### По Агентам
- [🤖 Agents](AGENTS.md) - Какие агенты используют какие skills
- [👤 Soul](SOUL.md) - Личность агентов
- [🔧 Tools](TOOLS.md) - Инструменты для skills

### Интеграции
- [📖 Instructions](../../../instructions/README.md) - Базовые инструкции
- [⚙️ Config](../../config/README.md) - Конфигурация OpenClaw

---

## 📚 См. Также

- [🎯 Workspace README](README.md)
- [🤖 Agents](AGENTS.md)
- [👤 Soul](SOUL.md)
- [🔧 Tools](TOOLS.md)

---

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../../README.md) → [🎯 Workspace](README.md) → [📋 Skills Index](#)
