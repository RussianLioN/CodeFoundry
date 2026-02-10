# 📚 tasks-sync — Usage Examples

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📚 tasks-sync — Examples**

> Concrete examples of using tasks-sync agent

---

## Example 1: First-time sync

**Scenario:** First time running sync on a project with 60 tasks

```bash
$ python3 scripts/sync-tasks.py --dry-run

No action specified, running in dry-run mode...

✓ Backup created: scripts/backups/TASKS.md.backup-1738596000
✓ Parsed 60 tasks from TASKS.md
✓ Fetched 0 existing issues

Planned changes:
  New issues to create: 60
  Issues to update: 0
  Unchanged: 0

[DRY RUN] Changes would be:
  [NEW] REORG-001: Реорганизация Структуры Файлов
  [NEW] OPENCLAW-001: OpenClaw Core Integration
  [NEW] TELEBOT-001: Telegram Bot MVP
  [NEW] REMOTE-001: Server Setup Scripts
  ... (60 total)

Continue with actual sync? (y/n): n

# User reviews output, then:
$ python3 scripts/sync-tasks.py --push

Continue with sync? (y/n): y

✓ Created issue #123 for REORG-001
✓ Created issue #124 for OPENCLAW-001
✓ Created issue #125 for TELEBOT-001
...
✓ Created 60 issues
✓ Updated TASKS.md with issue numbers

Summary:
  Created: 60
  Updated: 0
  Skipped: 0
  Conflicts: 0
```

---

## Example 2: Incremental sync

**Scenario:** Added 3 new tasks, completed 2 tasks

```bash
$ python3 scripts/sync-tasks.py --push

✓ Backup created: scripts/backups/TASKS.md.backup-1738597000
✓ Parsed 63 tasks from TASKS.md
✓ Fetched 60 existing issues

Planned changes:
  New issues to create: 3
  Issues to update: 2
  Unchanged: 58

Continue with sync? (y/n): y

✓ Created issue #183 for REMOTE-009
✓ Created issue #184 for REMOTE-010
✓ Created issue #185 for DOCAGENT-006
✓ Updated issue #125 for TELEBOT-001 (status: in_progress → done)
✓ Updated issue #145 for REMOTE-001 (status: in_progress → done)

Summary:
  Created: 3
  Updated: 2
  Skipped: 58
  Conflicts: 0
```

---

## Example 3: Status validation

**Scenario:** Check if TASKS.md and GitHub are in sync

```bash
$ python3 scripts/sync-tasks.py --validate

Validation Report:

✓ All 63 tasks have corresponding issues
✓ Status labels match
⚠ 2 orphaned issues found (no corresponding tasks)
  - #100: OLD-001 (deprecated task?)
  - #101: OLD-002 (deprecated task?)

Status Consistency: 100%
Overall: PASS (with warnings)

Run `/sync-tasks status` for details.
```

---

## Example 4: Status comparison

**Scenario:** See detailed status comparison

```bash
$ python3 scripts/sync-tasks.py --status

TASKS.md vs GitHub Issues Status:

┌─────────────┬──────────────┬──────────────┬─────────┐
│ Task ID     │ TASKS.md     │ Issue #      │ Match   │
├─────────────┼──────────────┼──────────────┼─────────┤
│ REORG-001   │ done         │ #123 done    │ ✓       │
│ OPENCLAW-001│ done         │ #124 done    │ ✓       │
│ TELEBOT-001 │ done         │ #125 in_progress │ ⚠   │
│ REMOTE-001  │ in_progress  │ #145 done    │ ⚠       │
└─────────────┴──────────────┴──────────────┴─────────┘

⚠ Mismatches: 2
Run `/sync-tasks push` to sync.
```

---

## Example 5: Integration with git workflow

**Scenario:** Sync tasks after committing changes

```bash
# Make changes to TASKS.md
nano TASKS.md

# Commit changes
git add TASKS.md
git commit -m "feat: complete TELEBOT-001"

# Sync to GitHub Issues
python3 scripts/sync-tasks.py --push

# Push both
git push origin main
```

---

## Example 6: Error recovery

**Scenario:** Sync failed partway through

```bash
$ python3 scripts/sync-tasks.py --push

✓ Created issue #183 for REMOTE-009
✓ Created issue #184 for REMOTE-010
✗ Failed to create issue for REMOTE-011: Rate limit exceeded

# Check what was synced
$ python3 scripts/sync-tasks.py --status

# Restore from backup
$ cp scripts/backups/TASKS.md.backup-1738597000 TASKS.md

# Wait for rate limit reset (1 hour), then:
$ python3 scripts/sync-tasks.py --push
```

---

## Example 7: Custom labels

**Scenario:** TASKS.md has custom priority labels

**Input TASKS.md:**
```markdown
### TELEBOT-001: Telegram Bot MVP ✅
- **Статус:** ВЫПОЛНЕНО
- **Приоритет:** Критический
```

**Created GitHub Issue:**
```markdown
Title: [TELEBOT-001] Telegram Bot MVP
Labels: status:done, priority:critical, phase:8.5
```

---

## Example 8: Handling dependencies

**Scenario:** Task has dependencies on other tasks

**Input TASKS.md:**
```markdown
### TELEBOT-002: Bot Testing ⏳
- **Зависимости:** TELEBOT-001, REMOTE-001
```

**Created GitHub Issue:**
```markdown
### Dependencies
TELEBOT-001, REMOTE-001
```

---

## Example 9: With verbose output

**Scenario:** Need detailed logging for debugging

```bash
$ python3 scripts/sync-tasks.py --push --verbose

✓ Backup created: scripts/backups/TASKS.md.backup-1738598000
[DEBUG] Parsing TASKS.md...
[DEBUG] Found 63 tasks in 10 phases
[DEBUG] Fetching issues from GitHub...
[DEBUG] Fetched 60 existing issues
[DEBUG] Comparing tasks vs issues...
[DEBUG] New: 3, Update: 2, Skip: 58
...
```

---

## Example 10: Pre-commit hook

**Scenario:** Auto-sync on every TASKS.md commit

**Setup:**
```bash
# .git/hooks/pre-commit
#!/bin/bash
if git diff --cached --name-only | grep -q "TASKS.md"; then
    python3 scripts/sync-tasks.py --validate
    if [ $? -ne 0 ]; then
        echo "TASKS.md validation failed. Commit aborted."
        exit 1
    fi
fi
```

---

*← [Back to Agents Index](index.md) | [Full Usage](tasks-sync.usage.md) →*
