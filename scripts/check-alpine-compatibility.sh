#!/bin/bash
#
# check-alpine-compatibility.sh
#
# Checks TypeScript files for Alpine Linux TypeScript compatibility issues.
# Alpine TypeScript doesn't support emoji in source files.
#
# Usage: ./scripts/check-alpine-compatibility.sh
# Exit codes: 0 = pass, 1 = fail

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

echo -e "${YELLOW}🔍 Checking Alpine Linux TypeScript compatibility...${NC}"
echo

# Check for emoji in TypeScript files
echo "Checking for emoji in TypeScript files..."

# Find all .ts files
TS_FILES=$(find . -name "*.ts" -type f 2>/dev/null | grep -v node_modules | grep -v dist || true)

if [ -z "$TS_FILES" ]; then
    echo "  No TypeScript files found."
    exit 0
fi

# Check each file for emoji
for file in $TS_FILES; do
    # Check for emoji ranges using grep with Perl regex
    if grep -P $'[\x{1F300}-\x{1F9FF}]' "$file" >/dev/null 2>&1; then
        echo -e "${RED}❌ FAIL: Emoji found in $file${NC}"
        grep -nP $'[\x{1F300}-\x{1F9FF}]' "$file" | head -5
        ISSUES_FOUND=1
    fi
done

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No emoji found in TypeScript files${NC}"
fi

echo

# Check for other Alpine TypeScript issues
echo "Checking for other Alpine compatibility issues..."

# Check for non-ASCII characters in template literals (can cause encoding issues)
NON_ASCII_ISSUES=0
for file in $TS_FILES; do
    # Look for template literals with problematic characters
    if grep -P '[^\x00-\x7F]' "$file" | grep '`' >/dev/null 2>&1; then
        # Filter out Russian/Cyrillic (which is OK)
        PROBLEMATIC=$(grep -P '[^\x00-\x7F]' "$file" | grep '`' | grep -vP '[А-Яа-яёЁ]' || true)
        if [ -n "$PROBLEMATIC" ]; then
            echo -e "${YELLOW}⚠️  WARNING: Non-ASCII characters in template literal: $file${NC}"
            echo "$PROBLEMATIC" | head -3
            NON_ASCII_ISSUES=1
        fi
    fi
done

if [ $NON_ASCII_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ No non-ASCII encoding issues found${NC}"
fi

echo

# Final result
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ Alpine compatibility check PASSED${NC}"
    exit 0
else
    echo -e "${RED}❌ Alpine compatibility check FAILED${NC}"
    echo
    echo "To fix emoji issues:"
    echo "  1. Replace emoji with ASCII alternatives:"
    echo "     📥 → [IN]"
    echo "     ✅ → [OK]"
    echo "     ❌ → [FAIL]"
    echo "     ⚠️ → [WARN]"
    echo "  2. Or use scripts/replace-emoji.sh"
    exit 1
fi
