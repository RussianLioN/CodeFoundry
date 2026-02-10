# microservices Profile

Orchestrator profile for **Microservices architectures** projects.

## Overview

This profile configures AI agents optimized for Microservices architectures.

## Included Agents

**Total agents:** 7 (system, services, api, devops, monitoring, tester, reviewer)

## Usage

Generate project with this profile:

```bash
cf-new --archetype microservices
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** microservices domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
