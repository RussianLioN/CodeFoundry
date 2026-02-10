# ═════════════════════════════════════════════════════════════════════════════
# Makefile for Microservices Development
# ═══════════════════════════════════════════════════════════════════════════════

SERVICES := auth-service user-service order-service payment-service notification-service analytics-service
PROTO_DIR := shared/proto
GO_PROTO_OUTPUT := shared/pkg/grpc

.PHONY: help
help: ## Show help
	@echo 'Microservices - Development Commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════════════════════
# Development
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: services-up
services-up: ## Start all services locally
	@echo "→ Starting services..."
	docker-compose up -d postgres redis nats kafka
	@echo "✓ Infrastructure started"
	@for service in $(SERVICES); do \
		echo "→ Building $$service..."; \
		cd services/$$service && go build -o ../../bin/$$service ./cmd/main.go && cd ../..; \
	done
	@echo "✓ Services built"

.PHONY: services-down
services-down: ## Stop all services
	@echo "→ Stopping services..."
	docker-compose down
	@echo "✓ Services stopped"

.PHONY: services-logs
services-logs: ## Show services logs
	docker-compose logs -f

.PHONY: services-status
services-status: ## Check services status
	@echo "→ Service health:"
	@curl -s http://localhost:8001/health && echo "✓ auth-service" || echo "✗ auth-service"
	@curl -s http://localhost:8002/health && echo "✓ user-service" || echo "✗ user-service"
	@curl -s http://localhost:8003/health && echo "✓ order-service" || echo "✗ order-service"

# ═══════════════════════════════════════════════════════════════════════════════
# gRPC / Protobuf
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: proto-gen
proto-gen: ## Generate gRPC code from proto files
	@echo "→ Generating Go code from protobuf..."
	@for proto in $$(find $(PROTO_DIR) -name '*.proto'); do \
		protoc \
			--go_out=$(GO_PROTO_OUTPUT) \
			--go_opt=paths=source_relative \
			--go-grpc_out=$(GO_PROTO_OUTPUT) \
			--go-grpc_opt=paths=source_relative \
			--proto_path=$(PROTO_DIR) \
			$$proto; \
	done
	@echo "✓ Generated gRPC code"

.PHONY: proto-lint
proto-lint: ## Lint proto files
	@echo "→ Linting proto files..."
	@for proto in $$(find $(PROTO_DIR) -name '*.proto'); do \
		protolint $$proto; \
	done
	@echo "✓ Proto files linted"

.PHONY: proto-docs
proto-docs: ## Generate proto documentation
	@echo "→ Generating proto docs..."
	@for proto in $$(find $(PROTO_DIR) -name '*.proto'); do \
		protoc \
			--doc_out=docs/api \
			--doc_opt=markdown,$$(basename $$proto .proto).md \
			--proto_path=$(PROTO_DIR) \
			$$proto; \
	done
	@echo "✓ Documentation generated"

# ═══════════════════════════════════════════════════════════════════════════════
# Service Mesh (Istio)
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: mesh-install
mesh-install: ## Install Istio to cluster
	@echo "→ Installing Istio..."
	istioctl install --set profile=default -y
	@echo "✓ Istio installed"

.PHONY: mesh-config
mesh-config: ## Apply Istio configuration
	@echo "→ Applying Istio configuration..."
	kubectl apply -f service-mesh/base/
	@echo "✓ Istio configuration applied"

.PHONY: mesh-dashboard
mesh-dashboard: ## Open Kiali dashboard
	@echo "→ Opening Kiali dashboard..."
	istioctl dashboard kiali

.PHONY: mesh-inject
mesh-inject: ## Enable Istio injection for namespace
	kubectl label namespace default istio-injection=enabled

# ═══════════════════════════════════════════════════════════════════════════════
# API Gateway (Kong)
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: gateway-apply
gateway-apply: ## Apply Kong gateway configuration
	@echo "→ Applying Kong configuration..."
	kubectl apply -f api-gateway/kong/
	@echo "✓ Kong configuration applied"

.PHONY: gateway-routes
gateway-routes: ## Show Kong routes
	@echo "→ Kong routes:"
	http :8001/routes

# ═══════════════════════════════════════════════════════════════════════════════
# Kubernetes
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: k8s-apply
k8s-apply: ## Apply Kubernetes manifests
	@echo "→ Applying Kubernetes manifests..."
	kubectl apply -k k8s/overlays/development
	@echo "✓ Manifests applied"

.PHONY: k8s-delete
k8s-delete: ## Delete Kubernetes resources
	@echo "→ Deleting Kubernetes resources..."
	kubectl delete -k k8s/overlays/development
	@echo "✓ Resources deleted"

.PHONY: k8s-status
k8s-status: ## Show Kubernetes status
	@echo "→ Pods:"
	kubectl get pods -A
	@echo ""
	@echo "→ Services:"
	kubectl get svc -A

.PHONY: k8s-logs
k8s-logs: ## Show logs for service (SERVICE=name)
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make k8s-logs SERVICE=auth-service"; \
		exit 1; \
	fi
	kubectl logs -l app=$(SERVICE) -f --all-containers

# ═══════════════════════════════════════════════════════════════════════════════
# Deployment
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: deploy-all
deploy-all: ## Deploy all services to Kubernetes
	@echo "→ Deploying all services..."
	@for service in $(SERVICES); do \
		echo "→ Deploying $$service..."; \
		cd services/$$service && docker build -t $$service:latest . && cd ../..; \
	done
	kubectl apply -k k8s/overlays/production
	@echo "✓ All services deployed"

.PHONY: deploy-staging
deploy-staging: ## Deploy to staging
	kubectl apply -k k8s/overlays/staging

.PHONY: rollout
rollout: ## Rollout restart (SERVICE=name)
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make rollout SERVICE=auth-service"; \
		exit 1; \
	fi
	kubectl rollout restart deployment/$(SERVICE)

# ═══════════════════════════════════════════════════════════════════════════════
# Testing
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: test-unit
test-unit: ## Run unit tests for all services
	@echo "→ Running unit tests..."
	@for service in $(SERVICES); do \
		echo "→ Testing $$service..."; \
		cd services/$$service && go test ./... -cover -coverprofile=coverage.out && cd ../..; \
	done
	@echo "✓ Unit tests passed"

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "→ Running integration tests..."
	docker-compose up -d postgres redis nats
	@for service in $(SERVICES); do \
		echo "→ Testing $$service..."; \
		cd services/$$service && go test -tags=integration ./... && cd ../..; \
	done
	@echo "✓ Integration tests passed"

.PHONY: test-contracts
test-contracts: ## Run contract tests (Pact)
	@echo "→ Running contract tests..."
	@for service in $(SERVICES); do \
		cd services/$$service && go test -tags=pact ./... && cd ../..; \
	done
	@echo "✓ Contract tests passed"

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests
	@echo "→ Running E2E tests..."
	go test ./tests/e2e/... -v

# ═══════════════════════════════════════════════════════════════════════════════
# Observability
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: observability-up
observability-up: ## Start observability stack
	@echo "→ Starting observability..."
	docker-compose up -d prometheus grafana jaeger
	@echo "✓ Observability started"
	@echo "→ Grafana: http://localhost:3000"
	@echo "→ Jaeger: http://localhost:16686"
	@echo "→ Prometheus: http://localhost:9090"

.PHONY: dashboards-apply
dashboards-apply: ## Apply Grafana dashboards
	@echo "→ Applying Grafana dashboards..."
	kubectl apply -f observability/grafana/dashboards/
	@echo "✓ Dashboards applied"

# ═══════════════════════════════════════════════════════════════════════════════
# Database
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: db-migrate
db-migrate: ## Run database migrations
	@echo "→ Running migrations..."
	@for service in $(SERVICES); do \
		if [ -f services/$$service/migrations/ ]; then \
			echo "→ Migrating $$service..."; \
			cd services/$$service && go run cmd/migrate/main.go up && cd ../..; \
		fi; \
	done
	@echo "✓ Migrations complete"

.PHONY: db-rollback
db-rollback: ## Rollback last migration (SERVICE=name)
	@if [ -z "$(SERVICE)" ]; then \
		echo "Usage: make db-rollback SERVICE=auth-service"; \
		exit 1; \
	fi
	cd services/$(SERVICE) && go run cmd/migrate/main.go down

# ═══════════════════════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean build artifacts
	@echo "→ Cleaning..."
	rm -rf bin/
	docker-compose down -v
	@echo "✓ Cleaned"

.DEFAULT_GOAL := help
