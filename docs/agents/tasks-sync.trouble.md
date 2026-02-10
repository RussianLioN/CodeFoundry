# 🛠️ tasks-sync — Troubleshooting

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **🛠️ tasks-sync — Troubleshooting**

> Common issues and solutions

---

## Quick Diagnostics

```bash
# Run diagnostics
python3 scripts/sync-tasks.py --validate

# Check backups
ls -lt scripts/backups/

# Check conflicts (if any)
cat scripts/conflicts.json
```

---

## Common Issues

### Issue: "gh: command not found"

**Symptoms:**
```
bash: gh: command not found
```

**Cause:** GitHub CLI is not installed

**Solution:**
```bash
# macOS
brew install gh

# Linux
sudo apt install gh  # Ubuntu/Debian
sudo yum install gh  # Fedora/RHEL

# Verify
gh --version
```

---

### Issue: "gh not authenticated"

**Symptoms:**
```
Error: gh not authenticated. Run 'gh auth login'
```

**Cause:** Not logged in to GitHub

**Solution:**
```bash
gh auth login
# Choose: GitHub.com → HTTPS → Login with browser
```

---

### Issue: "No tasks found in TASKS.md"

**Symptoms:**
```
✓ Parsed 0 tasks from TASKS.md
```

**Cause:** TASKS.md format doesn't match expected structure

**Solution:**

Check TASKS.md format:
```markdown
### REMOTE-001: Server Setup Scripts ✅
- **Статус:** ВЫПОЛНЕНО
- **Приоритет:** Высокий
- **Описание:** Server setup scripts
```

**Required:**
- `###` header with task ID
- Task ID format: `LETTERS-NUMBERS` (e.g., `REMOTE-001`)
- Status emoji: ✅ 🔄 ⏳ ❌

---

### Issue: "Rate limit exceeded"

**Symptoms:**
```
⚠ GitHub API rate limit approached (4500/5000)
```

**Cause:** Too many API requests in short time

**Solution:**
```bash
# Wait for rate limit reset (1 hour)
# Or use GitHub token with higher rate limit:
gh auth refresh -h "Authorization: token YOUR_TOKEN"
```

---

### Issue: "Orphaned issues found"

**Symptoms:**
```
⚠ 3 orphaned issues found (no corresponding tasks)
  - #100: OLD-001 (deprecated task?)
  - #101: OLD-002 (deprecated task?)
```

**Cause:** Issues exist for tasks removed from TASKS.md

**Solution:**
```bash
# Close orphaned issues
gh issue close #100 --comment "Task removed from TASKS.md"
gh issue close #101 --comment "Task removed from TASKS.md"

# Or keep them if they're still relevant
```

---

### Issue: "Status mismatch"

**Symptoms:**
```
⚠ Status mismatch for TELEBOT-001: TASKS.md=done, Issue=in_progress
```

**Cause:** Task status changed in TASKS.md but not synced

**Solution:**
```bash
# Run sync to update issue
python3 scripts/sync-tasks.py --push

# Or manually update issue
gh issue edit #123 --add-label "status:done"
```

---

## Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| E001 | Parse failed | Check TASKS.md format |
| E002 | gh not found | Install GitHub CLI |
| E003 | Not authenticated | Run `gh auth login` |
| E004 | Rate limit | Wait 1 hour |
| E005 | Backup failed | Check disk space |

---

## Recovery

### If sync corrupted TASKS.md

```bash
# Restore from backup
cp scripts/backups/TASKS.md.backup-XXXX TASKS.md

# List all backups
ls -lt scripts/backups/
```

### If wrong issues were created

```bash
# Delete created issues
gh issue list --label "status:done" --limit 100 | xargs -I {} gh issue close {}

# Re-sync from backup
cp scripts/backups/TASKS.md.backup-XXXX TASKS.md
python3 scripts/sync-tasks.py --push
```

### If everything fails

```bash
# 1. Restore TASKS.md from backup
cp scripts/backups/TASKS.md.backup-OLDEST TASKS.md

# 2. Delete all sync-created issues
gh issue list --limit 1000 | grep "^\[" | awk '{print $1}' | xargs -I {} gh issue close {}

# 3. Start fresh
python3 scripts/sync-tasks.py --dry-run  # Verify
python3 scripts/sync-tasks.py --push     # Sync
```

---

## Getting Help

1. Check [Full Usage](tasks-sync.usage.md)
2. Run with `--verbose` flag for more info
3. Search [GitHub Issues](https://github.com/RussianLioN/CodeFoundry/issues)
4. Create [New Issue](https://github.com/RussianLioN/CodeFoundry/issues/new)

---

*← [Back to Agents Index](index.md) | [Full Usage](tasks-sync.usage.md) →*
