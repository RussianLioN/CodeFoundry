#!/bin/bash
# GitOps Bootstrap Script
# Sets up ArgoCD and SealedSecrets for a new cluster

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 GitOps Bootstrap for CodeFoundry"
echo "==================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl not found${NC}"
    echo "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi
echo -e "${GREEN}✓ kubectl found${NC}"

# Check kubectl connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
    echo "Check your kubeconfig"
    exit 1
fi
echo -e "${GREEN}✓ Kubernetes cluster accessible${NC}"

# Check argocd CLI
if ! command -v argocd &> /dev/null; then
    echo -e "${YELLOW}⚠ argocd CLI not found${NC}"
    echo "Install argocd CLI:"
    echo "  macOS: brew install argocd"
    echo "  Linux: curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
    echo "          sudo install -m 555 argocd /usr/local/bin/argocd"
    read -p "Continue without argocd CLI? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check kubeseal
if ! command -v kubeseal &> /dev/null; then
    echo -e "${YELLOW}⚠ kubeseal not found${NC}"
    echo "Install kubeseal CLI:"
    echo "  macOS: brew install kubeseal"
    echo "  Linux: wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-linux-amd64 -O kubeseal"
    echo "          sudo install -m 555 kubeseal /usr/local/bin/kubeseal"
    read -p "Continue without kubeseal? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "🚀 Starting installation..."
echo ""

# Create ArgoCD namespace
echo "📦 Creating ArgoCD namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml

echo "⏳ Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-application-controller -n argocd --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Install SealedSecrets
echo "📦 Installing SealedSecrets..."
kubectl apply -f "$SCRIPT_DIR/../sealed-secrets/controller.yaml"

echo "⏳ Waiting for SealedSecrets controller to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=sealed-secrets -n kube-system --timeout=300s

# Apply ArgoCD projects
echo "📦 Creating ArgoCD projects..."
kubectl apply -f "$SCRIPT_DIR/../argocd/projects/"

echo ""
echo "✅ GitOps infrastructure installed successfully!"
echo ""

# Display access information
echo "🔑 ArgoCD Access:"
echo "  URL: https://localhost:8080"
echo "  Username: admin"
echo "  Password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo ""

echo "📝 Next steps:"
echo "  1. Port-forward to access ArgoCD UI:"
echo "     kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "  2. Login to ArgoCD CLI:"
echo "     argocd login localhost:8080 --username admin --password <password> --insecure"
echo ""
echo "  3. Backup the SealedSecrets key:"
echo "     kubectl get secret -n kube-system sealed-secrets-key -o yaml > sealed-secrets-key-backup.yaml"
echo ""
echo "  4. Create applications:"
echo "     kubectl apply -f <archetype>/gitops/application.yaml"
echo ""

echo "📚 For more information, see: $SCRIPT_DIR/../README.md"
