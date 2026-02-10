# cf-health — CodeFoundry Health Check

Run comprehensive health checks on the CodeFoundry project.

## Usage
```
/cf-health [--agents|--refs|--tokens|--remote|--all]
```

## Sub-checks

### --agents (Agent Routing Integrity)
Validate that all agents referenced in `.claude/auto-routing-rules.json` have corresponding `.md` files in `.claude/agents/`. Detect phantom agents.

**Steps:**
1. Read `.claude/auto-routing-rules.json`
2. Extract unique agent names (skip `system`, `code_assistant`, `reviewer`)
3. Check each has `.claude/agents/{name}.md`
4. Report phantoms

### --refs (@ref Link Integrity)
Check all `@ref:` links in instruction files resolve to existing files.

**Steps:**
1. Run `python3 scripts/check-refs.py`
2. Report broken links with file:target pairs

### --tokens (Token Budget Compliance)
Check all instruction files against P0/P1/P2 token budgets.

**Steps:**
1. Run `scripts/validate-token-budget.sh --verbose`
2. Report over-budget and near-budget files

### --remote (Remote Infrastructure Status)
Check SSH connectivity to ainetic.tech and Docker container status.

**Steps:**
1. `ssh ainetic.tech "echo OK"` — connectivity check
2. `ssh ainetic.tech "docker ps --format '{{.Names}}: {{.Status}}'"` — container status
3. Report status

### --all (Full Health Check)
Run all sub-checks and generate aggregated report using `templates/report-template.md`.

## Default behavior

Without arguments, run `--all` and display aggregated summary.

## Invocation

When the user runs `/cf-health`, execute the following:

1. Run `scripts/quality-gates.sh --all` for comprehensive validation
2. If `--remote` flag specified, additionally check SSH connectivity
3. Generate report in the Report Template Standard format

## Report Format

Use `templates/report-template.md` structure with:
- Type: `health-check`
- Metrics: per-check pass/fail/warn
- Findings: grouped by sub-check
- Status: overall pass/warn/fail
