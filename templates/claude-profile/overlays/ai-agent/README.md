# ai-agent Profile

Orchestrator profile for **AI assistant and agent-based systems** projects.

## Overview

This profile configures AI agents optimized for AI assistant and agent-based systems.

## Included Agents

**Total agents:** 3 (system, code, reviewer)

## Usage

Generate project with this profile:

```bash
cf-new --archetype ai-agent
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** ai-agent domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
