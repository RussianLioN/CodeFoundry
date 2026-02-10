#!/bin/bash
#
# backup.sh - Backup OpenClaw data
#
# Usage:
#   ./backup.sh [type]
#
# Types: full, workspace, configs, data

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
BASE_DIR="/opt/openclaw"
BACKUP_DIR="${BACKUP_DIR:-$BASE_DIR/backups}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_TYPE="${1:-full}"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

echo "OpenClaw Backup"
echo "==============="
echo "Type: $BACKUP_TYPE"
echo "Timestamp: $TIMESTAMP"
echo ""

# Create backup directories
mkdir -p "$BACKUP_DIR/daily"
mkdir -p "$BACKUP_DIR/weekly"
mkdir -p "$BACKUP_DIR/monthly"

case "$BACKUP_TYPE" in
    full)
        log_info "Creating full backup..."

        # Workspace
        log_info "Backing up workspace..."
        tar -czf "$BACKUP_DIR/daily/workspace-$TIMESTAMP.tar.gz" -C "$BASE_DIR" workspace

        # Configs
        log_info "Backing up configs..."
        tar -czf "$BACKUP_DIR/daily/configs-$TIMESTAMP.tar.gz" -C "$BASE_DIR" docker/.env configs/

        # Data (Redis, etc.)
        log_info "Backing up data..."
        tar -czf "$BACKUP_DIR/daily/data-$TIMESTAMP.tar.gz" -C "$BASE_DIR" data/

        # Logs (last 7 days)
        log_info "Backing up logs..."
        find "$BASE_DIR/logs" -name "*.log" -mtime -7 -print0 | \
            tar -czf "$BACKUP_DIR/daily/logs-$TIMESTAMP.tar.gz" --null -T -

        ;;

    workspace)
        log_info "Backing up workspace only..."
        tar -czf "$BACKUP_DIR/daily/workspace-$TIMESTAMP.tar.gz" -C "$BASE_DIR" workspace
        ;;

    configs)
        log_info "Backing up configs only..."
        tar -czf "$BACKUP_DIR/daily/configs-$TIMESTAMP.tar.gz" -C "$BASE_DIR" docker/.env configs/
        ;;

    data)
        log_info "Backing up data only..."
        tar -czf "$BACKUP_DIR/daily/data-$TIMESTAMP.tar.gz" -C "$BASE_DIR" data/
        ;;

    *)
        echo "Unknown backup type: $BACKUP_TYPE"
        echo "Valid types: full, workspace, configs, data"
        exit 1
        ;;
esac

log_info "✅ Backup complete: $BACKUP_DIR/daily/*-$TIMESTAMP.tar.gz"

# Cleanup old backups
log_info "Cleaning up old backups..."
find "$BACKUP_DIR/daily" -name "*.tar.gz" -mtime +7 -delete
find "$BACKUP_DIR/weekly" -name "*.tar.gz" -mtime +30 -delete
find "$BACKUP_DIR/monthly" -name "*.tar.gz" -mtime +365 -delete

# Show backup size
du -sh "$BACKUP_DIR/daily"/*-$TIMESTAMP.tar.gz

log_info "✅ Backup process complete"
