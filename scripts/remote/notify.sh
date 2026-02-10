#!/bin/bash
#
# notify.sh - Send notifications via Telegram
#
# Usage:
#   ./notify.sh <status> <message>
#
# Status: success, error, warning, info
#
# Examples:
#   ./notify.sh success "Deployment completed"
#   ./notify.sh error "Health check failed"

set -euo pipefail

# Configuration
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

STATUS="${1:-info}"
MESSAGE="${2:-}"

# Colors for terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get emoji based on status
get_emoji() {
    case "$1" in
        success) echo "✅" ;;
        error) echo "❌" ;;
        warning) echo "⚠️" ;;
        info) echo "ℹ️" ;;
        *) echo "📢" ;;
    esac
}

# Get color based on status
get_color() {
    case "$1" in
        success) echo "$GREEN" ;;
        error) echo "$RED" ;;
        warning) echo "$YELLOW" ;;
        info) echo "$BLUE" ;;
        *) echo "$NC" ;;
    esac
}

if [[ -z "$TELEGRAM_BOT_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT_ID" ]]; then
    echo -e "$(get_color error)Error: TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID must be set${NC}"
    exit 1
fi

if [[ -z "$MESSAGE" ]]; then
    echo "Usage: $0 <status> <message>"
    exit 1
fi

EMOJI=$(get_emoji "$STATUS")
COLOR=$(get_color "$STATUS")

# Build message
FULL_MESSAGE="${EMOJI} *OpenClaw ${STATUS^}*%0A%0A${MESSAGE}"

# Add timestamp if not present
if [[ ! "$MESSAGE" =~ "Time:" ]]; then
    FULL_MESSAGE="${FULL_MESSAGE}%0A%0ATime: $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Add server info
if [[ -n "${REMOTE_HOST:-}" ]]; then
    FULL_MESSAGE="${FULL_MESSAGE}%0AServer: ${REMOTE_HOST}"
fi

# Send notification
RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="$TELEGRAM_CHAT_ID" \
    -d text="$FULL_MESSAGE" \
    -d parse_mode="Markdown")

# Check for errors
if echo "$RESPONSE" | grep -q '"ok":false'; then
    echo -e "${RED}Failed to send notification${NC}"
    echo "$RESPONSE" | jq -r '.description'
    exit 1
fi

echo -e "${COLOR}${EMOJI} Notification sent: ${MESSAGE}${NC}"

# Also log to file if LOG_FILE is set
if [[ -n "${LOG_FILE:-}" ]]; then
    {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$STATUS] $MESSAGE"
    } >> "$LOG_FILE"
fi
