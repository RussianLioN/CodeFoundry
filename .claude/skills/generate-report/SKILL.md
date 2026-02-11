# Skill: Generate Structured Report

## Contract
- **Input:** Report data (title, type, findings, metrics)
- **Output:** Markdown report following `templates/report-template.md`
- **Stateless:** Yes
- **Side effects:** Writes report file

## Template Fields

| Field | Required | Description |
|-------|----------|-------------|
| REPORT_TITLE | Yes | Report heading |
| Type | Yes | audit / health-check / session-summary / optimization |
| Status | Yes | pass / warn / fail / info |
| Metrics | No | Table of metric/value/threshold/status |
| Findings | Yes | Grouped by Critical/Warning/Info |
| Recommendations | No | Prioritized action items |

## Usage Pattern

When generating any report output (cf-optimize, health checks, session summaries):

1. Read `templates/report-template.md`
2. Fill in YAML frontmatter fields
3. Populate sections with actual data
4. Write to output path or display

## Post-Creation Checklist (for all docs/*.md)

After creating any new document in `docs/`:

1. **Breadcrumbs** — add `> [🏠 Главная](../README.md) → [📂 ...] → [📄 Title](#)` at top and bottom
2. **docs/INDEX.md** — add entry in the appropriate section
3. **CLAUDE.md** — add to Navigation Map if P0/P1 relevance
4. **README.md** — add to Documentation table if user-facing
5. **Cross-links** — add references from related documents
6. **Validate** — run `make gate-blocking` to verify @ref integrity

Template for new documents: `templates/doc-template.md`

## Integration
- Template: `templates/report-template.md`
- Doc template: `templates/doc-template.md`
- Used by: cf-optimize, cf-health, session-closure
