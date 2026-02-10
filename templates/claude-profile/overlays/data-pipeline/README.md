# data-pipeline Profile

Orchestrator profile for **ETL/ELT data processing pipelines** projects.

## Overview

This profile configures AI agents optimized for ETL/ELT data processing pipelines.

## Included Agents

**Total agents:** 4 (system, data, code, tester)

## Usage

Generate project with this profile:

```bash
cf-new --archetype data-pipeline
```

## Configuration

Profile-specific settings:
- **Context window:** 200K tokens
- **Model:** Claude Sonnet 4.5 (default)
- **Specialization:** data-pipeline domain

## See Also

- [@ref: ../../architecture/orchestrator-profiles.md](../../architecture/orchestrator-profiles.md) — Orchestrator profiles overview
