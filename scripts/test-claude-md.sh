#!/usr/bin/env bash
# test-claude-md.sh — Validation tests for CLAUDE.md refactoring
#
# Purpose: Ensure critical rules are preserved after P0-001 refactoring
# Created: 2025-02-06
# Task: P0-001 (Упрощение CLAUDE.md)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# File path
CLAUDE_MD="${1:-CLAUDE.md}"

echo "========================================"
echo "  CLAUDE.md Validation Tests"
echo "========================================"
echo ""
echo "File: $CLAUDE_MD"
echo ""

# Check file exists
if [ ! -f "$CLAUDE_MD" ]; then
    echo -e "${RED}ERROR: File not found: $CLAUDE_MD${NC}"
    exit 1
fi

# Test 1: File size (lines)
echo "----------------------------------------"
echo "Test 1: File size (lines)"
LINE_COUNT=$(wc -l < "$CLAUDE_MD" | tr -d ' ')
if [ "$LINE_COUNT" -lt 300 ]; then
    echo -e "${GREEN}PASS: $LINE_COUNT lines (target: <300)${NC}"
    ((PASSED++))
elif [ "$LINE_COUNT" -lt 400 ]; then
    echo -e "${YELLOW}WARN: $LINE_COUNT lines (target: <300, acceptable: <400)${NC}"
    ((WARNINGS++))
else
    echo -e "${RED}FAIL: $LINE_COUNT lines (target: <300)${NC}"
    ((FAILED++))
fi

# Test 2: Token estimate (words / 0.75)
echo "----------------------------------------"
echo "Test 2: Token estimate"
WORD_COUNT=$(wc -w < "$CLAUDE_MD" | tr -d ' ')
TOKEN_ESTIMATE=$((WORD_COUNT * 100 / 75))
if [ "$TOKEN_ESTIMATE" -lt 2000 ]; then
    echo -e "${GREEN}PASS: ~$TOKEN_ESTIMATE tokens (target: <2000)${NC}"
    ((PASSED++))
elif [ "$TOKEN_ESTIMATE" -lt 3000 ]; then
    echo -e "${YELLOW}WARN: ~$TOKEN_ESTIMATE tokens (target: <2000, acceptable: <3000)${NC}"
    ((WARNINGS++))
else
    echo -e "${RED}FAIL: ~$TOKEN_ESTIMATE tokens (target: <2000)${NC}"
    ((FAILED++))
fi

# Test 3: MANDATORY count
echo "----------------------------------------"
echo "Test 3: MANDATORY keyword count"
MANDATORY_COUNT=$(grep -ci 'MANDATORY' "$CLAUDE_MD" || echo 0)
if [ "$MANDATORY_COUNT" -le 5 ]; then
    echo -e "${GREEN}PASS: $MANDATORY_COUNT occurrences (target: <=5)${NC}"
    ((PASSED++))
elif [ "$MANDATORY_COUNT" -le 10 ]; then
    echo -e "${YELLOW}WARN: $MANDATORY_COUNT occurrences (target: <=5, acceptable: <=10)${NC}"
    ((WARNINGS++))
else
    echo -e "${RED}FAIL: $MANDATORY_COUNT occurrences (target: <=5)${NC}"
    ((FAILED++))
fi

# Test 4: Critical Docker rule present
echo "----------------------------------------"
echo "Test 4: Critical Docker rule"
if grep -qi 'NEVER.*Docker.*local\|Docker.*local.*NEVER\|local.*Docker.*NEVER' "$CLAUDE_MD" || \
   grep -qi 'Docker.*not.*local\|no.*Docker.*local' "$CLAUDE_MD" || \
   grep -qi '@ref.*constraints.*docker\|@ref.*docker.*constraints' "$CLAUDE_MD"; then
    echo -e "${GREEN}PASS: Docker rule present (direct or via @ref)${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL: Docker rule MISSING! Critical constraint lost.${NC}"
    ((FAILED++))
fi

# Test 5: Critical Git workflow rule present
echo "----------------------------------------"
echo "Test 5: Critical Git workflow rule"
if grep -qi 'Git.*workflow\|GitOps\|git push.*deploy\|deploy.*git' "$CLAUDE_MD" || \
   grep -qi '@ref.*constraints\|@ref.*git' "$CLAUDE_MD"; then
    echo -e "${GREEN}PASS: Git workflow rule present${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL: Git workflow rule MISSING!${NC}"
    ((FAILED++))
fi

# Test 6: Session initialization reference
echo "----------------------------------------"
echo "Test 6: Session initialization"
if grep -qi 'session.*init\|SESSION\.md\|session-init' "$CLAUDE_MD"; then
    echo -e "${GREEN}PASS: Session initialization reference present${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL: Session initialization reference MISSING!${NC}"
    ((FAILED++))
fi

# Test 7: Context7 reference
echo "----------------------------------------"
echo "Test 7: Context7 MCP reference"
if grep -qi 'context7\|Context7' "$CLAUDE_MD"; then
    echo -e "${GREEN}PASS: Context7 reference present${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}WARN: Context7 reference not found${NC}"
    ((WARNINGS++))
fi

# Test 8: @ref links validation
echo "----------------------------------------"
echo "Test 8: @ref links validation"
BROKEN_REFS=0
# Extract @ref links and check if files exist
while IFS= read -r ref; do
    # Clean up the reference path
    ref_clean=$(echo "$ref" | sed 's/[)(]//g' | sed 's/\].*//g' | tr -d '[:space:]')
    if [ -n "$ref_clean" ] && [ ! -f "$ref_clean" ]; then
        echo -e "  ${RED}BROKEN: $ref_clean${NC}"
        ((BROKEN_REFS++))
    fi
done < <(grep -oP '@ref:\s*\K[^\s\]]+' "$CLAUDE_MD" 2>/dev/null || true)

if [ "$BROKEN_REFS" -eq 0 ]; then
    echo -e "${GREEN}PASS: All @ref links valid${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL: $BROKEN_REFS broken @ref links${NC}"
    ((FAILED++))
fi

# Test 9: Priority hierarchy present
echo "----------------------------------------"
echo "Test 9: Priority hierarchy (P0/P1/P2)"
if grep -qE 'P0|Priority.*0|BLOCKING|Priority Level' "$CLAUDE_MD"; then
    echo -e "${GREEN}PASS: Priority hierarchy present${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}WARN: Priority hierarchy not found (optional)${NC}"
    ((WARNINGS++))
fi

# Test 10: Quick Reference table exists
echo "----------------------------------------"
echo "Test 10: Quick Reference table"
if grep -qi 'Quick Reference\|Quick.*Ref' "$CLAUDE_MD"; then
    echo -e "${GREEN}PASS: Quick Reference section present${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}WARN: Quick Reference section not found${NC}"
    ((WARNINGS++))
fi

# Summary
echo ""
echo "========================================"
echo "  Summary"
echo "========================================"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}All critical tests passed!${NC}"
    exit 0
else
    echo -e "${RED}$FAILED critical test(s) failed!${NC}"
    exit 1
fi
