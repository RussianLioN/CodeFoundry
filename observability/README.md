# 📊 Observability — System Prompts

> [🏠 Главная](../../README.md) → [📊 Observability](#)

---

## Overview

Observability stack для мониторинга System Prompts Meta-Generator.

**Stack:**
- **Prometheus** — метрики
- **Alertmanager** — алерты
- **Grafana** — визуализация
- **Node Exporter** — system метрики
- **cAdvisor** — container метрики

---

## 🚀 Quick Start

```bash
# Запустить observability stack
cd observability
docker-compose up -d

# Открыть dashboards
open http://localhost:3001  # Grafana (admin:admin)
open http://localhost:9090  # Prometheus
open http://localhost:9093  # Alertmanager
```

---

## 📈 Dashboards

### System Prompts Overview

**Metrics:**
- Project generation rate (success/failures)
- CI success rate
- Archetype file counts
- System memory usage

**URL:** http://localhost:3001/d/system-prompts-overview

---

## 🚨 Alerts

### Alert Rules

| Alert | Severity | Description |
|-------|----------|-------------|
| `CIPipelineFailing` | warning | CI pipeline failing for >5m |
| `ProjectGenerationFailure` | critical | High failure rate |
| `HighCPUUsage` | warning | CPU >80% for >10m |
| `BrokenDocumentationLinks` | warning | Broken links detected |
| `ArchetypeValidationFailing` | critical | Archetype validation failing |

### Alert Routing

| Severity | Channel | Repeat |
|----------|---------|--------|
| critical | #critical-alerts | 5m |
| warning | #alerts | 12h |
| ci | #ci-cd | 1h |
| docs | #documentation | 24h |
| projects | #projects | 1h |

---

## 📊 Collected Metrics

### Project Generation Metrics

```prometheus
# Total projects generated
project_generation_success_total

# Failed generations
project_generation_failures_total

# Generation duration
project_generation_duration_seconds
```

### CI/CD Metrics

```prometheus
# GitHub Actions success rate
github_actions_success_rate

# Workflow failures
github_actions_workflow_failures

# Build duration
github_actions_build_duration_seconds
```

### System Metrics

```prometheus
# CPU usage
rate(process_cpu_seconds_total[5m])

# Memory usage
process_resident_memory_bytes

# Disk space
node_filesystem_avail_bytes
```

### Documentation Metrics

```prometheus
# Broken links
documentation_broken_links

# Last update
documentation_last_update_timestamp
```

### Archetype Metrics

```prometheus
# File count per archetype
archetype_files_count{archetype="fullstack"}

# Validation status
archetype_validation_status{archetype="...", status="failing"}
```

---

## 🔧 Configuration

### Prometheus

```bash
# Reload config
curl -X POST http://localhost:9090/-/reload

# Check targets
curl http://localhost:9090/api/v1/targets
```

### Alertmanager

```bash
# Reload config
curl -X POST http://localhost:9093/-/reload

# Check alerts
curl http://localhost:9093/api/v2/alerts
```

### Grafana

```bash
# Import dashboard
curl -X POST http://localhost:3001/api/dashboards/import \
  -H "Content-Type: application/json" \
  -d @observability/grafana/dashboards/overview.json
```

---

## 📝 Logging

### Structured Logging

```json
{
  "timestamp": "2025-11-05T12:00:00Z",
  "level": "INFO",
  "logger": "project-generator",
  "message": "Project created successfully",
  "context": {
    "archetype": "fullstack",
    "project_name": "my-saas",
    "duration_ms": 1234
  }
}
```

### Log Levels

- **DEBUG** — Подробная отладочная информация
- **INFO** — Общая информация (создание проекта, sync и т.д.)
- **WARNING** — Предупреждения (например, missing optional files)
- **ERROR** — Ошибки (ошибка генерации, ошибка sync)

---

## 🧪 Testing Alerts

```bash
# Trigger test alert
curl -X POST http://localhost:9093/api/v1/receivers/slack/test

# Check alert status
curl http://localhost:9093/api/v2/alerts
```

---

## 📚 См. Также

- [🏠 Главная](../../README.md)
- [📋 TASKS.md](../../TASKS.md)
- [🦞 OpenClaw](../../openclaw/README.md)

---

> [🏠 Главная](../../README.md) → [📊 Observability](#)
