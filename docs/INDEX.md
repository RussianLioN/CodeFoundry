# 📚 Индекс Документации Проекта

> [🏠 Главная](../README.md) → [📂 Документация](INDEX.md) → [📄 Индекс](#)

---

## Обзор Документации

Этот документ служит **центральным узлом** навигации по всей документации проекта.

---

## 🗺️ Карта Документации

### 🚀 Quick Start (Начало работы)

| Документ | Описание | Уровень |
|----------|----------|--------|
| [README.md](../README.md) | Главная страница проекта | Корень |
| [PROJECT.md](../PROJECT.md) | Архитектура и описание проекта | Корень |
| [TASKS.md](../TASKS.md) | Трекер задач и план работ | Корень |
| [Workflow Guide](WORKFLOW-GUIDE.md) | Полный справочник инструментов и workflow | 2 клика |
| [GitOps README](gitops-README.md) | GitOps 2.0 workflow | 2 клика |

### 💬 [Sessions](../sessions/index.md)
> История сессий работы над проектом

| Файл | Описание |
|------|----------|
| [SESSION.md](../SESSION.md) | Текущий контекст |
| [sessions/archive/sessions-01-11.md](../sessions/archive/sessions-01-11.md) | Sessions #1-11 |
| [sessions/archive/sessions-12-13.md](../sessions/archive/sessions-12-13.md) | Sessions #12-13 |
| [sessions/archive/sessions-14-16.md](../sessions/archive/sessions-14-16.md) | Sessions #14-16 |

### 📋 [Tasks](../tasks/index.md)
> Трекер задач и план работ

| Файл | Описание |
|------|----------|
| [TASKS.md](../TASKS.md) | Активные фазы (8.5, 9, 11, 12, 14) |
| [tasks/archive/phases-01-10.md](../tasks/archive/phases-01-10.md) | Завершённые фазы 1-10,13 |

### 📚 [Lessons Learned](./lessons/index.md) ⭐
> Уроки из реальных сессий — **обязательное чтение при повторяющихся ошибках**

| Артефакт | Описание | Когда применять |
|----------|----------|-----------------|
| [Troubleshooting Methodology](./lessons/troubleshooting-methodology.md) | Методология исправления повторяющихся ошибок | Ошибка повторяется 3+ раз |
| [WebSocket Client Health Check](./lessons/websocket-client-health-check.md) | Паттерн health check для WebSocket клиентов | Telegram Bot / Gateway issues |

**🚨 MANDATORY READ:** При повторяющихся ошибках читать [@ref: docs/lessons/troubleshooting-methodology.md](./lessons/troubleshooting-methodology.md)

### 🔧 [Improvements](./improvements/index.md) 🆕
> Планы улучшений архитектуры и технический долг

| Артефакт | Описание | Статус |
|----------|----------|--------|
| [Architecture Improvement Plan](./improvements/ARCHITECTURE-IMPROVEMENT-PLAN.md) | План улучшения архитектуры v1.0.0 | ✅ Утверждён |

**Приоритеты:**
- P0: Упрощение CLAUDE.md, Создание BOOTSTRAP.md
- P1: Автоматизация Testing, CLI Bridge на TypeScript
- P2: Mock Provider, Монорепо-структура (исследование)


### 🎓 Expert Opinions
> Мнения экспертов по различным аспектам проекта

| Документ | Описание |
|----------|----------|
| [Documentation Agent](experts-opinions-documentation-agent.md) | Мнения о documentation agent |
| [OpenClaw Orchestrator](experts-opinions-openclaw-orchestrator.md) | Мнения об OpenClaw |
| [Telegram Bot](experts-opinions-telegram-bot.md) | Мнения о Telegram боте |

### 🔬 Analysis & Reports 🆕
> Отчёты Expert Consilium и анализ архитектуры

| Артефакт | Описание | Дата |
|----------|----------|------|
| [🚀 Quick Start: OpenClaw](QUICKSTART-OPENCLAW.md) | Запуск OpenClaw за 30-60 мин | **СРОЧНО** |
| [Implementation Plan Variant A](analysis/2026-02-11-implementation-plan-variant-a.md) | План Варианта A с учётом замечаний | 2026-02-11 |
| [OpenClaw Expert Consilium Report](analysis/2026-02-11-openclaw-expert-consilium-report.md) | Анализ OpenClaw v2.0, план P0/P1/P2 | 2026-02-11 |
| [Architecture Comparison](analysis/OPENCLAW-ARCHITECTURE-COMPARISON.md) | Сравнение v2.0 vs New | 2026-02-11 |
| [Claude Code Integration](analysis/2026-02-11-claude-code-integration-proposal.md) | Предложение по интеграции | 2026-02-11 |
| [Implementation Plan](analysis/2026-02-11-implementation-plan.md) | План рекомендаций Expert Consilium | 2026-02-11 |

### 🏗️ Architecture
> Архитектура проекта и анализ систем

| Документ | Описание |
|----------|----------|
| [Architecture Analysis](ARCHITECTURE-ANALYSIS.md) | Полный анализ архитектуры |
| [OpenClaw Orchestrator Architecture](OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md) | Архитектура OpenClaw |
| [Remote Server Architecture](remote-server-architecture.md) | Архитектура удалённого сервера |

### 🌐 Remote Operations
> Работа с удалённым сервером и инфраструктурой

| Документ | Описание |
|----------|----------|
| [Remote Paths](REMOTE-PATHS.md) | Пути на удалённом сервере |
| [Shell Aliases](SHELL-ALIASES.md) | Полезные shell aliases |
| [GitHub Actions Secrets Setup](github-actions-secrets-setup.md) | 🔑 Настройка secrets для remote sync |
| [Testing](TESTING.md) | Тестирование проекта |
| [System Update](native-claude-code-sys-update.md) | Обновление Claude Code |

### 🦞 OpenClaw Интеграция

> Полная документация по OpenClaw: [openclaw/README.md](../openclaw/README.md)

| Документ | Описание | Уровень |
|----------|----------|--------|
| [🚀 Quick Start](QUICKSTART-OPENCLAW.md) | **Запуск OpenClaw за 30-60 мин** | ⭐ СРОЧНО |
| [OpenClaw README](../openclaw/README.md) | Главная документация OpenClaw | Категория |
| [Установка на VDS](../openclaw/install/VDS-SETUP.md) | Руководство по установке | 3 клика |
| [Конфигурация](../openclaw/config/README.md) | Настройка OpenClaw | Категория |
| [Workspace Skills](../openclaw/workspace/README.md) | Система скиллов агентов | Категория |
| [Telegram Интеграция](../openclaw/telegram/README.md) | Настройка Telegram бота | Категория |

### 📚 Инструкции (Instruction Modules)

> Главная: [instructions/README.md](../instructions/README.md)

| Категория | Документы |
|-----------|-----------|
| [Сессионные](../instructions/session/README.md) | session-init, session-closure |
| [Режимы работы](../instructions/modes/README.md) | prompt-generation, project-generation |
| [Поддержка](../instructions/support/README.md) | git-operations, quality-framework |

### 🐳 DevOps Инфраструктура

> Главная: [devops/README.md](../devops/README.md)

| Категория | Описание |
|-----------|----------|
| [Docker](../devops/docker/README.md) | Контейнеризация |
| [CI/CD](../devops/ci/README.md) | Пайплайны |
| [Kubernetes](../devops/k8s/README.md) | K8s манифесты |

### 🔄 Automation

> Главная: [automation/README.md](../automation/README.md)

| Категория | Описание |
|-----------|----------|
| [GitOps](../automation/gitops/README.md) | GitOps 2.0 workflows |
| [Scripts](../scripts/README.md) | 📜 Все скрипты + GitHub Secrets setup ⭐ |
| [Hooks](../automation/hooks/README.md) | Git hooks |

### 📊 Observability

> Главная: [observability/README.md](../observability/README.md)

| Категория | Описание |
|-----------|----------|
| [Monitoring](../observability/monitoring/README.md) | Prometheus/Grafana |
| [Logging](../observability/logging/README.md) | Логирование |
| [SLO](../observability/slo/README.md) | SLO/SLI определения |

### 🎨 Шаблоны Проектов

> Главная: [templates/README.md](../templates/README.md)

| Archetype | Описание |
|-----------|----------|
| [AI Agent](../templates/archetypes/ai-agent/README.md) | AI агент шаблон |
| [Web Service](../templates/archetypes/web-service/README.md) | REST API сервис |
| [Data Pipeline](../templates/archetypes/data-pipeline/README.md) | ETL пайплайн |

### 💻 AI IDE Поддержка

> Главная: [ide-support/README.md](../ide-support/README.md)

| IDE | Документация |
|-----|--------------|
| [Claude Code](../ide-support/claude/README.md) | Claude Code CLI |
| [Agent Teams](agents/agent-teams.md) | 🔀 Agent Teams (Opus 4.6) |
| [Agent Teams Integration Plan](reference/agent-teams-integration-plan.md) | 🆕 План интеграции (Phase 15) |
| [Expert Consilium](agents/expert-consilium.quick.md) | 🎓 Экспертные дебаты (13 экспертов) |
| [Cursor](../ide-support/cursor/README.md) | Cursor IDE |
| [Qoder](../ide-support/qoder/README.md) | Qoder IDE |

### 📚 [Reference](reference/) 🆕
> Техническая справка и артефакты проектирования

| Артефакт | Описание | Статус |
|----------|----------|--------|
| [Agent Teams Integration Plan](reference/agent-teams-integration-plan.md) | План интеграции Agent Teams | Phase 15 |
| [OpenClaw + Ollama + Gemini System](reference/openclaw-ollama-gemini-telegram-system.md) | Технический справка | ✅ |

---

## 📋 Поиск по Категориям

### По Роли

| Роль | Рекомендуемые документы |
|------|------------------------|
| **Разработчик** | [instructions/](../instructions/README.md), [devops/](../devops/README.md) |
| **DevOps Engineer** | [devops/](../devops/README.md), [automation/](../automation/README.md) |
| **SRE** | [observability/](../observability/README.md), [automation/gitops/](../automation/gitops/README.md) |
| **Prompt Engineer** | [instructions/modes/](../instructions/modes/README.md), [openclaw/workspace/](../openclaw/workspace/README.md) |
| **AI Researcher** | [PROJECT.md](../PROJECT.md), [openclaw/](../openclaw/README.md) |

### По Задаче

| Задача | Документ |
|--------|----------|
| **Настроить OpenClaw** | [openclaw/install/VDS-SETUP.md](../openclaw/install/VDS-SETUP.md) |
| **Создать новый проект** | [instructions/modes/project-generation.md](../instructions/modes/project-generation.md) |
| **Настроить CI/CD** | [devops/ci/README.md](../devops/ci/README.md) |
| **Добавить мониторинг** | [observability/monitoring/README.md](../observability/monitoring/README.md) |
| **Интегрировать IDE** | [ide-support/](../ide-support/README.md) |

---

## 🗺️ Полная Карта Навигации

Интерактивная карта навигации: [docs/nav/nav-map.md](nav/nav-map.md)

---

## 📖 Правила Документации

- [Навигация (3 клика)](NAVIGATION.md)
- [Правила форматирования](rules/documentation-rules.md)
- [Шаблоны документов](rules/templates.md)

---

## 🔄 История Изменений

Последнее обновление: 2026-02-11

Изменения:
- ✅ **[2026-02-11]** 🚀 **Quick Start OpenClaw** — запуск за 30-60 мин
- ✅ **[2026-02-11]** 📋 **Implementation Plan Variant A** — прагматичный подход с учётом замечаний
- ✅ **[2026-02-11]** 🔬 **Analysis & Reports** — расширенная секция с отчётами
- ✅ **[2026-02-11]** OpenClaw Expert Consilium Report — анализ v2.0, 75% готовность
- ✅ **[2026-02-10]** 🆕 **Expert Consilium** — система экспертных дебатов (13 экспертов)
- ✅ **[2026-02-10]** Добавлен автоматический скрипт setup-github-secrets.sh
- ✅ **[2026-02-10]** Создана документация scripts/README.md
- ✅ **[2026-02-10]** Добавлена документация по GitHub Actions Secrets Setup
- ✅ Добавлены разделы Sessions и Tasks с архивами (Phase 14 Housekeeping)
- ✅ Добавлена ссылка на Workflow Guide
- ✅ Добавлен раздел OpenClaw
- ✅ Реорганизована навигация по категориям
- ✅ Добавлено правило 3 кликов

---

> [🏠 Главная](../README.md) → [📂 Документация](INDEX.md) → [📄 Индекс](#)
