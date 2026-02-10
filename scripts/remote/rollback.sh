#!/bin/bash
#
# rollback.sh - Rollback OpenClaw to previous version
#
# Usage:
#   ./rollback.sh [version]
#
# If version not specified, lists available backups

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_USER="${REMOTE_USER:-}"
REMOTE_PATH="${REMOTE_PATH:-/opt/openclaw}"
VERSION="${1:-}"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ -z "$REMOTE_HOST" ]] || [[ -z "$REMOTE_USER" ]]; then
    log_error "REMOTE_HOST and REMOTE_USER must be set"
    exit 1
fi

# List available backups if no version specified
if [[ -z "$VERSION" ]]; then
    echo "Available backups:"
    echo ""

    ssh "$REMOTE_USER@$REMOTE_HOST" \
        "ls -lth $REMOTE_PATH/backups/ | grep '^-' | awk '{print \$9}' | head -10" || {
        log_error "Failed to list backups"
        exit 1
    }

    echo ""
    echo "Usage: $0 <backup-file>"
    echo "Example: $0 workspace-20250202-120000.tar.gz"
    exit 0
fi

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║            OpenClaw Rollback                                 ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Backup: $VERSION"
echo "Remote: $REMOTE_USER@$REMOTE_HOST"
echo ""

# Confirm rollback
log_warn "This will rollback to a previous version!"
read -p "Are you sure? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Rollback cancelled"
    exit 0
fi

# Create backup before rollback
log_info "Creating pre-rollback backup..."
ssh "$REMOTE_USER@$REMOTE_HOST" \
    "cd $REMOTE_PATH && \
     tar -czf backups/pre-rollback-$(date +%Y%m%d-%H%M%S).tar.gz workspace" || {
    log_error "Pre-rollback backup failed"
    exit 1
}
log_info "✅ Pre-rollback backup created"

# Stop services
log_info "Stopping services..."
ssh "$REMOTE_USER@$REMOTE_HOST" \
    "cd $REMOTE_PATH/docker && docker compose -f docker-compose.yml -f docker-compose.prod.yml down" || {
    log_error "Failed to stop services"
    exit 1
}
log_info "✅ Services stopped"

# Restore backup
log_info "Restoring backup..."
ssh "$REMOTE_USER@$REMOTE_HOST" << EOF
set -e

cd $REMOTE_PATH

# Remove current workspace
rm -rf workspace

# Extract backup
tar -xzf backups/$VERSION -C .

echo "✅ Backup restored"
EOF

if [[ $? -ne 0 ]]; then
    log_error "Restore failed"

    # Try to restart services anyway
    log_warn "Attempting to restart services..."
    ssh "$REMOTE_USER@$REMOTE_HOST" \
        "cd $REMOTE_PATH/docker && docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d"

    exit 1
fi
log_info "✅ Backup restored"

# Start services
log_info "Starting services..."
ssh "$REMOTE_USER@$REMOTE_HOST" \
    "cd $REMOTE_PATH/docker && docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d" || {
    log_error "Failed to start services"
    exit 1
}
log_info "✅ Services started"

# Wait for health
log_info "Waiting for services to be healthy..."
sleep 15

# Health check
ssh "$REMOTE_USER@$REMOTE_HOST" "curl -f http://localhost:18790/health" || {
    log_error "Health check failed after rollback"
    log_warn "Check logs: ssh $REMOTE_USER@$REMOTE_HOST 'cd $REMOTE_PATH/docker && docker compose logs'"
    exit 1
}

log_info "✅ Services healthy"

# Send notification
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] && [[ -n "${ALERT_CHAT_ID:-}" ]]; then
    log_info "Sending notification..."
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="$ALERT_CHAT_ID" \
        -d text="⚠️ *OpenClaw Rolled Back*%0A%0ATo: $VERSION%0AServer: $REMOTE_HOST%0ATime: $(date)" \
        -d parse_mode="Markdown"
fi

echo ""
echo "✅ Rollback completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Verify everything works"
echo "  2. Check logs: ssh $REMOTE_USER@$REMOTE_HOST 'cd $REMOTE_PATH/docker && docker compose logs -f'"
echo "  3. Fix issues in current branch"
echo "  4. Deploy again when ready"
