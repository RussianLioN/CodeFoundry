# Command: /expert-consilium-v2

> **Expert Consilium v2.0.2** — Multi-round adversarial debates with Agent Teams (CRITICAL BUGFIX #2)

## Description

Запускает систему анализа через Agent Teams с межагентскими дебатами. Эксперты группируются по доменам, проводят cross-examination, adversarial debates и red teaming для глубокого анализа проблемы.

## ⚠️ v2.0.2 Critical Fixes (2026-02-11)

**Fix #1:** Missing `subagent_type` parameter in Task tool calls
**Fix #2:** Missing `description` parameter in Task tool calls
**Fix #3:** Rate limit prevention — batch processing (4 agents at a time)

All Task tool calls now include required parameters:
- `subagent_type` (e.g., "general-purpose")
- `prompt` (full instructions)
- `description` (task description — REQUIRED!)
- `team_name` (team to join)
- `name` (unique teammate name)

## Usage

```
/expert-consilium-v2 <problem-statement>
```

## Key Features (v2.0)

- ✅ **Agent Teams** — Real inter-agent messaging via `SendMessage`
- ✅ **Multi-round debates** — Cross-examination → Adversarial → Red team
- ✅ **Position evolution** — Track how opinions change through rounds
- ✅ **Domain grouping** — 13 experts grouped into 4 domains

## Expert Domains

| Domain | Experts | Focus |
|--------|---------|-------|
| **Infrastructure** (5) | Docker, Unix, IaC, Backup, SRE | Container architecture, reliability |
| **Delivery** (3) | DevOps, CI/CD, GitOps | Automation, pipelines |
| **Quality** (2) | TDD, UAT | Testing, UX validation |
| **AI** (2) | AI IDE, Prompt Engineer | Token efficiency, prompts |
| **Solution Architect** (1, 1.5x) | — | Final synthesis |

## Output

```markdown
## Expert Consilium v2.0 Analysis

**Problem:** {problem}

**Domain Positions:**
- Infrastructure: {position} (confidence: {conf})
- Delivery: {position} (confidence: {conf})
- Quality: {position} (confidence: {conf})
- AI: {position} (confidence: {conf})

**Consensus:** {CONSENSUS} (X/4)

**Recommendation:** {recommendation}

**Confidence:** {confidence}

**Key Insight from Debates:** {what changed through challenges}
```

## Example

```
/expert-consilium-v2 "Should I use Make or npm scripts for Docker automation?"
```

**Result:**
- Recommendation: MAKE (confidence: 0.85)
- Consensus: STRONG_MAJORITY (3/3)
- Key insight: "Debates increased confidence through challenges"
