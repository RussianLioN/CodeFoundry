#!/bin/bash
# =============================================================================
# CodeFoundry Backup Script
# =============================================================================
# Automated backup for ainetic.tech remote testing infrastructure
#
# What gets backed up:
#   - Docker volumes (Ollama models, logs)
#   - Configuration files (.env.test)
#   - Git repositories
#   - Session state
#   - Critical directories
#
# Usage:
#   ./backup.sh                    # Full backup
#   ./backup.sh --quick          # Quick backup (no volumes)
#   ./backup.sh --restore       # Restore from backup
#   ./backup.sh --list          # List backups
#   ./backup.sh --prune         # Clean old backups
#
# Scheduling (cron):
#   0 2 * * * /root/projects/system-prompts/server/backup.sh --auto
# =============================================================================
# Sets error handling
set -e

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_ROOT="/backups/codefoundry"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# Load environment
if [[ -f "$SCRIPT_DIR/.env.test" ]]; then
    source "$SCRIPT_DIR/.env.test"
fi

# Configuration
RETENTION_DAYS=7
BACKUP_KEEP_DAILY=7
BACKUP_KEEP_WEEKLY=4
BACKUP_KEEP_MONTHLY=3

# Compose project
COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-codefoundry-test}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# =============================================================================
# Logging Functions
# =============================================================================

log_info() { echo -e "${BLUE}[BACKUP]${NC} $1"; }
log_success() { echo -e "${GREEN}[BACKUP]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[BACKUP]${NC} $1"; }
log_error() { echo -e "${RED}[BACKUP]${NC} $1"; }

# =============================================================================
# Helper Functions
# =============================================================================

show_help() {
    cat << EOF
CodeFoundry Backup Script

Usage: $0 [OPTIONS]

Operations:
    (no args)           Run full backup
    --quick             Quick backup (no volumes)
    --restore TIMESTAMP Restore from backup
    --list              List all backups
    --prune             Clean old backups
    --test              Test backup without creating

Options:
    --dry-run           Show what would be backed up
    --verbose           Verbose output
    --help              Show this help

Examples:
    $0                          # Full backup
    $0 --quick                  # Quick backup (no volumes)
    $0 --list                   # List backups
    $0 --restore 20250203-120000   # Restore specific backup

EOF
}

check_disk_space() {
    log_info "Checking disk space..."

    local available=$(df -BG / | awk '{print $4}')
    local required=1073741824  # 1GB minimum

    if [[ $available -lt $required ]]; then
        log_error "Insufficient disk space. Available: $available, Required: $required"
        return 1
    fi

    log_success "Disk space OK ($(numfmt --to=iec $available) available)"
    return 0
}

create_backup_dir() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would create: $BACKUP_DIR"
        return 0
    fi

    log_info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"/{volumes,config,state,logs}

    # Create metadata
    cat > "$BACKUP_DIR/metadata.txt" << EOF
Backup Timestamp: $TIMESTAMP
Date: $(date)
Hostname: $(hostname)
User: $(whoami)
Git Commit: $(cd "$PROJECT_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
Docker Version: $(docker --version)
EOF
}

backup_volumes() {
    log_info "Backing up Docker volumes..."

    # List volumes to backup
    local volumes=(
        "codefoundry-test-ollama"
        "codefoundry-prometheus"
        "codefoundry-grafana"
        "codefoundry-vector"
    )

    for volume in "${volumes[@]}"; do
        if docker volume inspect "$volume" &>/dev/null; then
            log_info "Backing up volume: $volume"

            if [[ "$DRY_RUN" == "true" ]]; then
                echo "[DRY RUN] Would backup $volume"
                continue
            fi

            # Create archive
            docker run --rm \
                -v "$volume:/data:ro" \
                -v "$BACKUP_DIR/volumes:/backup" \
                alpine tar czf "/backup/$volume.tar.gz" -C /data . || log_warning "Failed to backup $volume"
        else
            log_warning "Volume not found: $volume"
        fi
    done

    log_success "Docker volumes backed up"
}

backup_config() {
    log_info "Backing up configuration files..."

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would backup config files"
        return 0
    fi

    # Copy .env.test (without sensitive data)
    if [[ -f "$SCRIPT_DIR/.env.test" ]]; then
        grep -v "TOKEN\|KEY\|SECRET\|PASSWORD" "$SCRIPT_DIR/.env.test" > "$BACKUP_DIR/config/env.test.sanitized" || true
        log_success "Configuration backed up (sanitized)"
    fi

    # Backup SSH keys
    if [[ -d "$HOME/.ssh" ]]; then
        cp -r "$HOME/.ssh" "$BACKUP_DIR/config/ssh/" 2>/dev/null || true
        log_success "SSH keys backed up"
    fi
}

backup_git_state() {
    log_info "Backing up git state..."

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would backup git state"
        return 0
    fi

    # Save current git state
    cd "$PROJECT_DIR"

    # Save current branch and commit
    git branch > "$BACKUP_DIR/state/git-branch.txt" 2>/dev/null || true
    git log -1 --oneline > "$BACKUP_DIR/state/git-commit.txt" 2>/dev/null || true
    git diff HEAD > "$BACKUP_DIR/state/git-diff.patch" 2>/dev/null || true

    # Save uncommitted changes
    git status --porcelain > "$BACKUP_DIR/state/git-status.txt" 2>/dev/null || true

    log_success "Git state backed up"
}

backup_session_state() {
    log_info "Backing up session state..."

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would backup session state"
        return 0
    fi

    # Session state from container manager
    if [[ -f "/tmp/codefoundry-sessions/sessions.json" ]]; then
        cp "/tmp/codefoundry-sessions/sessions.json" "$BACKUP_DIR/state/sessions.json"
        log_success "Session state backed up"
    fi
}

backup_logs() {
    log_info "Backing up recent logs..."

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would backup logs"
        return 0
    fi

    # Vector logs
    if [[ -d "/var/log/codefoundry" ]]; then
        mkdir -p "$BACKUP_DIR/logs"
        cp -r /var/log/codefoundr/*.log "$BACKUP_DIR/logs/" 2>/dev/null || true
        log_success "Application logs backed up"
    fi

    # Docker logs for all codefoundry containers
    mkdir -p "$BACKUP_DIR/logs/docker"
    for container in $(docker ps -a --filter "name=codefoundry" --format "{{.Names}}"); do
        docker logs "$container" > "$BACKUP_DIR/logs/docker/${container##*/}.log" 2>/dev/null || true
    done

    log_success "Docker logs backed up"
}

create_backup_archive() {
    log_info "Creating backup archive..."

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would create archive"
        return 0
    fi

    # Create checksum
    cd "$BACKUP_ROOT"
    tar czf "codefoundry-$TIMESTAMP.tar.gz" "$TIMESTAMP"
    sha256sum "codefoundry-$TIMESTAMP.tar.gz" > "codefoundry-$TIMESTAMP.tar.gz.sha256"

    # Set permissions
    chmod 600 "codefoundry-$TIMESTAMP.tar.gz"*
    chmod 600 "codefoundry-$TIMESTAMP.tar.gz.sha256"

    log_success "Backup archive created: codefoundry-$TIMESTAMP.tar.gz"
    log_info "Checksum: $(cat "codefoundry-$TIMESTAMP.tar.gz.sha256")"

    # Cleanup directory (keep archive only)
    rm -rf "$TIMESTAMP"

    log_info "Temporary directory cleaned up"
}

list_backups() {
    log_info "Available backups:"
    echo ""

    local archives=($(find "$BACKUP_ROOT" -name "codefoundry-*.tar.gz" -type f -printf '%T@ %p\n' | sort -r | head -10))

    if [[ ${#archives[@]} -eq 0 ]]; then
        log_warning "No backups found"
        return 0
    fi

    echo "Date/Timestamp          Size      Checksum"
    echo "─────────────────────────────────────────────────────────────"

    for archive in "${archives[@]}"; do
        local timestamp=$(echo "$archive" | grep -oP 'codefoundry-\K[0-9-]+')
        local size=$(du -h "$archive" | cut -f1)
        local checksum=$(cat "$archive.sha256" 2>/dev/null | cut -d' ' -f1)
        echo "$(date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S')   $size   $checksum"
    done

    echo ""
    log_info "Total backups: ${#archives[@]}"
    log_info "Backup directory: $BACKUP_ROOT"
}

restore_backup() {
    local restore_timestamp="$1"

    if [[ -z "$restore_timestamp" ]]; then
        log_error "Restore timestamp is required"
        log_info "Available backups:"
        list_backups
        exit 1
    fi

    local archive="$BACKUP_ROOT/codefoundry-$restore_timestamp.tar.gz"

    if [[ ! -f "$archive" ]]; then
        log_error "Backup not found: $archive"
        exit 1
    fi

    log_warning "This will RESTORE from backup: $restore_timestamp"
    log_warning "All current data will be OVERWRITTEN"
    echo ""
    read -p "Continue? (yes/no): " -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Restore cancelled"
        exit 0
    fi

    log_info "Extracting backup..."

    # Verify checksum
    log_info "Verifying checksum..."
    cd "$BACKUP_ROOT"
    sha256sum -c "codefoundry-$restore_timestamp.tar.gz.sha256"

    # Extract
    mkdir -p "$restore_timestamp"
    tar xzf "codefoundry-$restore_timestamp.tar.gz" -C "$restore_timestamp"

    # Restore volumes
    log_info "Restoring Docker volumes..."
    for volume in "$restore_timestamp"/volumes/*.tar.gz; do
        if [[ -f "$volume" ]]; then
            local volname=$(basename "$volume" .tar.gz)
            docker volume create "$volname" 2>/dev/null || true
            docker run --rm -v "$volname:/data" -v "$(dirname "$volume"):/backup" \
                alpine tar xzf "/backup/$(basename "$volume")" -C /data || log_warning "Failed to restore $volname"
        fi
    done

    log_success "Restore complete"
    log_info "Restored to: $restore_timestamp"

    # Offer to restart services
    echo ""
    read -p "Restart services? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Restarting services..."
        cd "$PROJECT_DIR/server"
        make restart-test
    fi
}

prune_old_backups() {
    log_info "Pruning old backups..."

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] Would prune old backups"
        return 0
    fi

    # Calculate retention
    local daily_cutoff=$(date -d "$RETENTION_DAYS days ago" +%s)
    local weekly_cutoff=$(date -d "$((RETENTION_DAYS * 7)) days ago" +%s)
    local monthly_cutoff=$(date -d "$((RETENTION_DAYS * 30)) days ago" ago +%s)

    local deleted=0

    # Prune old archives
    while IFS= read -r archive; do
        local timestamp=$(echo "$archive" | grep -oP 'codefoundry-\K[0-9-]+')

        if [[ -n "$timestamp" ]]; then
            local archive_time=$(date -d "@$timestamp" +%s 2>/dev/null || echo "0")

            # Check if archive is older than retention period
            if [[ $archive_time -lt $monthly_cutoff ]]; then
                log_info "Pruning old backup: $(basename "$archive")"
                rm "$archive"
                ((deleted++))
            fi
        fi
    done < <(find "$BACKUP_ROOT" -name "codefoundry-*.tar.gz" -type f +rt)

    # Prune empty directories
    find "$BACKUP_ROOT" -type d -empty -delete

    log_success "Pruned $deleted old backup(s)"
}

backup_quick() {
    log_info "Running quick backup (config only)..."

    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_DIR="$BACKUP_ROOT/quick-$TIMESTAMP"

    mkdir -p "$BACKUP_DIR"

    # Config only
    backup_config

    log_success "Quick backup complete: $BACKUP_DIR"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    local mode="full"
    local dry_run=false
    local restore_timestamp=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --quick)
                mode="quick"
                shift
                ;;
            --restore)
                mode="restore"
                restore_timestamp="$2"
                shift 2
                ;;
            --list)
                list_backups
                exit 0
                ;;
            --prune)
                prune_old_backups
                exit 0
                ;;
            --test)
                dry_run=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --verbose)
                set -x
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  CodeFoundry Backup                                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check disk space
    if [[ "$mode" == "full" ]]; then
        check_disk_space || exit 1
    fi

    # Create backup directory
    create_backup_dir

    # Run backup based on mode
    case "$mode" in
        full)
            backup_volumes
            backup_config
            backup_git_state
            backup_session_state
            backup_logs
            create_backup_archive
            ;;
        quick)
            backup_quick
            ;;
        restore)
            restore_backup
            ;;
    esac

    echo ""
    log_success "Backup completed successfully!"
    echo ""
    log_info "Backup location: $BACKUP_ROOT"

    # Show space usage
    du -sh "$BACKUP_ROOT" 2>/dev/null | tail -1
}

main "$@"
