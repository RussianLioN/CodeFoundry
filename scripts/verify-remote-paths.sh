#!/usr/bin/env bash
# Verify Remote Paths - Check that all documented paths exist
# Part of TESTING.md workflow

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load paths from REMOTE-PATHS.md
REMOTE_HOST="ainetic.tech"
REMOTE_GIT_REPO="/root/projects/CodeFoundry"
REMOTE_WORKSPACE="/workspace/openclaw"
REMOTE_SCRIPTS="${REMOTE_GIT_REPO}/server/scripts"
REMOTE_LOGS="/var/log/codefoundry"

echo "========================================"
echo "Remote Paths Verification"
echo "========================================"
echo ""

# Test SSH connection
echo -e "${YELLOW}[1/6]${NC} Testing SSH connection..."
if ssh -o ConnectTimeout=5 "${REMOTE_HOST}" "hostname" &>/dev/null; then
    echo -e "${GREEN}✅ SSH connection OK${NC}"
else
    echo -e "${RED}❌ SSH connection FAILED${NC}"
    exit 1
fi

# Test git repo
echo -e "${YELLOW}[2/6]${NC} Testing GIT_REPO (${REMOTE_GIT_REPO})..."
if ssh "${REMOTE_HOST}" "[ -d '${REMOTE_GIT_REPO}' ]"; then
    echo -e "${GREEN}✅ GIT_REPO exists${NC}"
    ssh "${REMOTE_HOST}" "cd ${REMOTE_GIT_REPO} && git status --short | head -3"
else
    echo -e "${RED}❌ GIT_REPO not found${NC}"
    echo "   → Update REMOTE-PATHS.md with correct path"
fi

# Test workspace
echo -e "${YELLOW}[3/6]${NC} Testing WORKSPACE (${REMOTE_WORKSPACE})..."
if ssh "${REMOTE_HOST}" "[ -d '${REMOTE_WORKSPACE}' ]"; then
    echo -e "${GREEN}✅ WORKSPACE exists${NC}"
    ssh "${REMOTE_HOST}" "ls ${REMOTE_WORKSPACE}"
else
    echo -e "${RED}❌ WORKSPACE not found${NC}"
    echo "   → Update REMOTE-PATHS.md with correct path"
fi

# Test scripts
echo -e "${YELLOW}[4/6]${NC} Testing SCRIPTS (${REMOTE_SCRIPTS})..."
if ssh "${REMOTE_HOST}" "[ -d '${REMOTE_SCRIPTS}' ]"; then
    echo -e "${GREEN}✅ SCRIPTS exists${NC}"
    ssh "${REMOTE_HOST}" "ls ${REMOTE_SCRIPTS}/*.sh 2>/dev/null | head -5"
else
    echo -e "${RED}❌ SCRIPTS not found${NC}"
    echo "   → Update REMOTE-PATHS.md with correct path"
fi

# Test logs
echo -e "${YELLOW}[5/6]${NC} Testing LOGS (${REMOTE_LOGS})..."
if ssh "${REMOTE_HOST}" "[ -d '${REMOTE_LOGS}' ]"; then
    echo -e "${GREEN}✅ LOGS exists${NC}"
    ssh "${REMOTE_HOST}" "ls ${REMOTE_LOGS}/*.log 2>/dev/null | head -3"
else
    echo -e "${YELLOW}⚠️  LOGS not found (may not exist yet)${NC}"
fi

# Test docker compose
echo -e "${YELLOW}[6/6]${NC} Testing Docker Compose..."
REMOTE_DOCKER_COMPOSE="${REMOTE_GIT_REPO}/server/docker-compose.test.yml"
if ssh "${REMOTE_HOST}" "[ -f '${REMOTE_DOCKER_COMPOSE}' ]"; then
    echo -e "${GREEN}✅ Docker Compose exists${NC}"
    ssh "${REMOTE_HOST}" "cd ${REMOTE_GIT_REPO}/server && docker-compose -f docker-compose.test.yml ps --services 2>/dev/null | head -3"
else
    echo -e "${YELLOW}⚠️  Docker Compose not found at ${REMOTE_DOCKER_COMPOSE}${NC}"
    echo "   → May be in different location"
fi

echo ""
echo "========================================"
echo "Verification Complete"
echo "========================================"
echo ""
echo "If any paths failed:"
echo "  1. Update docs/REMOTE-PATHS.md"
echo "  2. Run this script again"
echo "  3. Commit updated paths"
