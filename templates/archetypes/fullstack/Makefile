# ═════════════════════════════════════════════════════════════════════════════
# Makefile for Fullstack Monorepo Development
# ═══════════════════════════════════════════════════════════════════════════════

NX := npx nx
DOCKER_COMPOSE := docker-compose

.PHONY: help
help: ## Show help
	@echo 'Fullstack Monorepo - Development Commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════════════════════
# Development
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: dev
dev: ## Start all applications in development mode
	@echo "→ Starting development servers..."
	$(NX) run-many --target=dev --all --parallel=true

.PHONY: dev-web
dev-web: ## Start web frontend
	$(NX) serve web

.PHONY: dev-api
dev-api: ## Start api backend
	$(NX) serve api

.PHONY: dev-mobile
dev-mobile: ## Start mobile app (if exists)
	$(NX) serve mobile

# ═══════════════════════════════════════════════════════════════════════════════
# Build
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: build
build: ## Build all applications
	@echo "→ Building all applications..."
	$(NX) run-many --target=build --all

.PHONY: build-web
build-web: ## Build web frontend
	$(NX) build web

.PHONY: build-api
build-api: ## Build api backend
	$(NX) build api

.PHONY: build-packages
build-packages: ## Build all packages
	$(NX) run-many --target=build --projects=types,ui,api-client,validators

# ═══════════════════════════════════════════════════════════════════════════════
# Testing
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: test
test: ## Run all tests
	$(NX) run-many --target=test --all

.PHONY: test-web
test-web: ## Run web tests
	$(NX) test web

.PHONY: test-api
test-api: ## Run api tests
	$(NX) test api

.PHONY: test-e2e
test-e2e: ## Run E2E tests
	$(NX) run web-e2e --headed

.PHONY: test-e2e-ci
test-e2e-ci: ## Run E2E tests in CI mode
	$(NX) run web-e2e

.PHONY: test-watch
test-watch: ## Run tests in watch mode
	$(NX) test --watch

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	$(NX) run-many --target=test --all --coverage

# ═══════════════════════════════════════════════════════════════════════════════
# Linting & Formatting
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: lint
lint: ## Lint all projects
	$(NX) run-many --target=lint --all

.PHONY: lint-fix
lint-fix: ## Fix linting issues
	$(NX) run-many --target=lint --all --fix

.PHONY: format
format: ## Format all files
	npx prettier --write "**/*.{js,jsx,ts,tsx,json,css,scss,md}"

.PHONY: format-check
format-check: ## Check formatting
	npx prettier --check "**/*.{js,jsx,ts,tsx,json,css,scss,md}"

# ═══════════════════════════════════════════════════════════════════════════════
# Docker
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: docker-up
docker-up: ## Start Docker services
	$(DOCKER_COMPOSE) up -d db redis mailhog
	@echo "✓ Infrastructure services started"

.PHONY: docker-down
docker-down: ## Stop Docker services
	$(DOCKER_COMPOSE) down

.PHONY: docker-logs
docker-logs: ## Show Docker logs
	$(DOCKER_COMPOSE) logs -f

.PHONY: docker-build
docker-build: ## Build Docker images
	docker build -f docker/Dockerfile.web -t fullstack-web:latest .
	docker build -f docker/Dockerfile.api -t fullstack-api:latest .

.PHONY: docker-dev
docker-dev: docker-up ## Start full development environment in Docker
	$(DOCKER_COMPOSE) up web api

# ═══════════════════════════════════════════════════════════════════════════════
# Database
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: db-migrate
db-migrate: ## Run database migrations
	$(NX) run api -- migrate:run

.PHONY: db-rollback
db-rollback: ## Rollback last migration
	$(NX) run api -- migrate:rollback

.PHONY: db-seed
db-seed: ## Seed database
	$(NX) run api -- seed:run

.PHONY: db-reset
db-reset: ## Reset database
	$(DOCKER_COMPOSE) exec db psql -U postgres -c "DROP DATABASE IF EXISTS fullstack;"
	$(DOCKER_COMPOSE) exec db psql -U postgres -c "CREATE DATABASE fullstack;"
	$(MAKE) db-migrate
	$(MAKE) db-seed

# ═══════════════════════════════════════════════════════════════════════════════
# Nx Commands
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: graph
graph: ## Show dependency graph
	$(NX) graph

.PHONY: affected
affected: ## Show affected projects
	$(NX) show projects --affected

.PHONY: affected-build
affected-build: ## Build affected projects only
	$(NX) run-many --target=build --affected

.PHONY: affected-test
affected-test: ## Test affected projects only
	$(NX) run-many --target=test --affected

# ═══════════════════════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean build artifacts
	@echo "→ Cleaning..."
	rm -rf node_modules
	rm -rf apps/*/node_modules
	rm -rf packages/*/node_modules
	rm -rf apps/*/.next
	rm -rf apps/*/dist
	rm -rf tmp
	find . -type d -name ".nx" -exec rm -rf {} +
	@echo "✓ Cleaned"

.PHONY: clean-install
clean-install: clean ## Clean and reinstall dependencies
	npm install

.DEFAULT_GOAL := help
