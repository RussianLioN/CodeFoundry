# presentation Profile

Orchestrator profile for **Presentation and documentation** projects.

## Overview

This profile configures AI agents optimized for Presentation and documentation.

## Included Agents

**Total agents:** 3 (system, docs, reviewer)

## Usage

Generate project with this profile:

```bash
cf-new --archetype presentation
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** presentation domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
