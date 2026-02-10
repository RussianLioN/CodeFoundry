#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# SAFETY CHECK — Quick verification of backup-coordinator fixes
# Standalone test that doesn't require git repository
# ═══════════════════════════════════════════════════════════════════════════════

set -e

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  BACKUP COORDINATOR — SAFETY CHECK"
echo "  Verification of P0 bug fixes"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BACKUP_SCRIPT="$PROJECT_ROOT/scripts/backup-coordinator.sh"

# Test counters
PASS=0
FAIL=0

check_pass() {
    echo -e "  ${GREEN}✓ PASS${NC}  $1"
    PASS=$((PASS + 1))
}

check_fail() {
    echo -e "  ${RED}✗ FAIL${NC}  $1"
    FAIL=$((FAIL + 1))
}

check_warn() {
    echo -e "  ${YELLOW}⚠ WARN${NC}  $1"
}

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 1: Backup script exists
# ─────────────────────────────────────────────────────────────────────────────

echo "1. Backup script exists"
if [ -f "$BACKUP_SCRIPT" ]; then
    check_pass "Script found at $BACKUP_SCRIPT"
else
    check_fail "Script NOT found at $BACKUP_SCRIPT"
    echo ""
    echo "Cannot proceed without backup script."
    exit 1
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 2: Script is executable
# ─────────────────────────────────────────────────────────────────────────────

echo "2. Script is executable"
if [ -x "$BACKUP_SCRIPT" ]; then
    check_pass "Script has execute permission"
else
    check_fail "Script missing execute permission"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 3: .git deletion fix is present
# ─────────────────────────────────────────────────────────────────────────────

echo "3. Critical bug fix: .git deletion protection"
if grep -q "exclude='.git'" "$BACKUP_SCRIPT"; then
    check_pass ".git exclusion found in rsync command"
else
    check_fail ".git exclusion NOT found - REPOSITORY DESTRUCTION BUG!"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 4: Command injection fix is present
# ─────────────────────────────────────────────────────────────────────────────

echo "4. Critical bug fix: Command injection protection"
if grep -q "sys.argv\[1\]" "$BACKUP_SCRIPT"; then
    check_pass "Secure argument passing found"
else
    check_fail "Command injection vulnerability NOT fixed!"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 5: Trap handlers are present
# ─────────────────────────────────────────────────────────────────────────────

echo "5. Error handling: Trap handlers"
if grep -q "trap cleanup EXIT INT TERM" "$BACKUP_SCRIPT"; then
    check_pass "Trap handlers installed"
else
    check_warn "Trap handlers not found (cleanup on error missing)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 6: Help command works
# ─────────────────────────────────────────────────────────────────────────────

echo "6. Usability: Help command"
if "$BACKUP_SCRIPT" help >/dev/null 2>&1; then
    check_pass "Help command works"
else
    check_fail "Help command failed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 7: .backup directory exclusion is present
# ─────────────────────────────────────────────────────────────────────────────

echo "7. Backup safety: .backup directory exclusion"
if grep -q "exclude='.backup'" "$BACKUP_SCRIPT"; then
    check_pass ".backup directory excluded from rollback"
else
    check_fail ".backup exclusion missing - infinite backup loop possible!"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 8: Script syntax is valid
# ─────────────────────────────────────────────────────────────────────────────

echo "8. Code quality: Shell syntax validation"
if bash -n "$BACKUP_SCRIPT" 2>/dev/null; then
    check_pass "Shell syntax is valid"
else
    check_fail "Shell syntax errors detected!"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 9: Log function creates directory
# ─────────────────────────────────────────────────────────────────────────────

echo "9. Robustness: Log directory auto-creation"
if grep -q "mkdir -p.*BACKUP_DIR" "$BACKUP_SCRIPT"; then
    check_pass "Log directory auto-creation present"
else
    check_warn "Log directory may not be created before logging"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 10: Validation functions exist
# ─────────────────────────────────────────────────────────────────────────────

echo "10. Completeness: Validation functions"
if grep -q "validate_git_integrity\|validate_file_count\|validate_critical_files" "$BACKUP_SCRIPT"; then
    check_pass "Validation functions found"
else
    check_warn "Some validation functions may be missing"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  SAFETY CHECK SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo "  Total:   $((PASS + FAIL))"
echo -e "  ${GREEN}Passed:  $PASS${NC}"
if [ $FAIL -gt 0 ]; then
    echo -e "  ${RED}Failed:  $FAIL${NC}"
    echo ""
    echo "❌ CRITICAL ISSUES FOUND - DO NOT USE IN PRODUCTION"
    echo ""
    echo "Failed checks must be fixed before backup-coordinator"
    echo "can be considered safe for production use."
    exit 1
else
    echo ""
    echo -e "${GREEN}✓ ALL CRITICAL CHECKS PASSED${NC}"
    echo ""
    echo "The backup-coordinator script has verified fixes for:"
    echo "  • .git directory deletion bug"
    echo "  • Command injection vulnerability"
    echo "  • Basic error handling"
    echo ""
    echo "Note: This is a basic safety check. Full test suite"
    echo "requires functional testing with actual git operations."
    exit 0
fi
