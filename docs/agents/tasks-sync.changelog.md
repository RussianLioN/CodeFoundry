# 📋 Changelog — tasks-sync

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📋 tasks-sync — Changelog**

> All notable changes to tasks-sync agent

---

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Add `--pull` mode (status feedback from issues)
- Add pre-commit hook integration
- Add `--filter` option for selective sync
- Add batch operations for rate limit optimization

---

## [1.0.0] - 2025-02-03

### Added
- Initial release of tasks-sync agent
- Unidirectional sync (TASKS.md → GitHub Issues)
- Dry-run mode for safe preview
- Automatic backup before changes
- 6-level documentation structure (core, quick, usage, trouble, examples, changelog)
- Cross-link navigation from CLAUDE.md
- Status mapping (✅ 🔄 ⏳ ❌ → GitHub labels)
- Conflict detection and logging
- Validation command for consistency checks
- Status comparison table

### Documentation
- Created AGENT-CREATION-GUIDE.md (13 experts consensus)
- Created docs/agents/index.md (agent discovery)
- Updated CLAUDE.md with agent cross-links

### Files
- `.claude/agents/tasks-sync.md` — Core agent (125 lines, down from 450+)
- `scripts/sync-tasks.py` — Python sync script (500+ lines)
- `docs/agents/tasks-sync.quick.md` — 5-minute setup
- `docs/agents/tasks-sync.usage.md` — Full usage guide
- `docs/agents/tasks-sync.trouble.md` — Troubleshooting
- `docs/agents/tasks-sync.examples.md` — Usage examples
- `docs/agents/tasks-sync.changelog.md` — This file

---

## Version History Summary

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-02-03 | Initial release |

---

*← [Back to Agents Index](index.md) | [Quick Start](tasks-sync.quick.md) →*
