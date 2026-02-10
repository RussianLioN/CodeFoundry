#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# OpenClaw: IDE Rules Sync Script
# ═══════════════════════════════════════════════════════════════════════════════
# Синхронизирует OpenClaw промпты из workspace/ в IDE-specific файлы
#
# Использование:
#   ./sync-ide-rules.sh [опции]
#
# Опции:
#   -d, --dry-run    Показать что будет сделано, но не выполнять
#   -v, --verbose    Подробный вывод
#   -h, --help       Показать справку
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${SCRIPT_DIR}/../workspace"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "${SCRIPT_DIR}/../..")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Options
DRY_RUN=false
VERBOSE=false

# ═══════════════════════════════════════════════════════════════════════════════
# Functions
# ═══════════════════════════════════════════════════════════════════════════════

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*"
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${GRAY}  →${NC} $*"
    fi
}

show_help() {
    cat << EOF
OpenClaw IDE Rules Sync Script

Синхронизирует промпты OpenClaw из workspace/ в IDE-specific файлы:

  - CLAUDE.md          (Claude Code CLI)
  - .cursorrules       (Cursor IDE)
  - .qoder/rules/QODER.md  (Qoder IDE)
  - QWEN.md            (QWEN Code CLI)
  - .clinerules        (VS Code + Cline)

Использование:
  $0 [опции]

Опции:
  -d, --dry-run    Показать что будет сделано, но не выполнять
  -v, --verbose    Подробный вывод
  -h, --help       Показать эту справку

Примеры:
  $0                    # Синхронизировать все файлы
  $0 --dry-run          # Показать что будет изменено
  $0 --verbose          # Подробный вывод

EOF
}

sync_file() {
    local target="$1"
    local source="$2"
    local name="$3"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Would sync: $target"
        log_verbose "  Source: $source"
        return 0
    fi

    # Создаём директорию если нужно
    local target_dir
    target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log_verbose "Created directory: $target_dir"
    fi

    # Копируем с добавлением заголовка
    {
        echo "# 🦞 OpenClaw System Prompt"
        echo ""
        echo "> Автоматически сгенерировано из: $source"
        echo ""
        echo "**Это автоматическая копия. Источник: openclaw/workspace/**"
        echo ""
        echo "Для изменений редактируйте: $source"
        echo ""
        echo "---"
        echo ""
        cat "$source"
    } > "$target"

    log_success "Synced: $name"
}

sync_ide() {
    local ide_name="$1"
    local target_file="$2"
    local source_file="$3"

    log_info "Syncing $ide_name..."
    sync_file "$target_file" "$source_file" "$ide_name"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Parse Arguments
# ═══════════════════════════════════════════════════════════════════════════════

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Неизвестная опция: $1"
            show_help
            exit 1
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  OpenClaw IDE Rules Sync${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════════${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    log_warn "DRY RUN MODE - Изменения не будут применены"
    echo ""
fi

# Проверяем наличие workspace
if [[ ! -d "$WORKSPACE_DIR" ]]; then
    log_error "Workspace directory not found: $WORKSPACE_DIR"
    exit 1
fi

# Source files
SYSTEM_FILE="${WORKSPACE_DIR}/SYSTEM.md"
SOUL_FILE="${WORKSPACE_DIR}/SOUL.md"

if [[ ! -f "$SYSTEM_FILE" ]]; then
    log_error "SYSTEM.md not found in workspace"
    exit 1
fi

if [[ ! -f "$SOUL_FILE" ]]; then
    log_error "SOUL.md not found in workspace"
    exit 1
fi

# Создаём объединённый контент
TEMP_DIR="$(mktemp -d)"
trap "rm -rf $TEMP_DIR" EXIT

cat "$SYSTEM_FILE" > "${TEMP_DIR}/openclaw-prompts.md"
echo "" >> "${TEMP_DIR}/openclaw-prompts.md"
cat "$SOUL_FILE" >> "${TEMP_DIR}/openclaw-prompts.md"

log_verbose "Workspace: $WORKSPACE_DIR"
log_verbose "Project root: $PROJECT_ROOT"
log_verbose "Temp dir: $TEMP_DIR"
echo ""

# Синхронизируем IDE файлы
sync_ide "CLAUDE.md" \
    "${PROJECT_ROOT}/CLAUDE.md" \
    "${TEMP_DIR}/openclaw-prompts.md"

sync_ide ".cursorrules" \
    "${PROJECT_ROOT}/.cursorrules" \
    "${TEMP_DIR}/openclaw-prompts.md"

sync_ide "QODER.md" \
    "${PROJECT_ROOT}/.qoder/rules/QODER.md" \
    "${TEMP_DIR}/openclaw-prompts.md"

sync_ide "QWEN.md" \
    "${PROJECT_ROOT}/QWEN.md" \
    "${TEMP_DIR}/openclaw-prompts.md"

sync_ide ".clinerules" \
    "${PROJECT_ROOT}/.clinerules" \
    "${TEMP_DIR}/openclaw-prompts.md"

echo ""
echo -e "${GREEN}═════════════════════════════════════════════════════════════${NC}"
if [[ "$DRY_RUN" == true ]]; then
    log_warn "Dry run complete. No files were modified."
else
    log_success "Sync complete! OpenClaw prompts synced to all IDEs."
fi
echo -e "${GREEN}═════════════════════════════════════════════════════════════${NC}"
echo ""
