# Tool Selection Rules

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **Tools**

---

## 🎯 Priority: P1-ERROR

**Use the right tool for the job. Mixing tools causes errors and lost work.**

---

## 📊 Tool Selection Guide

| Tool | Purpose | Best For | NOT For |
|------|---------|----------|---------|
| **Edit** | Modify files | docker-compose.yml, configs, code | Executing commands |
| **Bash** | Execute commands | Git ops, SSH, Docker (via SSH) | File editing |
| **Read** | Understand state | Reading files before changes | Making changes |
| **Glob** | Find files | Locate files by pattern | Reading content |
| **Grep** | Search content | Find text in files | File editing |
| **Write** | Create files | New files (rare) | Modifying existing |

---

## 🔀 Decision Tree

```
User requests something
  ↓
Is it a FILE CHANGE?
  YES → Use Edit tool
    └── Is it docker-compose.yml?
        YES → This is IaC → Edit → Git commit → Git push
  NO ↓

Is it a COMMAND?
  YES → Use Bash tool
    └── Is it Docker?
        YES → Check environment
          Local? → BLOCKED (use Git workflow or SSH)
          Remote? → Execute via SSH
    └── Is it Git?
        YES → Execute locally
  NO ↓

Is it READ/SEARCH?
  YES → Use Read/Glob/Grep
```

---

## 🚫 Forbidden Patterns

| Action | Forbidden | Correct |
|--------|-----------|---------|
| Edit file | `sed -i`, `awk`, `echo >` | `Edit` tool |
| Search file | `grep`, `rg` in Bash | `Grep` tool |
| Find file | `find`, `ls` in Bash | `Glob` tool |
| Read file | `cat`, `head`, `tail` | `Read` tool |

**Exception:** `sed -n` and `awk` for **read-only analysis** (display only) are allowed.

---

## ✅ Correct Examples

### Modify Config File

```
# WRONG
Bash: sed -i 's/old/new/' config.yml

# CORRECT
Edit tool:
  file_path: config.yml
  old_string: "old"
  new_string: "new"
```

### Search for Pattern

```
# WRONG
Bash: grep -r "pattern" .

# CORRECT
Grep tool:
  pattern: "pattern"
  path: "."
```

---

## 🔗 Related

- [@ref: environment.md](./environment.md) — Environment rules
- [@ref: docker.md](./docker.md) — Docker commands

---

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **Tools**
