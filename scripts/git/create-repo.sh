#!/bin/bash
#
# create-repo.sh - Create GitHub repository and initialize project
#
# Usage:
#   ./create-repo.sh <project-name> <project-path> [description]
#
# Example:
#   ./create-repo.sh my-bot /opt/openclaw/workspace/my-bot "Telegram bot for delivery"

set -euo pipefail

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
GITHUB_USERNAME="${GITHUB_USERNAME:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
PRIVATE_REPO="${PRIVATE_REPO:-true}"

# Validate arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <project-name> <project-path> [description]"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_PATH="$2"
DESCRIPTION="${3:-OpenClaw project: $PROJECT_NAME}"

# Validate GitHub credentials
if [[ -z "$GITHUB_USERNAME" ]] || [[ -z "$GITHUB_TOKEN" ]]; then
    echo "Error: GITHUB_USERNAME and GITHUB_TOKEN must be set"
    exit 1
fi

# Check if project path exists
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "Error: Project path does not exist: $PROJECT_PATH"
    exit 1
fi

echo "Creating GitHub repository: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo ""

# Initialize Git if not already initialized
cd "$PROJECT_PATH"
if [[ ! -d .git ]]; then
    echo "Initializing Git repository..."
    git init
    git config user.name "OpenClaw Bot"
    git config user.email "openclaw-bot@example.com"
    echo -e "${GREEN}✅ Git initialized${NC}"
else
    echo "Git already initialized"
fi

# Create .gitignore if not exists
if [[ ! -f .gitignore ]]; then
    echo "Creating .gitignore..."
    cat > .gitignore <<'EOF'
# Dependencies
node_modules/
__pycache__/
*.py[cod]
venv/

# IDE
.vscode/
.idea/

# Environment
.env
.env.local

# Logs
logs/
*.log

# Build
dist/
build/

# OS
.DS_Store
EOF
    echo -e "${GREEN}✅ .gitignore created${NC}"
fi

# Create initial commit if needed
if [[ -z $(git rev-parse --HEAD 2>/dev/null) ]]; then
    echo "Creating initial commit..."
    git add -A
    git commit -m "feat: Initial commit from OpenClaw

Project: $PROJECT_NAME
Description: $DESCRIPTION
Generated: $(date -Iseconds)"
    echo -e "${GREEN}✅ Initial commit created${NC}"
else
    echo "Commits already exist"
fi

# Create GitHub repository
echo "Creating GitHub repository..."
RESPONSE=$(curl -s -X POST \
    "https://api.github.com/user/repos" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "{
        \"name\": \"$PROJECT_NAME\",
        \"description\": \"$DESCRIPTION\",
        \"private\": $PRIVATE_REPO,
        \"auto_init\": false
    }")

# Check for errors
if echo "$RESPONSE" | grep -q "message"; then
    echo "Error creating repository:"
    echo "$RESPONSE" | jq -r '.message'
    exit 1
fi

# Extract repository URL
CLONE_URL=$(echo "$RESPONSE" | jq -r '.clone_url')
SSH_URL=$(echo "$RESPONSE" | jq -r '.ssh_url')
HTML_URL=$(echo "$RESPONSE" | jq -r '.html_url')

echo -e "${GREEN}✅ Repository created${NC}"
echo "  URL: $HTML_URL"

# Add remote
echo "Adding remote origin..."
if git remote get-url origin &>/dev/null; then
    git remote set-url origin "$SSH_URL"
else
    git remote add origin "$SSH_URL"
fi
echo -e "${GREEN}✅ Remote added${NC}"

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main
echo -e "${GREEN}✅ Pushed to GitHub${NC}"

echo ""
echo "Repository ready!"
echo "  Clone: git clone $SSH_URL"
echo "  Browse: $HTML_URL"
