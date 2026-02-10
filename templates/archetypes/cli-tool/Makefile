# ═════════════════════════════════════════════════════════════════════════════
# Makefile for CLI Tool Development
# ═══════════════════════════════════════════════════════════════════════════════

PROJECT_NAME := mycli
BINARY_DIR := bin
DIST_DIR := dist
GO := go
PYTHON := python3

# Go variables (if using Go)
GO_VERSION := 1.21
GO_BUILD_FLAGS := -ldflags="-s -w"
GO_BUILD_TARGETS := linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64

# Python variables (if using Python)
PYTHON_VERSION := 3.11

.PHONY: help
help: ## Show help
	@echo '$(PROJECT_NAME) - CLI Tool Commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════════════════════
# Go Commands
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: go-build
go-build: ## Build Go binary
	@echo "→ Building Go binary..."
	@mkdir -p $(BINARY_DIR)
	$(GO) build $(GO_BUILD_FLAGS) -o $(BINARY_DIR)/$(PROJECT_NAME) .
	@echo "✓ Built to $(BINARY_DIR)/$(PROJECT_NAME)"

.PHONY: go-build-all
go-build-all: ## Build for all platforms
	@echo "→ Building for all platforms..."
	@mkdir -p $(DIST_DIR)
	@for target in $(GO_BUILD_TARGETS); do \
		os=$$(echo $$target | cut -d'/' -f1); \
		arch=$$(echo $$target | cut -d'/' -f2); \
		output=$(DIST_DIR)/$(PROJECT_NAME)-$$os-$$arch; \
		if [ "$$os" = "windows" ]; then output=$$output.exe; fi; \
		echo "Building $$target..."; \
		GOOS=$$os GOARCH=$$arch $(GO) build $(GO_BUILD_FLAGS) -o $$output .; \
	done
	@echo "✓ Built all binaries"

.PHONY: go-install
go-install: ## Install Go binary to system
	@echo "→ Installing to /usr/local/bin..."
	@sudo cp $(BINARY_DIR)/$(PROJECT_NAME) /usr/local/bin/
	@echo "✓ Installed to /usr/local/bin/$(PROJECT_NAME)"

.PHONY: go-test
go-test: ## Run Go tests
	@echo "→ Running tests..."
	$(GO) test -v -race -coverprofile=coverage.out ./...
	$(GO) tool cover -html=coverage.out -o coverage.html
	@echo "✓ Tests complete"

.PHONY: go-lint
go-lint: ## Lint Go code
	@echo "→ Linting..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run ./...; \
	else \
		echo "⚠ golangci-lint not installed. Install with: curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $$(go env GOPATH)/bin"; \
	fi

.PHONY: go-fmt
go-fmt: ## Format Go code
	@echo "→ Formatting..."
	$(GO) fmt ./...
	@echo "✓ Formatted"

.PHONY: go-mod-tidy
go-mod-tidy: ## Tidy Go modules
	@echo "→ Tidying modules..."
	$(GO) mod tidy
	@echo "✓ Modules tidied"

.PHONY: go-completion
go-completion: ## Generate shell completions (specify shell: bash|zsh|fish|powershell)
	@if [ -z "$(SHELL)" ]; then \
		echo "Usage: make go-completion SHELL=bash|zsh|fish|powershell"; \
		exit 1; \
	fi
	@$(BINARY_DIR)/$(PROJECT_NAME) completion $(SHELL) > $(PROJECT_NAME).$(SHELL)
	@echo "✓ Generated $(PROJECT_NAME).$(SHELL)"

# ═══════════════════════════════════════════════════════════════════════════════
# Python Commands
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: py-install
py-install: ## Install Python package in editable mode
	@echo "→ Installing package..."
	$(PYTHON) -m pip install -e .
	@echo "✓ Installed"

.PHONY: py-build
py-build: ## Build Python distribution
	@echo "→ Building distribution..."
	@mkdir -p $(DIST_DIR)
	$(PYTHON) -m build
	@echo "✓ Built to $(DIST_DIR)/"

.PHONY: py-publish
py-publish: ## Publish to PyPI
	@echo "→ Publishing to PyPI..."
	$(PYTHON) -m twine upload $(DIST_DIR)/*
	@echo "✓ Published"

.PHONY: py-test
py-test: ## Run Python tests
	@echo "→ Running tests..."
	$(PYTHON) -m pytest tests/ -v --cov=src --cov-report=html
	@echo "✓ Tests complete"

.PHONY: py-lint
py-lint: ## Lint Python code
	@echo "→ Linting..."
	@if command -v ruff >/dev/null 2>&1; then \
		ruff check src/; \
	else \
		python -m pylint src/; \
	fi

.PHONY: py-fmt
py-fmt: ## Format Python code
	@echo "→ Formatting..."
	@if command -v black >/dev/null 2>&1; then \
		black src/; \
	fi
	@echo "✓ Formatted"

# ═══════════════════════════════════════════════════════════════════════════════
# Docker Commands
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "→ Building Docker image..."
	docker build -t $(PROJECT_NAME):latest -f docker/Dockerfile .
	@echo "✓ Built $(PROJECT_NAME):latest"

.PHONY: docker-run
docker-run: ## Run Docker container
	docker run --rm $(PROJECT_NAME):latest --help

# ═══════════════════════════════════════════════════════════════════════════════
# Release Commands
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: release
release: go-build-all ## Create release
	@echo "→ Creating release..."
	@mkdir -p release
	@for binary in $(DIST_DIR)/$(PROJECT_NAME)-*; do \
		cp $$binary release/; \
		cd release && tar -czf $$(basename $$binary).tar.gz $$(basename $$binary); \
		cd ..; \
	done
	@echo "✓ Release ready in release/"

.PHONY: checksums
checksums: ## Generate SHA256 checksums
	@echo "→ Generating checksums..."
	@cd release && sha256sum * > SHA256SUMS
	@echo "✓ SHA256SUMS generated"

# ═══════════════════════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean build artifacts
	@echo "→ Cleaning..."
	rm -rf $(BINARY_DIR) $(DIST_DIR) release coverage.out coverage.html
	@echo "✓ Cleaned"

.DEFAULT_GOAL := help
