# OpenClaw Gateway Makefile
# Usage: make [target]

.PHONY: help build dev start test clean install docker-build docker-run

# Default target
.DEFAULT_GOAL := help

# Variables
NODE_VERSION := 20
IMAGE_NAME := openclaw/gateway
IMAGE_TAG := latest
CONTAINER_NAME := openclaw-gateway

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

##@ Help
help: ## Display this help message
	@echo "$(BLUE)OpenClaw Gateway - Available Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

##@ Development
install: ## Install dependencies
	@echo "$(BLUE)📦 Installing dependencies...$(NC)"
	npm install

dev: ## Start development server with hot reload
	@echo "$(BLUE)🔧 Starting development server...$(NC)"
	npm run dev

build: ## Build TypeScript to dist/
	@echo "$(BLUE)🔨 Building TypeScript...$(NC)"
	npm run build

watch: ## Watch for changes and rebuild
	@echo "$(BLUE)👀 Watching for changes...$(NC)"
	npm run watch

##@ Production
start: ## Start production server
	@echo "$(BLUE)🚀 Starting production server...$(NC)"
	npm run start

##@ Testing
test: ## Run tests
	@echo "$(BLUE)🧪 Running tests...$(NC)"
	npm test

test:coverage ## Run tests with coverage
	@echo "$(BLUE)📊 Running tests with coverage...$(NC)"
	npm run test:coverage

lint: ## Run linter
	@echo "$(BLUE)🔍 Running linter...$(NC)"
	npm run lint

lint:fix ## Fix linting issues
	@echo "$(BLUE)🔧 Fixing linting issues...$(NC)"
	npm run lint:fix

##@ Docker
docker-build: ## Build Docker image
	@echo "$(BLUE)🐳 Building Docker image...$(NC)"
	docker build -f ../docker/Dockerfile.openclaw -t $(IMAGE_NAME):$(IMAGE_TAG) ..

docker-run: ## Run Docker container
	@echo "$(BLUE)🐳 Running Docker container...$(NC)"
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 18789:18789 \
		-p 18790:18790 \
		-v $(PWD)/../workspace:/workspace \
		-e OLLAMA_BASE_URL=http://ollama-service:11434 \
		-e OLLAMA_MODEL=gemini-3-flash \
		$(IMAGE_NAME):$(IMAGE_TAG)

docker-stop: ## Stop Docker container
	@echo "$(BLUE)🛑 Stopping Docker container...$(NC)"
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

docker-logs: ## Show Docker logs
	docker logs -f $(CONTAINER_NAME)

docker-shell: ## Open shell in running container
	docker exec -it $(CONTAINER_NAME) sh

##@ Utilities
clean: ## Clean build artifacts and dependencies
	@echo "$(BLUE)🧹 Cleaning...$(NC)"
	rm -rf dist/
	rm -rf node_modules/
	rm -rf .coverage/
	rm -rf *.log

clean:dist ## Clean only build artifacts
	@echo "$(BLUE)🧹 Cleaning dist/...$(NC)"
	rm -rf dist/

check: ## Check environment and dependencies
	@echo "$(BLUE)🔍 Checking environment...$(NC)"
	@command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found"; exit 1; }
	@command -v npm >/dev/null 2>&1 || { echo "❌ npm not found"; exit 1; }
	@echo "✅ Node.js: $$(node --version)"
	@echo "✅ npm: $$(npm --version)"
	@[ -f .env ] || echo "⚠️  .env file not found (using defaults)"

##@ Stack Operations
stack-up: ## Start full OpenClaw stack (Gateway + Ollama)
	@echo "$(BLUE)🚀 Starting OpenClaw stack...$(NC)"
	cd ../docker && docker-compose up -d

stack-down: ## Stop OpenClaw stack
	@echo "$(BLUE)🛑 Stopping OpenClaw stack...$(NC)"
	cd ../docker && docker-compose down

stack-logs: ## Show stack logs
	cd ../docker && docker-compose logs -f

stack-status: ## Show stack status
	cd ../docker && docker-compose ps

##@ Health & Debug
health: ## Check Gateway health
	@echo "$(BLUE)🏥 Checking Gateway health...$(NC)"
	@curl -f http://localhost:18790/health && echo " ✅ Healthy" || echo " ❌ Unhealthy"

test-websocket: ## Test WebSocket connection
	@echo "$(BLUE)🔌 Testing WebSocket connection...$(NC)"
	@echo '{"type":"ping"}' | websocat ws://localhost:18789

deps-tree: ## Show dependency tree
	@echo "$(BLUE)🌲 Dependency tree:$(NC)"
	npm ls || true
