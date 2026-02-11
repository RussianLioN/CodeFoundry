#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# fix-shell-syntax.sh — Check and fix shell script syntax errors
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Checking shell scripts syntax...${NC}"

# Check if shellcheck is installed
if ! command -v shellcheck &>/dev/null; then
    echo -e "${YELLOW}⚠️  shellcheck not found, installing...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install shellcheck
    else
        echo "Please install shellcheck: apt install shellcheck or yum install shellcheck"
        exit 1
    fi
fi

# Find all shell scripts
SCRIPTS=$(find . -name "*.sh" -not -path "./.git/*" -not -path "./node_modules/*" -type f)

ERRORS=0
FIXED=0

for script in $SCRIPTS; do
    echo -e "${BLUE}Checking: ${script}${NC}"

    # Run shellcheck
    if shellcheck -x "$script" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $script"
    else
        ERRORS=$((ERRORS + 1))
        echo -e "${RED}✗${NC} $script has issues"

        # Try to fix common issues automatically
        # Fix: missing shebang
        if ! head -1 "$script" | grep -q '^#!'; then
            echo -e "${YELLOW}  → Adding shebang${NC}"
            sed -i.bak '1i #!/bin/bash' "$script"
            rm "${script}.bak"
            FIXED=$((FIXED + 1))
        fi

        # Fix: $() vs backticks (warning only)
        if grep -q '`' "$script"; then
            echo -e "${YELLOW}  → Consider using \$() instead of backticks${NC}"
        fi

        # Show shellcheck suggestions
        shellcheck -f gcc "$script" 2>/dev/null || true
    fi
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  Scripts checked: $(echo "$SCRIPTS" | wc -l | tr -d ' ')"
echo -e "  Errors found: ${RED}${ERRORS}${NC}"
echo -e "  Auto-fixed: ${GREEN}${FIXED}${NC}"

if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ All scripts passed shellcheck${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some scripts have issues (see above)${NC}"
    exit 1
fi
