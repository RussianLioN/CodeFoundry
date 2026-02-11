# CodeFoundry — AI Assistant Hub

> Минимальный hub с @ref навигацией. Детали → в специализированных файлах.

---

## 🔴 P0: Session Start (MANDATORY)

1. **[@ref: TASKS.md](TASKS.md)** ← READ FIRST!
2. **Git sync** — `git fetch origin && git status`
3. **[@ref: SESSION.md](SESSION.md)** — current context

**🚨 NEVER skip TASKS.md!**

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
| Edit/Create | `Edit`/`Write` tools |
| Commands | `Bash` |
| Search | `Grep` |

**❌ NEVER:** `docker` local, `sed -i`, edit files on remote server

---

## 📋 Quick Ref

| Intent | Action |
|--------|--------|
| Deploy | Git commit → push |
| Quality | `make gate-blocking` |
| Aliases | [@ref: docs/SHELL-ALIASES.md](docs/SHELL-ALIASES.md) |

**Role:** Expert AI prompt engineer.

**Next:** [@ref: instructions/git-sync.md](instructions/git-sync.md)
