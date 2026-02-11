#!/usr/bin/env bash
# OpenClaw CLI Bridge for Claude Code
# Command Protocol v1.0 Implementation
#
# This script receives JSON commands from OpenClaw Gateway
# and executes them via Claude Code CLI
#
# Usage: echo '{"command":"status"}' | ./claude-wrapper.sh

set -euo pipefail

# ================================================================
# CONFIGURATION
# ================================================================

readonly SCRIPT_VERSION="1.0.0"
readonly CLAUDE_CODE_CONTAINER="${CLAUDE_CODE_CONTAINER:-claude-code-runner}"
readonly WORKSPACE_DIR="${WORKSPACE_DIR:-/workspace}"
readonly LOG_FILE="${LOG_FILE:-/tmp/claude-wrapper-$(date +%Y-%m-%d).log}"

# ================================================================
# LOGGING
# ================================================================

log() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE" >&2
}

log_debug() { log "DEBUG" "$@"; }
log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

# ================================================================
# JSON RESPONSE BUILDERS
# ================================================================

# Generate success response
success_response() {
    local id="$1"
    local result="$2"
    local message="$3"

    cat <<EOF
{
  "version": "1.0",
  "id": "$id",
  "status": "success",
  "result": $result,
  "message": "$message",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# Generate error response
error_response() {
    local id="$1"
    local code="$2"
    local message="$3"

    cat <<EOF
{
  "version": "1.0",
  "id": "$id",
  "status": "error",
  "error": {
    "code": "$code",
    "message": "$message"
  },
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# ================================================================
# COMMAND VALIDATION
# ================================================================

validate_command() {
    local command_json="$1"

    # Check if valid JSON
    if ! echo "$command_json" | jq empty 2>/dev/null; then
        log_error "Invalid JSON received"
        return 1
    fi

    # Check version
    local version
    version=$(echo "$command_json" | jq -r '.version // "1.0"')
    if [[ "$version" != "1.0" ]]; then
        log_error "Unsupported protocol version: $version"
        return 1
    fi

    # Check command field
    local command
    command=$(echo "$command_json" | jq -r '.command // empty')
    if [[ -z "$command" ]]; then
        log_error "Missing 'command' field"
        return 1
    fi

    return 0
}

# ================================================================
# COMMAND EXECUTORS
# ================================================================

# Command: create_project
exec_create_project() {
    local id="$1"
    local params="$2"

    local name
    local archetype
    local framework

    name=$(echo "$params" | jq -r '.name // empty')
    archetype=$(echo "$params" | jq -r '.archetype // "web-service"')
    framework=$(echo "$params" | jq -r '.framework // "nextjs"')

    # Validation
    if [[ -z "$name" ]]; then
        error_response "$id" "INVALID_PARAMS" "Project name is required"
        return 1
    fi

    # Validate project name
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        error_response "$id" "INVALID_PARAMS" "Invalid project name. Use only lowercase letters, numbers, and hyphens"
        return 1
    fi

    # Path traversal protection
    if [[ "$name" == *".."* ]]; then
        error_response "$id" "INVALID_PARAMS" "Path traversal detected"
        return 1
    fi

    log_info "Creating project: $name (archetype: $archetype, framework: $framework)"

    # Check if Claude Code container is running
    if ! docker exec "$CLAUDE_CODE_CONTAINER" pwd &>/dev/null; then
        error_response "$id" "CLAUDE_CODE_ERROR" "Claude Code container is not running"
        return 1
    fi

    # Execute Claude Code command
    local output
    local exit_code

    output=$(docker exec "$CLAUDE_CODE_CONTAINER" \
        claude code new "$name" \
        --archetype "$archetype" \
        --framework "$framework" \
        --output json 2>&1) || exit_code=$?

    if [[ ${exit_code:-0} -ne 0 ]]; then
        log_error "Claude Code failed: $output"
        error_response "$id" "CLAUDE_CODE_ERROR" "Failed to create project: $output"
        return 1
    fi

    # Parse output and build response
    local project_path="$WORKSPACE_DIR/$name"

    success_response "$id" \
        "{\"project_name\": \"$name\", \"project_path\": \"$project_path\", \"archetype\": \"$archetype\", \"framework\": \"$framework\"}" \
        "✅ Проект $name создан!\n📁 Path: $project_path\n📦 Archetype: $archetype"
}

# Command: status
exec_status() {
    local id="$1"

    log_info "Getting system status"

    # Check container status
    local gateway_status
    local claude_status
    local projects_json

    if docker ps | grep -q "codefoundry-test-gateway"; then
        gateway_status="healthy"
    else
        gateway_status="down"
    fi

    if docker exec "$CLAUDE_CODE_CONTAINER" pwd &>/dev/null; then
        claude_status="ready"
    else
        claude_status="unavailable"
    fi

    # Get projects list
    local projects_json='[]'

    # Only try to get projects if container exists
    if docker exec "$CLAUDE_CODE_CONTAINER" pwd &>/dev/null; then
        projects_json=$(docker exec "$CLAUDE_CODE_CONTAINER" \
            find "$WORKSPACE_DIR" -maxdepth 1 -type d ! -path "$WORKSPACE_DIR" \
            -exec basename {} \; 2>/dev/null | jq -R . | jq -s 'map({name: ., status: "active"})' 2>/dev/null) || projects_json='[]'
    fi

    # System metrics
    local uptime
    local mem_usage
    local disk_usage

    uptime=$(uptime -p 2>/dev/null || echo "unknown")
    mem_usage=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}' || echo "unknown")
    disk_usage=$(df -h "$WORKSPACE_DIR" 2>/dev/null | awk 'NR==2 {print $5}' || echo "unknown")

    success_response "$id" \
        "{\"gateway\": \"$gateway_status\", \"claude_code\": \"$claude_status\", \"projects\": $projects_json, \"system\": {\"uptime\": \"$uptime\", \"memory_usage\": \"$mem_usage\", \"disk_usage\": \"$disk_usage\"}}" \
        "📊 Статус системы:\n✅ Gateway: $gateway_status\n✅ Claude Code: $claude_status\n💾 Memory: $mem_usage\n💿 Disk: $disk_usage"
}

# Command: help
exec_help() {
    local id="$1"

    log_info "Showing help"

    success_response "$id" \
        '{"commands": [{"name": "/new", "description": "Создать новый проект", "usage": "/new <project-name> [archetype]", "example": "/new my-app web-service"}, {"name": "/status", "description": "Статус системы", "usage": "/status", "example": "/status"}, {"name": "/deploy", "description": "Задеплоить проект", "usage": "/deploy <project-name>", "example": "/deploy my-app"}, {"name": "/help", "description": "Показать справку", "usage": "/help", "example": "/help"}]}' \
        "📖 Доступные команды:\n\n/new <name> — Создать проект\n/status — Статус системы\n/deploy <name> — Деплой проекта\n/help — Справка"
}

# Command: deploy
exec_deploy() {
    local id="$1"
    local params="$2"

    local project_name
    project_name=$(echo "$params" | jq -r '.project_name // .name // empty')

    # Validation
    if [[ -z "$project_name" ]]; then
        error_response "$id" "INVALID_PARAMS" "Project name is required for deploy"
        return 1
    fi

    local project_path="$WORKSPACE_DIR/$project_name"

    # Check if project exists
    if [[ ! -d "$project_path" ]]; then
        error_response "$id" "PROJECT_NOT_FOUND" "Project not found: $project_name"
        return 1
    fi

    log_info "Deploying project: $project_name"

    # Check if Docker is available
    if ! command -v docker &>/dev/null; then
        error_response "$id" "DOCKER_ERROR" "Docker is not available"
        return 1
    fi

    # Build and start containers
    local output
    local exit_code

    output=$(cd "$project_path" && docker-compose up -d --build 2>&1) || exit_code=$?

    if [[ ${exit_code:-0} -ne 0 ]]; then
        log_error "Deploy failed: $output"
        error_response "$id" "DEPLOY_ERROR" "Failed to deploy: $(echo "$output" | head -1)"
        return 1
    fi

    success_response "$id" \
        "{\"project_name\": \"$project_name\", \"project_path\": \"$project_path\", \"deployed_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" \
        "🚀 Проект $project_name задеплоен!\n📁 Path: $project_path"
}

# ================================================================
# MAIN HANDLER
# ================================================================

main() {
    local command_json
    local command_id
    local command_name
    local command_params

    # Read JSON from stdin
    command_json=$(cat)

    log_debug "Received command: $command_json"

    # Validate JSON structure
    if ! validate_command "$command_json"; then
        echo '{"version": "1.0", "status": "error", "error": {"code": "INVALID_JSON", "message": "Invalid JSON or protocol version"}}'
        exit 1
    fi

    # Parse command fields
    command_id=$(echo "$command_json" | jq -r '.id // "unknown"')
    command_name=$(echo "$command_json" | jq -r '.command')
    command_params=$(echo "$command_json" | jq -c '.params // {}')

    # Log intent confidence if provided (v2.0.1 - Intent Classifier integration)
    local intent_confidence
    intent_confidence=$(echo "$command_json" | jq -r '.intent_confidence // empty')
    if [[ -n "$intent_confidence" ]]; then
        log_info "Intent confidence: $intent_confidence"
    fi

    log_info "Executing command: $command_name (id: $command_id)"

    # Route to appropriate executor
    case "$command_name" in
        create_project)
            exec_create_project "$command_id" "$command_params"
            ;;
        status)
            exec_status "$command_id"
            ;;
        deploy)
            exec_deploy "$command_id" "$command_params"
            ;;
        help)
            exec_help "$command_id"
            ;;
        *)
            log_warn "Unknown command: $command_name"
            error_response "$command_id" "UNKNOWN_COMMAND" "Unknown command: $command_name"
            exit 1
            ;;
    esac
}

# ================================================================
# ENTRY POINT
# ================================================================

# Check if jq is available
if ! command -v jq &>/dev/null; then
    echo '{"version": "1.0", "status": "error", "error": {"code": "MISSING_DEPENDENCY", "message": "jq is required but not installed"}}' >&2
    exit 1
fi

# Run main handler
main "$@"
