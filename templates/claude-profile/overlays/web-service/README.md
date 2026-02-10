# web-service Profile

Orchestrator profile for **REST/GraphQL web services** projects.

## Overview

This profile configures AI agents optimized for REST/GraphQL web services.

## Included Agents

**Total agents:** 4 (system, api, backend, tester)

## Usage

Generate project with this profile:

```bash
cf-new --archetype web-service
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** web-service domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
