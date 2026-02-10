#!/bin/bash
# ArgoCD Login Helper Script
# Automates login to ArgoCD cluster

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
ARGOCD_SERVER="${ARGOCD_SERVER:-localhost:8080}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔐 ArgoCD Login"
echo "==============="
echo ""

# Check if argocd CLI is installed
if ! command -v argocd &> /dev/null; then
    echo -e "${RED}✗ argocd CLI not found${NC}"
    echo "Install from: https://argoproj.github.io/argo-cd/cli_installation/"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

# Check if ArgoCD is running
if ! kubectl get namespace "$ARGOCD_NAMESPACE" &> /dev/null; then
    echo -e "${RED}✗ ArgoCD namespace not found: $ARGOCD_NAMESPACE${NC}"
    echo "Run GitOps bootstrap first:"
    echo "  ./gitops-bootstrap.sh"
    exit 1
fi

echo "📋 ArgoCD server: $ARGOCD_SERVER"
echo "📋 Namespace: $ARGOCD_NAMESPACE"
echo ""

# Get initial admin password
PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d)

if [ -z "$PASSWORD" ]; then
    echo -e "${YELLOW}⚠ Initial admin secret not found${NC}"
    echo "The password may have been changed. Enter password manually:"
    read -s -p "Password: " PASSWORD
    echo ""
else
    echo -e "${GREEN}✓ Retrieved initial admin password${NC}"
fi

# Perform login
echo ""
echo "🔐 Logging in to ArgoCD..."

# Login (with --insecure for self-signed certs)
argocd login "$ARGOCD_SERVER" \
    --username admin \
    --password "$PASSWORD" \
    --insecure

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Successfully logged in to ArgoCD${NC}"
    echo ""
    echo "📝 Useful commands:"
    echo "  argocd app list                    # List all applications"
    echo "  argocd app get <app>              # Get application details"
    echo "  argocd app sync <app>             # Sync application"
    echo "  argocd app rollback <app>         # Rollback application"
    echo "  argocd app logs <app>              # View application logs"
    echo ""
else
    echo -e "${RED}✗ Login failed${NC}"
    echo "Try manual login:"
    echo "  argocd login $ARGOCD_SERVER --username admin --password <password> --insecure"
    exit 1
fi
