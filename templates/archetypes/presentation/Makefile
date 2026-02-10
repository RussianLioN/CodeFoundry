# ═════════════════════════════════════════════════════════════════════════════
# Makefile for Presentation Development
# ═══════════════════════════════════════════════════════════════════════════════

PRESENTATION_TITLE := my-talk
SLIDES_DIR := slides
OUTPUT_DIR := output
THEME := custom

.PHONY: help
help: ## Show help
	@echo '$(PRESENTATION_TITLE) - Presentation Commands:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════════════════════
# Build
# ═════════════════════════════════════════════════════════════════════════════

.PHONY: build
build: ## Build HTML presentation
	@echo "→ Building presentation..."
	@mkdir -p $(OUTPUT_DIR)
	@echo "# Slides" > $(OUTPUT_DIR)/slides.md
	@for slide in $(wildcard $(SLIDES_DIR)/*.md); do \
		cat "$$slide" >> $(OUTPUT_DIR)/slides.md; \
		echo "" >> $(OUTPUT_DIR)/slides.md; \
		echo "---" >> $(OUTPUT_DIR)/slides.md; \
	done
	@echo "✓ Built to $(OUTPUT_DIR)/slides.md"

.PHONY: serve
serve: build ## Start local server (port 8000)
	@echo "→ Starting server..."
	@echo "→ Open http://localhost:8000"
	@python -m http.server 8000

.PHONY: export
export: build ## Export to PDF
	@echo "→ Exporting to PDF..."
	decktape automatic --no-sandbox --revealjs-src="http://localhost:8000" presentation.pdf
	@echo "✓ Exported to presentation.pdf"

# ═══════════════════════════════════════════════════════════════════════════════
# Deploy
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: deploy
deploy: build ## Deploy to GitHub Pages
	@echo "→ Deploying to GitHub Pages..."
	@git add -A
	@git commit -m "Update presentation"
	@git push
	@echo "✓ Deployed"

# ═══════════════════════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf $(OUTPUT_DIR)

.DEFAULT_GOAL := help
