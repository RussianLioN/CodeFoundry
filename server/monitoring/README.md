# 📊 CodeFoundry Monitoring Stack

> Monitoring and logging for ainetic.tech testing infrastructure

---

## Overview

The monitoring stack provides:

- **Metrics Collection** via Prometheus
- **Visualization** via Grafana
- **Container Metrics** via cAdvisor
- **System Metrics** via Node Exporter
- **Log Aggregation** via Vector

---

## Quick Start

### Start Monitoring Stack

```bash
cd ~/projects/system-prompts/server
docker-compose -f docker-compose.monitoring.yml up -d
```

### Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://ainetic.tech:3000 | admin/admin |
| Prometheus | http://ainetic.tech:9090 | - |
| cAdvisor | http://ainetic.tech:8080 | - |
| Vector API | http://ainetic.tech:8686 | - |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐  │
│  │  Grafana    │  │ Prometheus  │  │     Vector       │  │
│  │  :3000      │←→│  :9090      │←→│  :8686 (API)    │  │
│  │             │  │             │  │  :9598 (metrics) │  │
│  └─────────────┘  └──────┬──────┘  └────────┬───────────┘  │
│                          │                   │              │
│                    ┌─────┴─────┐       ┌─────┴─────┐       │
│                    │  Alerts  │       │   Logs    │       │
│                    └───────────┘       └───────────┘       │
│                                                          │
├───────────────────────────────────────────────────────────┤
│  Test Network (codefoundry-test-net)                      │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐             │
│  │ Gateway  │  │ Bot      │  │ TestRunner  │             │
│  │ :18789   │  │          │  │             │             │
│  └──────────┘  └──────────┘  └────────────┘             │
└───────────────────────────────────────────────────────────┘
```

---

## Components

### Prometheus

**Configuration:** `prometheus/prometheus.yml`

**Scrapes:**
- Gateway metrics (`:18790/metrics`)
- Bot metrics (`:3000/metrics`)
- cAdvisor container metrics
- Node Exporter system metrics
- Ollama metrics (if enabled)

**Retention:** 7 days, 1GB max

**Alert Rules:** `prometheus/alerts/testing-alerts.yml`

### Grafana

**Dashboards:** `grafana/dashboards/testing.json`

**Panels:**
- Gateway/Bot status (UP/DOWN)
- Request rate (req/s)
- Memory usage %
- Test failure rate
- Test duration (p50, p95)
- Container distribution

**Provisioning:** Auto-loaded on start

### cAdvisor

**Container Metrics:**
- CPU usage
- Memory usage
- Network I/O
- Disk I/O
- Container lifecycle events

### Node Exporter

**System Metrics:**
- CPU (load, usage)
- Memory (free, used, cached)
- Disk (usage, I/O)
- Network (traffic, errors)
- System info

### Vector

**Log Sources:**
- Docker container logs
- Gateway logs (`/workspace/openclaw/gateway/logs/`)
- Bot logs (`/workspace/openclaw/telegram-bot/logs/`)
- Test logs (`/var/log/tests/`)

**Log Sinks:**
- `/var/log/codefoundry/all-YYYY-MM-DD.log`
- `/var/log/codefoundry/errors-YYYY-MM-DD.log`
- `/var/log/codefoundry/gateway-YYYY-MM-DD.log`
- `/var/log/codefoundry/bot-YYYY-MM-DD.log`
- `/var/log/codefoundry/tests-YYYY-MM-DD.log`

**Features:**
- JSON structured logs
- Sensitive data filtering
- Log rotation (10 files)
- Gzip compression

---

## Alert Rules

### Container Health
- `ContainerDown` - Container unreachable for 2m
- `ContainerUnhealthy` - Health check failing for 5m
- `ContainerRestarting` - Frequent restarts

### Resource Usage
- `HighMemoryUsage` - Memory > 90% for 5m
- `HighCPUUsage` - CPU > 80% for 10m
- `DiskSpaceLow` - Disk < 10%

### Test Execution
- `TestFailureRate` - Failure rate > 30%
- `TestExecutionTimeout` - p95 > 5min
- `NoTestExecution` - No tests for 1 hour

### Gateway
- `GatewayDown` - Gateway unreachable
- `GatewayHighConnections` - > 100 connections
- `GatewayErrorRate` - Error rate > 5%

### Telegram Bot
- `TelegramBotDown` - Bot unreachable
- `TelegramBotAPIErrors` - API error rate elevated
- `NoTelegramActivity` - No activity for 2 hours

---

## Management Commands

### Start/Stop

```bash
# Start all
docker-compose -f docker-compose.monitoring.yml up -d

# Stop all
docker-compose -f docker-compose.monitoring.yml down

# Restart service
docker-compose -f docker-compose.monitoring.yml restart grafana

# View logs
docker-compose -f docker-compose.monitoring.yml logs -f
```

### Metrics

```bash
# Query Prometheus
curl 'http://localhost:9090/api/v1/query?query=up{job=~"codefoundry-.*"}' | jq

# Check Prometheus targets
curl 'http://localhost:9090/api/v1/targets' | jq

# Vector health
curl http://localhost:8686/health
```

### Logs

```bash
# View Vector logs
docker logs -f codefoundry-vector

# View aggregated logs
tail -f /var/log/codefoundry/all-$(date +%Y-%m-%d).log

# View error logs
tail -f /var/log/codefoundry/errors-$(date +%Y-%m-%d).log

# Search logs (requires jq)
jq 'select(.level == "ERROR")' /var/log/codefoundr/all-*.log
```

---

## Grafana Setup

### Initial Login

1. Open http://ainetic.tech:3000
2. Login: `admin` / `admin`
3. Change password on first login

### Import Dashboard

The testing dashboard is auto-provisioned. To view:

1. Home → Dashboards → CodeFoundry → Remote Testing
2. Or: http://ainetic.tech:3000/d/codefoundry-testing

### Create Custom Dashboard

1. Create → Dashboard
2. Add panels with Prometheus queries
3. Save as JSON to `grafana/dashboards/`

---

## Troubleshooting

### Grafana not connecting to Prometheus

```bash
# Check network
docker network inspect codefoundry-monitoring

# Check Prometheus
curl http://localhost:9090/api/v1/targets

# Check Grafana logs
docker logs codefoundry-grafana
```

### No metrics from containers

```bash
# Check cAdvisor
curl http://localhost:8080/healthz

# Check container labels
docker inspect codefoundry-test-gateway | jq '.[0].Config.Labels'

# Check Prometheus config
docker exec codefoundry-prometheus cat /etc/prometheus/prometheus.yml
```

### Vector not ingesting logs

```bash
# Check Vector config
docker exec codefoundry-vector cat /etc/vector/vector.toml

# Check Vector logs
docker logs codefoundry-vector

# Test Vector API
curl http://localhost:8686/health
```

### High disk usage

```bash
# Check Prometheus data size
du -sh /var/lib/docker/volumes/codefoundry-prometheus

# Reduce retention (edit prometheus.yml)
--storage.tsdb.retention.time=3d

# Clean old logs
find /var/log/codefoundry -name "*.gz" -mtime +7 -delete
```

---

## Advanced Configuration

### Enable Alertmanager

Uncomment in `docker-compose.monitoring.yml`:

```yaml
alertmanager:
  image: prom/alertmanager:v0.26.0
  ...
```

Configure alerts in `alertmanager/alertmanager.yml`.

### Enable Loki

Uncomment in `vector/vector.toml`:

```toml
[sinks.loki]
type = "loki"
endpoint = "http://loki:3100"
...
```

Add Loki to monitoring stack:

```yaml
loki:
  image: grafana/loki:2.9.2
  ...
```

---

## Performance Tuning

### Prometheus

- Reduce `scrape_interval` for less frequent scraping
- Reduce `retention.time` for less disk usage
- Enable `--enable-feature=remote-write-receiver` for federation

### Vector

- Increase `batch.max_events` for higher throughput
- Enable `compression = "gzip"` for network efficiency
- Use `remap` transforms for complex parsing

---

## Security Notes

1. **Change default Grafana password** on first login
2. **Restrict network access** to monitoring ports
3. **Use TLS** for production (add nginx reverse proxy)
4. **Rotate API keys** regularly
5. **Audit logs** for access monitoring

---

## Related Documentation

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [Vector Docs](https://vector.dev/docs/)
- [cAdvisor Docs](https://github.com/google/cadvisor)

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
