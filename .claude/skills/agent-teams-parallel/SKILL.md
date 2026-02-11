# Skill: Agent Teams Parallel Execution

## Contract
- **Input:** List of 2-5 independent tasks, max_agents count (default: 4)
- **Output:** Aggregated results from all agents, execution time metrics
- **Stateless:** Yes
- **Side effects:** Multiple files modified concurrently

## Algorithm

1. **VALIDATE** input conditions:
   - Tasks are independent (no shared files)
   - Task count ≤ max_agents
   - Each task has clear deliverable

2. **DECOMPOSE** tasks by agent:
   ```
   Agent 1 → Task 1 (e.g., update CLAUDE.md)
   Agent 2 → Task 2 (e.g., update SESSION.md)
   Agent 3 → Task 3 (e.g., update docs/INDEX.md)
   Agent 4 → Task 4 (e.g., validate all changes)
   ```

3. **EXECUTE** in parallel using Task tool:
   ```python
   # Pseudo-code for parallel execution
   results = parallel_execute([
       Task(agent=general-purpose, task=task1),
       Task(agent=general-purpose, task=task2),
       Task(agent=general-purpose, task=task3),
       Task(agent=general-purpose, task=task4),
   ], max_concurrency=4)
   ```

4. **AGGREGATE** results:
   - Collect outputs from all agents
   - Check for conflicts (none expected in parallel mode)
   - Report success/failure per task

5. **REPORT** metrics:
   - Total execution time
   - Sequential baseline estimate (for comparison)
   - Token usage per agent
   - Speedup factor (typically 3-5x)

## Token Budget
- **Agent 1:** ~200-500 tokens (depends on task)
- **Agent 2:** ~200-500 tokens
- **Agent 3:** ~200-500 tokens
- **Agent 4:** ~200-500 tokens
- **Total:** ~800-2000 tokens (vs ~2000-3000 sequential)

## Decision Matrix
| Scenario | Use Parallel? | Reason |
|----------|---------------|--------|
| 2-5 independent files | ✅ Yes | No conflicts, 3-5x speedup |
| Single file | ❌ No | No benefit, coordination overhead |
| Shared dependencies | ❌ No | Risk of merge conflicts |
| Complex (5+ files) | ✅ Yes | Use 4 agents + sequential |

## Example Usage

```
User: "Update CLAUDE.md, SESSION.md, docs/INDEX.md, TASKS.md in parallel using 4 agents"

Agent Teams execution:
  ✓ Agent 1: CLAUDE.md updated (45 sec)
  ✓ Agent 2: SESSION.md updated (38 sec)
  ✓ Agent 3: docs/INDEX.md updated (52 sec)
  ✓ Agent 4: TASKS.md updated (41 sec)

Total time: 52 sec (parallel)
Sequential baseline: ~176 sec
Speedup: 3.4x faster
Token usage: 1,850 tokens (vs ~2,400 sequential)
```

## Error Handling
| Error | Recovery |
|-------|----------|
| Agent failure | Continue with other agents, report failures |
| File conflict | Abort parallel execution, switch to sequential |
| Token limit | Reduce agent count, retry |

## Integration
- Requires: Claude Code 2.1.16+ with Task tool support
- Related: [agent-teams-safe-mode.md](.claude/skills/agent-teams-safe-mode.md) for backup/rollback
- Reference: [agent-teams-integration-plan.md](docs/reference/agent-teams-integration-plan.md) AT-004
