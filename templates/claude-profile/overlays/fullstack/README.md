# fullstack Profile

Orchestrator profile for **Full-stack web applications** projects.

## Overview

This profile configures AI agents optimized for Full-stack web applications.

## Included Agents

**Total agents:** 5 (system, frontend, backend, api, tester)

## Usage

Generate project with this profile:

```bash
cf-new --archetype fullstack
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** fullstack domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
