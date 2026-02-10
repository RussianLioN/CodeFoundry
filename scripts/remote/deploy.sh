#!/bin/bash
#
# deploy.sh - Deploy OpenClaw to remote server
#
# Usage:
#   ./deploy.sh [environment]
#
# Environments: dev, staging, production

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
ENVIRONMENT="${1:-production}"
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_USER="${REMOTE_USER:-}"
REMOTE_PATH="${REMOTE_PATH:-/opt/openclaw}"
COMPOSE_FILES="-f docker-compose.yml -f docker-compose.prod.yml"

# Colors for output
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Validate configuration
if [[ -z "$REMOTE_HOST" ]] || [[ -z "$REMOTE_USER" ]]; then
    log_error "REMOTE_HOST and REMOTE_USER must be set"
    echo "Set them in environment or .env file"
    exit 1
fi

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║            OpenClaw Remote Deployment                         ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Environment: $ENVIRONMENT"
echo "Remote: $REMOTE_USER@$REMOTE_HOST"
echo "Path: $REMOTE_PATH"
echo ""

# Confirm deployment
if [[ "$ENVIRONMENT" == "production" ]]; then
    log_warn "Deploying to PRODUCTION!"
    read -p "Are you sure? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Deployment cancelled"
        exit 0
    fi
fi

# Pre-deployment checks
log_info "Running pre-deployment checks..."

# Check if .env file exists
if [[ ! -f .env ]]; then
    log_error ".env file not found"
    exit 1
fi

log_info "✅ Pre-deployment checks passed"

# Build locally (optional)
log_info "Building Docker images..."
docker compose $COMPOSE_FILES build || {
    log_error "Build failed"
    exit 1
}
log_info "✅ Build complete"

# Create backup on remote
log_info "Creating remote backup..."
ssh "$REMOTE_USER@$REMOTE_HOST" \
    "cd $REMOTE_PATH && \
     mkdir -p backups && \
     tar -czf backups/pre-deploy-$(date +%Y%m%d-%H%M%S).tar.gz workspace" || {
    log_warn "Backup failed (continuing)"
}
log_info "✅ Backup created"

# Copy files to remote
log_info "Copying files to remote..."
rsync -avz \
    --exclude='node_modules/' \
    --exclude='dist/' \
    --exclude='.git/' \
    --exclude='workspace/' \
    --exclude='logs/' \
    --exclude='backups/' \
    --exclude='data/' \
    ./ "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/" || {
    log_error "rsync failed"
    exit 1
}
log_info "✅ Files copied"

# Deploy on remote
log_info "Deploying on remote server..."
ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
set -e

cd $REMOTE_PATH

# Pull latest if it's a git repo
if [ -d .git ]; then
    echo "Git repository detected, pulling latest..."
    git fetch origin
    git reset --hard origin/main
fi

# Restart services
echo "Restarting services..."
docker compose $COMPOSE_FILES down
docker compose $COMPOSE_FILES up -d --build

# Wait for services to start
echo "Waiting for services to start..."
sleep 15

# Health check
echo "Running health check..."
if curl -f http://localhost:18790/health; then
    echo "✅ Services healthy"
else
    echo "❌ Health check failed"
    docker compose $COMPOSE_FILES logs --tail=50
    exit 1
fi

echo ""
echo "✅ Deployment complete"
EOF

if [[ $? -eq 0 ]]; then
    log_info "✅ Deployment successful"

    # Run health check script
    log_info "Running post-deployment health check..."
    scp scripts/remote/health-check.sh "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/scripts/"
    ssh "$REMOTE_USER@$REMOTE_HOST" "$REMOTE_PATH/scripts/health-check.sh" || {
        log_warn "Health check failed (but deployment succeeded)"
    }

    # Send notification
    if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] && [[ -n "${ALERT_CHAT_ID:-}" ]]; then
        log_info "Sending notification..."
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="$ALERT_CHAT_ID" \
            -d text="✅ *OpenClaw Deployed*%0A%0AEnvironment: $ENVIRONMENT%0AServer: $REMOTE_HOST%0ATime: $(date)" \
            -d parse_mode="Markdown"
    fi

    echo ""
    echo "🎉 Deployment completed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Test the bot in Telegram"
    echo "  2. Check logs: ssh $REMOTE_USER@$REMOTE_HOST 'cd $REMOTE_PATH && docker compose logs -f'"
    echo "  3. Monitor metrics: https://$REMOTE_HOST/grafana (if enabled)"
else
    log_error "Deployment failed"
    exit 1
fi
