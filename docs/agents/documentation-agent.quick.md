# 📙 documentation-agent — Quick Start

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📙 documentation-agent**

> Monitors documentation health, validates @ref links, detects stale docs

---

## Prerequisites

```bash
# Validation scripts
ls scripts/validate-docs.py
ls scripts/check-refs.py

# Quality gates
make gate-blocking  # should pass
```

---

## 3 Steps to Start

### Step 1: Run documentation check

```
/doc-check
```

**Expected output:**
```
Running documentation validation...

✓ @ref links: 0 broken
⚠️  Stale docs: 3 files not updated in 30+ days
✓ Coverage: 15/15 agents have documentation

Recommendations:
- Update SESSION.md (last modified: 2026-01-15)
- Review templates/archetypes/*/README.md files
```

### Step 2: Generate health report

```
/doc-report
```

Generates comprehensive report with:
- @ref link integrity
- Stale documentation detection
- Token budget violations
- Coverage metrics

### Step 3: Fix issues

Agent provides actionable recommendations:

```bash
# Fix broken @ref links
vim instructions/session-init.md  # remove or update broken reference

# Update stale docs
vim SESSION.md  # add recent session summaries

# Fix token budgets
/cf-optimize  # optimize oversized files
```

---

## Verify

After fixes, run validation again:

```
/doc-check
```

Expected:
```
✓ All checks passed
```

---

## Validation Checks

| Check | Description | Command |
|-------|-------------|---------|
| **@ref-check** | All @ref links resolve | Built-in |
| **stale-check** | Files not updated >30 days | Built-in |
| **token-check** | Files exceed budgets | Via /cf-optimize |
| **coverage-check** | All agents have docs | Built-in |

---

## Token Budgets

| Priority | Limit | Files |
|----------|-------|-------|
| **P0** | 400 tokens | CLAUDE.md, SESSION.md |
| **P1** | 800 tokens | instructions/*.md |
| **P2** | 1500 tokens | docs/**/*.md |

---

## Common Commands

```
/doc-check      → Run full validation
/doc-report     → Health report only
/stale-check    → Find stale files only
/@ref-check     → Validate @ref links only
```

---

## Next Steps

- [Full Usage Guide](documentation-agent.usage.md) — Complete documentation
- [Quality Gates](../../scripts/quality-gates.sh) — Validation framework
- [Skills](../../.claude/skills/documentation-monitor.md) — Stateless skill interface

---

*← [Back to Agents Index](index.md) | [Full Usage](documentation-agent.usage.md) →*
