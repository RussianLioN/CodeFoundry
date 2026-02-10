# ═════════════════════════════════════════════════════════════════════════════
# 🏗️ Microservices Archetype
# ═══════════════════════════════════════════════════════════════════════════════

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🏗️ Microservices](#)

---

## Overview

Архетип для production-ready микросервисной архитектуры.

**Stack:**
- **Services:** Go (micro/gRPC) / Python (FastAPI)
- **Service Mesh:** Istio / Linkerd
- **API Gateway:** Kong / Envoy Gateway
- **Message Broker:** NATS / Kafka / RabbitMQ
- **Service Discovery:** Consul / Kubernetes native
- **Observability:** OpenTelemetry + Jaeger + Prometheus

---

## 🎯 Когда Использовать

✅ **Подходит для:**
- Enterprise приложения
- High-scale distributed systems
- Multi-team development
- Complex domain requirements
- Need for independent deployments

❌ **Не подходит для:**
- Простые CRUD → Web Service Archetype
- Monolith → Mobile/Monolith Archetype
- Startups/MVP → Web Service Archetype

---

## 📁 Структура Проекта

```
microservices/
├── services/                  # Микросервисы
│   ├── auth-service/         # Authentication & Authorization
│   ├── user-service/         # User management
│   ├── order-service/        # Order processing
│   ├── payment-service/      # Payment integration
│   ├── notification-service/ # Notifications (email, SMS, push)
│   └── analytics-service/    # Analytics & reporting
├── shared/                    # Общий код
│   ├── pkg/                  # Go packages
│   │   ├── grpc/             # gRPC proto definitions
│   │   ├── events/           # Domain events
│   │   ├── middleware/       # Shared middleware
│   │   └── errors/           # Error types
│   └── config/               # Shared configurations
├── api-gateway/               # API Gateway (Kong/Envoy)
├── service-mesh/              # Istio configuration
│   ├── base/                 # Base Istio config
│   ├── overlays/             # Environment-specific
│   └── policies/             # Security, traffic policies
├── messaging/                 # Message broker config
│   ├── nats/                 # NATS streams
│   ├── kafka/                # Kafka topics
│   └── schemas/              # Event schemas (Avro/JSON Schema)
├── observability/             # Monitoring & tracing
│   ├── opentelemetry/        # OTEL collectors
│   ├── jaeger/              # Distributed tracing
│   ├── prometheus/          # Metrics
│   └── grafana/             # Dashboards
├── db-migrations/             # Database migrations
├── k8s/                       # Kubernetes manifests
│   ├── base/                 # Base manifests
│   ├── overlays/             # Environments (staging, prod)
│   └── helm/                 # Helm charts
├── scripts/                   # Utility scripts
├── openclaw/                  # OpenClaw configuration
│   └── workspace/AGENTS.md
├── docker-compose.yml         # Local development
└── README.md
```

---

## 🚀 Quick Start

**Через CodeFoundry (рекомендуется):**
```bash
cd CodeFoundry
make new ARCHETYPE=microservices NAME=my-platform
cd my-platform
```

**Вручную:**
```bash
cp -r /path/to/CodeFoundry/templates/archetypes/microservices ~/projects/my-platform
cd ~/projects/my-platform
git init
```

---

## 🏛️ Architecture Principles

### 1. Bounded Contexts

Каждый микросервис = один bounded context (DDD):

```
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway                            │
│                   (Kong / Envoy)                            │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        ▼           ▼           ▼           ▼
┌─────────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐
│   Auth      │ │  User   │ │ Order   │ │ Payment   │
│  Service    │ │Service  │ │Service  │ │ Service   │
└─────────────┘ └─────────┘ └─────────┘ └───────────┘
        │             │          │             │
        └─────────────┴──────────┴─────────────┘
                      │
        ┌─────────────┴─────────────┐
        ▼                           ▼
┌─────────────┐           ┌───────────────────┐
│  Database   │           │   Message Broker  │
│  (Postgres) │           │  (NATS/Kafka)     │
└─────────────┘           └───────────────────┘
```

### 2. Communication Patterns

**Synchronous (gRPC/REST):**
```go
// gRPC definition
service UserService {
    rpc GetUser(GetUserRequest) returns (User);
    rpc ListUsers(ListUsersRequest) returns (UserList);
    rpc CreateUser(CreateUserRequest) returns (User);
}
```

**Asynchronous (Event-driven):**
```go
// Domain event
type UserCreatedEvent struct {
    UserID    string    `json:"user_id"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}

// Publish to NATS
nc.Publish("users.created", event)
```

### 3. Data Ownership

**Правило:** Одна таблица = один владелец

| Service | Owned Tables | Read Access |
|---------|--------------|-------------|
| auth-service | users, sessions | - |
| user-service | profiles, preferences | users (read-only) |
| order-service | orders, order_items | users (read-only) |
| payment-service | payments, transactions | - |

---

## 🔐 Service Mesh (Istio)

### Traffic Management

```yaml
# service-mesh/virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service
spec:
  hosts:
  - user-service
  http:
  - match:
    - headers:
        x-canary:
          exact: "true"
    route:
    - destination:
        host: user-service
        subset: v2  # Canary version
      weight: 100
  - route:
    - destination:
        host: user-service
        subset: v1  # Stable version
      weight: 100
```

### Circuit Breaker

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: user-service-cb
spec:
  host: user-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
```

### Security (mTLS)

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT  # All services must use mTLS
```

---

## 📡 API Gateway (Kong)

### Route Configuration

```yaml
# api-gateway/kong/routes.yaml
routes:
  - name: auth-service
    paths:
      - /v1/auth
      - /v1/users
    service: auth-service
    plugins:
      - rate-limiting
      - jwt-auth
      - cors

  - name: order-service
    paths:
      - /v1/orders
    service: order-service
    plugins:
      - rate-limiting
      - acl
      - request-transformer
```

### Plugins

**Rate Limiting:**
```yaml
rate_limiting:
  minute: 100
  hour: 1000
  policy: redis
  redis_host: redis
  redis_port: 6379
```

**JWT Authentication:**
```yaml
jwt:
  key_claim_name: kid
  claims_to_verify:
    - exp
```

---

## 🔄 Event-Driven Communication

### NATS JetStream

```go
// Publishing events
nc, _ := nats.Connect(nats.DefaultURL)
js, _ := jetstream.New(nc)

// Create stream
js.CreateStream(jetstream.StreamConfig{
    Name:     "ORDERS",
    Subjects: []string{"orders.>"},
})

// Publish event
js.Publish("orders.created", orderEvent)

// Subscribe (consumer group)
js.Subscribe("orders.>", func(msg *nats.Msg) {
    handleOrderCreated(msg)
}, nats.Durable("order-processor"), nats.ManualAck())
```

### Event Schemas (Avro)

```avro
{
  "type": "record",
  "name": "OrderCreated",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "user_id", "type": "string"},
    {"name": "items", "type": {
      "type": "array",
      "items": {
        "type": "record",
        "name": "OrderItem",
        "fields": [
          {"name": "product_id", "type": "string"},
          {"name": "quantity", "type": "int"},
          {"name": "price", "type": "double"}
        ]
      }
    }},
    {"name": "total", "type": "double"},
    {"name": "created_at", "type": "long"}
  ]
}
```

---

## 🔍 Distributed Tracing (OpenTelemetry)

### Go Service

```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/jaeger"
    "go.opentelemetry.io/otel/sdk/trace"
)

func initTracing() {
    exporter, _ := jaeger.New(jaeger.WithCollectorEndpoint())
    tp := trace.NewTracerProvider(trace.WithBatcher(exporter))
    otel.SetTracerProvider(tp)
}

// In handler
func (s *Service) HandleOrder(ctx context.Context, req *CreateOrderRequest) (*Order, error) {
    ctx, span := otel.Tracer("order-service").Start(ctx, "CreateOrder")
    defer span.End()

    // Traced database call
    order, err := s.repo.Create(ctx, req)
    if err != nil {
        span.RecordError(err)
        return nil, err
    }

    // Traced gRPC call
    user, err := s.userServiceClient.GetUser(ctx, order.UserID)
    span.SetAttributes(
        attribute.String("user.email", user.Email),
    )

    return order, nil
}
```

### Python Service

```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider

jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
)

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# In handler
def create_order(request):
    with tracer.start_as_current_span("CreateOrder") as span:
        try:
            order = repo.create(request)
            span.set_attribute("order.id", order.id)
            return order
        except Exception as e:
            span.record_exception(e)
            raise
```

---

## 🧪 Testing Strategy

### Contract Testing (Pact)

```go
// Consumer test (order-service expects user-service to respond)
func TestUserServiceContract(t *testing.T) {
    pact := &dsl.Pact{
        Consumer: "OrderService",
        Provider: "UserService",
    }

    pact.AddInteraction().
        Given("User exists").
        UponReceiving("A request for user").
        WithRequest(dsl.Request{
            Method: "GET",
            Path:   dsl.String("/v1/users/123"),
        }).
        WillRespondWith(dsl.Response{
            Status: 200,
            Body: dsl.Like(map[string]interface{}{
                "id":    dsl.String("123"),
                "email": dsl.Like("user@example.com"),
            }),
        })

    pact.Verify(t)
}
```

### Integration Tests (Testcontainers)

```go
func TestOrderServiceIntegration(t *testing.T) {
    // Start Postgres container
    postgres, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: testcontainers.ContainerRequest{
            Image:        "postgres:16",
            ExposedPorts: []string{"5432/tcp"},
            Env: map[string]string{
                "POSTGRES_DB": "testdb",
            },
        },
        Started: true,
    })

    // Start NATS container
    nats, _ := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: testcontainers.ContainerRequest{
            Image:        "nats:latest",
            ExposedPorts: []string{"4222/tcp"},
        },
        Started: true,
    })

    // Run tests against real services
    service := NewOrderService(postgres.ConnectionString, nats.ConnectionString)
    // ... test logic
}
```

---

## 🚀 Deployment Strategies

### Blue-Green Deployment

```yaml
# k8s/overlays/production/blue-green.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: user-service
spec:
  replicas: 4
  strategy:
    blueGreen:
      activeService: user-service-active
      previewService: user-service-preview
      autoPromotionEnabled: false
      scaleDownDelaySeconds: 30
```

### Canary Deployment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: user-service
spec:
  replicas: 10
  strategy:
    canary:
      steps:
      - setWeight: 10    # 10% traffic to canary
      - pause: {duration: 10m}
      - setWeight: 25    # 25% traffic
      - pause: {duration: 10m}
      - setWeight: 50    # 50% traffic
      - pause: {duration: 10m}
      - setWeight: 100   # 100% traffic
      analysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: user-service
```

---

## 🤖 OpenClaw Integration

См. [🤖 Agents](openclaw/workspace/AGENTS.md) для multi-agent конфигурации:

**6 агентов:**
- **Main Agent** — координатор
- **Dev Agent** — разработка сервисов
- **DevOps Agent** — infrastructure
- **Review Agent** — code review
- **SRE Agent** — reliability, SLO
- **Architect Agent** — system design

---

## 📋 Make Commands

| Команда | Описание |
|---------|----------|
| `make proto` | Генерировать gRPC код из proto |
| `make services-up` | Запустить все сервисы локально |
| `make services-down` | Остановить сервисы |
| `make mesh-install` | Установить Istio |
| `make mesh-config` | Применить Istio конфигурацию |
| `make test-contracts` | Запустить contract тесты |
| `make test-integration` | Интеграционные тесты |
| `make deploy-all` | Деплой всех сервисов |

---

## 📚 См. Также

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)
- [📋 Все Архетипы](../README.md)

### OpenClaw Integration
- [🦞 OpenClaw README](../../../openclaw/README.md)
- [🎯 Workspace](../../../openclaw/workspace/README.md)
- [🤖 Agents](../../../openclaw/workspace/AGENTS.md)
- [🎨 Skills Index](../../../openclaw/workspace/SKILLS-INDEX.md)

### Related Archetypes
- [🌐 Web Service Archetype](../web-service/README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.1.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs, quick start |
| 1.0.0 | 2025-11-05 | Первая версия Microservices archetype |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🏗️ Microservices](#)
