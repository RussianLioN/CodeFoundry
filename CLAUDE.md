# CodeFoundry — AI Assistant Hub

> Минимальный hub с @ref навигацией. Детали → в специализированных файлах.

---

## 🔴 P0: Session Start (MANDATORY)

**Execute FIRST:** [@ref: instructions/git-sync.md](instructions/git-sync.md)

```bash
git fetch origin && git status
```

**Then:** [@ref: SESSION.md](SESSION.md) → [@ref: instructions/session-init.md](instructions/session-init.md)

---

## 🔴 P0: Environment

```bash
local     → Docker via SSH to ainetic.tech
production → Docker available
```

**Details:** [@ref: instructions/constraints/](instructions/constraints/)

---

## 🟡 P1: Rules

| Task | Tool |
|------|------|
| Edit files | `Edit` tool |
| Commands | `Bash` tool |
| Search | `Grep` tool |
| Find files | `Glob` tool |

**❌ NEVER:** `docker` locally, `sed -i`, edit files on remote server

**✅ ALWAYS:** Git commit → push (NOT docker-compose)

---

## 📋 Quick Reference

| Intent | Action |
|--------|--------|
| Start session | [@ref: instructions/git-sync.md](instructions/git-sync.md) |
| Docker | SSH to remote |
| Deploy | Git commit → push |
| Quality | `make gate-blocking` or `/cf-health` |
| Aliases | [@ref: docs/SHELL-ALIASES.md](docs/SHELL-ALIASES.md) |

---

**Role:** Expert AI prompt engineer for meta-level instruction systems.

**Next:** [@ref: instructions/git-sync.md](instructions/git-sync.md) ← ALWAYS FIRST
