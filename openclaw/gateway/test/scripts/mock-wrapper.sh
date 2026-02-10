#!/bin/bash
# Mock CLI wrapper for testing

# Read JSON from stdin
INPUT=$(cat)

# Echo back mock response
echo '{
  "version": "1.0",
  "id": "test-id",
  "status": "success",
  "result": {
    "mock": true
  },
  "message": "Mock response",
  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
}'
