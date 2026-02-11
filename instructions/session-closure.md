# Session Closure

**When:** User says "завершить сессию"/"finish", work complete, or natural stopping point.
**Purpose:** Save state before conversation ends.

---

## Workflow

### Step 1: Assess Completeness

**Check TASKS.md:**
- IN_PROGRESS → DONE transitions
- Updated progress %

**Review work done:**
- Files created/modified
- Decisions made
- Problems solved

---

### Step 2: Prepare Session Summary

**🚨 Follow [@ref: instructions/session-summary.md](instructions/session-summary.md)**

**For SESSION.md update:**

**For SESSION.md update:**

1. **Accomplishments:** Completed tasks (with IDs), files changed, decisions
2. **Current State:** Last task, progress %, active files
3. **Decisions:** Choices made + rationale
4. **Issues:** Unresolved problems, blockers
5. **Next Plan:** Priority tasks, focus area

---

### Step 3: Update TASKS.md

Mark progress:
```markdown
- [x] TASK-001: Description
  - Status: IN_PROGRESS → DONE
  - Completed: [date]

### Overall Progress: X% → Y%
```

---

### Step 4: Git Commit (CRITICAL)

**ALWAYS commit before closing:**
```bash
git add -u
git status  # verify
git commit -m "feat: session summary"
git push origin main
```

---

### Step 5: Update SESSION.md

🚨 **CRITICAL:** UPDATE SESSION.md file, DO NOT create new files!

**Workflow:**
1. Update `SESSION.md` (root) with new session entry
2. Create/update archive file: `sessions/archive/sessions-XX.md`
3. Update `sessions/archive/README.md` index
4. DELETE any temporary/draft session files

**SESSION.md format:**
```markdown
## 📌 Current Context

**Last Session:** #XX (YYYY-MM-DD)
**Focus:** [тема]
**Progress:** X% | [статус]

**Last Achievements:**
- ✅ [краткие достижения]

**Next Steps:** See [@ref: TASKS.md](TASKS.md)

---

## 📚 History

Full session history:
- [sessions/archive/sessions-XX.md](sessions/archive/sessions-XX.md) ← **NEW** (replace XX with session number)
```

**Archive file format (sessions/archive/sessions-XX.md):**
```markdown
# Session #XX - [Title]

> [Sessions Archive](./) → **Session #XX**

> **Дата:** YYYY-MM-DD
> **Фокус:** [тема]

## 🎯 Достигнуто

- ✅ [достижения]

## 📊 Commits

| Commit | Описание |
|--------|----------|
| hash | message |

---

> [Previous archive](sessions-XX.md) | [↑ Sessions index](../index.md)
```

**🚨 NEVER:**
- ❌ Create `sessions/session-YYYY-MM-DD-[title].md` files
- ❌ Leave SESSION.md unchanged
- ❌ Skip updating archive README.md

**✅ ALWAYS:**
- ✅ Update SESSION.md (Single Source of Truth)
- ✅ Create/update archive file
- ✅ Update archive index
- ✅ Delete temporary files

---
