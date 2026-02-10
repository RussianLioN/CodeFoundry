# Agent Prompt Generation

**Purpose:** Create system prompts for specialized AI agents.

**When:** User wants agent-specific prompt (Code Assistant, Reviewer, Tester, etc.).
**Not for:** General tasks → Use [@ref: instructions/prompt-generation.md](instructions/prompt-generation.md)

---

## Agent vs System Prompt

| Aspect | System | Agent |
|--------|--------|-------|
| Target | General AI task | Specialized role |
| Scope | Complete workflow | Single domain |
| Output | One-shot prompt | Reusable agent file |

---

## Workflow

### 1. Gather Requirements (Russian)

Sequential questions: role, specialization, project type, interaction, success criteria, constraints.

### 2. Select Archetype

| Role | Archetype |
|------|-----------|
| Code | Code Assistant |
| Review | Reviewer |
| Test | Tester |
| Docs | Documentation |
| Debug | Debugger |
| Security | Security |
| DevOps | DevOps |
| Coord | Coordinator |

**Reference:** [@ref: templates/agents/](templates/agents/), [@ref: instructions/blocks-reference.md](instructions/blocks-reference.md)

### 3. Structure + Generate

Standard sections: Role, Task, Context, Tech Stack, Output Format, Examples.

---
