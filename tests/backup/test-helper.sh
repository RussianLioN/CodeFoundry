#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# test-helper.sh — Common fixtures and helpers for backup-coordinator tests
# ═══════════════════════════════════════════════════════════════════════════════

# Set up test environment
setup_test_env() {
    TEST_DIR="$(mktemp -d -t backup-test-XXXXXX)"
    TEST_REPO="$TEST_DIR/repo"
    PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
    BACKUP_SCRIPT="$PROJECT_ROOT/scripts/backup-coordinator.sh"

    # Create test repository
    mkdir -p "$TEST_REPO"
    cd "$TEST_REPO"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create initial commit
    echo "# Test Repository" > README.md
    mkdir -p .claude docs
    echo "version: 1.0.0" > .claude/settings.json
    echo "# Documentation" > docs/README.md

    git add .
    git commit -q -m "Initial commit"

    echo "$TEST_DIR"
}

# Cleanup test environment
cleanup_test_env() {
    local test_dir="$1"
    if [ -n "$test_dir" ] && [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
}

# Create test files
create_test_files() {
    local count="${1:-5}"
    local i=0

    while [ $i -lt "$count" ]; do
        echo "Test content $i" > "test-file-$i.txt"
        i=$((i + 1))
    done
}

# Modify test files (simulate work)
modify_test_files() {
    local count="${1:-3}"
    local i=0

    while [ $i -lt "$count" ]; do
        echo "Modified content $i" > "test-file-$i.txt"
        i=$((i + 1))
    done
}

# Verify file count
verify_file_count() {
    local expected="$1"
    local actual

    if [ -d .git ]; then
        actual=$(git ls-files | wc -l | tr -d ' ')
    else
        actual=$(find . -type f | wc -l | tr -d ' ')
    fi

    [ "$actual" -eq "$expected" ]
}

# Verify .git directory exists
verify_git_exists() {
    [ -d .git ] && [ -d .git/objects ] && [ -d .git/refs ]
}

# Verify backup coordinator script exists
verify_script_exists() {
    [ -f "$BACKUP_SCRIPT" ] && [ -x "$BACKUP_SCRIPT" ]
}

# Run backup coordinator command
run_backup_cmd() {
    local cmd="$1"
    shift
    local args=("$@")

    if [ ! -f "$BACKUP_SCRIPT" ]; then
        echo "ERROR: Backup script not found at $BACKUP_SCRIPT" >&2
        return 1
    fi

    "$BACKUP_SCRIPT" "$cmd" "${args[@]}"
}

# Get last stash reference
get_last_stash_ref() {
    git stash list | grep "backup-coordinator:" | head -1 | grep -o "stash@{[0-9]*}"
}

# Count backup-coordinator stashes
count_backup_stashes() {
    git stash list | grep -c "backup-coordinator:" || echo "0"
}

# Create filesystem snapshot (manual)
create_fs_snapshot() {
    local dest_dir="$1"
    mkdir -p "$dest_dir"
    rsync -av --exclude='.git' --exclude='.backup' ./ "$dest_dir/" >/dev/null 2>&1
}

# Compare two directories
compare_directories() {
    local dir1="$1"
    local dir2="$2"

    # Compare file counts
    local count1=$(find "$dir1" -type f | wc -l | tr -d ' ')
    local count2=$(find "$dir2" -type f | wc -l | tr -d ' ')

    [ "$count1" -eq "$count2" ]
}

# Export functions for BATS
export -f setup_test_env
export -f cleanup_test_env
export -f create_test_files
export -f modify_test_files
export -f verify_file_count
export -f verify_git_exists
export -f verify_script_exists
export -f run_backup_cmd
export -f get_last_stash_ref
export -f count_backup_stashes
export -f create_fs_snapshot
export -f compare_directories
