#!/bin/bash
# =============================================================================
# CodeFoundry Container Lifecycle Manager
# =============================================================================
# Manages ephemeral containers with session-based lifecycle
#
# Session Patterns:
#   - test-{timestamp}      : For testing
#   - dev-{username}        : For development
#   - bot-test-{timestamp}  : For bot testing
#
# Usage:
#   ./container-manager.sh start-session my-test
#   ./container-manager.sh list-sessions
#   ./container-manager.sh attach-session my-test
#   ./container-manager.sh stop-session my-test
#   ./container-manager.sh auto-cleanup
#
# Integration:
#   Called from Makefile: make start-session SESSION=name
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
SESSION_PREFIX="${CONTAINER_PREFIX:-test}"
SESSION_TIMEOUT="${SESSION_TIMEOUT:-86400}"  # 24 hours
SESSION_MAX_AGE_HOURS="${SESSION_MAX_AGE_HOURS:-24}"

# Docker
DOCKER_COMPOSE="docker-compose -f $COMPOSE_FILE -p $COMPOSE_PROJECT"

# State file for tracking sessions
STATE_DIR="/tmp/codefoundry-sessions"
STATE_FILE="$STATE_DIR/sessions.json"

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
log_session() { echo -e "${CYAN}[SESSION]${NC} $1"; }

# =============================================================================
# State Management
# =============================================================================

init_state() {
    mkdir -p "$STATE_DIR"
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "{}" > "$STATE_FILE"
    fi

    # Load state
    SESSIONS=$(cat "$STATE_FILE")
}

save_state() {
    echo "$SESSIONS" > "$STATE_FILE"
}

get_session_info() {
    local session_name="$1"
    echo "$SESSIONS" | jq -r ".sessions.\"$session_name\" // empty"
}

set_session_info() {
    local session_name="$1"
    local info="$2"

    # Update or create session
    SESSIONS=$(echo "$SESSIONS" | jq "
        .sessions |= (. + {\"$session_name\": $info})
    ")
    save_state
}

remove_session_info() {
    local session_name="$1"
    SESSIONS=$(echo "$SESSIONS" | jq "del(.sessions.\"$session_name\")")
    save_state
}

# =============================================================================
# Helper Functions
# =============================================================================

show_help() {
    cat << EOF
CodeFoundry Container Lifecycle Manager

Usage: $0 <command> [options]

Commands:
    start-session <name>     Start a new named session
    stop-session <name>      Stop a session gracefully
    restart-session <name>   Restart a session
    list-sessions            List all active sessions
    attach-session <name>    Attach to a session shell
    exec-session <name> <cmd> Execute command in session
    auto-cleanup              Remove old sessions (>24h)
    status                   Show container status
    help                     Show this help

Session Patterns:
    test-{timestamp}         For testing (e.g., test-1706980000)
    dev-{username}           For development (e.g., dev-john)
    bot-test-{timestamp}     For bot testing

Environment:
    SESSION_PREFIX           Container prefix (default: test)
    SESSION_TIMEOUT          Session timeout in seconds (default: 86400)
    SESSION_MAX_AGE_HOURS    Max session age in hours (default: 24)

Examples:
    $0 start-session my-test
    $0 list-sessions
    $0 attach-session my-test
    $0 stop-session my-test
    $0 auto-cleanup

EOF
}

generate_session_name() {
    local pattern="${1:-test}"
    local timestamp=$(date +%s)
    echo "${pattern}-${timestamp}"
}

check_session_exists() {
    local session_name="$1"

    # Check Docker containers
    if docker ps -a --filter "name=${COMPOSE_PROJECT}-${session_name}" --format "{{.Names}}" | grep -q .; then
        return 0
    fi

    return 1
}

get_session_containers() {
    local session_name="$1"
    docker ps -a --filter "name=${COMPOSE_PROJECT}-${session_name}" --format "{{.Names}}"
}

# =============================================================================
# Session Commands
# =============================================================================

start_session() {
    local session_name="$1"
    local service="${2:-}"

    if [[ -z "$session_name" ]]; then
        log_error "Session name is required"
        exit 1
    fi

    log_info "Starting session: $session_name"

    # Check if session already exists
    if check_session_exists "$session_name"; then
        log_warning "Session '$session_name' already exists"

        # Check if containers are running
        local running=$(get_session_containers "$session_name" | wc -l)
        if [[ "$running" -gt 0 ]]; then
            log_info "Session has $running container(s)"
            show_session_status "$session_name"
            return 0
        fi
    fi

    # Create session-specific compose override
    local override_file="/tmp/${COMPOSE_PROJECT}-${session_name}.yml"

    cat > "$override_file" << EOF
# Session override for: $session_name
name: ${COMPOSE_PROJECT}-${session_name}

services:
  gateway:
    container_name: ${COMPOSE_PROJECT}-${session_name}-gateway
    environment:
      - SESSION_NAME=$session_name

  telegram-bot:
    container_name: ${COMPOSE_PROJECT}-${session_name}-telegram-bot
    environment:
      - SESSION_NAME=$session_name

  test-runner:
    container_name: ${COMPOSE_PROJECT}-${session_name}-runner
    environment:
      - SESSION_NAME=$session_name
EOF

    # Start containers
    log_info "Starting containers for session: $session_name"

    if [[ -n "$service" ]]; then
        # Start specific service
        docker-compose -f "$COMPOSE_FILE" -f "$override_file" up -d "$service"
    else
        # Start all services
        docker-compose -f "$COMPOSE_FILE" -f "$override_file" up -d
    fi

    # Record session info
    local start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local session_info=$(jq -n \
        --arg name "$session_name" \
        --arg started "$start_time" \
        --arg compose_file "$override_file" \
        '{
            name: $name,
            started: $started,
            compose_file: $compose_file,
            status: "running"
        }')

    set_session_info "$session_name" "$session_info"

    # Save override file path for cleanup
    echo "$override_file" > "/tmp/${COMPOSE_PROJECT}-${session_name}.override"

    log_success "Session '$session_name' started"
    log_info "Override file: $override_file"

    # Show status
    sleep 2
    show_session_status "$session_name"
}

stop_session() {
    local session_name="$1"
    local force="${2:-false}"

    if [[ -z "$session_name" ]]; then
        log_error "Session name is required"
        exit 1
    fi

    log_info "Stopping session: $session_name"

    if ! check_session_exists "$session_name"; then
        log_warning "Session '$session_name' does not exist"
        return 0
    fi

    # Get override file
    local override_file="/tmp/${COMPOSE_PROJECT}-${session_name}.override"
    if [[ -f "$override_file" ]]; then
        COMPOSE_FILE="$COMPOSE_FILE -f $(cat $override_file)"
    fi

    # Stop containers
    local containers=$(get_session_containers "$session_name")
    if [[ -n "$containers" ]]; then
        log_info "Stopping containers:"
        echo "$containers" | while read -r container; do
            log_info "  - $container"
        done

        echo "$containers" | xargs -r docker stop
    fi

    # Remove containers
    if [[ "$force" == "true" ]]; then
        echo "$containers" | xargs -r docker rm -f
    fi

    # Clean up state
    remove_session_info "$session_name"

    # Clean up override file
    if [[ -f "$override_file" ]]; then
        rm -f "$override_file"
        rm -f "/tmp/${COMPOSE_PROJECT}-${session_name}.override"
    fi

    log_success "Session '$session_name' stopped"
}

restart_session() {
    local session_name="$1"

    if [[ -z "$session_name" ]]; then
        log_error "Session name is required"
        exit 1
    fi

    log_info "Restarting session: $session_name"

    stop_session "$session_name"
    sleep 2
    start_session "$session_name"
}

list_sessions() {
    init_state

    echo ""
    log_info "Active Sessions:"
    echo ""

    # Get all CodeFoundry containers
    local all_containers=$(docker ps -a --filter "name=${COMPOSE_PROJECT}" --format "{{.Names}}")

    if [[ -z "$all_containers" ]]; then
        log_warning "No sessions found"
        return 0
    fi

    # Extract unique session names
    local sessions=$(echo "$all_containers" | sed "s/${COMPOSE_PROJECT}-//" | sed 's/-gateway$//' | sed 's/-telegram-bot$//' | sed 's/-runner$//' | sort -u)

    # Display each session
    echo "$sessions" | while read -r session_name; do
        if [[ -n "$session_name" ]]; then
            show_session_status "$session_name"
            echo ""
        fi
    done

    # Show summary
    local session_count=$(echo "$sessions" | wc -l)
    local container_count=$(echo "$all_containers" | wc -l)
    log_info "Total: $session_count session(s), $container_count container(s)"
}

show_session_status() {
    local session_name="$1"
    local containers=$(get_session_containers "$session_name")

    if [[ -z "$containers" ]]; then
        log_warning "Session '$session_name': No containers"
        return 0
    fi

    # Get session info from state
    local session_info=$(get_session_info "$session_name")

    echo -e "${CYAN}▶ Session: $session_name${NC}"

    if [[ -n "$session_info" ]]; then
        local started=$(echo "$session_info" | jq -r '.started // "unknown"')
        local status=$(echo "$session_info" | jq -r '.status // "unknown"')
        echo "  Started: $started"
        echo "  Status: $status"
    fi

    echo "  Containers:"
    echo "$containers" | while read -r container; do
        local state=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")
        local ports=$(docker port "$container" 2>/dev/null | head -1)

        if [[ "$state" == "running" ]]; then
            echo -e "    ${GREEN}✓${NC} $container ($state)"
        else
            echo -e "    ${YELLOW}○${NC} $container ($state)"
        fi

        if [[ -n "$ports" ]]; then
            echo "      Ports: $ports"
        fi
    done
}

attach_session() {
    local session_name="$1"
    local service="${2:-test-runner}"

    if [[ -z "$session_name" ]]; then
        log_error "Session name is required"
        exit 1
    fi

    local container_name="${COMPOSE_PROJECT}-${session_name}-runner"

    if ! docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q .; then
        log_error "Container '$container_name' is not running"
        log_info "Available containers:"
        get_session_containers "$session_name"
        exit 1
    fi

    log_info "Attaching to session: $session_name"
    log_info "Container: $container_name"
    echo ""

    docker exec -it "$container_name" bash
}

exec_session() {
    local session_name="$1"
    local command="$2"

    if [[ -z "$session_name" ]] || [[ -z "$command" ]]; then
        log_error "Session name and command are required"
        exit 1
    fi

    local container_name="${COMPOSE_PROJECT}-${session_name}-runner"

    if ! docker ps --filter "name=$container_name" --format "{{.Names}}" | grep -q .; then
        log_error "Container '$container_name' is not running"
        exit 1
    fi

    log_info "Executing in session: $session_name"
    log_info "Command: $command"
    echo ""

    docker exec -it "$container_name" bash -c "$command"
}

auto_cleanup() {
    log_info "Running auto-cleanup for old sessions..."

    local now=$(date +%s)
    local max_age_seconds=$((SESSION_MAX_AGE_HOURS * 3600))
    local cleaned=0

    init_state

    # Get all sessions
    local all_containers=$(docker ps -a --filter "name=${COMPOSE_PROJECT}" --format "{{.Names}}")

    if [[ -z "$all_containers" ]]; then
        log_info "No sessions to clean"
        return 0
    fi

    # Extract unique session names
    local sessions=$(echo "$all_containers" | sed "s/${COMPOSE_PROJECT}-//" | sed 's/-gateway$//' | sed 's/-telegram-bot$//' | sed 's/-runner$//' | sort -u)

    # Check each session
    echo "$sessions" | while read -r session_name; do
        if [[ -z "$session_name" ]]; then
            continue
        fi

        # Get session info
        local session_info=$(get_session_info "$session_name")

        if [[ -n "$session_info" ]]; then
            local started_str=$(echo "$session_info" | jq -r '.started // ""')
            if [[ -n "$started_str" ]]; then
                local started=$(date -d "$started_str" +%s 2>/dev/null || echo 0)
                local age=$((now - started))

                if [[ $age -gt $max_age_seconds ]]; then
                    log_warning "Session '$session_name' is older than ${SESSION_MAX_AGE_HOURS}h"
                    log_info "Stopping session..."
                    stop_session "$session_name"
                    ((cleaned++))
                fi
            fi
        fi
    done

    # Clean up dangling containers
    local dangling=$(docker ps -a --filter "name=${COMPOSE_PROJECT}" --filter "status=exited" --format "{{.Names}}")
    if [[ -n "$dangling" ]]; then
        log_info "Removing dangling containers..."
        echo "$dangling" | xargs -r docker rm -f
    fi

    log_success "Auto-cleanup complete"
}

show_status() {
    log_info "Container status:"
    echo ""

    docker ps --filter "name=${COMPOSE_PROJECT}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"
    echo ""

    # Show health
    for container in $(docker ps --filter "name=${COMPOSE_PROJECT}" --format "{{.Names}}"); do
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
        if [[ "$health" == "healthy" ]]; then
            echo -e "  $container: ${GREEN}$health${NC}"
        elif [[ "$health" == "unhealthy" ]]; then
            echo -e "  $container: ${RED}$health${NC}"
        else
            echo -e "  $container: $health"
        fi
    done
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
        start-session)
            start_session "$@"
            ;;
        stop-session)
            stop_session "$@"
            ;;
        restart-session)
            restart_session "$@"
            ;;
        list-sessions)
            list_sessions
            ;;
        attach-session)
            attach_session "$@"
            ;;
        exec-session)
            exec_session "$@"
            ;;
        auto-cleanup)
            auto_cleanup
            ;;
        status)
            show_status
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
