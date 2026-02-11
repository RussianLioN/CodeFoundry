# Skill: Check Agent Routing Integrity

## Contract
- **Input:** `.claude/auto-routing-rules.json`
- **Output:** List of phantom agents (referenced in rules but no .md file)
- **Stateless:** Yes
- **Side effects:** None (read-only)

## Algorithm

1. Parse `auto-routing-rules.json`
2. Extract unique agent names (exclude `system`)
3. For each agent, check `.claude/agents/{name}.md` exists
4. Skip virtual agents: `code_assistant`, `reviewer` (built-in)
5. Report phantoms

## Verification

```bash
python3 -c "
import json, os
with open('.claude/auto-routing-rules.json') as f:
    data = json.load(f)
virtual = {'code_assistant', 'reviewer'}
phantoms = []
for rule in data.get('rules', []):
    agent = rule.get('agent', '')
    if agent and agent != 'system' and agent not in virtual:
        if not os.path.isfile(f'.claude/agents/{agent}.md'):
            phantoms.append(agent)
print(f'{len(set(phantoms))} phantom(s): {sorted(set(phantoms))}')
"
```

## Integration
- Used by: `scripts/quality-gates.sh` (Gate B6)
- Schema: `.claude/schemas/auto-routing-rules.schema.json`
