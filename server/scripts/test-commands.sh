#!/usr/bin/env bash
# Test script for Command Protocol v1.0
# Tests all MVP commands

# Don't exit on error globally - handle per test
set -uo pipefail

readonly CLI_WRAPPER="./claude-wrapper.sh"
readonly TEST_COUNT=4
declare -i PASSED=0
declare -i FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${YELLOW}[TEST]${NC} $*"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; ((PASSED++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $*"; ((FAILED++)); }

# Test 1: Help command
test_help() {
    log_info "Testing /help command..."

    local response
    response=$(echo '{"command":"help"}' | "$CLI_WRAPPER")

    if echo "$response" | jq -e '.status == "success"' >/dev/null; then
        log_pass "Help command works"
    else
        log_fail "Help command failed"
        echo "Response: $response"
    fi
}

# Test 2: Status command
test_status() {
    log_info "Testing /status command..."

    local response
    response=$(echo '{"command":"status"}' | "$CLI_WRAPPER")

    if echo "$response" | jq -e '.status == "success"' >/dev/null; then
        log_pass "Status command works"
    else
        log_fail "Status command failed"
        echo "Response: $response"
    fi
}

# Test 3: Invalid command
test_invalid_command() {
    log_info "Testing invalid command..."

    local response
    response=$(echo '{"command":"invalid_command"}' | "$CLI_WRAPPER")

    if echo "$response" | jq -e '.status == "error"' >/dev/null; then
        log_pass "Invalid command error handling works"
    else
        log_fail "Invalid command error handling failed"
        echo "Response: $response"
    fi
}

# Test 4: Path traversal protection
test_path_traversal() {
    log_info "Testing path traversal protection..."

    local response
    response=$(echo '{"command":"create_project","params":{"name":"../etc"}}' | "$CLI_WRAPPER")

    if echo "$response" | jq -e '.error.code == "INVALID_PARAMS"' >/dev/null; then
        log_pass "Path traversal protection works"
    else
        log_fail "Path traversal protection failed"
        echo "Response: $response"
    fi
}

# Main
main() {
    echo "========================================"
    echo "Command Protocol v1.0 Test Suite"
    echo "========================================"
    echo ""

    # Check if CLI wrapper exists
    if [[ ! -f "$CLI_WRAPPER" ]]; then
        echo "Error: CLI wrapper not found at $CLI_WRAPPER"
        exit 1
    fi

    # Check if jq is available
    if ! command -v jq &>/dev/null; then
        echo "Error: jq is required but not installed"
        exit 1
    fi

    # Run tests
    test_help
    test_status
    test_invalid_command
    test_path_traversal

    # Summary
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo -e "Passed: ${GREEN}$PASSED${NC}"
    echo -e "Failed: ${RED}$FAILED${NC}"
    echo "Total:  $((PASSED + FAILED))"
    echo ""

    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        exit 1
    fi
}

main "$@"
