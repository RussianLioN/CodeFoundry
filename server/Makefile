# =============================================================================
# CodeFoundry Remote Server Makefile
# =============================================================================
# ainetic.tech server management commands
#
# Usage:
#   make help          # Show all available commands
#   make sync          # Sync project from GitHub
#   make start-test    # Start ephemeral test container
#   make logs          # View container logs
#   make shell         # Enter container shell
# =============================================================================

# =============================================================================
# Configuration
# =============================================================================

# Shell
SHELL := /bin/bash

# Directories
SCRIPT_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
PROJECT_DIR := $(shell cd "$(SCRIPT_DIR).." && pwd)
SERVER_DIR := $(PROJECT_DIR)/server

# Project
PROJECT_NAME := system-prompts
GITHUB_REPO := origin
DEFAULT_BRANCH := main

# Docker
COMPOSE_FILE := $(SERVER_DIR)/docker-compose.test.yml
COMPOSE_PROJECT := codefoundry-test
CONTAINER_PREFIX := test

# Environment
ENV_FILE := $(SERVER_DIR)/env.test

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# =============================================================================
# Default Target
# =============================================================================

.DEFAULT_GOAL := help

# =============================================================================
# Help Target
# =============================================================================

help: ## Show this help message
	@echo -e "${BLUE}CodeFoundry Remote Server Commands${NC}"
	@echo ""
	@echo -e "${GREEN}Usage:${NC} make [target]"
	@echo ""
	@echo -e "${YELLOW}Available targets:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  ${BLUE}%-20s${NC} %s\n", $$1, $$2}'
	@echo ""
	@echo -e "${YELLOW}Examples:${NC}"
	@echo "  make sync              # Sync from GitHub"
	@echo "  make start-test        # Start test container"
	@echo "  make logs              # View logs"
	@echo "  make backup            # Full backup"
	@echo "  make backup-list        # List backups"
	@echo "  make shell             # Enter container"

# =============================================================================
# Sync Targets
# =============================================================================

sync: ## Sync project from GitHub
	@echo -e "${BLUE}→ Syncing from GitHub...${NC}"
	@$(SERVER_DIR)/sync.sh

sync-force: ## Force sync (discard local changes)
	@echo -e "${YELLOW}→ Force syncing from GitHub...${NC}"
	@$(SERVER_DIR)/sync.sh --force

sync-status: ## Check sync status
	@echo -e "${BLUE}→ Checking sync status...${NC}"
	@$(SERVER_DIR)/sync.sh --status

sync-recreate: ## Sync and recreate containers
	@echo -e "${BLUE}→ Syncing and recreating containers...${NC}"
	@$(SERVER_DIR)/sync.sh --recreate

# =============================================================================
# Container Lifecycle Targets
# =============================================================================

start-test: ## Start ephemeral test container
	@echo -e "${BLUE}→ Starting test container...${NC}"
	@if [ ! -f "$(COMPOSE_FILE)" ]; then \
		echo -e "${RED}Error: docker-compose.test.yml not found${NC}"; \
		exit 1; \
	fi
	@cd $(SERVER_DIR) && \
		TIMESTAMP=$$(date +%s) && \
		docker-compose -f $(COMPOSE_FILE) up -d
	@echo -e "${GREEN}✓ Test container started${NC}"
	@$(MAKE) --no-print-directory status

stop-test: ## Stop test container
	@echo -e "${BLUE}→ Stopping test container...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) down
	@echo -e "${GREEN}✓ Test container stopped${NC}"

restart-test: ## Restart test container
	@echo -e "${BLUE}→ Restarting test container...${NC}"
	@$(MAKE) --no-print-directory stop-test
	@sleep 2
	@$(MAKE) --no-print-directory start-test

# =============================================================================
# Session Management Targets
# =============================================================================

start-session: ## Start named session (use SESSION=name)
	@echo -e "${BLUE}→ Starting session: $(SESSION)${NC}"
	@$(SERVER_DIR)/container-manager.sh start-session "$(SESSION)"

stop-session: ## Stop named session (use SESSION=name)
	@echo -e "${BLUE}→ Stopping session: $(SESSION)${NC}"
	@$(SERVER_DIR)/container-manager.sh stop-session "$(SESSION)"

list-sessions: ## List all active sessions
	@echo -e "${BLUE}→ Active sessions:${NC}"
	@$(SERVER_DIR)/container-manager.sh list-sessions

attach-session: ## Attach to session (use SESSION=name)
	@echo -e "${BLUE}→ Attaching to session: $(SESSION)${NC}"
	@$(SERVER_DIR)/container-manager.sh attach-session "$(SESSION)"

# =============================================================================
# Interactive Targets
# =============================================================================

shell: ## Enter container shell
	@echo -e "${BLUE}→ Entering container shell...${NC}"
	@$$(docker ps --filter "name=$(COMPOSE_PROJECT)" --format "{{.Names}}" | head -1 | xargs -I {} docker exec -it {} bash)

shell-root: ## Enter container shell as root
	@echo -e "${BLUE}→ Entering container shell as root...${NC}"
	@$$(docker ps --filter "name=$(COMPOSE_PROJECT)" --format "{{.Names}}" | head -1 | xargs -I {} docker exec -it -u root {} bash)

# =============================================================================
# Logging Targets
# =============================================================================

logs: ## View container logs (follow mode)
	@echo -e "${BLUE}→ Following container logs...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) logs -f

logs-short: ## Show last 50 lines of logs
	@echo -e "${BLUE}→ Last 50 lines of logs:${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) logs --tail=50

logs-gateway: ## View gateway logs only
	@echo -e "${BLUE}→ Gateway logs:${NC}"
	@docker logs -f $(COMPOSE_PROJECT)-gateway-1 2>/dev/null || echo -e "${RED}Gateway container not running${NC}"

logs-bot: ## View telegram bot logs only
	@echo -e "${BLUE}→ Telegram bot logs:${NC}"
	@docker logs -f $(COMPOSE_PROJECT)-telegram-bot-1 2>/dev/null || echo -e "${RED}Bot container not running${NC}"

# =============================================================================
# Status & Health Targets
# =============================================================================

status: ## Show container status
	@echo -e "${BLUE}→ Container status:${NC}"
	@echo ""
	@docker ps --filter "name=$(COMPOSE_PROJECT)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo -e "${YELLOW}No containers running${NC}"
	@echo ""
	@$(MAKE) --no-print-directory health

health: ## Check container health
	@echo -e "${BLUE}→ Health check:${NC}"
	@for container in $$(docker ps --filter "name=$(COMPOSE_PROJECT)" --format "{{.Names}}"); do \
		health=$$(docker inspect --format='{{.State.Health.Status}' $$container 2>/dev/null || echo "no-healthcheck"); \
		if [ "$$health" = "healthy" ]; then \
			echo -e "  $$container: $${GREEN}$$health$${NC}"; \
		elif [ "$$health" = "unhealthy" ]; then \
			echo -e "  $$container: $${RED}$$health$${NC}"; \
		else \
			echo -e "  $$container: $$health"; \
		fi \
	done

ps: ## Alias for status
	@$(MAKE) --no-print-directory status

# =============================================================================
# Testing Targets
# =============================================================================

test-telegram: ## Test telegram bot in container
	@echo -e "${BLUE}→ Testing Telegram bot...${NC}"
	@if [ -f "$(SERVER_DIR)/test-telegram.sh" ]; then \
		$(SERVER_DIR)/test-telegram.sh; \
	else \
		echo -e "${YELLOW}test-telegram.sh not found yet${NC}"; \
	fi

test-gateway: ## Test gateway connection
	@echo -e "${BLUE}→ Testing Gateway connection...${NC}"
	@curl -s http://localhost:18790/health || echo -e "${RED}Gateway not responding${NC}"

# =============================================================================
# Cleanup Targets
# =============================================================================

clean: ## Remove all containers (preserves volumes)
	@echo -e "${YELLOW}→ Removing containers...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) down --remove-orphans
	@echo -e "${GREEN}✓ Containers removed${NC}"

clean-all: ## Remove containers and volumes
	@echo -e "${RED}→ Removing containers and volumes...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) down -v
	@echo -e "${GREEN}✓ Containers and volumes removed${NC}"

clean-images: ## Remove dangling images
	@echo -e "${YELLOW}→ Cleaning up dangling images...${NC}"
	@docker image prune -f
	@echo -e "${GREEN}✓ Images cleaned${NC}"

# =============================================================================
# Build Targets
# =============================================================================

build: ## Build all containers
	@echo -e "${BLUE}→ Building containers...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) build
	@echo -e "${GREEN}✓ Build complete${NC}"

build-gateway: ## Build gateway container
	@echo -e "${BLUE}→ Building gateway...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) build gateway
	@echo -e "${GREEN}✓ Gateway built${NC}"

build-bot: ## Build telegram bot container
	@echo -e "${BLUE}→ Building telegram bot...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) build telegram-bot
	@echo -e "${GREEN}✓ Telegram bot built${NC}"

rebuild: ## Rebuild all containers (no cache)
	@echo -e "${BLUE}→ Rebuilding containers (no cache)...${NC}"
	@cd $(SERVER_DIR) && \
		docker-compose -f $(COMPOSE_FILE) build --no-cache
	@echo -e "${GREEN}✓ Rebuild complete${NC}"

# =============================================================================
# Monitoring Targets
# =============================================================================

stats: ## Show container resource usage
	@echo -e "${BLUE}→ Container stats:${NC}"
	@docker stats --no-stream --filter "name=$(COMPOSE_PROJECT)"

top: ## Show running processes in containers
	@echo -e "${BLUE}→ Top processes in containers:${NC}"
	@for container in $$(docker ps --filter "name=$(COMPOSE_PROJECT)" --format "{{.Names}}"); do \
		echo -e "${YELLOW}$$container:${NC}"; \
		docker top $$container; \
		echo ""; \
	done

# =============================================================================
# Development Targets
# =============================================================================

dev-start: ## Start long-running dev container
	@echo -e "${BLUE}→ Starting dev container...${NC}"
	@if [ -f "$(SERVER_DIR)/docker-compose.dev.yml" ]; then \
		cd $(SERVER_DIR) && \
		docker-compose -f docker-compose.dev.yml up -d; \
		echo -e "${GREEN}✓ Dev container started${NC}"; \
	else \
		echo -e "${RED}docker-compose.dev.yml not found${NC}"; \
	fi

dev-stop: ## Stop dev container
	@echo -e "${BLUE}→ Stopping dev container...${NC}"
	@if [ -f "$(SERVER_DIR)/docker-compose.dev.yml" ]; then \
		cd $(SERVER_DIR) && \
		docker-compose -f docker-compose.dev.yml down; \
		echo -e "${GREEN}✓ Dev container stopped${NC}"; \
	fi

# =============================================================================
# Backup Targets
# =============================================================================

backup: ## Run full backup (volumes + config + state + logs)
	@echo -e "${BLUE}→ Running full backup...${NC}"
	@$(SERVER_DIR)/backup.sh

backup-quick: ## Run quick backup (config only, no volumes)
	@echo -e "${BLUE}→ Running quick backup...${NC}"
	@$(SERVER_DIR)/backup.sh --quick

backup-list: ## List all backups
	@echo -e "${BLUE}→ Listing backups...${NC}"
	@$(SERVER_DIR)/backup.sh --list

backup-restore: ## Restore from backup (usage: make backup-restore TIMESTAMP)
	@echo -e "${YELLOW}→ Restoring from backup...${NC}"
	@$(SERVER_DIR)/backup.sh --restore "$(TIMESTAMP)"

backup-prune: ## Clean old backups (per retention policy)
	@echo -e "${BLUE}→ Pruning old backups...${NC}"
	@$(SERVER_DIR)/backup.sh --prune

backup-test: ## Test backup without creating actual backup
	@echo -e "${BLUE}→ Testing backup (dry-run)...${NC}"
	@$(SERVER_DIR)/backup.sh --test

# =============================================================================
# Info Targets
# =============================================================================

info: ## Show system information
	@echo -e "${BLUE}→ System Information:${NC}"
	@echo ""
	@echo -e "${YELLOW}Project:${NC}"
	@echo "  Name:    $(PROJECT_NAME)"
	@echo "  Path:    $(PROJECT_DIR)"
	@echo "  Branch:  $$(git -C $(PROJECT_DIR) rev-parse --abbrev-ref HEAD)"
	@echo "  Commit:  $$(git -C $(PROJECT_DIR) rev-parse --short HEAD)"
	@echo ""
	@echo -e "${YELLOW}Docker:${NC}"
	@docker --version
	@docker-compose --version
	@echo ""
	@echo -e "${YELLOW}Running Containers:${NC}"
	@docker ps --filter "name=$(COMPOSE_PROJECT)" --format "  {{.Names}}: {{.Status}}" || echo "  None"

version: ## Show version information
	@echo -e "${BLUE}CodeFoundry Remote Server${NC}"
	@echo "Version: 1.0.0"
	@echo "Makefile: $(MAKEFILE_LIST)"

# =============================================================================
# Phony Targets
# =============================================================================

.PHONY: \
	help \
	sync sync-force sync-status sync-recreate \
	start-test stop-test restart-test \
	start-session stop-session list-sessions attach-session \
	shell shell-root \
	logs logs-short logs-gateway logs-bot \
	status health ps \
	test-telegram test-gateway \
	clean clean-all clean-images \
	build build-gateway build-bot rebuild \
	stats top \
	dev-start dev-stop \
	backup backup-quick backup-list backup-restore backup-prune backup-test \
	info version
