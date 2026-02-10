#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# run-tests.sh — Simple Bash Test Framework for Backup Coordinator
# No external dependencies required
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# Test statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Colors
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# Test assertions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local msg="${3:-Expected '$expected', got '$actual'}"

    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local msg="${3:-Expected not '$not_expected', got '$actual'}"

    if [ "$not_expected" != "$actual" ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

assert_success() {
    local exit_code="$1"
    local msg="${2:-Command failed with exit code $exit_code}"

    if [ "$exit_code" -eq 0 ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

assert_failure() {
    local exit_code="$1"
    local msg="${2:-Expected failure but got exit code $exit_code}"

    if [ "$exit_code" -ne 0 ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local msg="${2:-File does not exist: $file}"

    if [ -f "$file" ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    local msg="${2:-File should not exist: $file}"

    if [ ! -f "$file" ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local msg="${2:-Directory does not exist: $dir}"

    if [ -d "$dir" ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

assert_dir_not_exists() {
    local dir="$1"
    local msg="${2:-Directory should not exist: $dir}"

    if [ ! -d "$dir" ]; then
        return 0
    else
        echo "    ❌ Assertion failed: $msg" >&2
        return 1
    fi
}

# Run a single test
run_test() {
    local test_name="$1"
    local test_function="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    printf "  ${BLUE}Running${NC} $test_name... "

    # Run test in subshell for isolation
    if (
        # Source test helpers
        . "/Users/s060874gmail.com/coding/projects/system-prompts/tests/backup/test-helper.sh"

        # Run test function
        "$test_function"
    ); then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        printf "${GREEN}✓ PASS${NC}\n"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
        printf "${RED}✗ FAIL${NC}\n"
    fi
}

# Print test summary
print_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    printf "${BOLD}TEST SUMMARY${NC}\n"
    echo "═══════════════════════════════════════════════════════════"
    echo "  Total:   $TESTS_RUN"
    echo -e "  ${GREEN}Passed:  $TESTS_PASSED${NC}"
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "  ${RED}Failed:  $TESTS_FAILED${NC}"
    fi
    echo "───────────────────────────────────────────────────────────"

    if [ $TESTS_FAILED -gt 0 ]; then
        printf "\n${RED}Failed tests:${NC}\n"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
        echo ""
        return 1
    else
        printf "\n${GREEN}All tests passed!${NC}\n\n"
        return 0
    fi
}

# Export functions for use in test files
export -f assert_equals assert_not_equals assert_success assert_failure
export -f assert_file_exists assert_file_not_exists
export -f assert_dir_exists assert_dir_not_exists
export -f run_test
