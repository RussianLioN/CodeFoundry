# Agent Teams Commands — Quick Reference

> Quick commands for Agent Teams operations

## Parallel Execution

Execute independent tasks simultaneously:

```bash
# Example: Update 4 files in parallel
claude "Update CLAUDE.md, SESSION.md, docs/INDEX.md, TASKS.md in parallel using 4 agents"
```

**Expected speedup:** 3-5x faster than sequential

## Sequential Execution

Execute dependent tasks with state handoff:

```bash
# Example: Create → Validate → Update
claude "Create agent docs, validate links, update INDEX sequentially"
```

**Use when:** Output of task 1 is input for task 2

## Safe Mode (RECOMMENDED)

Execute with automatic backup and validation:

```bash
# Example: Safe multi-file update
claude "Update all documentation with Agent Teams in safe mode"
```

**What happens:**
1. Creates backup automatically
2. Runs Agent Teams operation
3. Validates results (5 checks)
4. Auto-rollback if validation fails

## Manual Safe Mode

For full control:

```bash
# Step 1: Create backup
make backup-create

# Step 2: Run your operation
claude "Your Agent Teams operation here"

# Step 3: Validate results
make backup-validate

# Step 4: If validation fails, rollback
make backup-rollback
```

## Decision Matrix

| Scenario | Command |
|----------|---------|
| 2-5 independent files | Use "in parallel" |
| Dependent tasks | Use "sequentially" |
| Any multi-file work | Use "in safe mode" |
| Critical production work | Use manual safe mode |

## Quick Examples

```bash
# Parallel: Update 3 docs
claude "Update CLAUDE.md, SESSION.md, docs/INDEX.md in parallel using 3 agents"

# Sequential: Generate → Check → Publish
claude "Generate docs, validate links, update INDEX sequentially"

# Safe: Multi-file update with backup
claude "Update docs/, templates/, scripts/ in safe mode with 4 agents"
```

## Safety Reminder

⚠️ **Always use safe mode for multi-file Agent Teams operations.**

The risk of file corruption from parallel writes is real. Safe mode provides:
- Automatic backup before work
- Post-work validation
- Automatic rollback on failure

---

**See also:**
- [agent-teams-parallel](.claude/skills/agent-teams-parallel.md)
- [agent-teams-sequential](.claude/skills/agent-teams-sequential.md)
- [agent-teams-safe-mode](.claude/skills/agent-teams-safe-mode.md)
