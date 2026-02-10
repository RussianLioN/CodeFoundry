# ═══════════════════════════════════════════════════════════════════════════════
# Makefile for Web Service Development
# ═══════════════════════════════════════════════════════════════════════════════
# Convenient commands for development, testing, and deployment
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# Variables
# ═══════════════════════════════════════════════════════════════════════════════

PROJECT_NAME := my-api
DOCKER_REGISTRY := docker.io/myuser
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Colors
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m

# ═══════════════════════════════════════════════════════════════════════════════
# Help
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: help
help: ## Show this help message
	@echo '$(PROJECT_NAME) - Makefile commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_BLUE)%-20s$(COLOR_RESET) %s\n", $$1, $$2}'
	@echo ''

# ═══════════════════════════════════════════════════════════════════════════════
# Development
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: init
init: ## Initialize project
	@echo "$(COLOR_GREEN)→ Initializing project...$(COLOR_RESET)"
	@if [ ! -f .env ]; then cp .env.example .env && echo "Created .env from .env.example"; fi
	@npm install
	@echo "$(COLOR_GREEN)✓ Project initialized$(COLOR_RESET)"

.PHONY: dev
dev: ## Start development environment with docker-compose
	@echo "$(COLOR_GREEN)→ Starting development environment...$(COLOR_RESET)"
	docker-compose -f docker/docker-compose.yml up --build

.PHONY: dev-local
dev-local: ## Start development server locally (requires Node.js)
	@echo "$(COLOR_GREEN)→ Starting local development server...$(COLOR_RESET)"
	npm run dev

.PHONY: install
install: ## Install dependencies
	@echo "$(COLOR_GREEN)→ Installing dependencies...$(COLOR_RESET)"
	npm install

# ═══════════════════════════════════════════════════════════════════════════════
# Building
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: build
build: ## Build Docker image
	@echo "$(COLOR_GREEN)→ Building Docker image...$(COLOR_RESET)"
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg BUILD_TIME=$(BUILD_TIME) \
		--build-arg GIT_COMMIT=$(GIT_COMMIT) \
		-f docker/Dockerfile \
		-t $(DOCKER_REGISTRY)/$(PROJECT_NAME):$(VERSION) \
		-t $(DOCKER_REGISTRY)/$(PROJECT_NAME):latest \
		.

.PHONY: build-dev
build-dev: ## Build development Docker image
	@echo "$(COLOR_GREEN)→ Building development image...$(COLOR_RESET)"
	docker build \
		-f docker/Dockerfile.dev \
		-t $(PROJECT_NAME):dev \
		.

.PHONY: compile
compile: ## Compile TypeScript (local build)
	@echo "$(COLOR_GREEN)→ Compiling TypeScript...$(COLOR_RESET)"
	npm run build

# ═══════════════════════════════════════════════════════════════════════════════
# Testing
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: test
test: ## Run all tests
	@echo "$(COLOR_GREEN)→ Running tests...$(COLOR_RESET)"
	npm test

.PHONY: test-unit
test-unit: ## Run unit tests only
	@echo "$(COLOR_GREEN)→ Running unit tests...$(COLOR_RESET)"
	npm run test:unit

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "$(COLOR_GREEN)→ Running integration tests...$(COLOR_RESET)"
	npm run test:integration

.PHONY: test-e2e
test-e2e: ## Run E2E tests
	@echo "$(COLOR_GREEN)→ Running E2E tests...$(COLOR_RESET)"
	npm run test:e2e

.PHONY: test-watch
test-watch: ## Run tests in watch mode
	@echo "$(COLOR_GREEN)→ Running tests in watch mode...$(COLOR_RESET)"
	npm run test:watch

.PHONY: coverage
coverage: ## Generate test coverage report
	@echo "$(COLOR_GREEN)→ Generating coverage report...$(COLOR_RESET)"
	npm run test:coverage

# ═══════════════════════════════════════════════════════════════════════════════
# Linting & Formatting
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: lint
lint: ## Run linter
	@echo "$(COLOR_GREEN)→ Running linter...$(COLOR_RESET)"
	npm run lint

.PHONY: lint-fix
lint-fix: ## Fix linting issues automatically
	@echo "$(COLOR_GREEN)→ Fixing linting issues...$(COLOR_RESET)"
	npm run lint:fix

.PHONY: format
format: ## Format code
	@echo "$(COLOR_GREEN)→ Formatting code...$(COLOR_RESET)"
	npm run format

.PHONY: format-check
format-check: ## Check code formatting
	@echo "$(COLOR_GREEN)→ Checking code formatting...$(COLOR_RESET)"
	npm run format:check

.PHONY: type-check
type-check: ## Run TypeScript type checking
	@echo "$(COLOR_GREEN)→ Type checking...$(COLOR_RESET)"
	npx tsc --noEmit

# ═══════════════════════════════════════════════════════════════════════════════
# Database
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: db-migrate
db-migrate: ## Run database migrations
	@echo "$(COLOR_GREEN)→ Running migrations...$(COLOR_RESET)"
	npm run db:migrate

.PHONY: db-migrate-rollback
db-migrate-rollback: ## Rollback last migration
	@echo "$(COLOR_GREEN)→ Rolling back migration...$(COLOR_RESET)"
	npm run db:rollback

.PHONY: db-seed
db-seed: ## Seed database with test data
	@echo "$(COLOR_GREEN)→ Seeding database...$(COLOR_RESET)"
	npm run db:seed

.PHONY: db-reset
db-reset: ## Reset database (drop, create, migrate)
	@echo "$(COLOR_YELLOW)→ Resetting database...$(COLOR_RESET)"
	npm run db:reset

# ═══════════════════════════════════════════════════════════════════════════════
# Docker
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: docker-run
docker-run: ## Run Docker container
	@echo "$(COLOR_GREEN)→ Running Docker container...$(COLOR_RESET)"
	docker run -d \
		--name $(PROJECT_NAME) \
		-p 3000:3000 \
		--env-file .env \
		$(DOCKER_REGISTRY)/$(PROJECT_NAME):latest

.PHONY: docker-stop
docker-stop: ## Stop Docker container
	@echo "$(COLOR_GREEN)→ Stopping Docker container...$(COLOR_RESET)"
	docker stop $(PROJECT_NAME) || true
	docker rm $(PROJECT_NAME) || true

.PHONY: docker-logs
docker-logs: ## Show Docker logs
	docker logs -f $(PROJECT_NAME)

.PHONY: docker-exec
docker-exec: ## Execute command in Docker container
	@read -p "Enter command: " cmd; \
	docker exec -it $(PROJECT_NAME) $$cmd

.PHONY: docker-shell
docker-shell: ## Open shell in Docker container
	docker exec -it $(PROJECT_NAME) sh

# ═══════════════════════════════════════════════════════════════════════════════
# Kubernetes
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: k8s-deploy-staging
k8s-deploy-staging: ## Deploy to staging
	@echo "$(COLOR_GREEN)→ Deploying to staging...$(COLOR_RESET)"
	kubectl apply -k k8s/overlays/staging

.PHONY: k8s-deploy-production
k8s-deploy-production: ## Deploy to production
	@echo "$(COLOR_GREEN)→ Deploying to production...$(COLOR_RESET)"
	kubectl apply -k k8s/overlays/production

.PHONY: k8s-rollback
k8s-rollback: ## Rollback last deployment
	@echo "$(COLOR_YELLOW)→ Rolling back...$(COLOR_RESET)"
	kubectl rollout undo deployment/$(PROJECT_NAME)

.PHONY: k8s-logs-staging
k8s-logs-staging: ## Show staging logs
	kubectl logs -f deployment/$(PROJECT_NAME) -n staging

.PHONY: k8s-logs-production
k8s-logs-production: ## Show production logs
	kubectl logs -f deployment/$(PROJECT_NAME) -n production

.PHONY: k8s-status
k8s-status: ## Show Kubernetes status
	@echo "$(COLOR_GREEN)→ Kubernetes status:$(COLOR_RESET)"
	kubectl get deployments,pods,services -l app=$(PROJECT_NAME)

# ═══════════════════════════════════════════════════════════════════════════════
# Deployment
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: deploy-staging
deploy-staging: build k8s-deploy-staging ## Build and deploy to staging
	@echo "$(COLOR_GREEN)✓ Deployed to staging$(COLOR_RESET)"

.PHONY: deploy-production
deploy-production: build k8s-deploy-production ## Build and deploy to production
	@echo "$(COLOR_GREEN)✓ Deployed to production$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(COLOR_GREEN)→ Cleaning...$(COLOR_RESET)"
	rm -rf dist/
	rm -rf node_modules/.cache/
	@echo "$(COLOR_GREEN)✓ Cleaned$(COLOR_RESET)"

.PHONY: clean-all
clean-all: clean ## Clean everything including node_modules
	@echo "$(COLOR_GREEN)→ Deep cleaning...$(COLOR_RESET)"
	rm -rf node_modules/
	@echo "$(COLOR_GREEN)✓ Deep cleaned$(COLOR_RESET)"

.PHONY: clean-docker
clean-docker: ## Remove Docker containers and images
	@echo "$(COLOR_GREEN)→ Cleaning Docker...$(COLOR_RESET)"
	docker-compose -f docker/docker-compose.yml down -v
	docker rmi $(PROJECT_NAME):dev 2>/dev/null || true
	@echo "$(COLOR_GREEN)✓ Docker cleaned$(COLOR_RESET)"

# ═══════════════════════════════════════════════════════════════════════════════
# Info
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: info
info: ## Show project information
	@echo "$(COLOR_BOLD)Project Information:$(COLOR_RESET)"
	@echo "  Name:    $(PROJECT_NAME)"
	@echo "  Version: $(VERSION)"
	@echo "  Commit:  $(GIT_COMMIT)"
	@echo "  Time:    $(BUILD_TIME)"

.PHONY: check
check: lint type-check test ## Run all checks (lint, type-check, test)
	@echo "$(COLOR_GREEN)✓ All checks passed$(COLOR_RESET)"

.DEFAULT_GOAL := help
