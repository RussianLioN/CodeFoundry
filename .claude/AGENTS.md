# CodeFoundry — Agent Registry

> Generated: 2026-02-09
> Project: CodeFoundry (meta-project)

---

## Overview

CodeFoundry uses **specialized subagents** launched via the `Task` tool. The main Claude instance acts as coordinator — no separate coordinator agent is needed.

**Global default model:** `sonnet` (via `CLAUDE_CODE_SUBAGENT_MODEL`)

---

## Registered Agents

### token-optimizer

- **File:** `agents/token-optimizer.md`
- **Model:** haiku
- **Role:** Token usage auditor and optimizer for instruction files
- **Triggers:** "optimize tokens", "token audit", "reduce tokens"
- **Command:** `/cf-optimize`

### tasks-sync

- **File:** `agents/tasks-sync.md`
- **Model:** haiku
- **Role:** TASKS.md → GitHub Issues synchronization
- **Triggers:** "sync tasks", "github issues", "sync github"

### documentation-agent

- **File:** `agents/documentation-agent.md`
- **Model:** haiku
- **Role:** Documentation health monitoring and validation
- **Triggers:** "doc-check", "validate docs", "stale docs"
- **Command:** `make doc-check`

### ollama-gemini-researcher

- **File:** `agents/ollama-gemini-researcher.md`
- **Model:** sonnet
- **Role:** Research specialist for Ollama/Gemini/OpenClaw deployment
- **Triggers:** "ollama", "gemini", "docker deploy", "openclaw"

### backup-coordinator

- **File:** `agents/backup-coordinator.md`
- **Model:** haiku
- **Role:** Automatic backup/restore coordinator for Agent Teams safety
- **Triggers:** "backup", "rollback", "validate backup", "agent teams safety"
- **Commands:** `make backup-create`, `make backup-validate`, `make backup-rollback`

### expert-consilium

- **File:** `agents/expert-consilium.md`
- **Model:** sonnet
- **Role:** Multi-expert analysis for complex technical decisions (13 virtual experts)
- **Triggers:** "expert analysis", "debate", "consensus", "technical decision"
- **Command:** `/expert-consilium`
- **Documentation:** [docs/agents/expert-consilium.quick.md](../docs/agents/expert-consilium.quick.md)

---

## Built-in Agent Types (Task tool)

These are always available without `.claude/agents/` files:

| Type | Model | Use Case |
|------|-------|----------|
| `Explore` | inherit | Codebase exploration, file search |
| `Plan` | inherit | Implementation planning |
| `Bash` | inherit | Command execution |
| `general-purpose` | inherit | Multi-step research |

---

## Routing

Agent selection is configured in `auto-routing-rules.json` (15 rules).
Schema: `schemas/auto-routing-rules.schema.json`.

---

## Adding a New Agent

1. Create `agents/{name}.md` with frontmatter (`name`, `model`, `tools`, `description`)
2. Add routing rule to `auto-routing-rules.json`
3. Add agent to schema enum in `schemas/auto-routing-rules.schema.json`
4. Update this file
5. Run `make gate-blocking` to validate

Guide: [@ref: docs/agents/AGENT-CREATION-GUIDE.md](../docs/agents/AGENT-CREATION-GUIDE.md)
