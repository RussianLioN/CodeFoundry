# Command: /expert-consilium-v2

> **Expert Consilium v2.0** — Multi-round adversarial debates with Agent Teams

## Description

Запускает систему анализа через Agent Teams с межагентскими дебатами. Эксперты分组 (grouped) по доменам, проводят cross-examination, adversarial debates и red teaming для глубокого анализа проблемы.

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
