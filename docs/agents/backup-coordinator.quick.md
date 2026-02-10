# 📙 backup-coordinator — Quick Start

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📙 backup-coordinator**

> Automatic backup/restore coordinator for Agent Teams operations

---

## Prerequisites

```bash
# Required tools
git --version    # git >= 2.0
rsync --version  # optional, for filesystem snapshots

# Verification
which git rsync  # both should be available
```

---

## 3 Steps to Start

### Step 1: Automatic activation

Backup coordinator activates automatically when Agent Teams operations are detected:

```
# Triggers: "parallel agents", "multi-agent", "agent team"
User: "Launch 3 agents in parallel to refactor the codebase"
→ backup-coordinator: Creating backup plan...
→ backup-coordinator: Git stash created: backup-coordinator: 20260210-130000
```

### Step 2: Pre-work backup

Before agents start work, backup is created automatically:

```bash
# Git stash (preferred)
git stash push -u -m "backup-coordinator: $(date -u +%Y%m%d-%H%M%S)"

# Filesystem snapshot (fallback)
rsync -av --exclude=.git --exclude=node_modules \
      . .backup/$(date +%Y%m%d-%H%M%S)/
```

### Step 3: Post-work validation

After agents complete work, state is validated:

```bash
# Checks performed:
✓ Git status clean
✓ @ref links intact
✓ No file corruption
✓ Quality gates passing
```

If validation fails → automatic rollback from backup.

---

## Verify

Check backup history:

```bash
# List git stashes
git stash list

# Expected output:
stash@{0}: On main: backup-coordinator: 20260210-130000
stash@{1}: On main: backup-coordinator: 20260210-120000

# List filesystem snapshots
ls -la .backup/
```

---

## Manual Usage

If you want to trigger backup manually:

```bash
# Manual backup
git stash push -u -m "manual-backup: $(date -u +%Y%m%d-%H%M%S)"

# Manual restore
git stash pop stash@{0}
```

---

## Next Steps

- [Full Usage Guide](backup-coordinator.usage.md) — All options and modes
- [Troubleshooting](backup-coordinator.trouble.md) — Common issues
- [Examples](../backup-coordinator.examples.md) — Real-world scenarios

---

*← [Back to Agents Index](index.md) | [Full Usage](backup-coordinator.usage.md) →*
