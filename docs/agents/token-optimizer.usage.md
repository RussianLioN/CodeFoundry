# Token Optimizer Agent

Agent for auditing and optimizing token usage in instruction files.

## Usage

Load this agent when:
- Auditing token consumption
- Detecting instruction waste
- Optimizing token budgets
- Validating @ref integrity

## Quick Start

```bash
# Full audit
/optimize

# Quick check
/optimize --quick

# Fix mode
/optimize --fix
```

## Commands Reference

| Command | Description |
|---------|-------------|
| (no args) | Full audit with recommendations |
| `--quick` | Fast token count only |
| `--fix` | Apply optimizations |
| `--budget` | Check against token budget |
| `--file <path>` | Audit single file |

## Token Budgets

| Priority | Per-File | Per-Chain |
|----------|----------|-----------|
| P0 | 400 tokens | 1,500 tokens |
| P1 | 800 tokens | 3,000 tokens |
| P2 | 1,500 tokens | 5,000 tokens |
