#!/bin/bash
# =============================================================================
# CodeFoundry Remote Server Setup Script
# =============================================================================
# Initial setup for ainetic.tech server
# Installs: Docker, Git, Node.js, and configures project directory
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/your-repo/main/server/setup.sh | bash
#   OR
#   bash setup.sh
#
# Requirements:
#   - Ubuntu/Debian Linux
#   - Root or sudo access
# =============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# =============================================================================
# Configuration
# =============================================================================

PROJECT_NAME="system-prompts"
GITHUB_REPO="git@github.com:your-username/${PROJECT_NAME}.git"
PROJECT_DIR="$HOME/projects/${PROJECT_NAME}"
DOCKER_COMPOSE_VERSION="v2.24.5"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Logging Functions
# =============================================================================

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

# =============================================================================
# System Checks
# =============================================================================

check_root() {
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        log_error "This script requires root privileges. Please run with sudo."
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Cannot detect OS. /etc/os-release not found."
        exit 1
    fi

    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]] && [[ "$ID" != "debian" ]]; then
        log_warning "This script is designed for Ubuntu/Debian. You're running: $ID"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    log_success "OS detected: $PRETTY_NAME"
}

check_existing_installation() {
    if [[ -d "$PROJECT_DIR" ]]; then
        log_warning "Project directory already exists: $PROJECT_DIR"
        read -p "Remove and reclone? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -rf "$PROJECT_DIR"
        else
            log_info "Using existing project directory"
            return 1
        fi
    fi
    return 0
}

# =============================================================================
# Installation Functions
# =============================================================================

update_system() {
    log_info "Updating system packages..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
    log_success "System updated"
}

install_docker() {
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version | awk '{print $3}' | tr -d ',')
        log_info "Docker already installed: $docker_version"
        return 0
    fi

    log_info "Installing Docker..."

    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # Install dependencies
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Add Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

    # Install Docker Compose
    sudo apt-get install -y docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker $USER

    log_success "Docker installed: $(docker --version)"
    log_warning "You may need to log out and back in for group changes to take effect."
}

install_git() {
    if command -v git &> /dev/null; then
        log_info "Git already installed: $(git --version)"
        return 0
    fi

    log_info "Installing Git..."
    sudo apt-get install -y git
    log_success "Git installed: $(git --version)"
}

install_nodejs() {
    if command -v node &> /dev/null; then
        log_info "Node.js already installed: $(node --version)"
        return 0
    fi

    log_info "Installing Node.js 20.x LTS..."

    # Install NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

    # Install Node.js
    sudo apt-get install -y nodejs

    log_success "Node.js installed: $(node --version)"
    log_success "npm installed: $(npm --version)"
}

install_additional_tools() {
    log_info "Installing additional tools..."

    # Useful tools
    sudo apt-get install -y \
        htop \
        tmux \
        jq \
        ripgrep \
        vim \
        net-tools \
        curl \
        wget

    log_success "Additional tools installed"
}

setup_project_directory() {
    if [[ -d "$PROJECT_DIR" ]]; then
        log_info "Project directory exists: $PROJECT_DIR"
        return 0
    fi

    log_info "Creating project directory..."
    mkdir -p "$HOME/projects"

    # Clone repository
    log_info "Cloning repository from GitHub..."
    git clone "$GITHUB_REPO" "$PROJECT_DIR"

    log_success "Project directory created: $PROJECT_DIR"
}

setup_ssh_keys() {
    if [[ -f "$HOME/.ssh/id_ed25519" ]] || [[ -f "$HOME/.ssh/id_rsa" ]]; then
        log_info "SSH keys already exist"
        return 0
    fi

    log_info "Generating SSH keys..."
    ssh-keygen -t ed25519 -C "$USER@ainetic.tech" -f "$HOME/.ssh/id_ed25519" -N ""

    log_success "SSH keys generated"
    log_info "Public key (add this to GitHub):"
    cat "$HOME/.ssh/id_ed25519.pub"
}

configure_git() {
    log_info "Configuring Git..."

    git config --global user.name "CodeFoundry Bot"
    git config --global user.email "bot@codefoundry.dev"
    git config --global init.defaultBranch main
    git config --global pull.rebase false

    log_success "Git configured"
}

create_environment_file() {
    local env_file="$PROJECT_DIR/server/.env.test"

    if [[ -f "$env_file" ]]; then
        log_info "Environment file exists: $env_file"
        return 0
    fi

    log_info "Creating environment file..."

    cat > "$env_file" << 'EOF'
# =============================================================================
# CodeFoundry Remote Testing Environment
# =============================================================================

# Project Configuration
PROJECT_NAME=system-prompts
PROJECT_DIR=/root/projects/system-prompts
GITHUB_REPO=git@github.com:your-username/system-prompts.git

# Container Configuration
CONTAINER_PREFIX=test
SESSION_TIMEOUT=86400  # 24 hours in seconds

# Docker Configuration
COMPOSE_PROJECT_NAME=codefoundry-test
DOCKER_NETWORK=codefoundry-test-net

# Logging Configuration
LOG_DIR=/var/log/codefoundry
LOG_RETENTION_DAYS=7

# Telegram Bot Configuration (for testing)
TELEGRAM_BOT_TOKEN=your_bot_token_here
AUTHORIZED_USER_IDS=your_user_id_here

# Gateway Configuration
GATEWAY_HOST=0.0.0.0
GATEWAY_PORT=18789
GATEWAY_HEALTH_PORT=18790

# Ollama Configuration (optional)
OLLAMA_ENABLED=false
OLLAMA_MODEL=gemini-3-flash-preview
OLLAMA_HOST=http://ollama:11434
EOF

    log_success "Environment file created: $env_file"
    log_warning "Edit $env_file with your actual values"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  CodeFoundry Remote Server Setup                           ║${NC}"
    echo -e "${BLUE}║  ainetic.tech Initial Configuration                         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Run checks
    check_root
    check_os

    # Install dependencies
    update_system
    install_docker
    install_git
    install_nodejs
    install_additional_tools

    # Setup project
    setup_project_directory
    setup_ssh_keys
    configure_git
    create_environment_file

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Setup Complete!                                           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    log_success "Server is ready for CodeFoundry remote testing!"
    echo ""
    log_info "Next steps:"
    echo "  1. Edit $PROJECT_DIR/server/.env.test with your values"
    echo "  2. Run: cd $PROJECT_DIR && make sync"
    echo "  3. Run: make start-test"
    echo ""
    log_warning "Log out and back in for Docker group changes to take effect."
}

# Run main function
main "$@"
