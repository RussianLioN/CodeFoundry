#!/bin/bash
#
# OpenClaw Health Check Script
#
# Checks health of all OpenClaw services and sends alerts if needed.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
COMPOSE_DIR="/opt/openclaw/docker"
GATEWAY_URL="${GATEWAY_URL:-http://localhost:18790}"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

# Service health check functions
check_docker() {
    if ! docker ps &> /dev/null; then
        echo -e "${RED}❌ Docker not running${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ Docker running${NC}"
    return 0
}

check_gateway() {
    local response
    response=$(curl -sf -w "%{http_code}" "$GATEWAY_URL/health" -o /tmp/gateway_health 2>/dev/null) || true

    if [[ "$response" == "200" ]]; then
        echo -e "${GREEN}✅ Gateway healthy${NC}"
        cat /tmp/gateway_health
        return 0
    else
        echo -e "${RED}❌ Gateway unhealthy (HTTP $response)${NC}"
        return 1
    fi
}

check_ollama() {
    if ! docker exec openclaw-ollama ollama list &> /dev/null; then
        echo -e "${RED}❌ Ollama not responding${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ Ollama running${NC}"
    return 0
}

check_telegram_bot() {
    if ! docker ps | grep -q openclaw-telegram-bot; then
        echo -e "${RED}❌ Telegram bot not running${NC}"
        return 1
    fi

    # Check if bot process is alive
    if ! docker exec openclaw-telegram-bot pgrep -f "node.*bot.js" &> /dev/null; then
        echo -e "${YELLOW}⚠️  Bot container running but process may be dead${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ Telegram bot running${NC}"
    return 0
}

check_workspace() {
    if [[ ! -d "/opt/openclaw/workspace" ]]; then
        echo -e "${RED}❌ Workspace directory missing${NC}"
        return 1
    fi

    local project_count
    project_count=$(find /opt/openclaw/workspace -maxdepth 1 -type d ! -name workspace | wc -l)

    echo -e "${GREEN}✅ Workspace OK ($project_count projects)${NC}"
    return 0
}

check_disk_space() {
    local usage
    usage=$(df -h /opt/openclaw | awk 'NR==2 {print $5}' | sed 's/%//')

    if [[ $usage -gt 90 ]]; then
        echo -e "${RED}❌ Disk space critical: ${usage}%${NC}"
        return 1
    elif [[ $usage -gt 80 ]]; then
        echo -e "${YELLOW}⚠️  Disk space warning: ${usage}%${NC}"
        return 0
    fi

    echo -e "${GREEN}✅ Disk space OK: ${usage}%${NC}"
    return 0
}

check_memory() {
    local mem_percent
    mem_percent=$(free | awk 'NR==2{printf "%.0f", $3/$2*100}')

    if [[ $mem_percent -gt 90 ]]; then
        echo -e "${RED}❌ Memory critical: ${mem_percent}%${NC}"
        return 1
    elif [[ $mem_percent -gt 80 ]]; then
        echo -e "${YELLOW}⚠️  Memory warning: ${mem_percent}%${NC}"
        return 0
    fi

    echo -e "${GREEN}✅ Memory OK: ${mem_percent}%${NC}"
    return 0
}

# Send Telegram alert
send_alert() {
    local message="$1"

    if [[ -z "$TELEGRAM_BOT_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT_ID" ]]; then
        return
    fi

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="🚨 *OpenClaw Alert*%0A%0A${message}" \
        -d parse_mode="Markdown" &> /dev/null || true
}

# Main health check
main() {
    local all_ok=true

    echo "OpenClaw Health Check"
    echo "====================="
    echo ""

    check_docker || all_ok=false
    check_gateway || all_ok=false
    check_ollama || all_ok=false
    check_telegram_bot || all_ok=false
    check_workspace || all_ok=false
    check_disk_space || all_ok=false
    check_memory || all_ok=false

    echo ""
    echo "====================="

    if $all_ok; then
        echo -e "${GREEN}All systems operational${NC}"
        exit 0
    else
        echo -e "${RED}Some systems need attention${NC}"

        # Send alert if configured
        send_alert "OpenClaw health check failed on $(hostname). Please check server status."

        exit 1
    fi
}

# Run checks
main
