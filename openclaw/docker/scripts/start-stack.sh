#!/bin/bash
# OpenClaw Docker Stack Quick Start
#
# This script starts OpenClaw with Ollama + gemini-3-flash
#
# Usage:
#   ./start-stack.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=========================================="
echo "  OpenClaw Stack - Quick Start"
echo "=========================================="
echo ""
log_info "Directory: $DOCKER_DIR"
echo ""

# Check Docker
log_step "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    log_warn "Docker not found. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log_warn "Docker Compose not found. Please install Docker Compose first."
    exit 1
fi

log_info "Docker is installed ✓"
echo ""

# Check .env file
log_step "Checking environment configuration..."
if [ ! -f "$DOCKER_DIR/.env" ]; then
    log_warn ".env file not found. Creating from template..."

    cat > "$DOCKER_DIR/.env" << 'EOF'
# OpenClaw Environment Configuration

# Workspace directory (absolute path)
WORKSPACE_DIR=./workspace

# Telegram Bot (optional)
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_WEBHOOK_SECRET=your_secret_here

# Tailscale (optional - for remote access)
TS_AUTHKEY=your_tailscale_authkey_here

# Ollama configuration
OLLAMA_BASE_URL=http://ollama-service:11434
OLLAMA_MODEL=gemini-3-flash

# Gateway configuration
GATEWAY_PORT=18789
NODE_ENV=production
EOF

    log_info "Created .env file ✓"
    log_warn "Please edit .env and set your configuration"
    log_info "Press Enter to continue or Ctrl+C to abort..."
    read
fi

log_info "Environment configured ✓"
echo ""

# Create workspace directory
log_step "Creating workspace directory..."
mkdir -p "$DOCKER_DIR/workspace"
log_info "Workspace ready ✓"
echo ""

# Start services
log_step "Starting OpenClaw stack..."

cd "$DOCKER_DIR"

# Use docker-compose or docker compose
if docker-compose version &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

log_info "Services started ✓"
echo ""

# Wait for Ollama to be ready
log_step "Waiting for Ollama service..."
echo "This may take 30-60 seconds on first run..."

max_wait=60
waited=0
while [ $waited -lt $max_wait ]; do
    if docker exec openclaw-ollama ollama list &> /dev/null 2>&1; then
        log_info "Ollama is ready ✓"
        break
    fi
    echo -n "."
    sleep 2
    waited=$((waited + 2))
done
echo ""

if [ $waited -ge $max_wait ]; then
    log_warn "Ollama took longer than expected to start"
    log_info "Check logs with: docker logs openclaw-ollama"
fi

# Initialize Ollama
log_step "Initializing Ollama with gemini-3-flash..."

if [ -f "$SCRIPT_DIR/init-ollama.sh" ]; then
    # Copy init script to container
    docker cp "$SCRIPT_DIR/init-ollama.sh" openclaw-ollama:/models/init-ollama.sh

    # Make it executable and run
    docker exec openclaw-ollama chmod +x /models/init-ollama.sh
    docker exec openclaw-ollama /models/init-ollama.sh
else
    log_warn "Init script not found, pulling model manually..."
    docker exec openclaw-ollama ollama pull gemini-3-flash
fi

log_info "Ollama initialized ✓"
echo ""

# Check services status
log_step "Service status:"
echo ""

if docker-compose version &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

echo ""

# Show connection info
log_info "=========================================="
log_info "OpenClaw Stack is Running!"
log_info "=========================================="
echo ""
echo "🔗 Connection Information:"
echo ""
echo "  • Gateway WebSocket:"
echo "    ws://localhost:18789"
echo ""
echo "  • Health Check:"
echo "    http://localhost:18790/health"
echo ""
echo "  • Ollama API:"
echo "    http://localhost:11434"
echo ""
echo "📝 Useful Commands:"
echo ""
echo "  # View logs"
echo "  docker-compose logs -f openclaw-gateway"
echo ""
echo "  # Execute bash in gateway"
echo "  docker exec -it openclaw-gateway bash"
echo ""
echo "  # Test Ollama"
echo "  docker exec openclaw-ollama ollama run gemini-3-flash 'Hello'"
echo ""
echo "  # Restart services"
echo "  docker-compose restart"
echo ""
echo "  # Stop everything"
echo "  docker-compose down"
echo ""
echo "📚 Documentation:"
echo "  • OpenClaw: $DOCKER_DIR/../README.md"
echo "  • Docker: $DOCKER_DIR/README.md"
echo ""
