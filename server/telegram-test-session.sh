#!/bin/bash
# =============================================================================
# CodeFoundry Telegram Bot Test Session Manager
# =============================================================================
# Creates and manages test sessions for Telegram bot testing
#
# Usage:
#   ./telegram-test-session.sh create [name]    # Create test session
#   ./telegram-test-session.sh stop [name]      # Stop test session
#   ./telegram-test-session.sh list            # List test sessions
#   ./telegram-test-session.sh test [name]     # Run tests in session
#
# Integration:
#   Uses container-manager.sh for session lifecycle
# =============================================================================

set -e

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONTAINER_MANAGER="$SCRIPT_DIR/container-manager.sh"

# Load environment
if [[ -f "$SCRIPT_DIR/.env.test" ]]; then
    source "$SCRIPT_DIR/.env.test"
fi

# Defaults
SESSION_PREFIX="bot-test"
COMPOSE_PROJECT="${COMPOSE_PROJECT_NAME:-codefoundry-test}"
LOG_DIR="/var/log/tests"

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

log_info() { echo -e "${BLUE}[SESSION]${NC} $1"; }
log_success() { echo -e "${GREEN}[SESSION]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[SESSION]${NC} $1"; }
log_error() { echo -e "${RED}[SESSION]${NC} $1"; }

# =============================================================================
# Helper Functions
# =============================================================================

show_help() {
    cat << EOF
CodeFoundry Telegram Bot Test Session Manager

Usage: $0 <command> [options]

Commands:
    create [name]      Create a new test session
    stop [name]        Stop a test session
    list               List all test sessions
    test [name]        Run tests in session
    logs [name]        View session logs
    shell [name]       Enter session shell
    help               Show this help

Session Name:
    If not provided, auto-generated as ${SESSION_PREFIX}-{timestamp}

Examples:
    $0 create                    # Create auto-named session
    $0 create my-test            # Create named session
    $0 list                      # List all sessions
    $0 test my-test              # Run tests in session
    $0 stop my-test              # Stop session

EOF
}

generate_session_name() {
    local timestamp=$(date +%s)
    echo "${SESSION_PREFIX}-${timestamp}"
}

# =============================================================================
# Session Commands
# =============================================================================

create_session() {
    local session_name="$1"

    if [[ -z "$session_name" ]]; then
        session_name=$(generate_session_name)
    fi

    log_info "Creating test session: $session_name"
    echo ""

    # Create session using container manager
    "$CONTAINER_MANAGER" start-session "$session_name"

    echo ""
    log_info "Session created successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Configure bot: nano server/.env.test"
    echo "  2. Run tests: $0 test $session_name"
    echo "  3. View logs: $0 logs $session_name"
    echo "  4. Stop session: $0 stop $session_name"
}

stop_session() {
    local session_name="$1"

    if [[ -z "$session_name" ]]; then
        log_error "Session name is required"
        exit 1
    fi

    log_info "Stopping test session: $session_name"

    "$CONTAINER_MANAGER" stop-session "$session_name"

    log_success "Session stopped"
}

list_sessions() {
    log_info "Test sessions:"
    echo ""

    # Get all bot-test sessions
    local sessions=$("$CONTAINER_MANAGER" list-sessions 2>/dev/null | grep "$SESSION_PREFIX" || true)

    if [[ -z "$sessions" ]]; then
        log_warning "No test sessions found"
        return 0
    fi

    echo "$sessions"
}

test_session() {
    local session_name="$1"

    if [[ -z "$session_name" ]]; then
        # Use latest session
        session_name=$("$CONTAINER_MANAGER" list-sessions 2>/dev/null | grep "$SESSION_PREFIX" | tail -1 | awk '{print $2}' || echo "")

        if [[ -z "$session_name" ]]; then
            log_error "No test session found"
            log_info "Create one first: $0 create"
            exit 1
        fi

        log_info "Using latest session: $session_name"
    fi

    log_info "Running tests in session: $session_name"
    echo ""

    # Check if session is running
    local bot_container="${COMPOSE_PROJECT}-${session_name}-telegram-bot"

    if ! docker ps --filter "name=$bot_container" --format "{{.Names}}" | grep -q .; then
        log_error "Bot container not running: $bot_container"
        log_info "Start session first: $0 create $session_name"
        exit 1
    fi

    # Run tests
    local test_script="$SCRIPT_DIR/test-telegram.sh"

    if [[ ! -f "$test_script" ]]; then
        log_error "Test script not found: $test_script"
        exit 1
    fi

    # Update container names for session
    export BOT_CONTAINER="${COMPOSE_PROJECT}-${session_name}-telegram-bot"
    export GATEWAY_CONTAINER="${COMPOSE_PROJECT}-${session_name}-gateway"

    "$test_script" --scenario all
}

view_logs() {
    local session_name="$1"

    if [[ -z "$session_name" ]]; then
        # Use latest session
        session_name=$("$CONTAINER_MANAGER" list-sessions 2>/dev/null | grep "$SESSION_PREFIX" | tail -1 | awk '{print $2}' || echo "")

        if [[ -z "$session_name" ]]; then
            log_error "No test session found"
            exit 1
        fi

        log_info "Using latest session: $session_name"
    fi

    log_info "Viewing logs for session: $session_name"
    echo ""

    local bot_container="${COMPOSE_PROJECT}-${session_name}-telegram-bot"
    local gateway_container="${COMPOSE_PROJECT}-${session_name}-gateway"

    echo -e "${CYAN}=== Bot Logs ===${NC}"
    docker logs --tail=50 "$bot_container" 2>&1 || echo "No logs available"

    echo ""
    echo -e "${CYAN}=== Gateway Logs ===${NC}"
    docker logs --tail=30 "$gateway_container" 2>&1 || echo "No logs available"
}

enter_shell() {
    local session_name="$1"

    if [[ -z "$session_name" ]]; then
        # Use latest session
        session_name=$("$CONTAINER_MANAGER" list-sessions 2>/dev/null | grep "$SESSION_PREFIX" | tail -1 | awk '{print $2}' || echo "")

        if [[ -z "$session_name" ]]; then
            log_error "No test session found"
            exit 1
        fi

        log_info "Using latest session: $session_name"
    fi

    log_info "Entering shell for session: $session_name"

    "$CONTAINER_MANAGER" attach-session "$session_name"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    local command="$1"
    shift

    case "$command" in
        create)
            create_session "$@"
            ;;
        stop)
            stop_session "$@"
            ;;
        list)
            list_sessions
            ;;
        test)
            test_session "$@"
            ;;
        logs)
            view_logs "$@"
            ;;
        shell)
            enter_shell "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
