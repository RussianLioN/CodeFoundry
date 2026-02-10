#!/bin/bash
# =============================================================================
# CodeFoundry Telegram Bot Testing Script
# =============================================================================
# Tests Telegram Bot on ainetic.tech with real API
#
# Usage:
#   ./test-telegram.sh                    # Run all tests
#   ./test-telegram.sh --scenario=start   # Test /start only
#   ./test-telegram.sh --watch            # Watch bot logs
#   ./test-telegram.sh --interactive      # Interactive testing mode
#
# Test Scenarios:
#   - start    : Test /start command
#   - new      : Test /new project creation
#   - status   : Test /status command
#   - help     : Test /help command
#   - webhook  : Test WebSocket connection
#   - reconnect : Test auto-reconnect
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
if [[ -f "$SCRIPT_DIR/.env.test" ]]; then
    source "$SCRIPT_DIR/.env.test"
fi

# Defaults
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.test.yml"
COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-codefoundry-test}"
BOT_CONTAINER="${COMPOSE_PROJECT}-telegram-bot-1"
GATEWAY_CONTAINER="${COMPOSE_PROJECT}-gateway-1"
LOG_DIR="/var/log/tests"
TEST_LOG_DIR="${LOG_DIR}/telegram-$(date +%Y%m%d-%H%M%S)"

# Telegram
BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
AUTHORIZED_USER="${AUTHORIZED_USER_IDS}"
GET_UPDATES_URL="https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"
SEND_MESSAGE_URL="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# =============================================================================
# Logging Functions
# =============================================================================

log_info() { echo -e "${BLUE}[TEST]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; ((TESTS_PASSED++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; ((TESTS_FAILED++)); }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_test() { echo -e "${CYAN}[TEST]${NC} $1"; ((TESTS_TOTAL++)); }

# =============================================================================
# Helper Functions
# =============================================================================

show_help() {
    cat << EOF
CodeFoundry Telegram Bot Testing Script

Usage: $0 [OPTIONS]

Options:
    --scenario NAME     Run specific scenario (start, new, status, help, webhook, reconnect)
    --watch             Watch bot logs in real-time
    --interactive       Interactive testing mode
    --verbose           Verbose output
    --help              Show this help

Scenarios:
    start               Test /start command
    new                 Test /new project creation
    status              Test /status command
    help                Test /help command
    webhook             Test WebSocket connection to Gateway
    reconnect           Test auto-reconnect behaviour
    all                 Run all tests (default)

Examples:
    $0                              # Run all tests
    $0 --scenario=start             # Test /start only
    $0 --watch                      # Watch logs

EOF
}

check_dependencies() {
    log_info "Checking dependencies..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_fail "Docker not found"
        exit 1
    fi

    # Check docker-compose
    if ! command -v docker-compose &> /dev/null; then
        log_fail "docker-compose not found"
        exit 1
    fi

    # Check jq
    if ! command -v jq &> /dev/null; then
        log_warning "jq not found, JSON parsing limited"
    fi

    # Check curl
    if ! command -v curl &> /dev/null; then
        log_fail "curl not found"
        exit 1
    fi

    log_success "All dependencies available"
}

check_bot_running() {
    log_info "Checking if bot container is running..."

    if ! docker ps --filter "name=$BOT_CONTAINER" --format "{{.Names}}" | grep -q .; then
        log_fail "Bot container not running: $BOT_CONTAINER"
        log_info "Start with: make start-test"
        exit 1
    fi

    log_success "Bot container running: $BOT_CONTAINER"
}

check_gateway_running() {
    log_info "Checking if gateway container is running..."

    if ! docker ps --filter "name=$GATEWAY_CONTAINER" --format "{{.Names}}" | grep -q .; then
        log_fail "Gateway container not running: $GATEWAY_CONTAINER"
        exit 1
    fi

    log_success "Gateway container running: $GATEWAY_CONTAINER"
}

check_bot_token() {
    log_info "Checking bot token..."

    if [[ -z "$BOT_TOKEN" ]] || [[ "$BOT_TOKEN" == "replace_with_actual"* ]]; then
        log_fail "Bot token not configured"
        log_info "Set TELEGRAM_BOT_TOKEN in server/.env.test"
        exit 1
    fi

    log_success "Bot token configured"
}

send_telegram_message() {
    local text="$1"
    local chat_id="$AUTHORIZED_USER"

    if [[ -z "$chat_id" ]]; then
        log_warning "AUTHORIZED_USER_IDS not set, skipping message"
        return 1
    fi

    log_info "Sending message to Telegram: $text"

    local response=$(curl -s -X POST "$SEND_MESSAGE_URL" \
        -d "chat_id=$chat_id" \
        -d "text=$text" \
        -d "parse_mode=Markdown")

    if echo "$response" | jq -e '.ok' > /dev/null 2>&1; then
        log_success "Message sent successfully"
        return 0
    else
        log_fail "Failed to send message"
        echo "$response" | jq -r '.description' 2>/dev/null || echo "$response"
        return 1
    fi
}

get_telegram_updates() {
    local timeout=5

    log_info "Fetching Telegram updates..."

    local response=$(curl -s -X GET "$GET_UPDATES_URL?timeout=$timeout" -d "allowed_updates=[\"message\"]")

    if echo "$response" | jq -e '.ok' > /dev/null 2>&1; then
        local count=$(echo "$response" | jq '.result | length')
        log_success "Received $count update(s)"

        if [[ "$count" -gt 0 ]]; then
            echo "$response" | jq -r '.result[] | "\(.message.from.first_name): \(.message.text)"'
        fi

        return 0
    else
        log_fail "Failed to fetch updates"
        echo "$response" | jq -r '.description' 2>/dev/null || echo "$response"
        return 1
    fi
}

# =============================================================================
# Test Scenarios
# =============================================================================

test_start_command() {
    log_test "Testing /start command..."

    # Send /start command
    send_telegram_message "/start"

    # Wait for response
    log_info "Waiting for bot response..."
    sleep 3

    # Check logs for response
    local logs=$(docker logs --tail=20 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "handleStart"; then
        log_success "Bot handled /start command"
    else
        log_fail "Bot did not handle /start command"
    fi

    if echo "$logs" | grep -q "welcome"; then
        log_success "Welcome message sent"
    else
        log_warning "No welcome message found in logs"
    fi
}

test_new_command() {
    log_test "Testing /new command..."

    # Send /new command
    send_telegram_message "/new"

    # Wait for response
    log_info "Waiting for bot response..."
    sleep 5

    # Check logs
    local logs=$(docker logs --tail=30 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "handleNew"; then
        log_success "Bot handled /new command"
    else
        log_fail "Bot did not handle /new command"
    fi

    if echo "$logs" | grep -q "gateway"; then
        log_success "Bot forwarded request to Gateway"
    else
        log_warning "No gateway communication found"
    fi
}

test_status_command() {
    log_test "Testing /status command..."

    # Send /status command
    send_telegram_message "/status"

    # Wait for response
    log_info "Waiting for bot response..."
    sleep 3

    # Check logs
    local logs=$(docker logs --tail=20 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "handleStatus"; then
        log_success "Bot handled /status command"
    else
        log_fail "Bot did not handle /status command"
    fi
}

test_help_command() {
    log_test "Testing /help command..."

    # Send /help command
    send_telegram_message "/help"

    # Wait for response
    log_info "Waiting for bot response..."
    sleep 3

    # Check logs
    local logs=$(docker logs --tail=20 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "handleHelp"; then
        log_success "Bot handled /help command"
    else
        log_fail "Bot did not handle /help command"
    fi
}

test_websocket_connection() {
    log_test "Testing WebSocket connection to Gateway..."

    # Check gateway health
    local gateway_health=$(docker exec "$GATEWAY_CONTAINER" wget -q -O- http://localhost:18790/health 2>/dev/null || echo "unhealthy")

    if [[ "$gateway_health" == *"healthy"* ]]; then
        log_success "Gateway is healthy"
    else
        log_fail "Gateway health check failed"
        return 1
    fi

    # Check bot logs for WebSocket connection
    local logs=$(docker logs --tail=50 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "WebSocket connected"; then
        log_success "Bot connected to Gateway via WebSocket"
    else
        log_warning "No WebSocket connection found in logs"
    fi

    if echo "$logs" | grep -q "ws://"; then
        log_success "WebSocket URL configured"
    else
        log_fail "WebSocket URL not found"
    fi
}

test_auto_reconnect() {
    log_test "Testing auto-reconnect behaviour..."

    # Get initial connection state
    local initial_logs=$(docker logs --tail=100 "$BOT_CONTAINER" 2>&1)
    local initial_connections=$(echo "$initial_logs" | grep -c "WebSocket connected" || echo "0")

    log_info "Initial connections: $initial_connections"

    # Restart gateway
    log_info "Restarting Gateway to trigger reconnect..."
    docker restart "$GATEWAY_CONTAINER" > /dev/null

    # Wait for reconnect
    log_info "Waiting for auto-reconnect..."
    sleep 10

    # Check reconnect attempts
    local reconnect_logs=$(docker logs --tail=50 "$BOT_CONTAINER" 2>&1)

    if echo "$reconnect_logs" | grep -q "reconnect"; then
        log_success "Bot attempted reconnection"
    else
        log_warning "No reconnection attempt found"
    fi

    if echo "$reconnect_logs" | grep -q "WebSocket connected"; then
        log_success "Bot successfully reconnected"
    else
        log_warning "Reconnection may not have completed"
    fi

    # Restart gateway back
    log_info "Restarting Gateway..."
    docker restart "$GATEWAY_CONTAINER" > /dev/null
    sleep 5
}

test_user_authorization() {
    log_test "Testing user authorization..."

    if [[ -z "$AUTHORIZED_USER" ]]; then
        log_warning "AUTHORIZED_USER_IDS not set, skipping test"
        return 0
    fi

    # Check if bot validates user
    local logs=$(docker logs --tail=100 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "authorized"; then
        log_success "Bot checks user authorization"
    else
        log_warning "No authorization check found"
    fi

    if echo "$logs" | grep -q "AUTHORIZED_USER_IDS"; then
        log_success "Authorization configured"
    else
        log_warning "Authorization configuration not found"
    fi
}

test_session_management() {
    log_test "Testing session management..."

    # Check session creation
    local logs=$(docker logs --tail=100 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "session"; then
        log_success "Bot uses sessions"
    else
        log_warning "No session management found"
    fi

    if echo "$logs" | grep -q "SESSION_TIMEOUT"; then
        log_success "Session timeout configured"
    else
        log_warning "Session timeout not found"
    fi
}

test_error_handling() {
    log_test "Testing error handling..."

    # Send invalid command
    send_telegram_message "/invalid_command_12345"

    # Wait for response
    sleep 3

    # Check error handling
    local logs=$(docker logs --tail=20 "$BOT_CONTAINER" 2>&1)

    if echo "$logs" | grep -q "error\|Error\|ERROR"; then
        log_success "Bot handles errors gracefully"
    else
        log_warning "Error handling not clear from logs"
    fi
}

# =============================================================================
# Run All Tests
# =============================================================================

run_all_tests() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  CodeFoundry Telegram Bot Test Suite                      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_dependencies
    check_bot_running
    check_gateway_running
    check_bot_token

    echo ""
    log_info "Starting test suite..."
    echo ""

    # Run tests
    test_websocket_connection
    test_user_authorization
    test_session_management
    test_start_command
    test_status_command
    test_help_command
    test_new_command
    test_auto_reconnect
    test_error_handling

    # Show results
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Test Results                                                 ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Total:  ${CYAN}$TESTS_TOTAL${NC}"
    echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""

    local pass_rate=0
    if [[ $TESTS_TOTAL -gt 0 ]]; then
        pass_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    fi

    echo -e "  Pass Rate: ${CYAN}${pass_rate}%${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        return 1
    fi
}

# =============================================================================
# Watch Logs
# =============================================================================

watch_logs() {
    log_info "Watching bot logs (Ctrl+C to stop)..."
    echo ""

    docker logs -f "$BOT_CONTAINER"
}

# =============================================================================
# Interactive Mode
# =============================================================================

interactive_mode() {
    echo ""
    log_info "Interactive testing mode"
    echo ""

    while true; do
        echo ""
        echo "Available commands:"
        echo "  1. Send /start"
        echo "  2. Send /new"
        echo "  3. Send /status"
        echo "  4. Send /help"
        echo "  5. Check updates"
        echo "  6. View logs"
        echo "  7. Check Gateway health"
        echo "  0. Exit"
        echo ""
        read -p "Choose: " choice

        case "$choice" in
            1) send_telegram_message "/start" ;;
            2) send_telegram_message "/new" ;;
            3) send_telegram_message "/status" ;;
            4) send_telegram_message "/help" ;;
            5) get_telegram_updates ;;
            6) docker logs --tail=50 "$BOT_CONTAINER" ;;
            7)
                docker exec "$GATEWAY_CONTAINER" wget -q -O- http://localhost:18790/health
                ;;
            0) break ;;
            *) log_warning "Invalid choice" ;;
        esac
    done
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    local scenario=""
    local watch_mode=false
    local interactive=false
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --scenario)
                scenario="$2"
                shift 2
                ;;
            --watch)
                watch_mode=true
                shift
                ;;
            --interactive)
                interactive=true
                shift
                ;;
            --verbose)
                verbose=true
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

    # Run mode
    if [[ "$watch_mode" == "true" ]]; then
        watch_logs
    elif [[ "$interactive" == "true" ]]; then
        check_bot_token
        interactive_mode
    elif [[ -n "$scenario" ]]; then
        check_dependencies
        check_bot_running
        check_gateway_running
        check_bot_token
        echo ""

        case "$scenario" in
            start) test_start_command ;;
            new) test_new_command ;;
            status) test_status_command ;;
            help) test_help_command ;;
            webhook) test_websocket_connection ;;
            reconnect) test_auto_reconnect ;;
            all) run_all_tests ;;
            *)
                log_error "Unknown scenario: $scenario"
                exit 1
                ;;
        esac
    else
        run_all_tests
    fi
}

main "$@"
