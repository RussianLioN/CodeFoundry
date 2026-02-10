# telegram-bot Profile

Orchestrator profile for **Telegram bots and messaging** projects.

## Overview

This profile configures AI agents optimized for Telegram bots and messaging.

## Included Agents

**Total agents:** 4 (system, bot, api, tester)

## Usage

Generate project with this profile:

```bash
cf-new --archetype telegram-bot
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** telegram-bot domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
