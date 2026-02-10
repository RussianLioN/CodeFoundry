# Skill: Validate @ref Links

## Contract
- **Input:** None (scans project files)
- **Output:** List of broken @ref links with file:target pairs
- **Stateless:** Yes
- **Side effects:** None (read-only)

## Algorithm

1. Scan instruction files: `CLAUDE.md`, `SESSION.md`, `instructions/**/*.md`, `.claude/agents/*.md`
2. Extract `@ref: <path>` patterns
3. Resolve paths (absolute + relative to file dir)
4. Filter out templates/examples (`path/to/`, `file.md`, glob patterns)
5. Report broken links

## Invocation

```bash
python3 scripts/check-refs.py
```

First line = count of broken refs. Remaining lines = `file: target` pairs.

## Integration
- Used by: `scripts/quality-gates.sh` (Gate B2)
- Trigger: `make gate-blocking`
