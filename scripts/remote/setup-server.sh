#!/bin/bash
#
# OpenClaw Remote Server Setup Script
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/RussianLioN/CodeFoundry/main/scripts/remote/setup-server.sh | bash
#
# Or download and run:
#   wget setup-server.sh
#   chmod +x setup-server.sh
#   ./setup-server.sh
#
# This script sets up a fresh Ubuntu server for OpenClaw deployment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Detect OS
detect_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Cannot detect OS. /etc/os-release not found."
        exit 1
    fi

    source /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID

    log_info "Detected OS: $OS $OS_VERSION"

    if [[ "$OS" != "ubuntu" ]] && [[ "$OS" != "debian" ]]; then
        log_warn "This script is designed for Ubuntu/Debian. Proceed with caution."
    fi
}

# Update system
update_system() {
    log_info "Updating system packages..."

    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get upgrade -y
    apt-get install -y \
        curl \
        wget \
        git \
        ufw \
        fail2ban \
        htop \
        tmux \
        vim \
        nano \
        ufw \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release

    log_success "System updated"
}

# Install Docker
install_docker() {
    if command -v docker &> /dev/null; then
        log_info "Docker already installed: $(docker --version)"
        return
    fi

    log_info "Installing Docker..."

    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable and start Docker
    systemctl enable docker
    systemctl start docker

    # Add current user to docker group (if not root)
    if [[ -n "${SUDO_USER:-}" ]]; then
        usermod -aG docker "$SUDO_USER"
        log_info "Added user $SUDO_USER to docker group"
    fi

    log_success "Docker installed: $(docker --version)"
}

# Install Docker Compose (standalone)
install_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        log_info "Docker Compose already installed: $(docker-compose --version)"
        return
    fi

    log_info "Installing Docker Compose..."

    # Get latest version
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

    curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" \
        -o /usr/local/bin/docker-compose

    chmod +x /usr/local/bin/docker-compose

    log_success "Docker Compose installed: $(docker-compose --version)"
}

# Create OpenClaw directory structure
create_directories() {
    log_info "Creating OpenClaw directory structure..."

    mkdir -p /opt/openclaw
    mkdir -p /opt/openclaw/workspace
    mkdir -p /opt/openclaw/logs
    mkdir -p /opt/openclaw/backups
    mkdir -p /opt/openclaw/configs
    mkdir -p /opt/openclaw/ssl

    log_success "Directories created in /opt/openclaw"
}

# Setup firewall
setup_firewall() {
    log_info "Configuring firewall..."

    # Reset UFW
    ufw --force reset

    # Default policies
    ufw default deny incoming
    ufw default allow outgoing

    # Allow SSH (important!)
    ufw allow 22/tcp comment 'SSH'

    # Allow HTTP/HTTPS
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'

    # Allow OpenClaw ports (optional, for direct access)
    ufw allow 18789/tcp comment 'OpenClaw Gateway WebSocket'
    ufw allow 18790/tcp comment 'OpenClaw Gateway Health'

    # Allow Docker metrics (optional)
    ufw allow 18791/tcp comment 'OpenClaw Metrics'

    # Enable UFW
    echo "y" | ufw enable

    log_success "Firewall configured"
    ufw status
}

# Setup fail2ban
setup_fail2ban() {
    log_info "Configuring fail2ban..."

    apt-get install -y fail2ban

    # Create local jail configuration
    cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = root@localhost
sendername = Fail2Ban
action = %(action_)s

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
EOF

    systemctl enable fail2ban
    systemctl restart fail2ban

    log_success "Fail2ban configured"
}

# Clone OpenClaw repository
clone_repository() {
    local REPO_URL=${1:-"git@github.com:RussianLioN/CodeFoundry.git"}
    local CLONE_DIR=${2:-"/opt/openclaw"}

    if [[ -d "$CLONE_DIR/.git" ]]; then
        log_info "Repository already cloned. Pulling latest..."
        cd "$CLONE_DIR"
        git pull
        return
    fi

    log_info "Cloning OpenClaw repository..."

    # Install git if not present
    if ! command -v git &> /dev/null; then
        apt-get install -y git
    fi

    git clone "$REPO_URL" "$CLONE_DIR"

    log_success "Repository cloned to $CLONE_DIR"
}

# Setup environment file
setup_env() {
    log_info "Setting up environment file..."

    local ENV_FILE="/opt/openclaw/docker/.env"

    if [[ ! -f "$ENV_FILE" ]]; then
        cp /opt/openclaw/docker/.env.example "$ENV_FILE"
        log_info "Created .env file from example"
    else
        log_info ".env file already exists"
    fi

    log_warn "Please edit $ENV_FILE and configure:"
    echo "  - TELEGRAM_BOT_TOKEN"
    echo "  - AUTHORIZED_USER_IDS"
    echo "  - Other settings as needed"
}

# Setup systemd service (optional)
setup_systemd() {
    log_info "Creating systemd service for OpenClaw..."

    cat > /etc/systemd/system/openclaw.service <<'EOF'
[Unit]
Description=OpenClaw AI-Powered Development System
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/openclaw/docker
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable openclaw.service

    log_success "Systemd service created and enabled"
    log_info "Use: systemctl start|stop|restart openclaw"
}

# Create helper scripts
create_helpers() {
    log_info "Creating helper scripts..."

    # OpenClaw control script
    cat > /usr/local/bin/openclaw <<'EOF'
#!/bin/bash
cd /opt/openclaw/docker

case "${1:-}" in
    start)
        docker compose up -d
        ;;
    stop)
        docker compose down
        ;;
    restart)
        docker compose restart
        ;;
    status)
        docker compose ps
        ;;
    logs)
        docker compose logs -f "${2:-}"
        ;;
    update)
        git pull
        docker compose pull
        docker compose up -d
        ;;
    *)
        echo "Usage: openclaw {start|stop|restart|status|logs|update}"
        exit 1
        ;;
esac
EOF

    chmod +x /usr/local/bin/openclaw

    log_success "Helper script created: /usr/local/bin/openclaw"
}

# Print summary
print_summary() {
    cat <<'SUMMARY'

╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║            OpenClaw Server Setup Complete!                   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

Next steps:

1. Configure environment:
   nano /opt/openclaw/docker/.env

2. Start OpenClaw:
   openclaw start
   # or
   systemctl start openclaw

3. Check status:
   openclaw status

4. View logs:
   openclaw logs

5. Get your Telegram ID:
   - Send /start to @userinfobot
   - Add to AUTHORIZED_USER_IDS in .env

6. Start a conversation with your bot in Telegram!

Helper commands:
  openclaw start     - Start all services
  openclaw stop      - Stop all services
  openclaw restart   - Restart services
  openclaw status    - Show service status
  openclaw logs      - Show logs
  openclaw update    - Update and restart

For full documentation:
  https://github.com/RussianLioN/CodeFoundry

SUMMARY
}

# Main execution
main() {
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║          OpenClaw Remote Server Setup Script                ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    check_root
    detect_os
    update_system
    install_docker
    install_docker_compose
    create_directories
    setup_firewall
    setup_fail2ban
    clone_repository "${1:-}" "${2:-}"
    setup_env
    setup_systemd
    create_helpers

    print_summary
}

# Run main function
main "$@"
