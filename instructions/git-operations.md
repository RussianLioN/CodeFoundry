# Git Operations

**Purpose:** Git sync between sessions/devices, version history, rollback capability.

---

## Session Start: Sync (CRITICAL - from session-init.md)

**When:** ALWAYS at session start, BEFORE loading TASKS.md/SESSION.md.

### Quick Sync
```bash
git fetch origin
git status

# If behind:
git pull origin main  # no local changes
# OR
git stash && git pull && git stash pop  # has local changes
```

### Handle Conflicts
```bash
git diff --name-only --diff-filter=U  # list conflicts
# Edit files, resolve <<<<<<< markers
git add <resolved-file>
git commit -m "Merge remote changes"
```

### Report (Russian)
Sync successful: "🔄 Проект синхронизирован. Последний коммит: [message]"
Conflicts: "⚠️ Обнаружены конфликты. Проверьте изменения."

---

## Session End: Commit and Push

**When:** Session complete, work to save.

### Commit Workflow
```bash
git add -u  # explicit files only, safer
git status  # verify staged
git commit -m "feat: description"
git push origin main
```

**Commit format:** `type(scope): description`
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation
- `refactor:` code restructuring
- `test:` tests
- `chore:` maintenance

### Advanced
GitHub CLI, conflict resolution, special cases, templates:

---

## Safety

- **ALWAYS** `git status` before add/commit/push
- **NEVER** `git add -A` (may add sensitive files)
- **NEVER** force push to main/master
- **VERIFY** staged files before commit

---
