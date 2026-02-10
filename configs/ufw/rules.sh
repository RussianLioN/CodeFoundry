#!/bin/bash
#
# OpenClaw UFW Firewall Rules
#
# Configure firewall for OpenClaw remote server

set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

echo "Configuring UFW firewall for OpenClaw..."

# Reset to default (be careful!)
ufw --force reset

# Default policies
ufw default deny incoming
ufw default allow outgoing

# SSH - CRITICAL! Allow your IP only if possible
ufw allow 22/tcp comment 'SSH from anywhere'
# Or restrict to your IP:
# uw allow from YOUR_IP_ADDRESS to any port 22 proto tcp comment 'SSH from my IP'

# HTTP/HTTPS
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

# OpenClaw Gateway (if direct access needed - not required with Nginx)
# ufw allow 18789/tcp comment 'OpenClaw Gateway WebSocket'
# ufw allow 18790/tcp comment 'OpenClaw Gateway Health'

# Metrics (restrict to specific IPs!)
# ufw allow from 10.0.0.0/8 to any port 18791 proto tcp comment 'Prometheus metrics from internal network'

# Docker networks (internal)
ufw allow from 172.16.0.0/12
ufw allow from 172.17.0.0/16
ufw allow from 172.18.0.0/16

# Enable firewall
echo "y" | ufw enable

echo -e "${GREEN}✅ Firewall configured${NC}"
ufw status verbose
