# ═══════════════════════════════════════════════════════════════════════════════
# Makefile for AI Agent Development
# ═══════════════════════════════════════════════════════════════════════════════

PROJECT_NAME := my-agent
DOCKER_REGISTRY := docker.io/myuser
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")

.PHONY: help
help: ## Show help
	@echo '$(PROJECT_NAME) - AI Agent Commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════════════════════
# Development
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: init
init: ## Initialize project
	@echo "→ Initializing project..."
	@if [ ! -f .env ]; then cp .env.example .env && echo "Created .env"; fi
	@poetry install
	@echo "✓ Project initialized"

.PHONY: dev
dev: ## Start development environment
	@echo "→ Starting development environment..."
	docker-compose -f docker/docker-compose.yml up --build

.PHONY: dev-local
dev-local: ## Start local development server
	@echo "→ Starting local server..."
	poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# ═══════════════════════════════════════════════════════════════════════════════
# Testing
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: test
test: ## Run all tests
	poetry run pytest

.PHONY: test-unit
test-unit: ## Run unit tests
	poetry run pytest tests/unit

.PHONY: test-integration
test-integration: ## Run integration tests
	poetry run pytest tests/integration

.PHONY: coverage
coverage: ## Generate coverage report
	poetry run pytest --cov=src/app --cov-report=html

# ═══════════════════════════════════════════════════════════════════════════════
# RAG / Documents
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: ingest-docs
ingest-docs: ## Ingest documents for RAG
	@echo "→ Ingesting documents..."
	poetry run python scripts/ingest_docs.py

.PHONY: create-collection
create-collection: ## Create vector collection
	@echo "→ Creating collection..."
	poetry run python scripts/create_collection.py

.PHONY: clear-vector-db
clear-vector-db: ## Clear vector database
	@echo "→ Clearing vector DB..."
	poetry run python scripts/clear_vector_db.py

# ═══════════════════════════════════════════════════════════════════════════════
# LLM / Prompts
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: test-prompts
test-prompts: ## Test prompts with LLM
	@echo "→ Testing prompts..."
	poetry run python scripts/test_prompts.py

.PHONY: ab-test-prompts
ab-test-prompts: ## Run A/B test on prompts
	@echo "→ Running A/B test..."
	poetry run python scripts/ab_test_prompts.py

.PHONY: migrate-prompts
migrate-prompts: ## Migrate prompts to new version
	@echo "→ Migrating prompts..."
	poetry run python scripts/migrate_prompts.py

# ═══════════════════════════════════════════════════════════════════════════════
# Deployment
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: build
build: ## Build Docker image
	docker build \
		--build-arg VERSION=$(VERSION) \
		-f docker/Dockerfile \
		-t $(DOCKER_REGISTRY)/$(PROJECT_NAME):$(VERSION) \
		-t $(DOCKER_REGISTRY)/$(PROJECT_NAME):latest \
		.

.PHONY: deploy-staging
deploy-staging: build ## Deploy to staging
	kubectl apply -k k8s/overlays/staging

.PHONY: deploy-production
deploy-production: build ## Deploy to production
	kubectl apply -k k8s/overlays/production

# ═══════════════════════════════════════════════════════════════════════════════
# Monitoring
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: logs
logs: ## Show application logs
	docker-compose -f docker/docker-compose.yml logs -f app

.PHONY: flower
flower: ## Open Flower UI
	open http://localhost:5555

# ═══════════════════════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf dist/ .pytest_cache/ __pycache__/

.PHONY: clean-all
clean-all: clean ## Clean everything
	rm -rf .venv/

.DEFAULT_GOAL := help
