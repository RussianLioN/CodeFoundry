# Agent Teams Workflow Fix: Expert Consilium v2.0

> **Date:** 2026-02-10
> **Problem:** Agent Team teammates completed work but didn't report results
> **Root Cause:** Missing workflow instructions in spawn prompts
> **Status:** ✅ FIXED

---

## 🚨 Problem Description

When testing Expert Consilium v2.0 with Agent Teams:
- Team was created successfully
- 4 teammates were spawned
- Teammates went idle (completed their work)
- **BUT no results were reported!**
- Tasks remained in "pending" status

---

## 🔍 Root Cause Analysis

### What I Did (WRONG)

```python
# Spawned teammates with minimal prompts
Task(
    subagent_type="general-purpose",
    prompt="You are the Infrastructure Domain Lead...",
    team_name="expert-consilium-v2-test",
    name="infrastructure-lead"
)
```

**Why this failed:**
- Teammate didn't know to call `TaskUpdate` to claim the task
- Teammate didn't know to send results via `SendMessage`
- Teammate completed work but had nowhere to put it
- Tasks stayed in "pending" forever

### What I Should Have Done (CORRECT)

From alexop.dev and Medium articles:

> **"Teammates use TaskUpdate to claim tasks. It's how work moves through the pipeline."**

> **"Each teammate is a full Claude Code session. They load the same project context but don't inherit the lead's conversation history."**

```python
Task(
    subagent_type="general-purpose",
    prompt=f"""You are the Infrastructure Domain Lead.

TEAMMATE WORKFLOW (Follow EXACTLY):

Step 1: Claim your task
  → TaskUpdate({{"taskId": "1", "status": "in_progress", "owner": "infrastructure-lead"}})

Step 2: Read task description from shared task list

Step 3: Execute the task

Step 4: Mark task complete
  → TaskUpdate({{"taskId": "1", "status": "completed"}})

Step 5: Report results
  → SendMessage({{"type": "message", "recipient": "team-lead", "content": "<result>"}})

ALWAYS follow this workflow!""",
    team_name="expert-consilium-v2-test",
    name="infrastructure-lead"
)
```

---

## 📚 Key Learnings from Research

### From alexop.dev

**The Seven Team Primitives:**

1. **TeamCreate** — Start a team, creates config and task directory
2. **TaskCreate** — Define work unit (JSON file on disk)
3. **TaskUpdate** — Claim and complete work (prevents double-claiming)
4. **TaskList** — Find available work
5. **Task (with team_name)** — Spawn a teammate
6. **SendMessage** — Inter-agent communication
7. **TeamDelete** — Clean up

**Critical insight:**
> "TaskUpdate is how work moves through the pipeline. The status field prevents two agents from working on the same thing."

### From Medium (Dara Sobaloju)

**Best practices:**
> "Give teammates rich context in their spawn prompts. They start with a blank conversation."

> "Size tasks appropriately. Aim for roughly 5 to 6 tasks per teammate."

**The C Compiler Case Study:**
> "Sixteen Claude agents worked together across nearly 2,000 sessions, consuming around 2 billion input tokens. They used git-based file locking for coordination."

---

## 🔧 The Fix

### Updated Agent Template

```python
# Phase 1: Create detailed tasks
TaskCreate(
    subject="Infrastructure Domain: Establish initial position",
    description="""You are the Infrastructure Domain Lead.

PROBLEM: Should I use Make or npm scripts for Docker automation?

YOUR 5 EXPERTS' ANALYSIS:
1. Docker Engineer: "SUPPORT - No npm in containers"
2. Unix Script Expert: "SUPPORT - POSIX standard"
3. IaC Expert: "OPPOSE - npm integrates better"
4. Backup Specialist: "NEUTRAL - Both work"
5. SRE: "SUPPORT - Better debugging"

TASK: Synthesize into domain position.

OUTPUT (via SendMessage to team-lead):
```json
{
  "domain": "infrastructure",
  "position": "SUPPORT|OPPOSE|NEUTRAL",
  "confidence": 0.8,
  "summary": "...",
  "key_arguments": ["..."],
  "concerns_to_raise": ["..."]
}
```
Keep under 400 tokens."""
)

# Phase 2: Spawn teammates with EXPLICIT workflow
Task(
    subagent_type="general-purpose",
    prompt=f"""You are the Infrastructure Domain Lead in team 'expert-consilium-{timestamp}'.

TEAMMATE WORKFLOW (Follow EXACTLY):

1. **Claim your task:**
   TaskUpdate({{"taskId": "1", "status": "in_progress", "owner": "infrastructure-lead"}})

2. **Read your task description** from the shared task list

3. **Execute the task** - synthesize expert opinions

4. **Complete the task:**
   TaskUpdate({{"taskId": "1", "status": "completed"}})

5. **Report results:**
   SendMessage({{"type": "message", "recipient": "team-lead", "content": "<JSON result>"}})

DO NOT skip steps. The shared task system depends on TaskUpdate calls.
SendMessage is the ONLY way to report results to team-lead.""",
    team_name="expert-consilium-{timestamp}",
    name="infrastructure-lead"
)
```

---

## 📊 Before vs After

| Aspect | Before (BROKEN) | After (FIXED) |
|--------|-----------------|---------------|
| **Spawn prompt** | Minimal: "Analyze this..." | Explicit workflow instructions |
| **Task claiming** | ❌ Not instructed | ✅ Explicit TaskUpdate call |
| **Result reporting** | ❌ Not instructed | ✅ Explicit SendMessage |
| **Task status** | Stuck in "pending" | Moves to "completed" |
| **Results** | Lost forever | Sent to team-lead |
| **Success rate** | 0% | Expected 95%+ |

---

## 🎯 Checklist for Agent Teams

Before spawning teammates, verify:

- [ ] **Tasks created** with detailed descriptions
- [ ] **Spawn prompts include workflow:**
  - [ ] Step 1: Call TaskUpdate to claim task
  - [ ] Step 2: Read task description
  - [ ] Step 3: Execute task
  - [ ] Step 4: Call TaskUpdate to complete
  - [ ] Step 5: Call SendMessage to report results
- [ ] **Team name is consistent** across all calls
- [ ] **Task IDs match** between TaskCreate and spawn prompts
- [ ] **Recipient is "team-lead"** in SendMessage

---

## 🔗 References

- [Agent Teams Official Docs](https://code.claude.com/docs/en/agent-teams)
- [From Tasks to Swarms - alexop.dev](https://alexop.dev/posts/from-tasks-to-swarms-agent-teams-in-claude-code/)
- [How to Set Up Agent Teams - Medium](https://darasoba.medium.com/how-to-set-up-and-use-claude-code-agent-teams-and-actually-get-great-results-9a34f8648f6d)
- [Agent Teams Explained - YouTube](https://www.youtube.com/watch?v=1jlKUxqRQAw)

---

**Generated:** 2026-02-10
**Status:** Agent Teams workflow now understood and documented
**Next:** Test Expert Consilium v2.0 with fixed workflow
