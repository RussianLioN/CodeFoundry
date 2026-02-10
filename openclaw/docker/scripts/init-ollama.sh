#!/bin/bash
# OpenClaw Ollama Initialization Script
#
# This script sets up Ollama with gemini-3-flash model
#
# Usage:
#   ./init-ollama.sh
#
# Or via docker-compose:
#   docker-compose exec ollama-service /models/init-ollama.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Ollama is running
check_ollama() {
    log_info "Checking Ollama service..."

    if ! curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
        log_error "Ollama is not responding on http://localhost:11434"
        log_info "Make sure ollama-service container is running"
        exit 1
    fi

    log_info "Ollama is running ✓"
}

# Wait for Ollama to be ready
wait_for_ollama() {
    log_info "Waiting for Ollama to be ready..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
            log_info "Ollama is ready!"
            return 0
        fi

        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done

    log_error "Ollama failed to start within expected time"
    exit 1
}

# Pull gemini-3-flash model
pull_model() {
    log_info "Pulling gemini-3-flash model..."
    log_warn "This may take a while depending on your connection speed..."

    # Pull the model
    ollama pull gemini-3-flash

    if [ $? -eq 0 ]; then
        log_info "Model pulled successfully ✓"
    else
        log_error "Failed to pull gemini-3-flash model"
        log_info "Make sure you have access to the model"
        exit 1
    fi
}

# Create custom model with Modelfile
create_custom_model() {
    log_info "Creating custom OpenClaw model..."

    if [ ! -f /models/modelfile ]; then
        log_warn "Modelfile not found at /models/modelfile"
        log_info "Using default gemini-3-flash model"
        return 0
    fi

    # Create custom model
    ollama create openclaw-gemini -f /models/modelfile

    if [ $? -eq 0 ]; then
        log_info "Custom model 'openclaw-gemini' created ✓"
    else
        log_warn "Failed to create custom model, using default"
    fi
}

# Verify model installation
verify_model() {
    log_info "Verifying model installation..."

    # List models
    local models=$(ollama list | grep -c "gemini" || true)

    if [ "$models" -gt 0 ]; then
        log_info "Found $models gemini model(s):"
        ollama list | grep "gemini"
    else
        log_error "No gemini models found"
        exit 1
    fi
}

# Test model inference
test_model() {
    log_info "Testing model inference..."

    local response=$(ollama run gemini-3-flash "Say 'OK'" 2>/dev/null)

    if echo "$response" | grep -qi "ok"; then
        log_info "Model inference test passed ✓"
    else
        log_warn "Model inference test returned unexpected response"
        log_info "Response: $response"
    fi
}

# Print model info
print_info() {
    log_info "Model Information:"
    echo ""
    ollama show gemini-3-flash
    echo ""

    log_info "Ollama Service Information:"
    echo "  API URL: http://localhost:11434"
    echo "  Model: gemini-3-flash"
    echo "  Context: 131K tokens"
    echo ""
}

# Main execution
main() {
    echo ""
    echo "=========================================="
    echo "  OpenClaw Ollama Initialization"
    echo "=========================================="
    echo ""

    wait_for_ollama
    echo ""

    pull_model
    echo ""

    create_custom_model
    echo ""

    verify_model
    echo ""

    test_model
    echo ""

    print_info

    log_info "Initialization complete! ✓"
    echo ""
    log_info "You can now use gemini-3-flash with OpenClaw"
    echo ""
}

# Run main function
main "$@"
