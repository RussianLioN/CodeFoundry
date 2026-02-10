#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# validate-token-budget.sh — Token budget validator for instruction files
# Part of: token-optimizer agent (P0-003)
# ═══════════════════════════════════════════════════════════════════════════════
#
# Usage:
#   ./scripts/validate-token-budget.sh [--quick|--verbose|--ci]
#
# Exit codes:
#   0 = All budgets OK
#   1 = Warning (approaching budget)
#   2 = Fail (budget exceeded)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

# Per-file token budgets
P0_FILE_BUDGET=400
P1_FILE_BUDGET=800
P2_FILE_BUDGET=1500

# Per-chain token budgets
P0_CHAIN_BUDGET=1500
P1_CHAIN_BUDGET=3000

# Warning threshold (% of budget)
WARN_THRESHOLD=90

# Mode
MODE="${1:---quick}"
EXIT_CODE=0

# Colors (disabled in CI)
if [ -t 1 ] && [ "${CI:-}" != "true" ]; then
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    GREEN='\033[0;32m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' YELLOW='' GREEN='' BOLD='' NC=''
fi

# ─── Functions ───────────────────────────────────────────────────────────────

estimate_tokens() {
    local file="$1"
    if [ -f "$file" ]; then
        # Use wc -m for UTF-8 (Cyrillic) character count, divide by 4
        local chars
        chars=$(wc -m < "$file" | tr -d ' ')
        echo $(( chars / 4 ))
    else
        echo 0
    fi
}

count_lines() {
    local file="$1"
    if [ -f "$file" ]; then
        wc -l < "$file" | tr -d ' '
    else
        echo 0
    fi
}

check_budget() {
    local file="$1"
    local tokens="$2"
    local budget="$3"
    local priority="$4"
    local pct=$(( tokens * 100 / budget ))

    if [ "$tokens" -gt "$budget" ]; then
        local over=$(( tokens - budget ))
        printf "  ${RED}OVER${NC}  %-45s %5d tokens (budget: %d, +%d over) [%s]\n" \
            "$file" "$tokens" "$budget" "$over" "$priority"
        if [ "$EXIT_CODE" -lt 2 ]; then EXIT_CODE=2; fi
    elif [ "$pct" -ge "$WARN_THRESHOLD" ]; then
        printf "  ${YELLOW}WARN${NC}  %-45s %5d tokens (budget: %d, %d%% used) [%s]\n" \
            "$file" "$tokens" "$budget" "$pct" "$priority"
        if [ "$EXIT_CODE" -lt 1 ]; then EXIT_CODE=1; fi
    else
        if [ "$MODE" = "--verbose" ] || [ "$MODE" = "--ci" ]; then
            printf "  ${GREEN} OK ${NC}  %-45s %5d tokens (budget: %d, %d%% used) [%s]\n" \
                "$file" "$tokens" "$budget" "$pct" "$priority"
        fi
    fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

# Find project root (where CLAUDE.md lives)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

if [ ! -f "CLAUDE.md" ]; then
    echo "Error: CLAUDE.md not found. Are you in the project root?"
    exit 2
fi

echo ""
echo "${BOLD}TOKEN BUDGET VALIDATION${NC}"
echo "═══════════════════════════════════════════════════════════"

# ─── P0 Files (every session) ────────────────────────────────────────────────

echo ""
echo "${BOLD}P0 Files${NC} (budget: ${P0_FILE_BUDGET} tokens/file)"

P0_FILES=(
    "CLAUDE.md"
    "SESSION.md"
    "instructions/session-init.md"
)

P0_CHAIN_TOTAL=0

for file in "${P0_FILES[@]}"; do
    if [ -f "$file" ]; then
        tokens=$(estimate_tokens "$file")
        P0_CHAIN_TOTAL=$((P0_CHAIN_TOTAL + tokens))

        # CLAUDE.md is hub — exempt from per-file budget, but still counted in chain
        if [ "$file" = "CLAUDE.md" ]; then
            if [ "$MODE" = "--verbose" ] || [ "$MODE" = "--ci" ]; then
                printf "  ${GREEN} HUB${NC}  %-45s %5d tokens (hub — exempt) [P0]\n" "$file" "$tokens"
            fi
        else
            check_budget "$file" "$tokens" "$P0_FILE_BUDGET" "P0"
        fi
    fi
done

# P0 chain check
echo ""
echo "${BOLD}P0 Chain${NC} (budget: ${P0_CHAIN_BUDGET} tokens)"
pct=$(( P0_CHAIN_TOTAL * 100 / P0_CHAIN_BUDGET ))
if [ "$P0_CHAIN_TOTAL" -gt "$P0_CHAIN_BUDGET" ]; then
    over=$(( P0_CHAIN_TOTAL - P0_CHAIN_BUDGET ))
    printf "  ${RED}OVER${NC}  P0 session start chain: %d tokens (budget: %d, +%d over)\n" \
        "$P0_CHAIN_TOTAL" "$P0_CHAIN_BUDGET" "$over"
    if [ "$EXIT_CODE" -lt 2 ]; then EXIT_CODE=2; fi
elif [ "$pct" -ge "$WARN_THRESHOLD" ]; then
    printf "  ${YELLOW}WARN${NC}  P0 session start chain: %d tokens (budget: %d, %d%% used)\n" \
        "$P0_CHAIN_TOTAL" "$P0_CHAIN_BUDGET" "$pct"
    if [ "$EXIT_CODE" -lt 1 ]; then EXIT_CODE=1; fi
else
    printf "  ${GREEN} OK ${NC}  P0 session start chain: %d tokens (budget: %d, %d%% used)\n" \
        "$P0_CHAIN_TOTAL" "$P0_CHAIN_BUDGET" "$pct"
fi

# ─── P1 Files (on demand) ────────────────────────────────────────────────────

echo ""
echo "${BOLD}P1 Files${NC} (budget: ${P1_FILE_BUDGET} tokens/file)"

P1_CHAIN_TOTAL=0
P1_COUNT=0

if [ -d "instructions" ]; then
    while IFS= read -r -d '' file; do
        # Skip P0 files
        case "$file" in
            ./instructions/session-init.md) continue ;;
        esac

        tokens=$(estimate_tokens "$file")
        P1_CHAIN_TOTAL=$((P1_CHAIN_TOTAL + tokens))
        P1_COUNT=$((P1_COUNT + 1))
        check_budget "$file" "$tokens" "$P1_FILE_BUDGET" "P1"
    done < <(find ./instructions -name "*.md" -type f -print0 | sort -z)
fi

# P1 total
if [ "$MODE" = "--verbose" ] || [ "$MODE" = "--ci" ]; then
    echo ""
    echo "${BOLD}P1 Total${NC}: $P1_COUNT files, ~$P1_CHAIN_TOTAL tokens"
fi

# ─── P2 Files (rare) ─────────────────────────────────────────────────────────

if [ "$MODE" = "--verbose" ] || [ "$MODE" = "--ci" ]; then
    echo ""
    echo "${BOLD}P2 Files${NC} (budget: ${P2_FILE_BUDGET} tokens/file)"

    P2_TOTAL=0
    if [ -d "docs" ]; then
        while IFS= read -r -d '' file; do
            tokens=$(estimate_tokens "$file")
            P2_TOTAL=$((P2_TOTAL + tokens))
            check_budget "$file" "$tokens" "$P2_FILE_BUDGET" "P2"
        done < <(find ./docs -name "*.md" -type f -print0 | sort -z)
    fi
fi

# ─── Grand Total ─────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════"

GRAND_TOTAL=0
TOTAL_FILES=0
while IFS= read -r -d '' file; do
    t=$(estimate_tokens "$file")
    GRAND_TOTAL=$((GRAND_TOTAL + t))
    TOTAL_FILES=$((TOTAL_FILES + 1))
done < <(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" -type f -print0)

printf "${BOLD}TOTAL: %d files, ~%d tokens${NC}\n" "$TOTAL_FILES" "$GRAND_TOTAL"

case $EXIT_CODE in
    0) printf "${GREEN}Result: ALL BUDGETS OK${NC}\n" ;;
    1) printf "${YELLOW}Result: WARNING — approaching budget limits${NC}\n" ;;
    2) printf "${RED}Result: FAIL — budget exceeded${NC}\n" ;;
esac

echo ""

exit $EXIT_CODE
