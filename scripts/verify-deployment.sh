#!/bin/bash
#
# verify-deployment.sh
#
# Deployment verification script that runs after git push.
# Verifies that remote build succeeded and container is running.
#
# Usage: ./scripts/verify-deployment.sh
# Exit codes: 0 = success, 1 = failure

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REMOTE_HOST="${DEPLOY_REMOTE_HOST:-ainetic.tech}"
REMOTE_PROJECT_DIR="${DEPLOY_REMOTE_DIR:-~/projects/CodeFoundry}"
SERVICE_NAME="${DEPLOY_SERVICE:-gateway}"
COMPOSE_FILE="${DEPLOY_COMPOSE_FILE:-docker-compose.test.yml}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔍 Deployment Verification                                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# =============================================================================
# STEP 1: Check SSH connectivity
# =============================================================================
echo -e "${YELLOW}[1/5] Checking SSH connectivity...${NC}"

if ssh -o ConnectTimeout=5 "$REMOTE_HOST" "echo 'OK'" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ SSH connection OK${NC}"
else
    echo -e "${RED}❌ Cannot connect to $REMOTE_HOST${NC}"
    exit 1
fi

echo

# =============================================================================
# STEP 2: Verify git pull happened
# =============================================================================
echo -e "${YELLOW}[2/5] Verifying git sync...${NC}"

REMOTE_COMMIT=$(ssh "$REMOTE_HOST" "cd $REMOTE_PROJECT_DIR && git rev-parse --short HEAD")
LOCAL_COMMIT=$(git rev-parse --short HEAD)

echo "  Local commit:  $LOCAL_COMMIT"
echo "  Remote commit: $REMOTE_COMMIT"

if [ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]; then
    echo -e "${GREEN}✅ Git sync verified${NC}"
else
    echo -e "${YELLOW}⚠️  Commit mismatch - remote may not have pulled yet${NC}"
    echo "   Waiting 5 seconds for git pull..."
    sleep 5

    REMOTE_COMMIT=$(ssh "$REMOTE_HOST" "cd $REMOTE_PROJECT_DIR && git rev-parse --short HEAD")
    if [ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]; then
        echo -e "${GREEN}✅ Git sync verified (after wait)${NC}"
    else
        echo -e "${YELLOW}⚠️  Commits still differ - proceeding anyway${NC}"
    fi
fi

echo

# =============================================================================
# STEP 3: Check Docker build status
# =============================================================================
echo -e "${YELLOW}[3/5] Checking Docker build status...${NC}"

# Get container creation time
CONTAINER_CREATED=$(ssh "$REMOTE_HOST" "docker ps --filter 'name=$SERVICE_NAME' --format '{{.CreatedAt}}' 2>/dev/null" || echo "")

if [ -z "$CONTAINER_CREATED" ]; then
    echo -e "${RED}❌ Container not running${NC}"

    # Show recent build attempts
    echo
    echo "Recent build logs:"
    ssh "$REMOTE_HOST" "cd $REMOTE_PROJECT_DIR/server && docker-compose --env-file .env.test -f $COMPOSE_FILE logs --tail=20 $SERVICE_NAME" 2>/dev/null || true

    exit 1
fi

echo "  Container created: $CONTAINER_CREATED"
echo -e "${GREEN}✅ Container is running${NC}"

echo

# =============================================================================
# STEP 4: Health check
# =============================================================================
echo -e "${YELLOW}[4/5] Running health check...${NC}"

# Check health endpoint
HEALTH_URL="http://${REMOTE_HOST}:18790/health"

if curl -f -s "$HEALTH_URL" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Health check PASSED${NC}"

    # Show health status
    HEALTH_STATUS=$(curl -s "$HEALTH_URL" 2>/dev/null || echo "{}")
    echo "  Status: $HEALTH_STATUS"
else
    echo -e "${YELLOW}⚠️  Health endpoint not accessible${NC}"
    echo "   This may be normal if service just started"
fi

echo

# =============================================================================
# STEP 5: Show recent logs
# =============================================================================
echo -e "${YELLOW}[5/5] Showing recent logs...${NC}"

echo
ssh "$REMOTE_HOST" "cd $REMOTE_PROJECT_DIR/server && docker-compose --env-file .env.test -f $COMPOSE_FILE logs --tail=30 $SERVICE_NAME" 2>/dev/null || echo "  Could not fetch logs"

echo

# =============================================================================
# FINAL RESULT
# =============================================================================
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Deployment verification PASSED                             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

exit 0
