# 📓 token-optimizer — Changelog

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📓 token-optimizer**

---

## [1.1.0] — 2025-02-06

### Added
- 4-level automation: Claude Code hooks, git pre-commit, GitHub Actions CI, Makefile targets
- `scripts/validate-token-budget.sh` — standalone validation script (modes: --quick, --verbose, --ci)
- `.claude/hooks/validate-md.sh` — PostToolUse hook for Edit/Write on .md files
- `.git/hooks/pre-commit` — token budget check on committed .md files
- `validate-token-budget` CI job in `.github/workflows/ci.yml`
- `make token-audit` and `make token-audit-verbose` Makefile targets
- Exit codes: 0 (OK), 1 (warning), 2 (fail)

### Changed
- `.claude/settings.json` — added hooks configuration

## [1.0.0] — 2025-02-06

### Added
- Initial release of token-optimizer agent
- 3 execution modes: audit, quick, fix
- 6-pass analysis: duplication, @ref validation, loading chains, keyword density, priority check, whitespace
- Composite scoring system (0-100)
- Token budget system (P0/P1/P2 thresholds)
- Slash command `/cf-optimize`
- Auto-routing integration (RU + EN keywords)
- 6-level progressive disclosure documentation

### Context
- Created after manual optimizations P0-001 (CLAUDE.md: 79% reduction) and P0-002 (SESSION.md: 97% reduction)
- Expert consensus: 8.7/10 (13 experts, unanimous approval)
- Addresses token regression prevention

---

## Roadmap

### [1.1.0] — Planned
- `--compare` flag for regression detection (diff against previous audit)
- Externalized token budgets (`config/token-budgets.json`)
- CI/CD integration (`validate-token-budget` job)

### [1.2.0] — Future
- Fuzzy duplication detection (paraphrased content)
- Compression ratio metric
- Prometheus metric export
- Audit report archiving (`docs/audits/`)

---

*← [Back to Agents Index](index.md) | [Quick Start](token-optimizer.quick.md) →*
