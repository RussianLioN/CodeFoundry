#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# backup-lessons.sh — Backup LESSONS.md and .tracking/ directory
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

BACKUP_DIR=".tracking/backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RETENTION_DAYS=30

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Creating lesson backups...${NC}"

mkdir -p "$BACKUP_DIR"

# Backup LESSONS.md
if [ -f "LESSONS.md" ]; then
    cp "LESSONS.md" "$BACKUP_DIR/LESSONS-$TIMESTAMP.md"
    echo -e "${GREEN}✓${NC} LESSONS.md backed up"
fi

# Backup error_log.json
if [ -f ".tracking/error_log.json" ]; then
    cp ".tracking/error_log.json" "$BACKUP_DIR/error_log-$TIMESTAMP.json"
    echo -e "${GREEN}✓${NC} error_log.json backed up"
fi

# Create full archive
tar -czf "$BACKUP_DIR/tracking-$TIMESTAMP.tar.gz" .tracking/ 2>/dev/null || true
echo -e "${GREEN}✓${NC} Full archive created: tracking-$TIMESTAMP.tar.gz"

# Cleanup old backups
find "$BACKUP_DIR" -name "LESSONS-*.md" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "error_log-*.json" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "tracking-*.tar.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true

echo -e "${GREEN}✓${NC} Cleaned up backups older than $RETENTION_DAYS days"
echo -e "${GREEN}✓ Backup complete${NC}"
