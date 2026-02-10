#!/bin/bash
set -e

echo "🚀 Starting OpenClaw Gateway..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Validate required variables
: "${GATEWAY_PORT:?GATEWAY_PORT not set}"
: "${OLLAMA_BASE_URL:?OLLAMA_BASE_URL not set}"
: "${OLLAMA_MODEL:?OLLAMA_MODEL not set}"

echo "📡 Gateway will listen on port ${GATEWAY_PORT}"
echo "🤖 Using Ollama at ${OLLAMA_BASE_URL}"
echo "🧠 Model: ${OLLAMA_MODEL}"

# Wait for Ollama to be ready
echo "⏳ Waiting for Ollama..."
until curl -s "${OLLAMA_BASE_URL}/api/tags" > /dev/null 2>&1; do
    echo "   Ollama not ready yet, waiting..."
    sleep 2
done
echo "✅ Ollama is ready!"

# Start the gateway
echo "🎯 Starting Gateway server..."
node dist/gateway.js
