#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# validate-md.sh — Claude Code PostToolUse hook for .md file validation
# Triggered after Edit/Write operations on markdown files
# ═══════════════════════════════════════════════════════════════════════════════

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only validate P0 files with blocking check (loaded every session)
# P1 files are loaded on-demand, so warn-only
if [[ "$FILE_PATH" == *.md ]]; then
    case "$FILE_PATH" in
        */CLAUDE.md|*/SESSION.md|*/instructions/session-init.md)
            # P0 files — blocking validation
            "$CLAUDE_PROJECT_DIR"/scripts/validate-token-budget.sh --quick 2>&1
            exit $?
            ;;
        */instructions/*.md)
            # P1 files — warn only, don't block
            "$CLAUDE_PROJECT_DIR"/scripts/validate-token-budget.sh --quick 2>&1 | head -1 || true
            exit 0
            ;;
    esac
fi

# Allow all other edits
exit 0
