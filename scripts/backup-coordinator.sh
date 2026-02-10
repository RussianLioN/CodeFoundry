#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# backup-coordinator.sh — Backup/Restore Coordinator for Agent Teams Operations
# Provides automatic backup, validation, and rollback for parallel AI agent work
# ═══════════════════════════════════════════════════════════════════════════════
#
# Usage:
#   ./scripts/backup-coordinator.sh create [--mode=git|fs|both]
#   ./scripts/backup-coordinator.sh validate [--verbose]
#   ./scripts/backup-coordinator.sh rollback [--stash=N|--snapshot=DIR]
#   ./scripts/backup-coordinator.sh list [--last=N]
#   ./scripts/backup-coordinator.sh clean [--older=Nd]
#
# Exit codes:
#   0 = Success
#   1 = Validation failed (with auto-rollback)
#   2 = Error (backup/restore failed)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

BACKUP_DIR="${PROJECT_ROOT}/.backup"
LOG_FILE="${BACKUP_DIR}/operations.log"
TIMESTAMP=$(date -u +"%Y%m%d-%H%M%S")

# Colors
if [ -t 1 ] && [ "${CI:-}" != "true" ]; then
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m'
else
    RED='' YELLOW='' GREEN='' BLUE='' BOLD='' DIM='' NC=''
fi

# ─── Utility Functions ───────────────────────────────────────────────────────

# Trap handler for cleanup on exit/interrupt
cleanup() {
    local exit_code=$?
    # Remove any partial backup on abnormal exit
    if [ -n "${PARTIAL_BACKUP:-}" ] && [ -d "$PARTIAL_BACKUP" ]; then
        rm -rf "$PARTIAL_BACKUP" 2>/dev/null || true
    fi
    exit $exit_code
}

trap cleanup EXIT INT TERM

log() {
    local level="$1" message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Ensure backup directory exists before logging
    mkdir -p "$BACKUP_DIR"

    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }

header() {
    echo ""
    echo -e "${BOLD}$1${NC}"
    echo "───────────────────────────────────────────────────"
}

# ─── Git Detection ───────────────────────────────────────────────────────────

is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

git_is_clean() {
    git diff --quiet && git diff --cached --quiet
}

get_git_status() {
    git status --short | wc -l | tr -d ' '
}

# ─── Backup Functions ────────────────────────────────────────────────────────

backup_git_stash() {
    header "Creating Git Stash Backup"

    if ! is_git_repo; then
        error "Not a git repository"
        return 2
    fi

    local stash_msg="backup-coordinator: ${TIMESTAMP}"
    local file_count=$(git ls-files | wc -l | tr -d ' ')

    info "Files tracked: $file_count"
    info "Creating stash: $stash_msg"

    if git stash push -u -m "$stash_msg" 2>/dev/null; then
        local stash_num=$(git stash list | grep "backup-coordinator:" | wc -l | tr -d ' ')
        success "Git stash created: stash@{$((stash_num - 1))} - $stash_msg"
        echo "stash@{$((stash_num - 1))}" > "${BACKUP_DIR}/last_stash.txt"
        return 0
    else
        error "Git stash failed"
        return 2
    fi
}

backup_filesystem_snapshot() {
    header "Creating Filesystem Snapshot"

    local snapshot_dir="${BACKUP_DIR}/${TIMESTAMP}"
    mkdir -p "$snapshot_dir"

    info "Snapshot directory: $snapshot_dir"

    # Use rsync if available, fallback to cp
    if command -v rsync >/dev/null 2>&1; then
        info "Using rsync for snapshot"
        rsync -av \
            --exclude='.git' \
            --exclude='node_modules' \
            --exclude='.backup' \
            --exclude='*.pyc' \
            --exclude='__pycache__' \
            --exclude='.DS_Store' \
            "$PROJECT_ROOT/" "$snapshot_dir/" 2>/dev/null | tail -1
    else
        info "Using cp for snapshot (rsync not available)"
        cp -R "$PROJECT_ROOT"/* "$snapshot_dir/" 2>/dev/null
    fi

    local file_count=$(find "$snapshot_dir" -type f | wc -l | tr -d ' ')
    success "Filesystem snapshot created: $file_count files"
    echo "$snapshot_dir" > "${BACKUP_DIR}/last_snapshot.txt"

    return 0
}

backup_create() {
    local mode="${1:-auto}"

    header "BACKUP COORDINATOR — CREATE"

    mkdir -p "$BACKUP_DIR"

    # Auto-detect mode
    if [ "$mode" = "auto" ]; then
        if is_git_repo; then
            mode="git"
        else
            mode="fs"
        fi
        info "Auto-detected mode: $mode"
    fi

    log "INFO" "Backup create started (mode: $mode)"

    local backup_result=0

    case "$mode" in
        git)
            backup_git_stash || backup_result=$?
            ;;
        fs|filesystem)
            backup_filesystem_snapshot || backup_result=$?
            ;;
        both)
            backup_git_stash || backup_result=$?
            backup_filesystem_snapshot || backup_result=$?
            ;;
        *)
            error "Unknown mode: $mode"
            return 2
            ;;
    esac

    if [ $backup_result -eq 0 ]; then
        log "INFO" "Backup created successfully"
        return 0
    else
        log "ERROR" "Backup creation failed"
        return $backup_result
    fi
}

# ─── Validation Functions ────────────────────────────────────────────────────

validate_git_integrity() {
    local verbose="${1:-false}"

    if ! is_git_repo; then
        [ "$verbose" = "true" ] && info "Not a git repo, skipping git integrity check"
        return 0
    fi

    local changed_files=$(get_git_status)

    if [ "$verbose" = "true" ]; then
        info "Git integrity: $changed_files changed file(s)"
    fi

    # Check for unexpected deletions
    local deleted_files=$(git status | grep -c "deleted:" || true)

    if [ "$deleted_files" -gt 0 ]; then
        error "Git integrity: $deleted_files file(s) deleted"
        return 1
    fi

    return 0
}

validate_file_count() {
    local verbose="${1:-false}"

    if ! is_git_repo; then
        [ "$verbose" = "true" ] && info "Not a git repo, skipping file count check"
        return 0
    fi

    local current_count=$(git ls-files | wc -l | tr -d ' ')
    local baseline_file="${BACKUP_DIR}/baseline_count.txt"

    # Establish baseline on first run
    if [ ! -f "$baseline_file" ]; then
        echo "$current_count" > "$baseline_file"
        [ "$verbose" = "true" ] && info "File count baseline: $current_count"
        return 0
    fi

    local baseline=$(cat "$baseline_file")

    if [ "$verbose" = "true" ]; then
        info "File count: $current_count (baseline: $baseline)"
    fi

    if [ "$current_count" -lt "$baseline" ]; then
        error "File count decreased: $baseline → $current_count"
        return 1
    fi

    return 0
}

validate_critical_files() {
    local verbose="${1:-false}"

    local critical_files="CLAUDE.md SESSION.md PROJECT.md TASKS.md"
    local missing=0

    for file in $critical_files; do
        if [ ! -f "$file" ]; then
            error "Critical file missing: $file"
            missing=$((missing + 1))
        fi
    done

    if [ "$missing" -eq 0 ]; then
        [ "$verbose" = "true" ] && info "Critical files: all present"
        return 0
    else
        return 1
    fi
}

validate_json_syntax() {
    local verbose="${1:-false}"
    local errors=0

    while IFS= read -r -d '' json_file; do
        # SECURE: Use proper argument passing to prevent command injection
        if ! python3 -c "import sys, json; json.load(open(sys.argv[1]))" "$json_file" 2>/dev/null; then
            error "JSON syntax error: $json_file"
            errors=$((errors + 1))
        fi
    done < <(find .claude -name "*.json" -type f -print0 2>/dev/null)

    if [ $errors -eq 0 ]; then
        [ "$verbose" = "true" ] && info "JSON syntax: all valid"
        return 0
    else
        return 1
    fi
}

validate_ref_links() {
    local verbose="${1:-false}"

    if [ ! -f "$SCRIPT_DIR/check-refs.py" ]; then
        [ "$verbose" = "true" ] && info "@ref validation: check-refs.py not found, skipping"
        return 0
    fi

    local result
    result=$(python3 "$SCRIPT_DIR/check-refs.py" 2>/dev/null)
    local broken=$(echo "$result" | head -1)

    if [ "$verbose" = "true" ]; then
        info "@ref links: $broken broken reference(s)"
    fi

    if [ "$broken" -gt 0 ]; then
        error "@ref integrity: $broken broken reference(s)"
        return 1
    fi

    return 0
}

validate_all() {
    local verbose="${1:-false}"
    local checks_passed=0
    local checks_total=5

    header "POST-WORK VALIDATION"

    validate_git_integrity "$verbose" && checks_passed=$((checks_passed + 1))
    validate_file_count "$verbose" && checks_passed=$((checks_passed + 1))
    validate_critical_files "$verbose" && checks_passed=$((checks_passed + 1))
    validate_json_syntax "$verbose" && checks_passed=$((checks_passed + 1))
    validate_ref_links "$verbose" && checks_passed=$((checks_passed + 1))

    echo ""
    success "Validation: $checks_passed/$checks_total checks passed"

    if [ $checks_passed -eq $checks_total ]; then
        log "INFO" "Validation passed: $checks_passed/$checks_total"
        return 0
    else
        log "WARN" "Validation failed: $checks_passed/$checks_total"
        return 1
    fi
}

# ─── Rollback Functions ──────────────────────────────────────────────────────

rollback_git_stash() {
    local stash_num="${1:-0}"

    header "Rolling Back from Git Stash"

    if ! is_git_repo; then
        error "Not a git repository"
        return 2
    fi

    info "Restoring stash@{$stash_num}"

    if git stash pop "stash@{$stash_num}" 2>/dev/null; then
        success "Git stash restored successfully"
        return 0
    else
        error "Git stash restore failed"
        return 2
    fi
}

rollback_filesystem_snapshot() {
    local snapshot_dir="${1:-}"

    if [ -z "$snapshot_dir" ]; then
        if [ -f "${BACKUP_DIR}/last_snapshot.txt" ]; then
            snapshot_dir=$(cat "${BACKUP_DIR}/last_snapshot.txt")
        else
            error "No snapshot directory specified and no last snapshot found"
            return 2
        fi
    fi

    header "Rolling Back from Filesystem Snapshot"

    if [ ! -d "$snapshot_dir" ]; then
        error "Snapshot directory not found: $snapshot_dir"
        return 2
    fi

    info "Restoring from: $snapshot_dir"

    if command -v rsync >/dev/null 2>&1; then
        # CRITICAL: Exclude .git to prevent repository destruction
        rsync -av --delete --exclude='.git' --exclude='.backup' "$snapshot_dir/" "$PROJECT_ROOT/" 2>/dev/null | tail -1
    else
        error "rsync not available, cannot safely restore"
        return 2
    fi

    success "Filesystem snapshot restored successfully"
    return 0
}

rollback_auto() {
    header "AUTOMATIC ROLLBACK"

    # Try git stash first
    if is_git_repo && [ -f "${BACKUP_DIR}/last_stash.txt" ]; then
        info "Attempting git stash rollback"
        rollback_git_stash "$(cat "${BACKUP_DIR}/last_stash.txt")" && return 0
    fi

    # Fallback to filesystem snapshot
    if [ -f "${BACKUP_DIR}/last_snapshot.txt" ]; then
        info "Attempting filesystem snapshot rollback"
        rollback_filesystem_snapshot && return 0
    fi

    error "No backup found for automatic rollback"
    return 2
}

# ─── List & Clean Functions ──────────────────────────────────────────────────

backup_list() {
    local last="${1:-10}"

    header "Backup History (last $last)"

    # Git stashes
    if is_git_repo; then
        echo ""
        echo -e "${BOLD}Git Stashes:${NC}"
        git stash list | grep "backup-coordinator:" | tail -n "$last" || true
    fi

    # Filesystem snapshots
    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        echo -e "${BOLD}Filesystem Snapshots:${NC}"
        ls -lt "$BACKUP_DIR" 2>/dev/null | grep "^d" | grep -E "^[0-9]{8}" | head -n "$last" || true
    fi
}

backup_clean() {
    local older="${1:-7d}"

    header "Cleaning Old Backups"

    local days
    days=$(echo "$older" | sed 's/d$//')

    # Clean filesystem snapshots
    if [ -d "$BACKUP_DIR" ]; then
        info "Removing snapshots older than $days days"
        find "$BACKUP_DIR" -type d -mtime +$days -exec rm -rf {} + 2>/dev/null || true
        success "Old snapshots cleaned"
    fi

    # Note: Git stashes are NOT auto-cleaned (user decision)
    warning "Git stashes not cleaned (manual cleanup required)"
}

# ─── Main ────────────────────────────────────────────────────────────────────

show_usage() {
    cat <<EOF
Usage: $0 <command> [options]

Commands:
  create [MODE]      Create backup (modes: git, fs, both, auto)
  validate           Run post-work validation checks
  rollback [STASH]   Rollback to backup (auto-detect if not specified)
  list [N]           Show backup history (last N entries)
  clean [Nd]         Remove old backups (default: 7d)

Options:
  --verbose          Show detailed output
  --stash=N          Rollback to specific git stash
  --snapshot=DIR     Rollback to specific snapshot

Examples:
  $0 create                    Auto-detect mode and create backup
  $0 create --mode=git         Create git stash backup
  $0 validate --verbose        Run validation with details
  $0 rollback                  Auto-rollback to last backup
  $0 list --last=5             Show last 5 backups
EOF
}

# Parse arguments
MODE="auto"
VERBOSE="false"

# Parse --flags
for arg in "$@"; do
    case "$arg" in
        --mode=*)
            MODE="${arg#--mode=}"
            ;;
        --verbose)
            VERBOSE="true"
            ;;
    esac
done

# Get command (first non-flag argument)
COMMAND=""
for arg in "$@"; do
    case "$arg" in
        --*) continue ;;
        *)
            COMMAND="$arg"
            break
            ;;
    esac
done

case "${COMMAND:-help}" in
    create)
        backup_create "$MODE"
        ;;
    validate)
        validate_all "$VERBOSE"
        ;;
    rollback)
        # Check for --stash or --snapshot flags
        ROLLBACK_TARGET=""
        for arg in "$@"; do
            case "$arg" in
                --stash=*)
                    rollback_git_stash "${arg#--stash=}"
                    exit $?
                    ;;
                --snapshot=*)
                    rollback_filesystem_snapshot "${arg#--snapshot=}"
                    exit $?
                    ;;
            esac
        done
        rollback_auto
        ;;
    list)
        last="10"
        for arg in "$@"; do
            case "$arg" in
                --last=*)
                    last="${arg#--last=}"
                    ;;
            esac
        done
        backup_list "$last"
        ;;
    clean)
        older="7d"
        for arg in "$@"; do
            case "$arg" in
                --older=*)
                    older="${arg#--older=}"
                    ;;
            esac
        done
        backup_clean "$older"
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        error "Unknown command: ${COMMAND:-}"
        show_usage
        exit 2
        ;;
esac
