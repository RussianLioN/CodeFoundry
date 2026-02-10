# Skill: Measure Token Budget

## Contract
- **Input:** Optional `--quick|--verbose|--ci` flag
- **Output:** Token usage report per priority tier (P0/P1/P2)
- **Stateless:** Yes
- **Side effects:** None (read-only)

## Algorithm

1. Estimate tokens: `chars / 4` (UTF-8 aware via `wc -m`)
2. Check per-file budgets: P0=400, P1=800, P2=1500
3. Check chain budgets: P0=1500, P1=3000
4. Report over-budget and near-budget files

## Invocation

```bash
scripts/validate-token-budget.sh [--quick|--verbose|--ci]
```

Exit codes: 0=OK, 1=WARNING, 2=OVER_BUDGET

## Integration
- Used by: `scripts/quality-gates.sh` (Gate B3)
- Used by: `.claude/hooks/validate-md.sh` (PostToolUse hook)
- Trigger: `make token-audit`
