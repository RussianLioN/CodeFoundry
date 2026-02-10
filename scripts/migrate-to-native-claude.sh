#!/usr/bin/env bash
#
# Claude Code Native Migration Script
#
# Автоматическая миграция с npm на нативную версию Claude Code
# с бэкапированием настроек и фиксацией stable-канала обновлений
#
# Based on: docs/native-claude-code-sys-update.md
#
# Usage:
#   ./scripts/migrate-to-native-claude.sh [--dry-run] [--force]
#
# Options:
#   --dry-run    Показать что будет сделано, не выполняя действий
#   --force      Пропустить подтверждения
#
# Date: 2026-02-03

set -euo pipefail

#######################################
# Конфигурация
#######################################

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BACKUP_DIR="${HOME}/claude-backup-$(date +%Y%m%d-%H%M%S)"
CLAUDE_USER_SETTINGS="${HOME}/.claude/settings.json"
CLAUDE_USER_JSON="${HOME}/.claude.json"
CLAUDE_USER_DIR="${HOME}/.claude"
CLAUDE_BIN="${HOME}/.local/bin/claude"

# Цвета для вывода
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

#######################################
# Функции
#######################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

detect_os_and_arch() {
    local os arch

    case "$(uname -s)" in
        Darwin) os="macOS" ;;
        Linux) os="Linux" ;;
        *) os="Unknown" ;;
    esac

    case "$(uname -m)" in
        arm64|aarch64) arch="arm64" ;;
        x86_64|amd64) arch="x86_64" ;;
        *) arch="unknown" ;;
    esac

    echo "${os}:${arch}"
}

check_prerequisites() {
    log_step "Проверка пререквизитов"

    local missing=()

    if ! command -v curl &> /dev/null; then
        missing+=("curl")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Не установлены необходимые пакеты: ${missing[*]}"
        log_info "Установите их перед запуском скрипта:"
        echo "  macOS: brew install ${missing[*]}"
        echo "  Linux: apt-get install ${missing[*]}"
        exit 1
    fi

    log_success "Все пререквизиты установлены"

    # Проверка jq (опционально)
    if command -v jq &> /dev/null; then
        log_success "jq установлен — будет использован для работы с JSON"
        HAS_JQ=true
    else
        log_warn "jq не установлен — будут использованы базовые средства"
        log_info "Рекомендуется: brew install jq (macOS) или apt-get install jq (Linux)"
        HAS_JQ=false
    fi
}

create_backup() {
    log_step "Создание бэкапа настроек"

    mkdir -p "${BACKUP_DIR}"

    local backed_up=()

    # Копируем .claude.json
    if [ -f "${CLAUDE_USER_JSON}" ]; then
        cp -f "${CLAUDE_USER_JSON}" "${BACKUP_DIR}/"
        backed_up+=(".claude.json")
        log_success "Скопирован: ~/.claude.json"
    else
        log_warn "Файл ~/.claude.json не найден (пропускаем)"
    fi

    # Копируем ~/.claude/ директорию
    if [ -d "${CLAUDE_USER_DIR}" ]; then
        cp -rf "${CLAUDE_USER_DIR}" "${BACKUP_DIR}/"
        backed_up+=(".claude/")
        log_success "Скопирована: ~/.claude/"
    else
        log_warn "Директория ~/.claude не найдена (пропускаем)"
    fi

    # Явно копируем settings.json, если есть
    if [ -f "${CLAUDE_USER_SETTINGS}" ]; then
        cp -f "${CLAUDE_USER_SETTINGS}" "${BACKUP_DIR}/settings-user.json"
        backed_up+=("~/.claude/settings.json")
        log_success "Скопирован: ~/.claude/settings.json"
    fi

    # Проверяем бэкап проекта
    if [ -f "${PROJECT_ROOT}/.claude/settings.json" ]; then
        mkdir -p "${BACKUP_DIR}/project-settings"
        cp -f "${PROJECT_ROOT}/.claude/settings.json" "${BACKUP_DIR}/project-settings/"
        backed_up+=("project .claude/settings.json")
        log_success "Скопирован: проект .claude/settings.json"
    fi

    echo ""
    log_success "Бэкап создан: ${BACKUP_DIR}"
    log_info "Сохранено файлов: ${#backed_up[@]}"

    if [ "${DRY_RUN}" = "true" ]; then
        ls -la "${BACKUP_DIR}"
    fi
}

remove_npm_version() {
    log_step "Удаление npm-версии (если установлена)"

    local npm_claude
    npm_claude=$(npm list -g 2>/dev/null | grep -i claude || true)

    if [ -z "${npm_claude}" ]; then
        log_info "npm-версия Claude Code не найдена"
        return 0
    fi

    log_warn "Найдена npm-версия:"
    echo "${npm_claude}"

    if [ "${FORCE}" != "true" ]; then
        echo ""
        read -p "Удалить npm-версию? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warn "Пропуск удаления npm-версии"
            return 0
        fi
    fi

    log_info "Удаление @anthropic-ai/claude-code..."
    if [ "${DRY_RUN}" = "true" ]; then
        echo "[DRY-RUN] npm uninstall -g @anthropic-ai/claude-code"
    else
        npm uninstall -g @anthropic-ai/claude-code || {
            log_warn "Не удалось удалить через npm, пробуем вручную..."
            npm list -g --depth=0 | grep -i claude | awk '{print $1}' | xargs npm uninstall -g 2>/dev/null || true
        }
    fi

    log_success "npm-версия удалена (или была установлена частично)"
}

install_native() {
    log_step "Установка нативной версии Claude Code"

    local os_arch
    os_arch=$(detect_os_and_arch)
    local os="${os_arch%%:*}"
    local arch="${os_arch##*:}"

    log_info "Обнаружено: ${os_arch}"

    if [ "${DRY_RUN}" = "true" ]; then
        echo "[DRY-RUN] curl -fsSL https://claude.ai/install.sh | bash"
        return 0
    fi

    log_info "Загрузка и установка через официальный скрипт..."
    if curl -fsSL https://claude.ai/install.sh | bash; then
        log_success "Нативная версия установлена"
    else
        log_error "Не удалось установить нативную версию"
        log_info "Проверьте соединение с интернетом и попробуйте снова"
        exit 1
    fi
}

set_stable_channel() {
    log_step "Фиксация канала обновлений на stable"

    local settings_file="${CLAUDE_USER_SETTINGS}"

    # Создаём директорию если нет
    if [ "${DRY_RUN}" != "true" ]; then
        mkdir -p "$(dirname "${settings_file}")"
    fi

    # Проверяем текущее значение
    local current_channel
    if [ "${HAS_JQ}" = true ] && [ -f "${settings_file}" ]; then
        current_channel=$(jq -r '.autoUpdatesChannel // "not set"' "${settings_file}" 2>/dev/null || echo "not set")
        log_info "Текущий канал: ${current_channel}"
    fi

    if [ "${DRY_RUN}" = "true" ]; then
        echo "[DRY-RUN] Установка autoUpdatesChannel = \"stable\" в ${settings_file}"
        return 0
    fi

    # Устанавливаем stable
    if [ -f "${settings_file}" ]; then
        # Файл существует - обновляем
        if [ "${HAS_JQ}" = true ]; then
            local tmp
            tmp=$(mktemp)
            jq '.autoUpdatesChannel = "stable"' "${settings_file}" > "${tmp}" && mv "${tmp}" "${settings_file}"
            chmod 600 "${settings_file}"
        else
            # Без jq - простая замена или добавление
            if grep -q "autoUpdatesChannel" "${settings_file}" 2>/dev/null; then
                # Заменяем существующее значение
                sed -i.bak 's/"autoUpdatesChannel"\s*:\s*"[^"]*"/"autoUpdatesChannel": "stable"/g' "${settings_file}"
                rm -f "${settings_file}.bak"
            else
                # Добавляем в существующий JSON
                # Простейший вариант - добавляем запятую к последней строке перед } и добавляем поле
                sed -i.bak '$s/}\s*$/,\n  "autoUpdatesChannel": "stable"\n}/' "${settings_file}" 2>/dev/null || true
                rm -f "${settings_file}.bak"
            fi
            chmod 600 "${settings_file}"
        fi
    else
        # Файл не существует - создаём
        cat > "${settings_file}" << 'EOF'
{
  "autoUpdatesChannel": "stable"
}
EOF
        chmod 600 "${settings_file}"
    fi

    log_success "Канал обновлений установлен на stable"

    # Показываем результат
    if [ -f "${settings_file}" ]; then
        echo ""
        log_info "Содержимое ~/.claude/settings.json:"
        cat "${settings_file}"
    fi
}

verify_installation() {
    log_step "Проверка корректности установки"

    local os_arch
    os_arch=$(detect_os_and_arch)
    local os="${os_arch%%:*}"
    local arch="${os_arch##*:}"

    # Проверка наличия бинарника
    if [ ! -f "${CLAUDE_BIN}" ]; then
        log_error "Бинарник не найден: ${CLAUDE_BIN}"
        log_info "Возможно, ~/.local/bin не в PATH. Проверьте:"
        echo "  echo \$PATH"
        echo "  which claude"
        return 1
    fi

    log_success "Бинарник найден: ${CLAUDE_BIN}"

    # Проверка архитектуры
    local bin_arch
    bin_arch=$(file "${CLAUDE_BIN}" 2>/dev/null || echo "unknown")

    echo ""
    log_info "Архитектура бинарника:"
    echo "  ${bin_arch}"

    # Проверка на Apple Silicon
    if [ "${os}" = "macOS" ] && [ "${arch}" = "arm64" ]; then
        if echo "${bin_arch}" | grep -q "x86_64"; then
            log_error "ОБНАРУЖЕНА x86_64 версия на Apple Silicon!"
            log_error "Это вызовет ошибку 'CPU lacks AVX support'"
            echo ""
            log_warn "Решение: переустановите с канала stable:"
            echo "  1. Убедитесь что autoUpdatesChannel = \"stable\""
            echo "  2. Переустановите: curl -fsSL https://claude.ai/install.sh | bash"
            return 1
        elif echo "${bin_arch}" | grep -q "arm64"; then
            log_success "Архитектура корректна: arm64 на Apple Silicon"
        else
            log_warn "Не удалось определить архитектуру"
        fi
    fi

    # Проверка версии
    echo ""
    log_info "Проверка версии:"
    if "${CLAUDE_BIN}" --version 2>&1; then
        log_success "Claude Code запускается корректно"
    else
        log_warn "Возможны проблемы при запуске"
    fi
}

show_summary() {
    log_step "Итоги миграции"

    echo ""
    echo "📦 Бэкап настроек: ${BACKUP_DIR}"
    echo ""
    echo "📝 Что было сделано:"
    echo "  ✅ Создан бэкап пользовательских настроек"
    echo "  ✅ Удалена npm-версия (если была установлена)"
    echo "  ✅ Установлена нативная версия Claude Code"
    echo "  ✅ Канал обновлений зафиксирован на stable"
    echo ""
    echo "🔧 Следующие шаги:"
    echo "  1. Проверьте версию: claude --version"
    echo "  2. Откройте проект: cd ${PROJECT_ROOT} && claude"
    echo ""
    echo "📚 Полная документация: docs/native-claude-code-sys-update.md"
    echo ""
    echo "🔄 Откат изменений (если нужно):"
    echo "  cp -r ${BACKUP_DIR}/.claude* ~/"
    echo ""

    if [ "${os}" = "macOS" ] && [ "${arch}" = "arm64" ]; then
        echo -e "${YELLOW}⚠️  ВАЖНО ДЛЯ APPLE SILICON:${NC}"
        echo "  Канал обновлений установлен на stable для предотвращения"
        echo "  установки x86_64 версии. Обновляйтесь вручную при необходимости."
        echo ""
    fi
}

#######################################
# Парсинг аргументов
#######################################

DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            cat << EOF
Использование: ${SCRIPT_NAME} [OPTIONS]

Автоматическая миграция Claude Code с npm на нативную версию.

Options:
  --dry-run    Показать что будет сделано, не выполняя действий
  --force      Пропустить подтверждения
  -h, --help   Показать эту справку

Examples:
  ${SCRIPT_NAME}              # Интерактивный режим
  ${SCRIPT_NAME} --dry-run    # Проверка без изменений
  ${SCRIPT_NAME} --force      # Автоматический режим без вопросов

EOF
            exit 0
            ;;
        *)
            log_error "Неизвестный параметр: $1"
            echo "Используйте --help для справки"
            exit 1
            ;;
    esac
done

#######################################
# Главное выполнение
#######################################

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║   Claude Code Native Migration Script                     ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    local os_arch
    os_arch=$(detect_os_and_arch)
    echo "🖥️  Платформа: ${os_arch}"
    echo "📁 Проект: ${PROJECT_ROOT}"
    echo ""

    if [ "${DRY_RUN}" = "true" ]; then
        log_warn "РЕЖИМ DRY-RUN - никаких изменений не будет"
    fi

    if [ "${FORCE}" != "true" ] && [ "${DRY_RUN}" != "true" ]; then
        echo "Этот скрипт выполнит следующее:"
        echo "  1. Создаст бэкап настроек Claude Code"
        echo "  2. Удалит npm-версию (если установлена)"
        echo "  3. Установит нативную версию"
        echo "  4. Зафиксирует канал обновлений на stable"
        echo ""
        read -p "Продолжить? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Отменено пользователем"
            exit 0
        fi
    fi

    # Шаги миграции
    check_prerequisites
    create_backup
    remove_npm_version
    install_native
    set_stable_channel
    verify_installation
    show_summary

    log_success "Миграция завершена!"
}

# Запуск
main "$@"
