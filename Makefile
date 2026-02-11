# ═════════════════════════════════════════════════════════════════════════════
# Makefile for System Prompts Meta-Generator
# ═══════════════════════════════════════════════════════════════════════════════

SHELL := /bin/bash
SCRIPTS_DIR := scripts

.PHONY: help
help: ## Show help
	@echo '$(PROJECT_NAME) - System Prompts Commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════════════════════
# Project Generation
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: new
new: ## Create new project from archetype (usage: make new ARCHETYPE=web-service NAME=my-project)
	@if [ -z "$(ARCHETYPE)" ] || [ -z "$(NAME)" ]; then \
		echo "Usage: make new ARCHETYPE=<archetype> NAME=<project-name>"; \
		echo ""; \
		echo "Available archetypes:"; \
		echo "  web-service       REST/GraphQL API"; \
		echo "  ai-agent          AI assistant with RAG"; \
		echo "  data-pipeline     ETL/ELT pipelines"; \
		echo "  telegram-bot      Telegram bot"; \
		echo "  presentation      Presentation (Markdown)"; \
		echo "  cli-tool          CLI utility"; \
		echo "  microservices     Microservices architecture"; \
		echo "  fullstack         Fullstack application"; \
		echo ""; \
		echo "Example:"; \
		echo "  make new ARCHETYPE=fullstack NAME=my-saas"; \
		exit 1; \
	fi
	@$(SCRIPTS_DIR)/new-project.sh $(ARCHETYPE) $(NAME)

.PHONY: list-archetypes
list-archetypes: ## List all available archetypes
	@echo "Available archetypes:"
	@for dir in templates/archetypes/*/; do \
		name=$$(basename "$$dir"); \
		readme="$$dir/README.md"; \
		if [ -f "$$readme" ]; then \
			desc=$$(grep -A 1 "^## Overview" "$$readme" | tail -1 | sed 's/^[[:space:]]*//'); \
		else \
			desc=""; \
		fi; \
		printf "  %-20s %s\n" "$$name" "$$desc"; \
	done

# ═══════════════════════════════════════════════════════════════════════════════
# Agent Generation
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: generate-agents
generate-agents: ## Generate AI agents for project (usage: make generate-agents NAME=MyProject TYPE=web-service LANG=python [FW=fastapi])
	@if [ -z "$(NAME)" ] || [ -z "$(TYPE)" ]; then \
		echo "Usage: make generate-agents NAME=<project-name> TYPE=<project-type> [LANG=<language>] [FW=<framework>]"; \
		echo ""; \
		echo "Project types:"; \
		echo "  telegram-bot      Telegram bot"; \
		echo "  web-service       REST/GraphQL API"; \
		echo "  ai-agent          AI assistant"; \
		echo "  data-pipeline     ETL/ELT"; \
		echo "  microservices     Microservices"; \
		echo "  fullstack         Fullstack app"; \
		echo "  cli-tool          CLI utility"; \
		echo "  presentation      Presentation"; \
		echo ""; \
		echo "Languages: python, javascript, typescript, go"; \
		echo "Frameworks: fastapi, django, react, next, aiogram, etc."; \
		echo ""; \
		echo "Examples:"; \
		echo "  make generate-agents NAME=MyBot TYPE=telegram-bot LANG=python FW=aiogram"; \
		echo "  make generate-agents NAME=MyAPI TYPE=web-service LANG=typescript FW=next"; \
		exit 1; \
	fi
	@python3 $(SCRIPTS_DIR)/generate-agents.py $(NAME) $(TYPE) $(or $(LANG),python) $(or $(FW),) $(PWD)

.PHONY: analyze-needs
analyze-needs: ## Analyze agent needs for project type (usage: make analyze-needs TYPE=web-service)
	@if [ -z "$(TYPE)" ]; then \
		echo "Usage: make analyze-needs TYPE=<project-type>"; \
		exit 1; \
	fi
	@python3 $(SCRIPTS_DIR)/analyze-agent-needs.py $(TYPE)

.PHONY: test-agents
test-agents: ## Test agent generation system
	@bash $(SCRIPTS_DIR)/test-agent-generation.sh

# ═══════════════════════════════════════════════════════════════════════════════
# Git Operations
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: sync-github
sync-github: ## Sync current project to GitHub
	@$(SCRIPTS_DIR)/sync-github.sh

.PHONY: status
status: ## Show git status
	@git status

.PHONY: commit
commit: ## Commit changes (usage: make commit MSG="your message")
	@if [ -z "$(MSG)" ]; then \
		echo "Usage: make commit MSG='commit message'"; \
		exit 1; \
	fi
	@git add -u
	@git commit -m "$(MSG)"

.PHONY: push
push: ## Push changes to remote
	@git push

# ═══════════════════════════════════════════════════════════════════════════════
# Documentation
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: docs
docs: ## Generate documentation index
	@echo "Generating documentation index..."
	@# Could add docs generation here

.PHONY: docs-serve
docs-serve: ## Serve documentation locally
	@echo "Serving documentation on http://localhost:8000"
	@python3 -m http.server 8000

# ═════════════════════════════════════════════════════════════════════════════
# Auto-Tracking (Session Tracker Agent)
# ═════════════════════════════════════════════════════════════════════════════

.PHONY: track
track: ## Track last commit and update docs automatically
	@echo "📊 Tracking commit..."
	@python3 scripts/auto-track.py track-commit HEAD

.PHONY: session-start
session-start: ## Start new session (initialize tracking)
	@echo "📚 Starting new session..."
	@rm -f .tracking/session_state.json
	@echo "✓ Session tracking initialized"

.PHONY: session-end
session-end: ## End session and generate summary
	@echo "📚 Finalizing session..."
	@python3 scripts/auto-track.py finalize-session
	@echo "✓ SESSION.md updated"
	@git add SESSION.md TASKS.md CHANGELOG.md 2>/dev/null || true
	@git commit -m "docs: Session ended" 2>/dev/null || echo "✓ Session documented"

.PHONY: session-status
session-status: ## Show session tracking status
	@if [ -f ".tracking/session_state.json" ]; then \
		cat .tracking/session_state.json | python3 -m json.tool; \
	else \
		echo "No active session"; \
	fi

.PHONY: update-progress
update-progress: ## Recalculate progress in TASKS.md
	@echo "📊 Updating progress..."
	@python3 scripts/auto-track.py update-progress
	@echo "✓ Progress updated"


# ═══════════════════════════════════════════════════════════════════════════════
# Token Optimization
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: token-audit
token-audit: ## Audit token usage in instruction files (quick)
	@$(SCRIPTS_DIR)/validate-token-budget.sh --quick

.PHONY: token-audit-verbose
token-audit-verbose: ## Audit token usage with full details
	@$(SCRIPTS_DIR)/validate-token-budget.sh --verbose

# ═══════════════════════════════════════════════════════════════════════════════
# Development
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: install
install: ## Install dependencies (if any)
	@echo "No dependencies to install for meta-generator"

.PHONY: test
test: ## Run all tests (agents + CI + quality gates)
	@echo "→ Running test suite..."
	@$(MAKE) test-agents
	@$(MAKE) ci-test
	@$(MAKE) gate-blocking

.PHONY: lint
lint: ## Lint code (shell scripts, python, etc.)
	@echo "→ Linting shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		./scripts/fix-shell-syntax.sh; \
	else \
		echo "⚠️  shellcheck not found, skipping shell lint"; \
	fi

.PHONY: test-unit
test-unit: ## Run unit tests
	@echo "→ Running unit tests..."
	@pytest tests/unit/ -v

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "→ Running integration tests..."
	@pytest tests/integration/ -v

.PHONY: test-e2e
test-e2e: ## Run end-to-end tests
	@echo "→ Running E2E tests..."
	@pytest tests/e2e/ -v

.PHONY: test-all
test-all: ## Run all pytest tests (unit + integration + e2e)
	@echo "→ Running all tests..."
	@pytest tests/ -v --cov=scripts --cov-report=html:htmlcov

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@echo "→ Running tests with coverage..."
	@pytest tests/ --cov=scripts --cov-report=term-missing --cov-report=html:htmlcov
	@echo "→ Coverage report: htmlcov/index.html"

.PHONY: shell-check
shell-check: ## Check shell script syntax with shellcheck
	@./scripts/fix-shell-syntax.sh

# ═══════════════════════════════════════════════════════════════════════════════
# Documentation
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: doc-check
doc-check: ## Validate documentation (refs, stale, orphans, tokens, coverage)
	@echo "→ Validating documentation..."
	@python3 scripts/validate-docs.py --all

.PHONY: doc-report
doc-report: ## Generate documentation health report
	@echo "→ Generating documentation health report..."
	@python3 scripts/validate-docs.py --report

.PHONY: doc-refs
doc-refs: ## Validate @ref links only
	@python3 scripts/validate-docs.py --ref-check

.PHONY: doc-stale
doc-stale: ## Check for stale documentation
	@python3 scripts/validate-docs.py --stale-check

.PHONY: doc-orphans
doc-orphans: ## Find orphaned .md files
	@python3 scripts/validate-docs.py --orphan-check

.PHONY: doc-tokens
doc-tokens: ## Validate token budgets
	@python3 scripts/validate-docs.py --token-check

.PHONY: doc-coverage
doc-coverage: ## Check documentation coverage
	@python3 scripts/validate-docs.py --coverage

# ═══════════════════════════════════════════════════════════════════════════════
# OpenClaw
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: openclaw-init
openclaw-init: ## Initialize OpenClaw in current project
	@if [ ! -d "openclaw" ]; then \
		echo "Creating OpenClaw workspace..."; \
		mkdir -p openclaw/workspace; \
		cp -r openclaw/workspace openclaw/; \
		echo "✓ OpenClaw initialized"; \
	else \
		echo "OpenClaw already initialized"; \
	fi

.PHONY: openclaw-sync
openclaw-sync: ## Sync OpenClaw prompts from central repo
	@echo "Syncing OpenClaw prompts..."
	@./openclaw/scripts/sync-ide-rules.sh

# ═══════════════════════════════════════════════════════════════════════════════
# Backup Coordinator (Agent Teams Safety)
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: backup-create
backup-create: ## Create backup before Agent Teams operation
	@$(SCRIPTS_DIR)/backup-coordinator.sh create --mode=auto

.PHONY: backup-validate
backup-validate: ## Run post-work validation checks
	@$(SCRIPTS_DIR)/backup-coordinator.sh validate --verbose

.PHONY: backup-rollback
backup-rollback: ## Rollback to last backup
	@$(SCRIPTS_DIR)/backup-coordinator.sh rollback

.PHONY: backup-list
backup-list: ## Show backup history
	@$(SCRIPTS_DIR)/backup-coordinator.sh list --last=10

.PHONY: backup-clean
backup-clean: ## Remove old backups (older than 7 days)
	@$(SCRIPTS_DIR)/backup-coordinator.sh clean --older=7d

.PHONY: test-backup
test-backup: ## Run backup coordinator safety checks
	@./tests/backup/safety-check.sh

.PHONY: backup-lessons
backup-lessons: ## Backup LESSONS.md and .tracking/ directory
	@$(SCRIPTS_DIR)/backup-lessons.sh

.PHONY: auto-commit-lessons
auto-commit-lessons: ## GitOps auto-commit for LESSONS.md
	@$(SCRIPTS_DIR)/auto-lesson-commit.sh

.PHONY: crontab-install
crontab-install: ## Install backup automation crontab
	@echo "Installing crontab entries..."
	@crontab -l > /tmp/crontab.bak 2>/dev/null || true
	@grep -q "backup-lessons.sh" /tmp/crontab.bak 2>/dev/null || cat crontab.backup >> /tmp/crontab.bak
	@crontab /tmp/crontab.bak
	@echo "✓ Crontab installed"
	@crontab -l | grep -E "(backup-lessons|lesson-learned)"

.PHONY: crontab-show
crontab-show: ## Show installed crontab entries
	@crontab -l | grep -E "(backup-lessons|lesson-learned|project-.*\.tar\.gz)" || echo "No crontab entries found"

.PHONY: docker-volume-create
docker-volume-create: ## Create Docker volume for .tracking/
	@docker volume create system-prompts-tracking 2>/dev/null || echo "Volume already exists"
	@echo "✓ Docker volume created: system-prompts-tracking"

.PHONY: docker-volume-backup
docker-volume-backup: ## Backup Docker volume to tarball
	@docker run --rm \
		-v system-prompts-tracking:/data \
		-v "$(PWD)/.tracking/backups:/backup" \
		alpine tar -czf /backup/tracking-volume-$$(date +%Y%m%d).tar.gz -C /data .
	@echo "✓ Volume backed up to .tracking/backups/"

# ═══════════════════════════════════════════════════════════════════════════════
# Docker
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "→ Building Docker image..."
	docker build -t system-prompts:latest .
	@echo "✓ Image built"

.PHONY: docker-run
docker-run: ## Run Docker container
	@echo "→ Running container..."
	docker run -it --rm \
		-v "$(PWD):/system-prompts" \
		-v "/workspace:/workspace" \
		system-prompts:latest

.PHONY: docker-bash
docker-bash: ## Run container with bash shell
	@echo "→ Starting bash in container..."
	docker run -it --rm \
		-v "$(PWD):/system-prompts" \
		-v "/workspace:/workspace" \
		system-prompts:latest \
		/bin/bash

.PHONY: docker-compose-up
docker-compose-up: ## Start services with docker-compose
	@echo "→ Starting services..."
	docker-compose up -d

.PHONY: docker-compose-down
docker-compose-down: ## Stop services
	@echo "→ Stopping services..."
	docker-compose down

.PHONY: docker-compose-logs
docker-compose-logs: ## Show docker-compose logs
	docker-compose logs -f

# ═══════════════════════════════════════════════════════════════════════════════
# Quality Gates
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: gate-blocking
gate-blocking: ## Run blocking quality gates (must pass before commit/deploy)
	@$(SCRIPTS_DIR)/quality-gates.sh --blocking

.PHONY: gate-info
gate-info: ## Run info quality gates (non-blocking warnings)
	@$(SCRIPTS_DIR)/quality-gates.sh --info

.PHONY: gate-all
gate-all: ## Run all quality gates (blocking + info)
	@$(SCRIPTS_DIR)/quality-gates.sh --all

# ═══════════════════════════════════════════════════════════════════════════════
# Settings Management (Claude Code)
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: settings-validate
settings-validate: ## Validate Claude Code settings.local.json
	@python3 scripts/validate-settings.py

.PHONY: settings-sanitize
settings-sanitize: ## Auto-fix invalid permission patterns in settings.local.json
	@python3 scripts/sanitize-settings.py --fix

.PHONY: settings-backup
settings-backup: ## Backup current settings
	@cp .claude/settings.local.json .claude/settings.backup.$$(date +%Y%m%d-%H%M%S).json

.PHONY: settings-restore
settings-restore: ## Restore from latest backup (usage: make settings-restore BACKUP=settings.backup.20260211-120000)
	@if [ -z "$(BACKUP)" ]; then \
		latest=$$(ls -t .claude/settings.backup.*.json 2>/dev/null | head -1); \
		if [ -n "$$latest" ]; then \
			echo "Restoring from $$latest"; \
			cp "$$latest" .claude/settings.local.json; \
		else \
			echo "No backup found"; \
			exit 1; \
		fi; \
	else \
		cp ".claude/$(BACKUP)" .claude/settings.local.json; \
	fi

.PHONY: settings-reset
settings-reset: ## Reset to example settings
	@cp .claude/settings.example.json .claude/settings.local.json
	@echo "✓ Settings reset to example"

# ═══════════════════════════════════════════════════════════════════════════════
# Lessons Learned System
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: lessons-log
lessons-log: ## Log an error occurrence (usage: make lessons-log TYPE=error_type LOC=file)
	@if [ -z "$(TYPE)" ] || [ -z "$(LOC)" ]; then \
		echo "Usage: make lessons-log TYPE=<error_type> LOC=<location>"; \
		exit 1; \
	fi
	@python3 scripts/lesson-learned-tracker.py log --type "$(TYPE)" --location "$(LOC)"

.PHONY: lessons-stats
lessons-stats: ## Show error statistics and lesson extraction status
	@python3 scripts/lesson-learned-tracker.py stats

.PHONY: lessons-extract
lessons-extract: ## Extract lessons from repeated errors (3+ occurrences)
	@python3 scripts/lesson-learned-tracker.py extract

.PHONY: lessons-show
lessons-show: ## Show all lessons
	@cat LESSONS.md

# ═══════════════════════════════════════════════════════════════════════════════
# CI/CD
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: ci-test
ci-test: ## Run CI checks locally
	@echo "→ Running CI checks..."
	@echo "→ Validating structure..."
	@for file in README.md CLAUDE.md PROJECT.md TASKS.md QUICKSTART.md Makefile; do \
		if [ -f "$$file" ]; then \
			echo "✓ $$file exists"; \
		else \
			echo "✗ $$file missing"; \
			exit 1; \
		fi; \
	done
	@echo "→ Validating scripts..."
	@for script in scripts/*.sh; do \
		if [ -x "$$script" ]; then \
			echo "✓ $$script is executable"; \
		else \
			echo "⚠ $$script is not executable"; \
		fi; \
	done
	@echo "✓ CI checks passed"

.PHONY: ci-validate-archetypes
ci-validate-archetypes: ## Validate all archetypes
	@echo "→ Validating archetypes..."
	@for archetype in templates/archetypes/*/; do \
		name=$$(basename "$$archetype"); \
		if [ -f "$$archetype/README.md" ] && [ -f "$$archetype/openclaw/workspace/AGENTS.md" ]; then \
			echo "✓ $$name: valid"; \
		else \
			echo "⚠ $$name: incomplete"; \
		fi; \
	done

.PHONY: ci-test-generation
ci-test-generation: ## Test project generation
	@echo "→ Testing project generation..."
	@./scripts/new-project.sh cli-tool test-ci-project
	@if [ -d "test-ci-project" ]; then \
		echo "✓ Project created"; \
		cd test-ci-project && \
		if [ -f "README.md" ] && [ -f "TASKS.md" ]; then \
			echo "✓ Required files exist"; \
		else \
			echo "✗ Required files missing"; \
			exit 1; \
		fi; \
		cd .. && rm -rf test-ci-project; \
	else \
		echo "✗ Project not created"; \
		exit 1; \
	fi

# ═══════════════════════════════════════════════════════════════════════════════
# Observability
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: observability-up
observability-up: ## Start observability stack (Prometheus, Grafana, Alertmanager)
	@echo "→ Starting observability stack..."
	cd observability && docker-compose up -d
	@echo "✓ Observability stack started"
	@echo ""
	@echo "Services:"
	@echo "  Grafana:    http://localhost:3001 (admin:admin)"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Alertmanager: http://localhost:9093"
	@echo "  Node Exporter: http://localhost:9100/metrics"

.PHONY: observability-down
observability-down: ## Stop observability stack
	@echo "→ Stopping observability stack..."
	cd observability && docker-compose down
	@echo "✓ Observability stack stopped"

.PHONY: observability-logs
observability-logs: ## Show observability logs
	cd observability && docker-compose logs -f

.PHONY: observability-status
observability-status: ## Show observability status
	cd observability && docker-compose ps

# ═══════════════════════════════════════════════════════════════════════════════
# Utility
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean temporary files
	@echo "Cleaning..."
	@find . -type d -name ".next" -prune -exec rm -rf {} +
	@find . -type d -name "dist" -prune -exec rm -rf {} +
	@find . -type d -name "node_modules" -prune -exec rm -rf {} +
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	@find . -type d -name "*.egg-info" -prune -exec rm -rf {} +
	@echo "✓ Cleaned"

.PHONY: version
version: ## Show version info
	@echo "CodeFoundry - Project Generation System"
	@echo "Version: 1.0.0"
	@echo "Archetypes: 8"
	@echo "Templates: 84 files"
	@echo "GitHub: https://github.com/RussianLioN/CodeFoundry"

.DEFAULT_GOAL := help
