#!/bin/bash
#
# Initialize OpenClaw volumes on remote server
#
# Creates and sets up all necessary directories and permissions

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

# Base directory
BASE_DIR="/opt/openclaw"

echo "Initializing OpenClaw volumes..."
echo "================================"
echo ""

# Create all directories
echo "Creating directory structure..."

dirs=(
    "$BASE_DIR/workspace"
    "$BASE_DIR/workspace/projects"
    "$BASE_DIR/logs"
    "$BASE_DIR/logs/gateway"
    "$BASE_DIR/logs/bot"
    "$BASE_DIR/logs/ollama"
    "$BASE_DIR/backups"
    "$BASE_DIR/backups/daily"
    "$BASE_DIR/backups/weekly"
    "$BASE_DIR/backups/monthly"
    "$BASE_DIR/data"
    "$BASE_DIR/data/ollama"
    "$BASE_DIR/data/bot"
    "$BASE_DIR/data/redis"
    "$BASE_DIR/data/prometheus"
    "$BASE_DIR/data/grafana"
    "$BASE_DIR/tmp"
    "$BASE_DIR/configs"
    "$BASE_DIR/ssl"
    "$BASE_DIR/monitoring"
    "$BASE_DIR/monitoring/prometheus"
    "$BASE_DIR/monitoring/grafana"
    "$BASE_DIR/monitoring/grafana/provisioning"
    "$BASE_DIR/monitoring/grafana/provisioning/datasources"
    "$BASE_DIR/monitoring/grafana/provisioning/dashboards"
)

for dir in "${dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo "  Created: $dir"
    else
        echo "  Exists: $dir"
    fi
done

echo ""
echo "Setting permissions..."

# Set ownership and permissions
chown -R root:root "$BASE_DIR"
chmod -R 755 "$BASE_DIR"

# Special permissions for writable directories
writable_dirs=(
    "$BASE_DIR/workspace"
    "$BASE_DIR/logs"
    "$BASE_DIR/backups"
    "$BASE_DIR/tmp"
    "$BASE_DIR/data"
)

for dir in "${writable_dirs[@]}"; do
    chmod -R 775 "$dir"
done

# Docker user permissions (if running as non-root)
if id -u docker &> /dev/null; then
    chown -R docker:docker "$BASE_DIR/workspace"
    chown -R docker:docker "$BASE_DIR/logs"
    chown -R docker:docker "$BASE_DIR/data"
fi

echo ""
echo "Creating configuration files..."

# Prometheus config
if [[ ! -f "$BASE_DIR/monitoring/prometheus.yml" ]]; then
    cat > "$BASE_DIR/monitoring/prometheus.yml" <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'openclaw-gateway'
    static_configs:
      - targets: ['gateway:18790']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
    echo "  Created: prometheus.yml"
fi

# Grafana datasources
if [[ ! -f "$BASE_DIR/monitoring/grafana/provisioning/datasources/prometheus.yml" ]]; then
    mkdir -p "$BASE_DIR/monitoring/grafana/provisioning/datasources"
    cat > "$BASE_DIR/monitoring/grafana/provisioning/datasources/prometheus.yml" <<'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
EOF
    echo "  Created: grafana datasource"
fi

# Placeholder for SSL
if [[ ! -f "$BASE_DIR/ssl/README.md" ]]; then
    cat > "$BASE_DIR/ssl/README.md" <<'EOF'
# SSL Certificates

Place your SSL certificates here:

- fullchain.pem
- privkey.pem

Or use Let's Encrypt with certbot:
  certbot certonly --webroot -w /var/www/html -d your-domain.com
EOF
    echo "  Created: SSL README"
fi

echo ""
echo -e "${GREEN}✅ Volume initialization complete!${NC}"
echo ""
echo "Summary:"
echo "  Base directory: $BASE_DIR"
echo "  Workspace: $BASE_DIR/workspace"
echo "  Logs: $BASE_DIR/logs"
echo "  Backups: $BASE_DIR/backups"
echo "  Data: $BASE_DIR/data"
echo ""
echo "Next steps:"
echo "  1. Configure .env file"
echo "  2. Run: docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d"
