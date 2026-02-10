# Git Sync Session Start

> 🔴 **P0-BLOCKING** — Execute FIRST in every session
> ⏱️ Time: ~3-5 seconds

---

## Purpose

Sync local repo with remote before work:
- ✅ Latest version
- ✅ Prevent merge conflicts
- ✅ Sync from other devices
- ✅ Context from last commit

---

## Steps

### 1. Fetch

```bash
git fetch origin
```

### 2. Check Status

```bash
git status
```

| Output | Meaning | Action |
|--------|---------|--------|
| `behind` | Remote changes | Pull |
| `up to date` | Synced | Continue |
| `Changes not staged` | Local changes | Warn, continue |
| `ahead` | Unpushed commits | Offer push |

### 3. Pull if Needed

```bash
git pull origin main
```

**Conflicts:** Resolve, then `git add` + `git commit`.

### 4. Report (Russian)

```
🔄 Проект синхронизирован
Последний коммит: [message]
```

→ [@ref: instructions/git-operations.md](instructions/git-operations.md) for full reference.

---
