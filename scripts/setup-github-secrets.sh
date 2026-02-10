#!/bin/bash
# ═════════════════════════════════════════════════════════════════════════════
# Setup GitHub Secrets for OpenClaw Remote Sync
# ═════════════════════════════════════════════════════════════════════════════
#
# Автоматически добавляет необходимые GitHub Secrets для remote-sync workflow
# Использует существующий SSH ключ ~/.ssh/id_n8n_servers
#
# Usage: ./scripts/setup-github-secrets.sh [--dry-run]
#
# ═════════════════════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="RussianLioN/CodeFoundry"
SSH_KEY_PATH="$HOME/.ssh/id_n8n_servers"
REMOTE_HOST="ainetic.tech"
REMOTE_USER="root"
SSH_PORT="22"
REMOTE_PATH="/opt/openclaw"

# Dry run mode
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}⚠️  DRY RUN MODE — no secrets will be uploaded${NC}"
    echo ""
fi

# ────────────────────────────────────────────────────────────────────────────────
# Helper functions
# ────────────────────────────────────────────────────────────────────────────────

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# ────────────────────────────────────────────────────────────────────────────────
# Pre-flight checks
# ────────────────────────────────────────────────────────────────────────────────

print_header "Step 1: Pre-flight Checks"

# Check gh CLI
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) not found"
    print_info "Install: brew install gh  # macOS"
    print_info "        or: https://cli.github.com/"
    exit 1
fi
print_success "GitHub CLI found"

# Check gh auth
if ! gh auth status &> /dev/null; then
    print_error "Not logged in to GitHub"
    print_info "Run: gh auth login"
    exit 1
fi
print_success "Authenticated with GitHub"

# Check SSH key exists
if [ ! -f "$SSH_KEY_PATH" ]; then
    print_error "SSH key not found: $SSH_KEY_PATH"
    exit 1
fi
print_success "SSH key found: $SSH_KEY_PATH"

# Check SSH connection
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$REMOTE_HOST" "echo 'OK'" &> /dev/null; then
    print_success "SSH connection to $REMOTE_HOST"
else
    print_warning "Could not verify SSH connection to $REMOTE_HOST"
    print_info "This may be normal if StrictHostKeyChecking is enabled"
fi

# Check if public key is on server
PUBLIC_KEY=$(ssh-keygen -y -f "$SSH_KEY_PATH" 2>/dev/null)
if ssh "$REMOTE_HOST" "grep -q '$PUBLIC_KEY' ~/.ssh/authorized_keys" 2>/dev/null; then
    print_success "Public key already in authorized_keys on server"
else
    print_warning "Public key may not be on server"
    print_info "Run: ssh-copy-id -i ${SSH_KEY_PATH}.pub ${REMOTE_USER}@${REMOTE_HOST}"
fi

# Check OpenClaw directory
if ssh "$REMOTE_HOST" "[ -d '$REMOTE_PATH' ]" 2>/dev/null; then
    print_success "OpenClaw directory exists: $REMOTE_PATH"
else
    print_warning "OpenClaw directory not found: $REMOTE_PATH"
fi

echo ""

# ────────────────────────────────────────────────────────────────────────────────
# Read SSH key
# ────────────────────────────────────────────────────────────────────────────────

print_header "Step 2: Read SSH Key"

# Read the SSH key
SSH_PRIVATE_KEY=$(cat "$SSH_KEY_PATH")

# Verify key format
if [[ ! "$SSH_PRIVATE_KEY" =~ ^-----BEGIN ]]; then
    print_error "Invalid SSH key format"
    exit 1
fi

KEY_LINES=$(echo "$SSH_PRIVATE_KEY" | wc -l)
print_success "SSH key read: $KEY_LINES lines"
print_info "Key type: $(head -1 "$SSH_KEY_PATH" | sed 's/-----BEGIN //;s/-----//')"

echo ""

# ────────────────────────────────────────────────────────────────────────────────
# Set GitHub Secrets
# ────────────────────────────────────────────────────────────────────────────────

print_header "Step 3: Set GitHub Secrets"

# Function to set secret
set_secret() {
    local secret_name="$1"
    local secret_value="$2"

    if [ "$DRY_RUN" = true ]; then
        print_info "[DRY RUN] Would set $secret_name"
        echo "         Value: $(echo "$secret_value" | head -c 50)..."
    else
        if gh secret set "$secret_name" --body "$secret_value" 2>/dev/null; then
            print_success "Set $secret_name"
        else
            print_error "Failed to set $secret_name"
            return 1
        fi
    fi
}

# Set each secret
set_secret "REMOTE_HOST" "$REMOTE_HOST"
set_secret "REMOTE_USER" "$REMOTE_USER"
set_secret "SSH_PRIVATE_KEY" "$SSH_PRIVATE_KEY"
set_secret "SSH_PORT" "$SSH_PORT"
set_secret "REMOTE_PATH" "$REMOTE_PATH"

echo ""

# ────────────────────────────────────────────────────────────────────────────────
# Verify secrets
# ────────────────────────────────────────────────────────────────────────────────

print_header "Step 4: Verify Secrets"

if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Skipping verification"
else
    # List secrets (gh doesn't show values, only names)
    print_info "Secrets in repository:"
    if gh secret list --json name -q '.[].name' | grep -q "REMOTE_HOST"; then
        print_success "REMOTE_HOST ✅"
    else
        print_error "REMOTE_HOST ❌"
    fi

    if gh secret list --json name -q '.[].name' | grep -q "SSH_PRIVATE_KEY"; then
        print_success "SSH_PRIVATE_KEY ✅"
    else
        print_error "SSH_PRIVATE_KEY ❌"
    fi
fi

echo ""

# ────────────────────────────────────────────────────────────────────────────────
# Test workflow
# ────────────────────────────────────────────────────────────────────────────────

print_header "Step 5: Test Workflow"

if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Skipping workflow test"
else
    print_info "To test the workflow:"
    echo ""
    echo "  1. Make a commit to trigger the workflow:"
    echo "     git commit --allow-empty -m 'test: trigger remote sync'"
    echo ""
    echo "  2. Push to main:"
    echo "     git push origin main"
    echo ""
    echo "  3. Check the workflow status:"
    echo "     gh run list --workflow=remote-sync.yml --limit 1"
    echo ""
    echo "  4. Or open in browser:"
    echo "     https://github.com/$REPO/actions"
fi

echo ""

# ────────────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────────────

print_header "Summary"

if [ "$DRY_RUN" = true ]; then
    print_info "Dry run complete. No secrets were uploaded."
    echo ""
    print_info "To actually upload secrets, run:"
    echo "  ./scripts/setup-github-secrets.sh"
else
    print_success "GitHub Secrets configured successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Trigger a workflow with a commit"
    echo "  2. Check Actions tab for results"
    echo ""
    print_info "Repository: https://github.com/$REPO/actions/secrets"
fi

echo ""
