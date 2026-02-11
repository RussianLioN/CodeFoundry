# Claude Code Settings Management

> Best practices for managing `settings.local.json` in CodeFoundry projects.

---

## Problem

Claude Code **automatically adds** executed commands to `permissions.allow`. Complex commands (heredoc, pipes, multi-line) create **invalid JSON patterns** that break the entire file at startup.

---

## Solution

### 1. Automated Validation

```bash
# Validate settings
python3 scripts/validate-settings.py

# Auto-fix invalid patterns
python3 scripts/sanitize-settings.py --fix
```

### 2. Pre-commit Hook

```bash
# Install hook
ln -s ../../.git/hooks/pre-commit-validate-settings .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### 3. Git Ignore

```bash
# .gitignore
.claude/settings.local.json
.claude/settings.backup.*.json
```

---

## Recovery

If `settings.local.json` breaks:

```bash
# 1. Validate and see error
jq '.' .claude/settings.local.json

# 2. Auto-fix
python3 scripts/sanitize-settings.py --fix

# 3. Or restore from backup
cp .claude/settings.backup.*.json .claude/settings.local.json

# 4. Or start from example
cp .claude/settings.example.json .claude/settings.local.json
```

---

## Prevention

- Use `Write` tool for file creation (not Bash heredoc)
- Keep permission patterns simple: `Bash(*)` or `Bash(command *)`
- Validate before committing: `make gate-blocking`

---

## Files

| File | Purpose |
|------|---------|
| `scripts/validate-settings.py` | Validation script |
| `scripts/sanitize-settings.py` | Auto-fix script |
| `.claude/settings.example.json` | Template |
| `.claude/schemas/settings.schema.json` | JSON Schema |
| `.git/hooks/pre-commit-validate-settings` | Pre-commit hook |
