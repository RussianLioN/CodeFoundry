#!/bin/bash
#
# cloud-sync.sh - Sync backups to cloud storage
#
# Supports: S3 (AWS), Backblaze B2, Google Cloud Storage
#
# Usage:
#   ./cloud-sync.sh [provider]
#
# Providers: s3, b2, gcs
#
# Configuration:
#   Set credentials in environment or .env file

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROVIDER="${1:-}"
BASE_DIR="/opt/openclaw"
BACKUP_DIR="$BASE_DIR/backups"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ -z "$PROVIDER" ]]; then
    log_error "Provider not specified"
    echo "Usage: $0 [s3|b2|gcs]"
    exit 1
fi

case "$PROVIDER" in
    s3)
        # AWS S3
        BUCKET="${S3_BUCKET:-openclaw-backups}"
        REGION="${S3_REGION:-us-east-1}"

        log_info "Syncing to AWS S3: $BUCKET"

        # Check for AWS credentials
        if [[ -z "${AWS_ACCESS_KEY_ID:-}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
            log_error "AWS credentials not set"
            echo "Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
            exit 1
        fi

        # Install AWS CLI if not present
        if ! command -v aws &> /dev/null; then
            log_info "Installing AWS CLI..."
            apt-get install -y awscli
        fi

        # Sync daily backups
        log_info "Syncing daily backups..."
        aws s3 sync "$BACKUP_DIR/daily/" "s3://$BUCKET/daily/" \
            --region "$REGION" \
            --storage-class STANDARD_IA \
            || {
                log_error "S3 sync failed"
                exit 1
            }

        # Sync weekly backups
        log_info "Syncing weekly backups..."
        aws s3 sync "$BACKUP_DIR/weekly/" "s3://$BUCKET/weekly/" \
            --region "$REGION" \
            --storage-class GLACIER \
            || {
                log_error "S3 sync failed"
                exit 1
            }

        # Sync monthly backups
        log_info "Syncing monthly backups..."
        aws s3 sync "$BACKUP_DIR/monthly/" "s3://$BUCKET/monthly/" \
            --region "$REGION" \
            --storage-class DEEP_ARCHIVE \
            || {
                log_error "S3 sync failed"
                exit 1
            }

        log_info "✅ Synced to S3"
        ;;

    b2)
        # Backblaze B2
        BUCKET="${B2_BUCKET:-openclaw-backups}"
        B2_KEY_ID="${B2_KEY_ID:-}"
        B2_KEY="${B2_KEY:-}"

        log_info "Syncing to Backblaze B2: $BUCKET"

        if [[ -z "$B2_KEY_ID" ]] || [[ -z "$B2_KEY" ]]; then
            log_error "Backblaze credentials not set"
            echo "Set B2_KEY_ID and B2_KEY"
            exit 1
        fi

        # Install rclone if not present
        if ! command -v rclone &> /dev/null; then
            log_info "Installing rclone..."
            curl -s https://rclone.org/install.sh | bash
        fi

        # Configure rclone for B2
        mkdir -p /root/.config/rclone
        cat > /root/.config/rclone/rclone.conf <<EOF
[b2]
type = b2
account = $B2_KEY_ID
key = $B2_KEY
EOF

        # Sync backups
        rclone sync "$BACKUP_DIR/daily/" "b2:$BUCKET/daily/" --progress
        rclone sync "$BACKUP_DIR/weekly/" "b2:$BUCKET/weekly/" --progress
        rclone sync "$BACKUP_DIR/monthly/" "b2:$BUCKET/monthly/" --progress

        log_info "✅ Synced to Backblaze B2"
        ;;

    gcs)
        # Google Cloud Storage
        BUCKET="${GCS_BUCKET:-openclaw-backups}"

        log_info "Syncing to Google Cloud Storage: $BUCKET"

        # Check for gcloud credentials
        if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
            log_error "Google credentials not set"
            echo "Set GOOGLE_APPLICATION_CREDENTIALS"
            exit 1
        fi

        # Install gcloud if not present
        if ! command -v gcloud &> /dev/null; then
            log_info "Installing Google Cloud SDK..."
            curl -s https://sdk.cloud.google.com | bash
        fi

        # Sync backups using gsutil
        gsutil -m rsync -r "$BACKUP_DIR/daily/" "gs://$BUCKET/daily/"
        gsutil -m rsync -r "$BACKUP_DIR/weekly/" "gs://$BUCKET/weekly/"
        gsutil -m rsync -r "$BACKUP_DIR/monthly/" "gs://$BUCKET/monthly/"

        log_info "✅ Synced to Google Cloud Storage"
        ;;

    *)
        log_error "Unknown provider: $PROVIDER"
        echo "Supported providers: s3, b2, gcs"
        exit 1
        ;;
esac

# Send notification
if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] && [[ -n "${ALERT_CHAT_ID:-}" ]]; then
    log_info "Sending notification..."
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="$ALERT_CHAT_ID" \
        -d text="☁️ *OpenClaw Backup Synced*%0A%0AProvider: $PROVIDER%0ATime: $(date)" \
        -d parse_mode="Markdown"
fi

log_info "✅ Cloud sync complete"
