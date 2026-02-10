#!/bin/bash
# =============================================================================
# CodeFoundry Remote Server Sync Script
# =============================================================================
# Syncs project from GitHub to ainetic.tech server
#
# Usage:
#   ./sync.sh                    # Sync from remote
#   ./sync.sh --force            # Force sync (discard local changes)
#   ./sync.sh --status           # Check sync status
#   ./sync.sh --branch <name>    # Sync specific branch
#
# This script:
#   1. Checks for local changes
#   2. Fetches from GitHub
#   3. Pulls latest changes
#   4. Shows what changed
#   5. Optionally recreates containers
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment if exists
if [[ -f "$SCRIPT_DIR/.env.test" ]]; then
    source "$SCRIPT_DIR/.env.test"
fi

# Default values
PROJECT_NAME="${PROJECT_NAME:-system-prompts}"
GITHUB_REPO="${GITHUB_REPO:-origin}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

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

log_info() { echo -e "${BLUE}[SYNC]${NC} $1"; }
log_success() { echo -e "${GREEN}[SYNC]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[SYNC]${NC} $1"; }
log_error() { echo -e "${RED}[SYNC]${NC} $1"; }
log_diff() { echo -e "${CYAN}[DIFF]${NC} $1"; }

# =============================================================================
# Helper Functions
# =============================================================================

show_help() {
    cat << EOF
CodeFoundry Remote Sync Script

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -f, --force         Force sync (discard local changes)
    -s, --status        Check sync status only
    -b, --branch NAME   Sync specific branch (default: main)
    -r, --recreate      Recreate containers after sync
    -v, --verbose       Verbose output

Examples:
    $0                  # Sync from remote
    $0 --status         # Check if we're behind/ahead
    $0 --branch dev     # Sync dev branch
    $0 --force --recreate  # Force sync and recreate containers

EOF
}

check_git_repo() {
    if [[ ! -d "$PROJECT_DIR/.git" ]]; then
        log_error "Not a git repository: $PROJECT_DIR"
        log_info "Run setup.sh first or clone repository manually"
        exit 1
    fi
}

get_current_branch() {
    git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD
}

get_current_commit() {
    git -C "$PROJECT_DIR" rev-parse --short HEAD
}

get_remote_commit() {
    local branch="$1"
    git -C "$PROJECT_DIR" rev-parse --short "origin/$branch" 2>/dev/null || echo "unknown"
}

has_local_changes() {
    ! git -C "$PROJECT_DIR" diff-index --quiet HEAD --
}

has_untracked_files() {
    [[ -n $(git -C "$PROJECT_DIR" ls-files --others --exclude-standard) ]]
}

show_status() {
    local branch="$1"

    log_info "Checking sync status..."

    # Fetch remote info
    git -C "$PROJECT_DIR" fetch --dry-run -v 2>&1 | grep -q "origin/$branch" && local has_updates=true || local has_updates=false

    local local_commit=$(get_current_commit)
    local remote_commit=$(get_remote_commit "$branch")

    echo ""
    echo -e "${CYAN}Current Status:${NC}"
    echo "  Branch:        $branch"
    echo "  Local commit:  $local_commit"
    echo "  Remote commit: $remote_commit"
    echo ""

    if has_local_changes; then
        log_warning "You have uncommitted changes:"
        git -C "$PROJECT_DIR" status --short
    fi

    if has_untracked_files; then
        log_warning "You have untracked files:"
        git -C "$PROJECT_DIR" ls-files --others --exclude-standard | head -10
    fi

    if [[ "$local_commit" == "$remote_commit" ]]; then
        log_success "Already up to date!"
    else
        log_info "Updates available from remote"
    fi
}

# =============================================================================
# Sync Functions
# =============================================================================

sync_from_remote() {
    local branch="$1"
    local force="$2"

    log_info "Syncing from GitHub..."
    echo "  Repository: $PROJECT_DIR"
    echo "  Branch:     $branch"
    echo ""

    # Check for local changes
    if has_local_changes && [[ "$force" != "true" ]]; then
        log_error "You have uncommitted changes!"
        echo ""
        log_diff "Changed files:"
        git -C "$PROJECT_DIR" status --short
        echo ""
        log_info "Options:"
        echo "  1. Commit changes: git commit -am 'Your message'"
        echo "  2. Stash changes: git stash"
        echo "  3. Discard changes: $0 --force"
        exit 1
    fi

    # Stash if needed
    if has_local_changes; then
        log_warning "Stashing local changes (--force)..."
        git -C "$PROJECT_DIR" stash push -m "Auto-stash before sync"
    fi

    # Fetch from remote
    log_info "Fetching from remote..."
    git -C "$PROJECT_DIR" fetch origin

    # Check if branch exists on remote
    if ! git -C "$PROJECT_DIR" rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
        log_error "Branch '$branch' not found on remote"
        exit 1
    fi

    # Switch to branch if not current
    local current_branch=$(get_current_branch)
    if [[ "$current_branch" != "$branch" ]]; then
        log_info "Switching to branch: $branch"
        git -C "$PROJECT_DIR" checkout "$branch"
    fi

    # Pull changes
    log_info "Pulling changes..."
    local before_commit=$(get_current_commit)
    git -C "$PROJECT_DIR" pull origin "$branch"
    local after_commit=$(get_current_commit)

    # Show what changed
    if [[ "$before_commit" != "$after_commit" ]]; then
        echo ""
        log_success "Synced successfully!"
        echo ""
        log_diff "Changes pulled:"
        git -C "$PROJECT_DIR" log --oneline --no-decorate "$before_commit..$after_commit"
        echo ""

        # Show changed files
        local changed_files=$(git -C "$PROJECT_DIR" diff --name-only "$before_commit..$after_commit" | wc -l)
        log_info "Files changed: $changed_files"
    else
        log_success "Already up to date!"
    fi
}

show_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Sync Complete!                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    log_info "Project directory: $PROJECT_DIR"
    log_info "Current branch:    $(get_current_branch)"
    log_info "Current commit:    $(get_current_commit)"
    echo ""
    log_info "Next steps:"
    echo "  make start-test     # Start ephemeral test container"
    echo "  make logs           # View container logs"
    echo "  make shell          # Enter container shell"
    echo ""
}

# =============================================================================
# Container Management
# =============================================================================

recreate_containers() {
    log_info "Recreating containers..."

    if [[ ! -f "$PROJECT_DIR/server/docker-compose.test.yml" ]]; then
        log_warning "docker-compose.test.yml not found, skipping container recreation"
        return 0
    fi

    cd "$PROJECT_DIR/server"

    # Stop existing containers
    docker-compose -f docker-compose.test.yml down 2>/dev/null || true

    # Start new containers
    docker-compose -f docker-compose.test.yml up -d

    log_success "Containers recreated!"
    log_info "Run 'make logs' to view logs"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    local branch="$DEFAULT_BRANCH"
    local force=false
    local status_only=false
    local recreate=false
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -s|--status)
                status_only=true
                shift
                ;;
            -b|--branch)
                branch="$2"
                shift 2
                ;;
            -r|--recreate)
                recreate=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                set -x
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Check git repository
    check_git_repo

    # Show status only
    if [[ "$status_only" == "true" ]]; then
        show_status "$branch"
        exit 0
    fi

    # Sync from remote
    sync_from_remote "$branch" "$force"

    # Recreate containers if requested
    if [[ "$recreate" == "true" ]]; then
        recreate_containers
    fi

    # Show summary
    show_summary
}

main "$@"
