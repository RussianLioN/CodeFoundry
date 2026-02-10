# 📊 Skill: Monitoring

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🚀 DevOps Skills](#)

---

## Description

Настройка и управление мониторингом приложений, инфраструктуры и бизнес-метрик с интеграцией популярных систем наблюдаемости.

---

## 🎯 Capabilities

### 📈 Metrics Collection

**Использование:**
```
👤 "Настрой мониторинг для приложения"
👤 "Добавь метрики CPU и памяти"
👤 "Создай дашборд для API"
```

**Типы метрик:**
- **System** — CPU, Memory, Disk, Network
- **Application** — Request rate, Latency, Error rate
- **Business** — Orders per minute, Active users, Revenue
- **Custom** — Domain-specific metrics

---

### 🔔 Alerting

**Использование:**
```
👤 "Настрой алерты на высокие latency"
👤 "Создай алерт если диск заполнен"
👤 "Отправляй уведомления в Telegram"
```

**Типы алертов:**
- **Threshold** — Превышение порогового значения
- **Anomaly** — Аномальное поведение
- **Rate** — Скорость изменения
- **Composite** — Сложные условия

---

### 📊 Dashboards

**Использование:**
```
👤 "Создай дашборд для мониторинга"
👤 "Покажи графики производительности"
👤 "Добавь график запросов в секунду"
```

**Виды дашбордов:**
- **System Overview** — Общее состояние системы
- **Application Performance** — Метрики приложения
- **Business Metrics** — Бизнес-показатели
- **Incident Response** — Для troubleshooting

---

## 🔧 Supported Systems

| Система | Тип | Особенности |
|---------|-----|-------------|
| **Prometheus** | Metrics | Time series DB,Pull model,Alertmanager |
| **Grafana** | Dashboards | Визуализация,алерты,plugins |
| **Loki** | Logs | Aggregated logging,Like Prometheus |
| **Tempo** | Tracing | Distributed tracing |
| **ELK Stack** | Logs | Elasticsearch,Logstash,Kibana |
| **Datadog** | APM | SaaS,All-in-one,APM |
| **New Relic** | APM | SaaS,APM,Browser monitoring |
| **CloudWatch** | Metrics | AWS native,Logs,Metrics |

---

## 📦 Prometheus Configuration

### prometheus.yml

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'production'
    environment: 'eu-west-1'

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

# Rule files
rule_files:
  - 'alerts/*.yml'

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter - system metrics
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: 'server-01'

  # Application metrics
  - job_name: 'myapp'
    static_configs:
      - targets: ['myapp:3000']
    metrics_path: '/metrics'
    scrape_interval: 10s

  # Kubernetes pods
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

---

## 🚨 Alert Rules

### alerts/rules.yml

```yaml
groups:
  - name: system_alerts
    interval: 30s
    rules:
      # High CPU usage
      - alert: HighCPUUsage
        expr: (100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 80
        for: 5m
        labels:
          severity: warning
          team: devops
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes (current: {{ $value }}%)"

      # High memory usage
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 85% (current: {{ $value }}%)"

      # Disk space low
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 15
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "Disk space low on {{ $labels.instance }}"
          description: "Disk space is below 15% (current: {{ $value }}%)"

  - name: application_alerts
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: (rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100 > 5
        for: 5m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "High error rate"
          description: "Error rate is above 5% for 5 minutes (current: {{ $value }}%)"

      # High latency
      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P95 latency is above 1s (current: {{ $value }}s)"

      # Service down
      - alert: ServiceDown
        expr: up{job="myapp"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "Service has been down for 2 minutes"
```

---

## 🎨 Grafana Dashboards

### Dashboard JSON Template

```json
{
  "dashboard": {
    "title": "Application Overview",
    "tags": ["app", "production"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ]
      },
      {
        "id": 2,
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m])",
            "legendFormat": "Errors"
          }
        ]
      },
      {
        "id": 3,
        "title": "P95 Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "P95"
          }
        ]
      }
    ]
  }
}
```

---

## 📝 Application Metrics

### Node.js (Prometheus Client)

```javascript
const promClient = require('prom-client');

// Create registry
const register = new promClient.Registry();

// Default metrics (CPU, memory, etc.)
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status']
});

// Middleware
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || 'unknown', res.statusCode)
      .observe(duration);
    httpRequestsTotal
      .labels(req.method, req.route?.path || 'unknown', res.statusCode)
      .inc();
  });

  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### Python (FastAPI)

```python
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Histogram

# Custom metrics
request_count = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

# Setup
app = FastAPI()

Instrumentator().instrument(app).expose(app)

# Usage in endpoints
@app.get("/api/users")
async def get_users():
    with request_duration.labels('GET', '/api/users').time():
        # Your logic here
        result = await fetch_users()
        request_count.labels('GET', '/api/users', 200).inc()
        return result
```

---

## 🔔 Alert Notifications

### Alertmanager Configuration

```yaml
global:
  resolve_timeout: 5m
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
  telegram_api_url: 'https://api.telegram.org/bot{token}/sendMessage'

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'

  routes:
    - match:
        severity: critical
      receiver: 'critical-alerts'
      continue: true

    - match:
        severity: warning
      receiver: 'warning-alerts'

receivers:
  - name: 'default'
    slack_configs:
      - channel: '#alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

  - name: 'critical-alerts'
    slack_configs:
      - channel: '#critical'
    telegram_configs:
      - bot_token: 'YOUR_BOT_TOKEN'
        chat_id: 123456789
        message: '🚨 CRITICAL: {{ .GroupLabels.alertname }}'

  - name: 'warning-alerts'
    slack_configs:
      - channel: '#warnings'
```

---

## 📊 Logging Strategy

### Loki Configuration

```yaml
server:
  http_listen_port: 3100

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: myapp
    static_configs:
      - targets:
          - localhost
        labels:
          job: myapp
          __path__: /var/log/myapp/*.log

    pipeline_stages:
      - json:
          expressions:
            level: level
            message: message
            timestamp: time

      - labels:
          level:

      - timestamp:
          source: timestamp
          format: RFC3339
```

---

## 📝 Usage Examples

### Сценарий 1: Базовый мониторинг

```
👤 "Настрой Prometheus + Grafana для моего приложения"

🤖 Monitoring Skill:
    1. 📋 Analysing application stack...
    2. ✅ Detected: Node.js + Express
    3. 📦 Creating configs:
       - prometheus.yml (scrape config)
       - alerts/rules.yml (alert rules)
       - grafana/dashboards/app.json (dashboard)
    4. 🐳 Adding docker-compose.yml with:
       - prometheus
       - grafana
       - node-exporter
       - alertmanager
    5. ✅ Monitoring stack ready
    6. 🌐 Access at: http://localhost:3000 (Grafana)
```

### Сценарий 2: Алерты

```
👤 "Настрой алерты и отправку в Telegram"

🤖 Monitoring Skill:
    1. 📝 Creating alertmanager.yml...
    2. 📋 Adding alert rules:
       - Service down (critical)
       - High error rate (critical)
       - High latency (warning)
    3. 📱 Configuring Telegram bot...
    4. ✅ Alerts configured
    5. 💬 Test alert sent to verify setup
```

### Сценарий 3: Voice Command

```
🗣️ "Добавь мониторинг базы данных"

🤖 Monitoring Skill:
    1. 📋 Adding database monitoring...
    2. 📦 Created configs:
       - postgres_exporter scrape config
       - DB metrics dashboard
       - Alert rules for:
         • Connection pool exhaustion
         • Slow queries
         • Replication lag
    3. ✅ DB monitoring enabled
```

---

## 🔗 Integration with Tools

Использует инструменты:
- **write** — создание конфигураций
- **read** — чтение существующих настроек
- **bash** — запуск сервисов
- **docker** — развертывание стека мониторинга

---

## 🔗 Voice Commands

| Голосовая команда | Действие |
|-------------------|----------|
| "Настрой мониторинг" | Настройка Prometheus + Grafana |
| "Добавь алерты" | Создание alert rules |
| "Создай дашборд" | Генерация Grafana dashboard |
| "Покажи метрики" | Отображение текущих метрик |
| "Настрой логирование" | Настройка Loki |

---

## 🛡️ Best Practices

### 1. USE Method (Utilization, Saturation, Errors)

```yaml
# Utilization - насколько ресурс используется
rate(node_cpu_seconds_total{mode!="idle"}[5m])

# Saturation - насколько ресурс перегружен
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes

# Errors - количество ошибок
rate(http_requests_total{status=~"5.."}[5m])
```

### 2. RED Method (Rate, Errors, Duration)

```yaml
# Rate - запросов в секунду
rate(http_requests_total[5m])

# Errors - процент ошибок
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Duration - latency (P95)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### 3. Label Cardinality

```yaml
# ❌ Плохо - слишком много label значений
http_requests_total{user_id="12345"}

# ✅ Хорошо - ограниченные label значения
http_requests_total{method="GET", status="200", route="/api/users"}
```

---

## 📚 См. Также

- [🚀 DevOps Skills Index](../README.md)
- [🐳 Docker Deploy](docker-deploy.md)
- [🚀 CI Pipeline](ci-pipeline.md)
- [🎯 Workspace](../README.md)
- [🤖 Agents](../AGENTS.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [📊 Monitoring](#)
