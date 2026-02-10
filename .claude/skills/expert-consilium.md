# Skill: Expert Consilium — Multi-Expert Debate & Analysis

## Contract
- **Input:** Problem statement, code context, decision criteria
- **Output:** Consolidated expert recommendation with consensus level
- **Stateless:** Yes (each analysis is independent)
- **Side effects:** Creates analysis report in `docs/analysis/{timestamp}-consilium.md`

## Overview

**Expert Consilium** — это систематический метод анализа сложных технических решений через структурированные дебаты между 13 виртуальными экспертами. Каждый эксперт представляет уникальную перспективу, а модератор синтезирует консолидированное решение.

## Expert Panel

### Core Architecture Experts (1-3)
1. **Solution Architect** — *Weight: 1.5x* — System design, patterns, trade-offs
2. **Senior Docker Engineer** — Container architecture, orchestration
3. **Unix Script Expert (Bash/Zsh Master)** — Scripting best practices

### DevOps & Automation Experts (4-6)
4. **DevOps Engineer** — Automation, tooling, workflow optimization
5. **CI/CD Architect** — Pipeline design, build orchestration
6. **GitOps Specialist (GitOps 2.0)** — Declarative infrastructure, Git-driven ops

### Infrastructure & Reliability Experts (7-9)
7. **Infrastructure as Code Expert** — IaC patterns, state management
8. **Backup & Disaster Recovery Specialist** — Data safety, recovery strategies
9. **SRE (Site Reliability Engineer)** — Production reliability, SLIs/SLOs

### AI & Development Experts (10-13)
10. **AI IDE Expert (Claude Code Specialist)** — AI-assisted development workflows
11. **Senior Prompt Engineer** — AI prompt optimization, instruction design
12. **Test-Driven Development Expert** — TDD patterns, testing strategies
13. **User Acceptance Testing Engineer** — UX validation, user scenarios

## Algorithm

### Phase 1: Problem Definition
```
Input:
  - problem_statement: Clear description of issue/decision
  - context: Relevant code, configs, constraints
  - criteria: Success metrics, priorities (e.g., "speed > safety")
```

### Phase 2: Expert Analysis (Parallel)
```python
# Each expert receives:
{
  "problem": problem_statement,
  "context": context,
  "role": expert_role,
  "perspective": expertise_focus,
  "output_format": {
    "position": "support | oppose | neutral",
    "arguments_for": ["arg1", "arg2", ...],
    "arguments_against": ["arg1", "arg2", ...],
    "concerns": ["concern1", ...],
    "alternative": "suggested alternative if any"
  }
}
```

### Phase 3: Debate Synthesis
```python
# Moderator analyzes all expert opinions:
synthesis = {
  "consensus_level": "unanimous | strong_majority | majority | split | no_consensus",
  "supporters": [expert_roles],
  "opponents": [expert_roles],
  "key_concerns": [top_concerns],
  "recommended_action": "what to do",
  "confidence": 0.0-1.0,
  "alternatives": ["alternative approaches"]
}
```

### Phase 4: Report Generation
```markdown
# Expert Consilium Report

## Problem Statement
[Original problem]

## Expert Positions

### Support (8/13)
- **Solution Architect:** "Pattern X is well-established..."
- **DevOps Engineer:** "Simplifies automation..."
- [6 more supporters]

### Oppose (2/13)
- **IaC Expert:** "State management risk..."
- **SRE:** "Production complexity..."

### Neutral (3/13)
- **Docker Engineer:** "Depends on orchestration..."
- [2 more neutral]

## Synthesis
**Consensus:** Strong majority (8/13)
**Recommendation:** Proceed with monitoring
**Confidence:** 0.72

## Key Concerns
1. State consistency (IaC, SRE)
2. Rollback complexity (Backup Specialist)

## Mitigation Plan
[Specific actions to address concerns]
```

## Token Budget

| Phase | Tokens | Notes |
|-------|--------|-------|
| Problem definition | +100 | User input |
| Expert analysis (13×) | ~2000-4000 | ~150-300 per expert |
| Debate synthesis | +500 | Moderator work |
| Report generation | +300 | Final report |
| **Total** | **~2900-4900** | Depends on problem complexity |

## Decision Matrix

| Scenario | Use Consilium? | Reason |
|----------|----------------|--------|
| High-impact architecture change | ✅ Yes | Multiple perspectives critical |
| Security/corruption risk | ✅ Yes | Need expert validation |
| Simple bug fix | ❌ No | Overkill, use single agent |
| 2-3 file updates | ❌ No | Direct edit sufficient |
| New feature with trade-offs | ✅ Yes | Need design analysis |
| Infrastructure change | ✅ Yes | DevOps/SRE input essential |

## Usage Examples

### Example 1: Architecture Decision
```
User: "Should I migrate from bash scripts to Python for automation?"

Expert Consilium analysis:
  Solution Architect: "Python better for complexity >100 lines"
  Unix Script Expert: "Bash still best for glue/simplicity"
  DevOps: "Python if team knows it, else Bash"
  [10 more experts...]

Consensus: Mixed
Recommendation: Hybrid approach — Bash for <50 lines, Python for complex logic
Confidence: 0.68
```

### Example 2: Safety-Critical Change
```
User: "Can I parallelize quality gates safely?"

Expert Consilium analysis:
  DevOps: "Yes, with proper isolation"
  SRE: "Monitor for race conditions"
  Backup Specialist: "Pre-backup critical"
  [10 more experts...]

Consensus: Strong support (11/13)
Recommendation: Proceed with backup-coordinator + validation
Confidence: 0.85
```

### Example 3: Tool Selection
```
User: "Should I use Make or npm scripts for automation?"

Expert Consilium analysis:
  Unix Script Expert: "Make is POSIX standard"
  DevOps: "npm scripts if Node project"
  CI/CD: "Make more portable across projects"
  [10 more experts...]

Consensus: Context-dependent
Recommendation: Make for cross-tool, npm for Node-only
Confidence: 0.91
```

## Expert Specializations

### Solution Architect
**Perspective:** System-level design, patterns, trade-offs
**Priorities:** Scalability, maintainability, architectural consistency
**Typical arguments:**
- "This pattern is well-established in X domain"
- "Introduces coupling between A and B"
- "Better separation of concerns"

### Senior Docker Engineer
**Perspective:** Container architecture, orchestration
**Priorities:** Container isolation, resource efficiency, orchestration compatibility
**Typical arguments:**
- "Port conflict risk between services"
- "Multi-stage build reduces image size"
- "Orchestration complexity increases"

### Unix Script Expert
**Perspective:** Bash/Zsh scripting, POSIX compatibility
**Priorities:** Simplicity, portability, script maintainability
**Typical arguments:**
- "GNU tools not available on macOS"
- "Backticks $() cause issues"
- "Extract to Python for >50 lines"

### DevOps Engineer
**Perspective:** Automation, tooling, workflow
**Priorities:** Automation reliability, developer experience, toolchain consistency
**Typical arguments:**
- "Simplifies CI/CD pipeline"
- "Reduces manual intervention"
- "Team familiarity factor"

### CI/CD Architect
**Perspective:** Pipeline design, build orchestration
**Priorities:** Pipeline reliability, build speed, failure diagnostics
**Typical arguments:**
- "Parallel execution 3-5x faster"
- "Failure isolation needed"
- "Artifact management complexity"

### GitOps Specialist
**Perspective:** Declarative infrastructure, Git-driven operations
**Priorities:** Git as single source of truth, declarative config, audit trail
**Typical arguments:**
- "GitOps 2.0 = declarative + AI agents"
- "Automatic sync on commit"
- "Rollback via git revert"

### IaC Expert
**Perspective:** Infrastructure as Code patterns, state management
**Priorities:** State consistency, drift detection, reproducibility
**Typical arguments:**
- "State management risk with parallel execution"
- "Terraform state locking needed"
- "Drift detection required"

### Backup & Disaster Recovery Specialist
**Perspective:** Data safety, recovery strategies
**Priorities:** Backup reliability, recovery speed, data integrity
**Typical arguments:**
- "Pre-backup critical for multi-agent work"
- "Validation needed post-work"
- "Rollback strategy undefined"

### SRE
**Perspective:** Production reliability, observability
**Priorities:** SLIs/SLOs, failure modes, monitoring
**Typical arguments:**
- "Requires circuit breaker for failures"
- "Health checks needed"
- "Production complexity increases"

### AI IDE Expert
**Perspective:** Claude Code, AI-assisted development
**Priorities:** AI workflow efficiency, context optimization, token management
**Typical arguments:**
- "Token consumption 2-5x with agents"
- "Model selection critical (Opus vs Sonnet)"
- "AI agent coordination overhead"

### Senior Prompt Engineer
**Perspective:** AI prompt optimization, instruction design
**Priorities:** Prompt clarity, token efficiency, instruction maintainability
**Typical arguments:**
- "Prompt orchestration masterpiece"
- "@ref pattern reduces tokens 60-80%"
- "Instruction bloat risk"

### TDD Expert
**Perspective:** Test-driven development, testing strategies
**Priorities:** Test speed, coverage, test maintainability
**Typical arguments:**
- "Parallel test generation accelerates TDD"
- "Test isolation critical"
- "Fast feedback required"

### UAT Engineer
**Perspective:** User acceptance testing, UX validation
**Priorities:** User scenarios, edge cases, documentation clarity
**Typical arguments:**
- "Multi-persona testing capability"
- "Novice user scenario missing"
- "Documentation unclear for power users"

## Consensus Levels

| Level | Threshold | Interpretation | Action |
|-------|-----------|----------------|--------|
| **Unanimous** | 13/13 agree | Clear best path | Proceed confidently |
| **Strong Majority** | 10-12 agree | Good path, minor concerns | Proceed with monitoring |
| **Majority** | 7-9 agree | Valid path, notable concerns | Proceed with safeguards |
| **Split** | 4-6 vs 4-6 | Trade-offs, context-dependent | Requires user decision |
| **No Consensus** | <4 agree | High uncertainty | Reject or gather more info |

## Integration

- **Requires:** Claude Code 2.1.16+ with Task tool
- **Related:** [agent-teams-parallel.md](agent-teams-parallel.md) for expert execution
- **Related:** [generate-report.md](generate-report.md) for report formatting
- **Reference:** [agent-teams-integration-plan.md](docs/reference/agent-teams-integration-plan.md) AT-015

## Error Handling

| Error | Recovery |
|-------|----------|
| Expert analysis timeout | Continue with partial expert set |
| Moderator synthesis fails | Present raw expert opinions |
| Report generation fails | Return synthesis in plain text |
| Token limit exceeded | Reduce expert count to top 8 by relevance |

---

## Quick Start

```
User: "Run expert consilium on: [PROBLEM STATEMENT]"

Claude: "Launching Expert Consilium with 13 experts..."
  → [Parallel analysis: 13 experts]
  → [Moderator synthesis]
  → [Report generated]

Result: docs/analysis/2026-02-10-consilium-{topic}.md
```

---

**Version:** 1.0.0
**Last Updated:** 2026-02-10
**Status:** READY FOR USE
