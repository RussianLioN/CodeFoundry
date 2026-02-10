# Skill: Agent Teams Sequential Execution

## Contract
- **Input:** List of 2-5 tasks with dependencies, state handoff protocol
- **Output:** Results from each agent, state transition log
- **Stateless:** No (maintains handoff state between agents)
- **Side effects:** Files modified in sequence

## Algorithm

1. **VALIDATE** input conditions:
   - Tasks have explicit dependencies (e.g., output of task 1 → input of task 2)
   - Handoff protocol defined (what state is passed)
   - Sequential order specified

2. **DECOMPOSE** tasks by agent with handoff:
   ```
   Agent 1 → Task 1 (generate output)
       ↓ handoff: output_1, context_1
   Agent 2 → Task 2 (use output_1 as input)
       ↓ handoff: output_2, context_2
   Agent 3 → Task 3 (use output_2 as input)
       ↓ handoff: output_3, context_3
   ```

3. **EXECUTE** sequentially using Task tool:
   ```python
   # Pseudo-code for sequential execution
   state = {}

   for task, agent in task_sequence:
       result = Task(
           agent=agent,
           task=task,
           context=state  # Pass state from previous agent
       )
       state = result.handoff  # Update state for next agent
   ```

4. **VALIDATE** each transition:
   - Agent output matches expected handoff format
   - State is correctly propagated
   - No data loss between agents

5. **REPORT** execution trace:
   - Agent 1 → output_1 (45 sec) → Agent 2
   - Agent 2 → output_2 (38 sec) → Agent 3
   - Agent 3 → final_output (52 sec) → DONE
   - Total time: 135 sec

## Token Budget
- **State overhead:** +50-100 tokens per handoff
- **Agent 1:** ~200-500 tokens + state
- **Agent 2:** ~200-500 tokens + state
- **Agent 3:** ~200-500 tokens + state
- **Total:** ~650-1600 tokens + handoff overhead

## Handoff Protocol
```python
# Expected handoff format
handoff = {
    "output": "<agent's main output>",
    "context": {
        "files_modified": ["file1.md", "file2.md"],
        "summary": "brief description of changes",
        "next_steps": "what next agent should do"
    },
    "status": "success|failure|partial"
}
```

## Decision Matrix
| Scenario | Use Sequential? | Reason |
|----------|-----------------|--------|
| Dependent tasks | ✅ Yes | Output of task 1 required for task 2 |
| Stateful workflow | ✅ Yes | Context must be maintained |
| Independent tasks | ❌ No | Use parallel for 3-5x speedup |
| Error recovery needed | ✅ Yes | Stop on failure, debug, retry |

## Example Usage

```
User: "Create agent documentation, validate links, update INDEX sequentially"

Agent Teams execution:
  Agent 1 (documentation-agent):
    → Created docs/agents/new-agent.md
    → Handoff: {"files": ["new-agent.md"], "status": "success"}

  Agent 2 (token-optimizer):
    → Validated @ref links in new-agent.md
    → Handoff: {"valid": true, "broken_links": 0}

  Agent 3 (documentation-agent):
    → Updated docs/INDEX.md with new-agent.md reference
    → Handoff: {"updated": true, "entries_added": 1}

Total time: 145 sec
Token usage: 1,420 tokens
```

## Error Handling
| Error | Recovery |
|-------|----------|
| Agent failure | Stop sequence, report error, offer retry |
| Invalid handoff | Abort sequence, validate handoff format |
| State corruption | Rollback to last valid state, retry |
| Timeout | Continue without handoff, log warning |

## Integration
- Requires: Claude Code 2.1.16+ with Task tool support
- Related: [agent-teams-parallel.md](.claude/skills/agent-teams-parallel.md) for independent tasks
- Reference: [agent-teams-integration-plan.md](docs/reference/agent-teams-integration-plan.md) AT-004
