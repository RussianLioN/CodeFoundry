#!/bin/bash
################################################################################
# OpenClaw VDS Installation Script
################################################################################
# Автоматическая установка OpenClaw на Linux VDS
# Для: Ubuntu 22.04+, Debian 12+, AlmaLinux 9+
#
# Использование:
#   curl -fsSL https://raw.githubusercontent.com/.../install-openclaw.sh | bash
#   или
#   ./install-openclaw.sh
#
# Navigation: Главная → OpenClaw → Скрипты
################################################################################

set -e  # Выход при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Логирование
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_warning "Рекомендуется запускать от root или с sudo"
        read -p "Продолжить? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Определение ОС
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    else
        log_error "Не удалось определить ОС"
        exit 1
    fi

    log_info "Обнаружена ОС: $OS $OS_VERSION"
}

# Установка зависимостей
install_dependencies() {
    log_info "Установка зависимостей..."

    case $OS in
        ubuntu|debian)
            apt update
            apt install -y \
                curl \
                wget \
                git \
                nodejs \
                npm \
                docker.io \
                docker-compose \
                python3 \
                python3-pip \
                ufw \
                fail2ban
            ;;
        almalinux|rocky|centos)
            dnf install -y \
                curl \
                wget \
                git \
                nodejs \
                npm \
                docker \
                python3 \
                python3-pip \
                fail2ban
            ;;
        *)
            log_error "Неподдерживаемая ОС: $OS"
            exit 1
            ;;
    esac

    log_success "Зависимости установлены"
}

# Установка Tailscale
install_tailscale() {
    log_info "Установка Tailscale..."

    case $OS in
        ubuntu|debian)
            curl -fsSL https://tailscale.com/install.sh | sh
            ;;
        almalinux|rocky|centos)
            curl -fsSL https://tailscale.com/install.sh | sh
            ;;
    esac

    log_success "Tailscale установлен"
}

# Установка OpenClaw
install_openclaw() {
    log_info "Установка OpenClaw..."

    # Проверка Node.js версии
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 20 ]; then
        log_error "Требуется Node.js 20+, установлена версия: $(node -v)"
        exit 1
    fi

    # Установка OpenClaw глобально
    npm install -g openclaw@latest

    # Проверка установки
    if command -v openclaw &> /dev/null; then
        log_success "OpenClaw установлен: $(openclaw --version)"
    else
        log_error "Не удалось установить OpenClaw"
        exit 1
    fi
}

# Настройка systemd
setup_systemd() {
    log_info "Настройка systemd service..."

    # Создаём пользователя для OpenClaw (если не root)
    if [ "$EUID" -eq 0 ]; then
        useradd -r -s /bin/bash -d /opt/openclaw openclaw 2>/dev/null || true
        USER=openclaw
    else
        USER=$USER
    fi

    # systemd unit для пользователя
    cat > /tmp/openclaw.service <<'EOF'
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
ExecStart=$(which openclaw) gateway --port 18789 --verbose
Restart=always
RestartSec=10
Environment=NODE_ENV=production

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

[Install]
WantedBy=default.target
EOF

    # Установка service
    if [ "$EUID" -eq 0 ]; then
        mv /tmp/openclaw.service /etc/systemd/system/openclaw.service
        systemctl daemon-reload
        systemctl enable openclaw.service
        log_success "OpenClaw service создан"
    else
        log_warning "Не root пользователь. Создаём user service..."
        mkdir -p ~/.config/systemd/user/
        mv /tmp/openclaw.service ~/.config/systemd/user/openclaw.service
        systemctl --user daemon-reload
        systemctl --user enable openclaw.service
        log_success "OpenClaw user service создан"
    fi
}

# Настройка Firewall
setup_firewall() {
    log_info "Настройка firewall..."

    if command -v ufw &> /dev/null; then
        # Ubuntu/Debian
        ufw allow 22/tcp comment 'SSH'
        ufw allow 18789/tcp comment 'OpenClaw Gateway'
        ufw --force enable
        log_success "UFW настроен"
    elif command -v firewall-cmd &> /dev/null; then
        # AlmaLinux/Rocky
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --permanent --add-port=18789/tcp
        firewall-cmd --reload
        log_success "Firewalld настроен"
    fi
}

# Создаём директорию workspace
setup_workspace() {
    log_info "Создание workspace..."

    WORKSPACE_ROOT="/opt/openclaw/workspace"
    if [ "$EUID" -ne 0 ]; then
        WORKSPACE_ROOT="$HOME/openclaw/workspace"
    fi

    mkdir -p "$WORKSPACE_ROOT"
    mkdir -p "$WORKSPACE_ROOT/skills"
    mkdir -p "$WORKSPACE_ROOT/projects"

    # Копируем skills из репозитория
    if [ -d "$(dirname "$0")/../workspace/skills" ]; then
        cp -r "$(dirname "$0")/../workspace/skills"/* "$WORKSPACE_ROOT/skills/"
        log_success "Skills скопированы в workspace"
    fi

    echo "$WORKSPACE_ROOT" > /tmp/openclaw_workspace.txt
}

# Конфигурация OpenClaw
setup_config() {
    log_info "Создание конфигурации OpenClaw..."

    CONFIG_DIR="$HOME/.openclaw"
    if [ "$EUID" -eq 0 ]; then
        CONFIG_DIR="/opt/openclaw/.openclaw"
    fi

    mkdir -p "$CONFIG_DIR"

    # Базовая конфигурация
    cat > "$CONFIG_DIR/openclaw.json" <<EOF
{
  "gateway": {
    "bind": "127.0.0.1",
    "port": 18789,
    "tailscale": {
      "mode": "off",
      "resetOnExit": false
    }
  },
  "agent": {
    "model": "anthropic/claude-opus-4-5",
    "defaults": {
      "workspace": "$(cat /tmp/openclaw_workspace.txt)",
      "thinkingLevel": "medium"
    }
  },
  "channels": {
    "telegram": {
      "botToken": "",
      "allowFrom": [],
      "webhookUrl": ""
    }
  },
  "browser": {
    "enabled": false
  },
  "logging": {
    "level": "info"
  }
}
EOF

    log_success "Конфигурация создана: $CONFIG_DIR/openclaw.json"
    log_warning "Отредактируйте конфигурацию и добавьте TELEGRAM_BOT_TOKEN"
}

# Tailscale setup
setup_tailscale_auth() {
    log_info "Настройка Tailscale..."
    log_info "Для настройки Tailscale выполните:"
    echo ""
    echo "  tailscale up --authkey=<YOUR_AUTH_KEY>"
    echo ""
    log_info "Получить auth key: https://login.tailscale.com/admin/settings/keys"

    read -p "Настроить Tailscale сейчас? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Введите Tailscale Auth Key: " TS_AUTH_KEY
        if [ -n "$TS_AUTH_KEY" ]; then
            tailscale up --authkey="$TS_AUTH_KEY" \
                --hostname=openclaw-vds \
                --advertise-exit-node=false \
                --accept-routes
            log_success "Tailscale настроен"
            log_info "Tailnet IP: $(tailscale ip -4)"
        fi
    fi
}

# Telegram setup
setup_telegram_bot() {
    log_info "Настройка Telegram бота..."
    log_info "Для создания бота:"
    echo "  1. Откройте @BotFather в Telegram"
    echo "  2. Отправьте /newbot"
    echo "  3. Следуйте инструкциям"
    echo "  4. Получите BOT_TOKEN"
    echo ""

    read -p "Введите Telegram BOT_TOKEN (или Enter для пропуска): " BOT_TOKEN

    if [ -n "$BOT_TOKEN" ]; then
        CONFIG_DIR="$HOME/.openclaw"
        if [ "$EUID" -eq 0 ]; then
            CONFIG_DIR="/opt/openclaw/.openclaw"
        fi

        # Обновляем конфигурацию
        if command -v jq &> /dev/null; then
            jq --arg token "$BOT_TOKEN" '.channels.telegram.botToken = $token' \
                "$CONFIG_DIR/openclaw.json" > "$CONFIG_DIR/openclaw.json.tmp"
            mv "$CONFIG_DIR/openclaw.json.tmp" "$CONFIG_DIR/openclaw.json"
        else
            log_warning "jq не установлен. Отредактируйте конфигурацию вручную:"
            echo "  channels.telegram.botToken = \"$BOT_TOKEN\""
        fi

        log_success "Telegram бот настроен"
    else
        log_warning "Telegram бот не настроён. Настройте позже:"
        echo "  ./openclaw/scripts/setup-telegram.sh"
    fi
}

# Установка завершена
installation_complete() {
    log_success "=========================================="
    log_success "OpenClaw установлен на VDS!"
    log_success "=========================================="
    echo ""
    echo "📋 Следующие шаги:"
    echo ""
    echo "1️⃣  Запустите мастер настройки:"
    echo "   openclaw onboard"
    echo ""
    echo "2️⃣  Запустите OpenClaw:"
    if [ "$EUID" -eq 0 ]; then
        echo "   systemctl start openclaw"
    else
        echo "   systemctl --user start openclaw"
    fi
    echo ""
    echo "3️⃣  Проверьте статус:"
    echo "   systemctl status openclaw"
    echo ""
    echo "4️⃣  Настройте Tailscale (для удалённого доступа):"
    echo "   tailscale up --authkey=<YOUR_KEY>"
    echo ""
    echo "5️⃣  Настройте Telegram бот:"
    echo "   ./openclaw/scripts/setup-telegram.sh"
    echo ""
    echo "📚 Документация:"
    echo "   openclaw/README.md"
    echo ""

    # Создаём файл с информацией об установке
    cat > /tmp/openclaw_install_info.txt <<EOF
OpenClaw VDS Installation
========================
Date: $(date)
OS: $OS $OS_VERSION
Node: $(node -v)
NPM: $(npm -v)
OpenClaw: $(openclaw --version)

Workspace: $(cat /tmp/openclaw_workspace.txt)
Config: $CONFIG_DIR

Commands:
  openclaw onboard          - Master настройки
  openclaw gateway          - Запуск Gateway
  openclaw doctor           - Диагностика

Systemd:
  systemctl start openclaw  - Запуск service
  systemctl stop openclaw   - Остановка service
  systemctl status openclaw - Статус service

Logs:
  journalctl -u openclaw -f - Логи в реальном времени

Documentation:
  https://github.com/RussianLioN/CodeFoundry/tree/main/openclaw
EOF

    log_info "Информация об установке сохранена: /tmp/openclaw_install_info.txt"
}

# Главная функция
main() {
    echo ""
    echo "🦞 OpenClaw VDS Installation"
    echo "================================"
    echo ""

    check_root
    detect_os
    install_dependencies
    install_tailscale
    install_openclaw
    setup_systemd
    setup_workspace
    setup_config
    setup_firewall

    echo ""
    read -p "Настроить Tailscale и Telegram сейчас? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_tailscale_auth
        setup_telegram_bot
    fi

    installation_complete
}

# Запуск
main "$@"
