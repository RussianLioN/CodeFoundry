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

Add session entry with:
- Session number + date
- Focus area
- Achievements (bullet points)
- Next steps reference


---
