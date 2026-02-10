#!/bin/bash
# SealedSecrets Encryption Script
# Encrypts Kubernetes Secrets into SealedSecrets

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
SECRET_FILE="${1:-}"
NAMESPACE="${2:-default}"
SCOPE="${3:-strict}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Help function
show_help() {
    echo "🔒 SealedSecrets Encryption Script"
    echo "==================================="
    echo ""
    echo "Usage: $0 <secret-file.yaml> [namespace] [scope]"
    echo ""
    echo "Arguments:"
    echo "  secret-file    Path to the Secret manifest to encrypt"
    echo "  namespace      Target namespace (default: default)"
    echo "  scope          Encryption scope: strict|namespace-wide|cluster-wide (default: strict)"
    echo ""
    echo "Example:"
    echo "  $0 database-secret.yaml default strict"
    echo ""
    echo "Scopes:"
    echo "  strict         - Secret can only be decrypted in the same namespace"
    echo "  namespace-wide - Secret can be decrypted in the same namespace by any service"
    echo "  cluster-wide   - Secret can be decrypted in any namespace"
    echo ""
}

# Check if help is requested
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Validate inputs
if [ -z "$SECRET_FILE" ]; then
    echo -e "${RED}✗ No secret file specified${NC}"
    echo ""
    show_help
    exit 1
fi

if [ ! -f "$SECRET_FILE" ]; then
    echo -e "${RED}✗ Secret file not found: $SECRET_FILE${NC}"
    exit 1
fi

# Check if kubeseal is installed
if ! command -v kubeseal &> /dev/null; then
    echo -e "${RED}✗ kubeseal not found${NC}"
    echo "Install kubeseal:"
    echo "  macOS: brew install kubeseal"
    echo "  Linux: wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-linux-amd64 -O kubeseal"
    echo "          sudo install -m 555 kubeseal /usr/local/bin/kubeseal"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

# Check if SealedSecrets controller is running
if ! kubectl get namespace kube-system &> /dev/null; then
    echo -e "${RED}✗ kube-system namespace not found${NC}"
    exit 1
fi

SEALED_SECRETS_POD=$(kubectl get pod -n kube-system -l app.kubernetes.io/name=sealed-secrets -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$SEALED_SECRETS_POD" ]; then
    echo -e "${RED}✗ SealedSecrets controller not found${NC}"
    echo "Install SealedSecrets first:"
    echo "  kubectl apply -f templates/archetypes/shared/gitops/sealed-secrets/controller.yaml"
    exit 1
fi

echo -e "${BLUE}🔒 SealedSecrets Encryption${NC}"
echo "=============================="
echo ""
echo "📄 Secret file: $SECRET_FILE"
echo "📋 Namespace: $NAMESPACE"
echo "🔒 Scope: $SCOPE"
echo ""

# Get the certificate from the controller
echo -e "${BLUE}📋 Fetching certificate from controller...${NC}"
CERT_URL="https://$(kubectl get svc -n kube-system sealed-secrets-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)"
if [ -z "$CERT_URL" ] || [ "$CERT_URL" = "https://" ]; then
    # Use cluster IP if LoadBalancer IP is not available
    CERT_URL="https://$(kubectl get svc -n kube-system sealed-secrets-controller -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
fi

if [ -z "$CERT_URL" ] || [ "$CERT_URL" = "https://" ]; then
    echo -e "${YELLOW}⚠ Could not get controller service IP${NC}"
    echo "Using direct cluster method..."
    kubeseal --fetch-cert
else
    echo -e "${GREEN}✓ Using controller certificate from: $CERT_URL${NC}"
fi

# Encrypt the secret
echo ""
echo -e "${BLUE}🔐 Encrypting secret...${NC}"

OUTPUT_FILE="${SECRET_FILE%.yaml}-sealed.yaml"

kubeseal --format=yaml \
    --scope="$SCOPE" \
    --namespace="$NAMESPACE" \
    --cert="$CERT_URL" \
    < "$SECRET_FILE" > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Secret encrypted successfully!${NC}"
    echo ""
    echo "📄 Sealed secret saved to: $OUTPUT_FILE"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Review the sealed secret:"
    echo "     cat $OUTPUT_FILE"
    echo ""
    echo "  2. Add to Git:"
    echo "     git add $OUTPUT_FILE"
    echo "     git commit -m 'Add sealed secret for <service>'"
    echo ""
    echo "  3. Apply to cluster:"
    echo "     kubectl apply -f $OUTPUT_FILE"
    echo ""
    echo "  4. Verify secret was created:"
    echo "     kubectl get secret $(basename "$SECRET_FILE" .yaml) -n $NAMESPACE"
    echo ""
    echo "  ⚠️  IMPORTANT: Backup the SealedSecrets private key!"
    echo "     kubectl get secret -n kube-system sealed-secrets-key -o yaml > sealed-secrets-key-backup.yaml"
    echo "     Store this backup securely (e.g., in a password manager or vault)"
else
    echo -e "${RED}✗ Encryption failed${NC}"
    rm -f "$OUTPUT_FILE"
    exit 1
fi
