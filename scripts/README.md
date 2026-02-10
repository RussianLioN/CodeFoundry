> [🏠 Главная](../README.md) → [🔄 Automation](../automation/README.md) → **Scripts**

---

# Scripts Directory

> Автоматизационные скрипты для CodeFoundry

---

## 🚀 Quick Reference

### Project Creation

| Скрипт | Описание | Использование |
|--------|----------|---------------|
| `new-project.sh` | Создание нового проекта из архетипа | `./scripts/new-project.sh <archetype> <name>` |
| `generate-agents.py` | Генерация AI агентов | `./scripts/generate-agents.py` |
| `generate-claude-profile.py` | Генерация Claude Profile | `./scripts/generate-claude-profile.py --archetype <type>` |

### Quality & Validation

| Скрипт | Описание | Использование |
|--------|----------|---------------|
| `quality-gates.sh` | Проверка качества (все gates) | `make gate-blocking` |
| `check-refs.py` | Проверка @ref ссылок | `python3 scripts/check-refs.py` |

### Git Operations

| Скрипт | Описание | Использование |
|--------|----------|---------------|
| `git/sync.sh` | Git sync (fetch + status) | `./scripts/git/sync.sh` |
| `git/commit.sh` | Git commit с правилами | `./scripts/git/commit.sh` |

### DevOps & Deployment

| Скрипт | Описание | Использование |
|--------|----------|---------------|
| `setup-github-secrets.sh` | ⭐ Настройка GitHub Secrets | `./scripts/setup-github-secrets.sh` |
| `remote/ssh.sh` | SSH подключение к ainetic.tech | `./scripts/remote/ssh.sh` |
| `backup-coordinator.sh` | Координация бэкапов | `./scripts/backup-coordinator.sh` |

---

## ⭐ GitHub Actions Secrets Setup

**Новый скрипт для автоматической настройки remote sync!**

```bash
./scripts/setup-github-secrets.sh
```

**Что делает:**
- ✅ Проверяет prerequisites (gh CLI, SSH доступ)
- ✅ Читает существующий SSH ключ `~/.ssh/id_n8n_servers`
- ✅ Добавляет secrets: `REMOTE_HOST`, `REMOTE_USER`, `SSH_PRIVATE_KEY`, `SSH_PORT`, `REMOTE_PATH`
- ✅ Проверяет результат

**Подробнее:** [@ref: docs/github-actions-secrets-setup.md](../docs/github-actions-secrets-setup.md)

---

## 📋 Полный список скриптов

### Python Scripts (`.py`)

| Файл | Описание |
|------|----------|
| `analyze-agent-needs.py` | Анализ требований к агентам |
| `auto-track.py` | Автоматический трекинг задач |
| `check-refs.py` | Проверка целостности @ref ссылок |
| `generate-agents.py` | Генерация конфигурации агентов |
| `generate-claude-profile.py` | Генератор Claude Profiles |

### Shell Scripts (`.sh`)

| Файл | Описание |
|------|----------|
| `new-project.sh` | Создание нового проекта |
| `quality-gates.sh` | Единый фреймворк quality gates |
| `setup-github-secrets.sh` | Настройка GitHub Secrets |
| `backup-coordinator.sh` | Координатор бэкапов |
| `migrate-to-native-claude.sh` | Миграция на native Claude Code |
| `diagnose.sh` | Диагностика проблем |
| `check-alpine-compatibility.sh` | Проверка совместимости с Alpine |

### Subdirectories

| Директория | Содержимое |
|------------|------------|
| `backup/` | Скрипты бэкапа |
| `git/` | Git операции |
| `remote/` | Remote operations |
| `backups/` | Хранилище бэкапов |

---

## 🔧 Common Patterns

### Запуск с dry-run

```bash
# Проверить что будет сделано
./scripts/setup-github-secrets.sh --dry-run
```

### Запуск с verbose output

```bash
# Подробный вывод
bash -x ./scripts/quality-gates.sh
```

### Makefile shortcuts

```bash
# Quality gates
make gate-blocking   # Только blocking checks
make gate-all        # Все checks
make gate-info       # Информация о состоянии
```

---

## 📚 Связанная документация

- [Automation Overview](../automation/README.md)
- [GitOps Workflow](../automation/gitops/README.md)
- [Quality Framework](../instructions/quality-framework.md)
- [GitHub Actions Secrets Setup](../docs/github-actions-secrets-setup.md)

---

**Последнее обновление:** 2026-02-10
