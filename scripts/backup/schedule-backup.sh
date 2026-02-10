#!/bin/bash
#
# schedule-backup.sh - Schedule automatic backups via cron
#
# Usage:
#   ./schedule-backup.sh [install|uninstall]
#
# This sets up cron jobs for automatic backups

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ACTION="${1:-install}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="/opt/openclaw"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

case "$ACTION" in
    install)
        echo "Setting up automatic backups..."
        echo ""

        # Check if running as root
        if [[ $EUID -ne 0 ]]; then
            log_error "This script must be run as root"
            exit 1
        fi

        # Daily backup at 2 AM
        log_info "Installing daily backup job (2 AM)..."
        cat > /etc/cron.d/openclaw-daily <<EOF
# OpenClaw Daily Backup
0 2 * * * root $SCRIPT_DIR/backup.sh full >> $BASE_DIR/logs/backup.log 2>&1
EOF
        chmod 644 /etc/cron.d/openclaw-daily

        # Weekly backup on Sunday at 3 AM
        log_info "Installing weekly backup job (Sunday 3 AM)..."
        cat > /etc/cron.d/openclaw-weekly <<EOF
# OpenClaw Weekly Backup
0 3 * * 0 root $SCRIPT_DIR/backup.sh full && mv $BASE_DIR/backups/daily/workspace-*.tar.gz $BASE_DIR/backups/weekly/ >> $BASE_DIR/logs/backup.log 2>&1
EOF
        chmod 644 /etc/cron.d/openclaw-weekly

        # Hourly Git sync
        log_info "Installing hourly Git sync job..."
        cat > /etc/cron.d/openclaw-git <<EOF
# OpenClaw Git Sync
0 * * * * root cd $BASE_DIR/workspace && for dir in */; do cd "$BASE_DIR/workspace/\$dir" && git add -A && git commit -m "Auto-commit $(date)" && git push; done 2>/dev/null
EOF
        chmod 644 /etc/cron.d/openclaw-git

        log_info "✅ Cron jobs installed"
        echo ""
        echo "Installed jobs:"
        echo "  - Daily full backup: 2 AM"
        echo "  - Weekly full backup: Sunday 3 AM"
        echo "  - Hourly Git sync"
        echo ""
        echo "View logs: tail -f $BASE_DIR/logs/backup.log"
        ;;

    uninstall)
        echo "Removing automatic backup jobs..."
        echo ""

        if [[ $EUID -ne 0 ]]; then
            log_error "This script must be run as root"
            exit 1
        fi

        rm -f /etc/cron.d/openclaw-daily
        rm -f /etc/cron.d/openclaw-weekly
        rm -f /etc/cron.d/openclaw-git

        log_info "✅ Cron jobs removed"
        ;;

    *)
        echo "Usage: $0 [install|uninstall]"
        exit 1
        ;;
esac
