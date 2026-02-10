#!/bin/bash
#
# diagnose.sh
#
# Comprehensive diagnostic script for troubleshooting deployment issues.
# Runs through all checks and provides detailed status output.
#
# Usage: ./scripts/diagnose.sh
# Output: Detailed diagnostic report

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34M'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🔍 CodeFoundry Deployment Diagnostic Tool                      ║${NC}"
echo -e "${CYAN}║  Version: 1.0.0                                                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo

# Save output to file
LOG_FILE="/tmp/cfoundry-diagnostic-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "Diagnostic log: $LOG_FILE"
echo

# =============================================================================
# SECTION 1: Local Environment
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🖥️  LOCAL ENVIRONMENT${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

echo "Hostname: $(hostname)"
echo "OS: $(uname -s) $(uname -r)"
echo "Working directory: $(pwd)"
echo "Git branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
echo "Git commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
echo

echo -e "${YELLOW}Node.js version:${NC}"
node --version 2>/dev/null || echo "  Not installed"
echo

echo -e "${YELLOW}npm version:${NC}"
npm --version 2>/dev/null || echo "  Not installed"
echo

echo -e "${YELLOW}Docker status:${NC}"
if docker --version >/dev/null 2>&1; then
    echo "  $(docker --version)"
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}  ✅ Docker daemon running${NC}"
    else
        echo -e "${RED}  ❌ Docker daemon not accessible${NC}"
    fi
else
    echo "  Not installed (expected for local development)"
fi

echo

# =============================================================================
# SECTION 2: Git Status
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 GIT STATUS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

echo -e "${YELLOW}Uncommitted changes:${NC}"
if git status --porcelain 2>/dev/null | grep -q .; then
    git status --short
else
    echo "  None"
fi

echo

echo -e "${YELLOW}Recent commits:${NC}"
git log --oneline -5 2>/dev/null || echo "  No git history"

echo

# =============================================================================
# SECTION 3: TypeScript Compilation
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔨 TYPESCRIPT COMPILATION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

if [ -f "openclaw/gateway/package.json" ]; then
    echo -e "${YELLOW}Gateway project:${NC}"
    cd openclaw/gateway

    echo "Running 'npm run build'..."
    if npm run build 2>&1 | tail -20; then
        echo -e "${GREEN}✅ Build PASSED${NC}"
    else
        echo -e "${RED}❌ Build FAILED${NC}"
    fi

    cd - >/dev/null
elif [ -f "package.json" ]; then
    echo -e "${YELLOW}Root project:${NC}"
    if npm run build 2>&1 | tail -20; then
        echo -e "${GREEN}✅ Build PASSED${NC}"
    else
        echo -e "${RED}❌ Build FAILED${NC}"
    fi
else
    echo "  No package.json found"
fi

echo

# =============================================================================
# SECTION 4: Alpine Compatibility
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🏔️  ALPINE COMPATIBILITY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

if [ -x "scripts/check-alpine-compatibility.sh" ]; then
    ./scripts/check-alpine-compatibility.sh || true
else
    echo "  check-alpine-compatibility.sh not found"
fi

echo

# =============================================================================
# SECTION 5: Remote Environment
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🌐 REMOTE ENVIRONMENT${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

REMOTE_HOST="${DEPLOY_REMOTE_HOST:-ainetic.tech}"

echo -e "${YELLOW}SSH connectivity:${NC}"
if ssh -o ConnectTimeout=5 "$REMOTE_HOST" "echo 'OK'" >/dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Connected to $REMOTE_HOST${NC}"

    echo
    echo -e "${YELLOW}Remote system:${NC}"
    ssh "$REMOTE_HOST" "uname -a" 2>/dev/null || true

    echo
    echo -e "${YELLOW}Remote Docker:${NC}"
    ssh "$REMOTE_HOST" "docker --version" 2>/dev/null || echo "  Not installed"

    echo
    echo -e "${YELLOW}Remote Git:${NC}"
    ssh "$REMOTE_HOST" "cd ~/projects/CodeFoundry && git log --oneline -3" 2>/dev/null || echo "  Not available"

    echo
    echo -e "${YELLOW}Remote containers:${NC}"
    ssh "$REMOTE_HOST" "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null || echo "  Could not list"

else
    echo -e "${RED}  ❌ Cannot connect to $REMOTE_HOST${NC}"
fi

echo

# =============================================================================
# SECTION 6: Configuration Files
# =============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}⚙️  CONFIGURATION FILES${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

echo -e "${YELLOW}CLAUDE.md:${NC}"
if [ -f "CLAUDE.md" ]; then
    echo "  ✅ Exists ($(wc -l < CLAUDE.md) lines)"
else
    echo "  ❌ Missing"
fi

echo

echo -e "${YELLOW}tsconfig.json files:${NC}"
find . -name "tsconfig.json" -not -path "*/node_modules/*" | while read file; do
    echo "  $file"
done

echo

echo -e "${YELLOW}docker-compose files:${NC}"
find . -name "docker-compose*.yml" | while read file; do
    echo "  $file"
done

echo

# =============================================================================
# SUMMARY
# =============================================================================
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  📋 DIAGNOSTIC COMPLETE                                       ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo
echo "Full log saved to: $LOG_FILE"
echo
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the output above for any ${RED}❌ FAILED${NC} checks"
echo "  2. Fix any issues found"
echo "  3. Run './scripts/verify-deployment.sh' after git push"
echo
