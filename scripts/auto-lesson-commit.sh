#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# auto-lesson-commit.sh — GitOps auto-commit for LESSONS.md
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if LESSONS.md has changes
if git diff --quiet LESSONS.md 2>/dev/null; then
    if [ -f "LESSONS.md" ]; then
        echo -e "${BLUE}ℹ️  No changes to LESSONS.md${NC}"
    fi
    exit 0
fi

# Check if there are new lessons
if grep -q "^## " LESSONS.md 2>/dev/null; then
    # Extract lesson count
    LESSON_COUNT=$(grep -c "^## " LESSONS.md || echo "0")

    echo -e "${BLUE}📚 LESSONS.md has changes (${LESSON_COUNT} lessons)${NC}"

    # Stage LESSONS.md
    git add LESSONS.md

    # Create commit
    COMMIT_MSG="docs: auto-extract lessons from .tracking/error_log.json

Lessons: ${LESSON_COUNT}
Trigger: Automatic extraction on threshold reached
Source: scripts/lesson-learned-tracker.py"

    git commit -m "$COMMIT_MSG"

    echo -e "${GREEN}✓ LESSONS.md auto-committed${NC}"

    # Ask if user wants to push
    echo -e "${BLUE}Push to remote? (y/N)${NC}"
    read -r -n 1 response
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git push origin main
        echo -e "${GREEN}✓ Pushed to origin/main${NC}"
    fi
else
    echo -e "${BLUE}ℹ️  No lessons found in LESSONS.md${NC}"
fi
