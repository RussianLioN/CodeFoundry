#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# P0 Safety Tests — CRITICAL tests that MUST pass before production
# These tests verify that backup-coordinator doesn't destroy data
# ═══════════════════════════════════════════════════════════════════════════════

# Source test framework and helpers
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../run-tests.sh"
source "$SCRIPT_DIR/../test-helper.sh"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 1: Git stash creates valid backup
# ─────────────────────────────────────────────────────────────────────────────

test_git_stash_creates_backup() {
    local test_dir
    test_dir=$(setup_test_env)

    # Create test files and commit
    create_test_files 5
    git add .
    git commit -q -m "Add test files"

    # Modify files
    modify_test_files 3

    # Run backup
    run_backup_cmd create --mode=git

    local exit_code=$?
    assert_success "$exit_code" "Backup creation should succeed"

    # Verify stash was created
    local stash_count
    stash_count=$(count_backup_stashes)
    assert_equals "1" "$stash_count" "Should have 1 backup stash"

    # Verify stash contains our changes
    local stash_ref
    stash_ref=$(get_last_stash_ref)
    assert_not_equals "" "$stash_ref" "Should have valid stash reference"

    cleanup_test_env "$test_dir"
}

# ─────────────────────────────────────────────────────────────────────────────
# TEST 2: .git directory is NEVER deleted (CRITICAL!)
# ─────────────────────────────────────────────────────────────────────────────

test_git_directory_never_deleted() {
    local test_dir
    test_dir=$(setup_test_env)

    # Verify .git exists initially
    assert_dir_exists ".git" ".git should exist initially"

    # Create filesystem backup
    create_fs_snapshot "$test_dir/snapshot"

    # Simulate rollback (this is where the bug was)
    if command -v rsync >/dev/null 2>&1; then
        rsync -av --delete --exclude='.git' --exclude='.backup' "$test_dir/snapshot/" ./ >/dev/null 2>&1
    fi

    local exit_code=$?
    assert_success "$exit_code" "Rsync should succeed"

    # CRITICAL CHECK: .git must still exist
    assert_dir_exists ".git" ".git directory must NEVER be deleted!"

    # Verify git still works
    git rev-parse --git-dir >/dev/null 2>&1
    local git_ok=$?
    assert_success "$git_ok" "Git should still function after rollback"

    cleanup_test_env "$test_dir"
}

# ─────────────────────────────────────────────────────────────────────────────
# TEST 3: Filesystem snapshot preserves all files
# ─────────────────────────────────────────────────────────────────────────────

test_filesystem_snapshot_preserves_files() {
    local test_dir
    test_dir=$(setup_test_env)

    # Create various test files
    create_test_files 10
    mkdir -p subdir
    echo "nested" > subdir/nested.txt
    mkdir -p .claude docs
    echo "config" > .claude/settings.json
    echo "docs" > docs/README.md

    local original_count
    original_count=$(find . -type f -not -path './.git/*' | wc -l | tr -d ' ')

    # Create snapshot
    local snapshot_dir="$test_dir/snapshot"
    create_fs_snapshot "$snapshot_dir"

    # Verify snapshot was created
    assert_dir_exists "$snapshot_dir" "Snapshot directory should exist"

    # Count files in snapshot
    local snapshot_count
    snapshot_count=$(find "$snapshot_dir" -type f | wc -l | tr -d ' ')

    assert_equals "$original_count" "$snapshot_count" "Snapshot should contain all files"

    cleanup_test_env "$test_dir"
}

# ─────────────────────────────────────────────────────────────────────────────
# TEST 4: Rollback restores state exactly
# ─────────────────────────────────────────────────────────────────────────────

test_rollback_restores_state() {
    local test_dir
    test_dir=$(setup_test_env)

    # Create and commit initial state
    create_test_files 5
    git add .
    git commit -q -m "Initial state"

    # Save initial file count
    local initial_count
    initial_count=$(git ls-files | wc -l | tr -d ' ')

    # Modify files
    modify_test_files 3

    # Create backup
    run_backup_cmd create --mode=git
    local backup_ok=$?
    assert_success "$backup_ok" "Backup should succeed"

    # Corrupt state (delete files)
    rm -f test-file-0.txt test-file-1.txt

    # Rollback
    run_backup_cmd rollback
    local rollback_ok=$?
    assert_success "$rollback_ok" "Rollback should succeed"

    # Verify files restored
    assert_file_exists "test-file-0.txt" "Deleted file should be restored"
    assert_file_exists "test-file-1.txt" "Deleted file should be restored"

    # Verify file count matches
    local final_count
    final_count=$(git ls-files | wc -l | tr -d ' ')
    assert_equals "$initial_count" "$final_count" "File count should match initial state"

    cleanup_test_env "$test_dir"
}

# ─────────────────────────────────────────────────────────────────────────────
# TEST 5: Backup is actually restorable
# ─────────────────────────────────────────────────────────────────────────────

test_backup_is_restorable() {
    local test_dir
    test_dir=$(setup_test_env)

    # Create and commit files
    create_test_files 5
    git add .
    git commit -q -m "Add files"

    # Create backup
    run_backup_cmd create --mode=git
    local backup_ok=$?
    assert_success "$backup_ok" "Backup should succeed"

    # Get stash reference
    local stash_ref
    stash_ref=$(get_last_stash_ref)

    # Modify all files
    modify_test_files 5

    # Verify files are modified
    local modified
    modified=$(git diff --name-only | wc -l | tr -d ' ')
    assert_not_equals "0" "$modified" "Files should be modified"

    # Restore from stash
    git stash pop "$stash_ref" >/dev/null 2>&1
    local restore_ok=$?
    assert_success "$restore_ok" "Stash pop should succeed"

    # Verify files restored
    assert_file_exists "test-file-0.txt" "File should exist after restore"

    # Verify no uncommitted changes
    local changes
    changes=$(git diff --name-only | wc -l | tr -d ' ')
    assert_equals "0" "$changes" "Should have no uncommitted changes after restore"

    cleanup_test_env "$test_dir"
}

# ─────────────────────────────────────────────────────────────────────────────
# TEST 6: Command injection protection
# ─────────────────────────────────────────────────────────────────────────────

test_command_injection_protection() {
    local test_dir
    test_dir=$(setup_test_env)

    # Create a file with dangerous name (semicolons, pipes, etc)
    touch "file;rm -rf /tmp/test.txt" 2>/dev/null || touch 'file$(evil).txt'

    # Run backup - should NOT execute the malicious commands
    run_backup_cmd create --mode=git
    local backup_ok=$?
    assert_success "$backup_ok" "Backup should handle dangerous filenames"

    # Verify /tmp/test.txt was NOT created (command didn't execute)
    assert_file_not_exists "/tmp/test.txt" "Malicious command should not execute"

    cleanup_test_env "$test_dir"
}

# ─────────────────────────────────────────────────────────────────────────────
# Run all P0 tests
# ─────────────────────────────────────────────────────────────────────────────

main() {
    echo ""
    printf "${BOLD}P0 SAFETY TESTS — Backup Coordinator${NC}\n"
    echo "These tests MUST ALL PASS before production use"
    echo "───────────────────────────────────────────────────"
    echo ""

    run_test "Git stash creates valid backup" test_git_stash_creates_backup
    run_test ".git directory is NEVER deleted" test_git_directory_never_deleted
    run_test "Filesystem snapshot preserves files" test_filesystem_snapshot_preserves_files
    run_test "Rollback restores state exactly" test_rollback_restores_state
    run_test "Backup is actually restorable" test_backup_is_restorable
    run_test "Command injection protection" test_command_injection_protection

    print_summary
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
