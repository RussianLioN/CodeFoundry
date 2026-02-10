#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════════════════
# New Project Generator
# Usage: ./scripts/new-project.sh <archetype> <project-name>
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARCHETYPES_DIR="$PROJECT_ROOT/templates/archetypes"

# ────────────────────────────────────────────────────────────────────────────────
# Colors
# ────────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ────────────────────────────────────────────────────────────────────────────────
# Functions
# ────────────────────────────────────────────────────────────────────────────────

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

print_banner() {
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                   🚀 System Prompts - Project Generator                    ║
║                                                                              ║
║              Создаём новый IT проект из готового архетипа                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

usage() {
    cat << EOF
Использование: new-project [--no-claude-profile] <archetype> <project-name>

Флаги:
  --no-claude-profile   Skip .claude/ profile generation

Архетипы:
  web-service       REST/GraphQL API (Node.js/Python/Go)
  ai-agent          AI assistant с RAG (Python)
  data-pipeline     ETL/ELT pipelines (Airflow, dbt)
  telegram-bot      Telegram bot (aiogram)
  presentation      Презентация (Markdown, Reveal.js)
  cli-tool          CLI утилита (Go/Rust/Python)
  microservices     Микросервисы (Istio, gRPC)
  fullstack         Fullstack приложение (Next.js + NestJS)

Примеры:
  new-project web-service my-api
  new-project fullstack my-saas
  new-project telegram-bot my-bot

EOF
    exit 1
}

# ────────────────────────────────────────────────────────────────────────────────
# Validation
# ────────────────────────────────────────────────────────────────────────────────

SKIP_CLAUDE_PROFILE=false

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-claude-profile)
            SKIP_CLAUDE_PROFILE=true
            shift
            ;;
        -*)
            log_error "Unknown flag: $1"
            usage
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -ne 2 ]; then
    usage
fi

ARCHETYPE="$1"
PROJECT_NAME="$2"

# Validate archetype
if [ ! -d "$ARCHETYPES_DIR/$ARCHETYPE" ]; then
    log_error "Архетип '$ARCHETYPE' не найден"
    echo ""
    log_info "Доступные архетипы:"
    for dir in "$ARCHETYPES_DIR"/*; do
        if [ -d "$dir" ]; then
            echo "  - $(basename "$dir")"
        fi
    done
    exit 1
fi

# Validate project name
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    log_error "Имя проекта должно содержать только lowercase, цифры и дефисы"
    exit 1
fi

# Check if project directory already exists
PROJECT_DIR="$(pwd)/$PROJECT_NAME"
if [ -d "$PROJECT_DIR" ]; then
    log_error "Директория '$PROJECT_NAME' уже существует"
    exit 1
fi

# ────────────────────────────────────────────────────────────────────────────────
# Main Script
# ────────────────────────────────────────────────────────────────────────────────

print_banner

log_info "Архетип: $ARCHETYPE"
log_info "Проект: $PROJECT_NAME"
log_info "Директория: $PROJECT_DIR"
echo ""

# 1. Create project directory
log_info "Создаём директорию проекта..."
mkdir -p "$PROJECT_DIR"
log_success "Директория создана: $PROJECT_DIR"

# 2. Copy archetype files
log_info "Копируем файлы архетипа..."
cp -r "$ARCHETYPES_DIR/$ARCHETYPE"/* "$PROJECT_DIR/"
log_success "Файлы скопированы"

# 3. Remove .git directory if exists
log_info "Удаляем .git из архетипа..."
rm -rf "$PROJECT_DIR/.git"

# 4. Initialize git repository
log_info "Инициализируем Git репозиторий..."
cd "$PROJECT_DIR"
git init -q
git config user.name "System Prompts"
git config user.email "system@prompts.local"
log_success "Git репозиторий инициализирован"

# 5. Create initial commit
log_info "Создаём initial commit..."
git add -A
git commit -q -m "Initial commit from $ARCHETYPE archetype"
log_success "Initial commit создан"

# 6. Copy OpenClaw workspace files
log_info "Копируем OpenClaw конфигурацию..."
mkdir -p "$PROJECT_DIR/openclaw/workspace"
cp -r "$PROJECT_ROOT/openclaw/workspace"/* "$PROJECT_DIR/openclaw/workspace/" 2>/dev/null || true
log_success "OpenClaw конфигурация скопирована"

# 7. Copy GitOps configuration
log_info "Копируем GitOps конфигурацию..."
mkdir -p "$PROJECT_DIR/gitops"
cp -r "$PROJECT_ROOT/templates/archetypes/shared/gitops"/* "$PROJECT_DIR/gitops/" 2>/dev/null || true
log_success "GitOps конфигурация скопирована"

# 7.5. Generate .claude/ profile
if [ "$SKIP_CLAUDE_PROFILE" = false ]; then
    PROFILE_TEMPLATE_DIR="$PROJECT_ROOT/templates/claude-profile"
    if [ -d "$PROFILE_TEMPLATE_DIR/base" ]; then
        log_info "Генерируем .claude/ профиль..."
        python3 "$PROJECT_ROOT/scripts/generate-claude-profile.py" \
            --archetype "$ARCHETYPE" \
            --project-name "$PROJECT_NAME" \
            --project-dir "$PROJECT_DIR" \
            --template-dir "$PROFILE_TEMPLATE_DIR"
        log_success ".claude/ профиль сгенерирован"
    else
        log_warn "Шаблоны профиля не найдены, пропускаем генерацию .claude/"
    fi
else
    log_info "Генерация .claude/ профиля пропущена (--no-claude-profile)"
fi

# 8. Create project-specific files
log_info "Создаём проектные файлы..."

# PROJECT.md
cat > "$PROJECT_DIR/PROJECT.md" << EOF
# 📋 Project: $PROJECT_NAME

> Archetype: $ARCHETYPE
> Created: $(date +%Y-%m-%d)

## Overview

Описание вашего проекта.

## Tech Stack

- **Архетип:** $ARCHETYPE
- **Язык:** TBD
- **Фреймворки:** TBD

## Quick Start

\`\`\`bash
# Установка зависимостей
make install

# Запуск разработки
make dev

# Тесты
make test
\`\`\`

## Documentation

- [📋 TASKS.md](TASKS.md) — Задачи проекта
- [💬 SESSION.md](SESSION.md) — История сессий
- [📝 CHANGELOG.md](CHANGELOG.md) — История изменений

## OpenClaw

Этот проект использует OpenClaw для AI-ассистированной разработки.

См. [openclaw/README.md](openclaw/README.md) для деталей.
EOF

# TASKS.md
cat > "$PROJECT_DIR/TASKS.md" << EOF
# 📋 Трекер Задач - $PROJECT_NAME

> [🏠 Главная](README.md) → [📋 TASKS.md](#)

---

## Статус Проекта: В РАЗРАБОТКЕ

**Архетип:** $ARCHETYPE
**Дата создания:** $(date +%Y-%m-%d)

---

## 🎯 Первоочередные Задачи

### SETUP-001: Initial Setup ⏳
- **Статус:** ЗАПЛАНИРОВАНО
- **Описание:** Первоначальная настройка проекта
- **Задачи:**
  - [ ] Настроить переменные окружения
  - [ ] Установить зависимости
  - [ ] Настроить базу данных
  - [ ] Запустить приложение локально

---

## 📋 Легенда Статусов

- ⏳ **ОЖИДАЕТ** — Еще не начато
- 🔄 **В_РАБОТЕ** — Сейчас работаем над этим
- ✅ **ВЫПОЛНЕНО** — Успешно завершено
- ❌ **ЗАБЛОКИРОВАНО** — Ожидание зависимости

---

> [🏠 Главная](README.md) → [📋 TASKS.md](#)
EOF

# SESSION.md
cat > "$PROJECT_DIR/SESSION.md" << EOF
# 💬 Session History - $PROJECT_NAME

> [🏠 Главная](README.md) → [💬 SESSIONS](#)

---

## Sessions

### Session #1 - Project Creation
**Дата:** $(date +%Y-%m-%d)
**Участники:** System Prompts
**Цель:** Создание проекта из архетипа $ARCHETYPE

**Решения:**
- Проект создан из архетипа
- OpenClaw конфигурация скопирована
- Git репозиторий инициализирован

**Next Steps:**
- Настроить переменные окружения
- Установить зависимости
- Запустить приложение

---

## 📋 Session Template

\`\`\`
### Session #N - [Title]
**Дата:** YYYY-MM-DD
**Участники:**
**Цель:**

**Обсуждение:**

**Решения:**

**Next Steps:**
\`\`\`

---

> [🏠 Главная](README.md) → [💬 SESSIONS](#)
EOF

# CHANGELOG.md
cat > "$PROJECT_DIR/CHANGELOG.md" << EOF
# 📝 Changelog - $PROJECT_NAME

Все заметные изменения этого проекта будут задокументированы в этом файле.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru-RU/1.0.0/),
и этот проект придерживается [Semantic Versioning](https://semver.org/lang/ru-RU/).

## [Unreleased]

### Added
- Проект создан из архетипа \`$ARCHETYPE\`
- OpenClaw интеграция
- Initial project structure

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 0.1.0 | $(date +%Y-%m-%d) | Initial release |

---

> [🏠 Главная](README.md) → [📝 CHANGELOG.md](#)
EOF

log_success "Проектные файлы созданы"

# 8. Create README.md if not exists
if [ ! -f "$PROJECT_DIR/README.md" ]; then
    cat > "$PROJECT_DIR/README.md" << EOF
# $PROJECT_NAME

> **Архетип:** $ARCHETYPE
> **Создан:** $(date +%Y-%m-%d)

## Quick Start

\`\`\`bash
# Клонирование репозитория
git clone <repo-url> $PROJECT_NAME
cd $PROJECT_NAME

# Установка зависимостей
make install

# Запуск разработки
make dev
\`\`\`

## Документация

- [📋 Project](PROJECT.md) — Описание проекта
- [📋 Tasks](TASKS.md) — Задачи
- [💬 Sessions](SESSION.md) — История сессий
- [📝 Changelog](CHANGELOG.md) — Изменения
- [🦞 OpenClaw](openclaw/README.md) — AI-ассистент

## Лицензия

MIT
EOF
    log_success "README.md создан"
fi

# 9. Make scripts executable
log_info "Делаем скрипты исполняемыми..."
find "$PROJECT_DIR" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
log_success "Скрипты исполняемые"

# 10. Summary
echo ""
log_success "═══════════════════════════════════════════════════════════════════"
log_success "🎉 Проект '$PROJECT_NAME' успешно создан!"
log_success "═══════════════════════════════════════════════════════════════════"
echo ""
log_info "Дальнейшие шаги:"
echo ""
echo "  1. Перейти в проект:"
echo "     ${GREEN}cd $PROJECT_NAME${NC}"
echo ""
echo "  2. Настроить переменные окружения:"
echo "     ${GREEN}cp .env.example .env${NC}"
echo "     ${GREEN}# Отредактируйте .env${NC}"
echo ""
echo "  3. Установить зависимости:"
echo "     ${GREEN}make install${NC}"
echo ""
echo "  4. Запустить разработку:"
echo "     ${GREEN}make dev${NC}"
echo ""
echo "  5. Создать GitHub репозиторий и запушить:"
echo "     ${GREEN}make sync-github${NC}"
echo ""
echo "  6. (Опционально) Настроить GitOps для production:"
echo "     ${GREEN}./gitops/scripts/gitops-bootstrap.sh${NC}"
echo "     ${GREEN}kubectl apply -f gitops/application.yaml${NC}"
echo ""
echo "📚 Документация:"
echo "  - openclaw/README.md — Как использовать OpenClaw"
echo "  - README.md — Общая информация о проекте"
echo "  - gitops/README.md — GitOps руководство"
if [ "$SKIP_CLAUDE_PROFILE" = false ] && [ -d "$PROJECT_DIR/.claude" ]; then
echo "  - .claude/ — AI agent profile (Claude Code integration)"
fi
echo ""
