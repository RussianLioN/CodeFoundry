# 📙 tasks-sync — Quick Start

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📙 tasks-sync**

> Get started in 5 minutes

---

## Prerequisites

Check that you have the required tools:

```bash
# GitHub CLI (required)
gh --version
# Expected: gh version 2.0.0+ (or install: brew install gh)

# Python 3.9+ (required)
python3 --version
# Expected: Python 3.9+

# TASKS.md file (required)
ls TASKS.md
# Expected: TASKS.md file exists
```

---

## 3 Steps to Start

### Step 1: Authenticate with GitHub (first time only)

```bash
gh auth login
# Follow the prompts (choose "GitHub.com", "HTTPS", "Login with browser")
```

### Step 2: Test in dry-run mode

```bash
python3 scripts/sync-tasks.py --dry-run
```

**Expected output:**
```
No action specified, running in dry-run mode...

✓ Backup created: scripts/backups/TASKS.md.backup-XXXX
✓ Parsed 60 tasks from TASKS.md
✓ Fetched 0 existing issues

Planned changes:
  New issues to create: 60
  Issues to update: 0
  Unchanged: 0

[DRY RUN] Changes would be:
  [NEW] REMOTE-001: Server Setup Scripts
  [NEW] TELEBOT-001: Telegram Bot MVP
  ...
```

### Step 3: Run actual sync

```bash
python3 scripts/sync-tasks.py --push
```

**Expected output:**
```
✓ Backup created: scripts/backups/TASKS.md.backup-XXXX
✓ Parsed 60 tasks from TASKS.md
✓ Fetched 0 existing issues

Planned changes:
  New issues to create: 60
  Issues to update: 0
  Unchanged: 0

Continue with sync? (y/n): y

✓ Created 60 issues
✓ Updated TASKS.md with issue numbers

Summary:
  Created: 60
  Updated: 0
  Skipped: 0
  Conflicts: 0
```

---

## Verify

Check that issues were created:

```bash
gh issue list --limit 10
```

**Expected:** List of issues with `[REMOTE-XXX]` or `[TELEBOT-XXX]` prefixes.

---

## Next Steps

- **[Full Usage](tasks-sync.usage.md)** — All commands and options
- **[Examples](tasks-sync.examples.md)** — Common workflows
- **[Troubleshooting](tasks-sync.trouble.md)** — If something goes wrong

---

*← [Back to Agents Index](index.md) | [Full Usage](tasks-sync.usage.md) →*
