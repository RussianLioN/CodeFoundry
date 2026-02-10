# ═══════════════════════════════════════════════════════════════════════════════
# Makefile for Telegram Bot Development
# ═══════════════════════════════════════════════════════════════════════════════

PROJECT_NAME := my-bot
DOCKER_REGISTRY := docker.io/myuser
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")

.PHONY: help
help: ## Show help
	@echo '$(PROJECT_NAME) - Telegram Bot Commands:'
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
dev: ## Start bot in polling mode
	@echo "→ Starting bot (polling mode)..."
	poetry run python -m app.main

.PHONY: dev-webhook
dev-webhook: ## Start bot with webhook (ngrok)
	@echo "→ Starting bot (webhook mode)..."
	@echo "→ Set up ngrok: ngrok http 8000"
	@poetry run python -m app.main --mode webhook

# ═══════════════════════════════════════════════════════════════════════════════
# Bot Commands
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: set-webhook
set-webhook: ## Set webhook for production
	@echo "→ Setting webhook..."
	@curl -X POST "https://api.telegram.org/bot${BOT_TOKEN}/setWebhook?url=${WEBHOOK_URL}/webhook"
	@echo "✓ Webhook set"

.PHONY: delete-webhook
delete-webhook: ## Delete webhook
	@echo "→ Deleting webhook..."
	@curl -X POST "https://api.telegram.org/bot${BOT_TOKEN}/deleteWebhook"
	@echo "✓ Webhook deleted"

.PHONY: get-info
get-info: ## Get bot info
	@curl -X GET "https://api.telegram.org/bot${BOT_TOKEN}/getMe"

# ═══════════════════════════════════════════════════════════════════════════════
# Testing
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: test
test: ## Run tests
	poetry run pytest

.PHONY: lint
lint: ## Run linter
	poetry run ruff check src/

.PHONY: format
format: ## Format code
	poetry run black src/
	poetry run ruff check --fix src/

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

.PHONY: deploy
deploy: build ## Deploy to production
	kubectl apply -k k8s/overlays/production

# ═══════════════════════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf dist/ .pytest_cache/ __pycache__/

.DEFAULT_GOAL := help
