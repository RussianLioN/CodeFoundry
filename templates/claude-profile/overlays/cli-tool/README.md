# cli-tool Profile

Orchestrator profile for **Command-line interface tools** projects.

## Overview

This profile configures AI agents optimized for Command-line interface tools.

## Included Agents

**Total agents:** 2 (system, code)

## Usage

Generate project with this profile:

```bash
cf-new --archetype cli-tool
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** cli-tool domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
