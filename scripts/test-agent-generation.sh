#!/usr/bin/env bash
# Test script for Agent Generator
# Tests multiple project types to ensure all templates render correctly

set -e

echo "🧪 Testing Agent Generation System"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_TESTS=0
PASSED=0
FAILED=0

# Test 1: Telegram Bot (Python + aiogram)
echo ""
echo "📦 Test 1: Telegram Bot (Python + aiogram)"
TOTAL_TESTS=1
TEST_DIR="/tmp/test-agent-gen-telegram"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

if python3 scripts/generate-agents.py TestBot telegram-bot python aiogram "$TEST_DIR" > /dev/null 2>&1; then
    echo "  ✓ Generation succeeded"
    if [ -d "$TEST_DIR/.claude" ] && [ -f "$TEST_DIR/.claude/AGENTS.md" ]; then
        agent_count=$(ls -1 "$TEST_DIR/.claude"/*.md 2>/dev/null | grep -v AGENTS.md | wc -l)
        echo "  ✓ Generated: $agent_count agent(s)"
        undefined=$(grep -r "{{ " "$TEST_DIR/.claude/" 2>/dev/null | grep -vE "version|template_version|creation_date|project_name|project_type|agent_name|agent_id|format|primary_language|framework" || true)
        if [ -z "$undefined" ]; then
            echo "  ✓ No undefined variables"
            echo "  ✅ Test 1 passed"
            ((PASSED++))
        else
            echo "  ❌ Found undefined variables"
            ((FAILED++))
        fi
    else
        echo "  ❌ .claude directory or AGENTS.md not found"
        ((FAILED++))
    fi
else
    echo "  ❌ Generation failed"
    ((FAILED++))
fi
rm -rf "$TEST_DIR"

# Test 2: Web Service (TypeScript + Next.js)
echo ""
echo "📦 Test 2: Web Service (TypeScript + Next.js)"
((TOTAL_TESTS++))
TEST_DIR="/tmp/test-agent-gen-web"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

if python3 scripts/generate-agents.py TestAPI web-service typescript next "$TEST_DIR" > /dev/null 2>&1; then
    echo "  ✓ Generation succeeded"
    if [ -d "$TEST_DIR/.claude" ] && [ -f "$TEST_DIR/.claude/AGENTS.md" ]; then
        agent_count=$(ls -1 "$TEST_DIR/.claude"/*.md 2>/dev/null | grep -v AGENTS.md | wc -l)
        echo "  ✓ Generated: $agent_count agent(s)"
        if grep -q "camelCase" "$TEST_DIR/.claude/code_assistant.md"; then
            echo "  ✓ TypeScript defaults applied (camelCase)"
        fi
        undefined=$(grep -r "{{ " "$TEST_DIR/.claude/" 2>/dev/null | grep -vE "version|template_version|creation_date|project_name|project_type|agent_name|agent_id|format|primary_language|framework" || true)
        if [ -z "$undefined" ]; then
            echo "  ✓ No undefined variables"
            echo "  ✅ Test 2 passed"
            ((PASSED++))
        else
            echo "  ❌ Found undefined variables"
            ((FAILED++))
        fi
    else
        echo "  ❌ .claude directory or AGENTS.md not found"
        ((FAILED++))
    fi
else
    echo "  ❌ Generation failed"
    ((FAILED++))
fi
rm -rf "$TEST_DIR"

# Test 3: AI Agent (Python + FastAPI)
echo ""
echo "📦 Test 3: AI Agent (Python + FastAPI)"
((TOTAL_TESTS++))
TEST_DIR="/tmp/test-agent-gen-ai"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

if python3 scripts/generate-agents.py TestAI ai-agent python fastapi "$TEST_DIR" > /dev/null 2>&1; then
    echo "  ✓ Generation succeeded"
    if [ -d "$TEST_DIR/.claude" ] && [ -f "$TEST_DIR/.claude/AGENTS.md" ]; then
        agent_count=$(ls -1 "$TEST_DIR/.claude"/*.md 2>/dev/null | grep -v AGENTS.md | wc -l)
        echo "  ✓ Generated: $agent_count agent(s)"
        undefined=$(grep -r "{{ " "$TEST_DIR/.claude/" 2>/dev/null | grep -vE "version|template_version|creation_date|project_name|project_type|agent_name|agent_id|format|primary_language|framework" || true)
        if [ -z "$undefined" ]; then
            echo "  ✓ No undefined variables"
            echo "  ✅ Test 3 passed"
            ((PASSED++))
        else
            echo "  ❌ Found undefined variables"
            ((FAILED++))
        fi
    else
        echo "  ❌ .claude directory or AGENTS.md not found"
        ((FAILED++))
    fi
else
    echo "  ❌ Generation failed"
    ((FAILED++))
fi
rm -rf "$TEST_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Results:"
echo "   Passed: $PASSED/$TOTAL_TESTS"
echo "   Failed: $FAILED/$TOTAL_TESTS"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    exit 0
else
    echo ""
    echo "❌ Some tests failed"
    exit 1
fi
