# CodeFoundry — AI Assistant Hub

> Минимальный hub с @ref навигацией. Детали → в специализированных файлах.

---

## 🔴 P0: Session Start (MANDATORY)

**Execute FIRST:**

1. **Check project status** — [@ref: TASKS.md](TASKS.md) ← **READ THIS FIRST!**
   - What's completed? (Phase 8.5 = 25%, Phase 11 = 75%)
   - What's in progress? (active tasks)
   - What's blocked? (dependencies)

2. **Git sync** — [@ref: instructions/git-sync.md](instructions/git-sync.md)
   ```bash
   git fetch origin && git status
   ```

3. **Session context** — [@ref: SESSION.md](SESSION.md)
   - Recent changes
   - Current focus
   - Known issues

**🚨 NEVER skip TASKS.md check!** This prevents duplicate work on completed tasks.

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
| Lessons Learned | [@ref: docs/lessons/claude-code-skills-vs-commands.md](docs/lessons/claude-code-skills-vs-commands.md) |

---

**Role:** Expert AI prompt engineer for meta-level instruction systems.

**Next:** [@ref: instructions/git-sync.md](instructions/git-sync.md) ← ALWAYS FIRST
