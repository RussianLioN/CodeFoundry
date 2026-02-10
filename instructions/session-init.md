# Session Initialization

**Purpose:** Determine session type by checking project state.

---

## Step 0: Git Sync (CRITICAL - DO FIRST)

**BEFORE loading TASKS.md/SESSION.md:**

```
→ Load @ref: instructions/git-operations.md#session-start
→ Execute: git fetch origin && git status
→ Sync if needed, handle conflicts
```

**Why first:** Latest version, prevent conflicts, sync devices.
**If fails:** Log warning, continue with local files.

---

## Step 1: Determine Session Type

| TASKS.md | SESSION.md | → Type |
|----------|-----------|-------|
| NO       | NO        | **FIRST** |
| YES      | YES       | **CONTINUATION** |
| YES      | NO        | **RECOVERY** → treat as continuation |
| NO       | YES       | **ERROR** → treat as first |

---

## Step 2: Execute Workflow

**FIRST SESSION:** → [@ref: instructions/first-session-workflow.md](instructions/first-session-workflow.md)
**CONTINUATION:** → [@ref: instructions/continuation-workflow.md](instructions/continuation-workflow.md)
**RECOVERY/ERROR:** Ask user "Начать с начала или продолжить?"

---

## Notes

- Check happens BEFORE greeting user
- Load only ONE workflow file
- Never load both simultaneously

---
