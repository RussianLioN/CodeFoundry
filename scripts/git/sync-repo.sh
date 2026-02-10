#!/bin/bash
#
# sync-repo.sh - Sync local repository with remote
#
# Usage:
#   ./sync-repo.sh <project-path>
#
# This script:
# 1. Fetches remote changes
# 2. Stashes local changes
# 3. Pulls remote changes
# 4. Tries to apply stashed changes
# 5. Pushes local commits

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <project-path>"
    exit 1
fi

PROJECT_PATH="$1"

if [[ ! -d "$PROJECT_PATH" ]]; then
    echo -e "${RED}Error: Project path does not exist: $PROJECT_PATH${NC}"
    exit 1
fi

cd "$PROJECT_PATH"

# Check if git repository
if [[ ! -d .git ]]; then
    echo -e "${RED}Error: Not a Git repository${NC}"
    exit 1
fi

echo "Syncing repository..."
echo "Path: $PROJECT_PATH"
echo ""

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Branch: $BRANCH"

# Check if remote exists
if ! git remote get-url origin &>/dev/null; then
    echo -e "${YELLOW}No remote origin configured${NC}"
    exit 0
fi

# Fetch remote
echo ""
echo "Fetching remote..."
git fetch origin || {
    echo -e "${RED}Failed to fetch from remote${NC}"
    exit 1
}

# Check if we have local changes
LOCAL_CHANGES=$(git status --porcelain | wc -l)
BEHIND=$(git rev-list --left-right --count origin/"$BRANCH"...HEAD 2>/dev/null | cut -f1)
AHEAD=$(git rev-list --left-right --count origin/"$BRANCH"...HEAD 2>/dev/null | cut -f2)

echo -e "${GREEN}✅ Fetched${NC}"

# Show status
echo ""
echo "Status:"
echo "  Local changes: $LOCAL_CHANGES files"
echo "  Behind: ${BEHIND:-0} commits"
echo "  Ahead: ${AHEAD:-0} commits"

# If we're behind, pull
if [[ -n "$BEHIND" ]] && [[ "$BEHIND" -gt 0 ]]; then
    echo ""
    echo "Pulling changes from remote..."

    # Stash local changes if any
    STASHED=false
    if [[ $LOCAL_CHANGES -gt 0 ]]; then
        echo "Stashing local changes..."
        git stash save "Auto-stash before sync $(date)"
        STASHED=true
    fi

    # Pull
    git pull origin "$BRANCH" || {
        echo -e "${RED}Failed to pull. Conflicts may exist.${NC}"
        echo "Please resolve conflicts manually."
        exit 1
    }

    echo -e "${GREEN}✅ Pulled${NC}"

    # Try to reapply stashed changes
    if [[ "$STASHED" == "true" ]]; then
        echo "Applying stashed changes..."
        if git stash pop; then
            echo -e "${GREEN}✅ Stash applied${NC}"
        else
            echo -e "${YELLOW}Could not apply stash. Conflicts detected.${NC}"
            echo "Stash saved. Run 'git stash pop' after resolving conflicts."
        fi
    fi
fi

# If we're ahead, push
if [[ -n "$AHEAD" ]] && [[ "$AHEAD" -gt 0 ]]; then
    echo ""
    echo "Pushing local commits..."
    git push origin "$BRANCH" || {
        echo -e "${RED}Failed to push${NC}"
        exit 1
    }
    echo -e "${GREEN}✅ Pushed${NC}"
fi

echo ""
echo -e "${GREEN}✅ Sync complete${NC}"

# Show final status
git status -s
