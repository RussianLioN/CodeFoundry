# Agent Teams Integration Plan — CodeFoundry

> **Status:** PLANNED
> **Priority:** 🟡 NORMAL (P1)
> **Created:** 2026-02-10
> **Source:** Consilium of 13 Experts + CodeFoundry Project Review
> **Expected Duration:** 6-8 weeks (4 phases)

---

## Executive Summary

**Goal:** Integrate Claude Code Agent Teams capability into CodeFoundry's architecture while maintaining token optimization through @ref pattern.

**Expert Consensus:** 13 experts (Solution Architect, DevOps, GitOps, IaC, SRE, AI IDE, Prompt Engineer, TDD, UAT, Docker, Script Expert, CI/CD, Backup Specialist) reviewed the integration plan.

**Key Findings:**
- Current @ref pattern (60-80% token savings) + Agent Teams = perfect complementary architecture
- 12 specific opportunities identified across Core Config, Templates, Quality Gates
- Token overhead: 2-5x for parallel execution, but 3-5x faster completion

---

## Architecture Overview

### Hybrid Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CodeFoundry Meta-Level                   │
│  (CLAUDE.md + @ref modules = токен-оптимизация)             │
└────────────────────────┬────────────────────────────────────┘
                         ↓
        ┌────────────────┴────────────────┐
        ↓                                  ↓
┌──────────────────┐            ┌──────────────────┐
│  Кастомные Агенты │            │   Agent Teams    │
│  (Single-Agent)   │            │  (Multi-Agent)   │
└──────────────────┘            └──────────────────┘
        │                                  │
        • documentation-agent              • Parallel QA
        • tasks-sync                       • Code Review Teams
        • token-optimizer                  • Multi-file Updates
        • ollama-gemini-researcher         • Documentation Gen
        │                                  │
        └────────────────┬─────────────────┘
                         ↓
              ┌──────────────────────┐
              │  Generated Projects  │
              │  (with 2-8 agents)   │
              └──────────────────────┘
```

### Decision Matrix

| Task Complexity | Agent Type | Example |
|-----------------|------------|---------|
| Simple (1-2 files) | Custom Agent | documentation-agent for single file |
| Medium (3-5 files) | 2-3 Agent Teams | Multi-file doc update |
| Complex (5+ files) | 4+ Agent Teams + Coordinator | Full codebase review |

---

## Phase 1: Foundation (Week 1-2, Priority: HIGH)

### AT-001: Agent Teams Routing Rules

**Status:** PLANNED
**Priority:** HIGH
**Files:**
- `.claude/auto-routing-rules.json` — add agent-teams routes
- `.claude/schemas/auto-routing-rules.schema.json` — validate schema
- `.codefoundry/routing.yaml` (if exists)

**Implementation:**
```json
{
  "agent-teams": {
    "pattern": "parallel|multi-agent|agent team|review all",
    "agent": "general-purpose",
    "config": {
      "mode": "team",
      "max_agents": 4,
      "parallel": true
    },
    "priority": 3
  },
  "doc-update-team": {
    "pattern": "update docs.*all|documentation.*parallel",
    "agent": "general-purpose",
    "config": {
      "mode": "team",
      "agents": ["doc-guardian", "ref-validator", "task-archivist", "session-historian"]
    },
    "priority": 4
  }
}
```

**Acceptance:**
- [ ] Schema validation passes
- [ ] Routing rules match expected patterns
- [ ] Quality gates pass (`make gate-blocking`)

---

### AT-002: Backup Coordinator Agent

**Status:** PLANNED
**Priority:** HIGH (CRITICAL for safety)
**Files:**
- `.claude/agents/backup-coordinator.md` (~150 lines)
- `scripts/backup-coordinator.sh` (~200 lines)

**Expert Recommendation:** Backup & Disaster Recovery Specialist

> "Agent Teams work in parallel → multiple file writes → higher corruption risk. Need automatic backup before/after agent work."

**Capabilities:**
- Pre-work backup: git stash + filesystem snapshot
- State snapshots during work
- Post-work validation
- Automatic rollback on error

**Agent Template:**
```markdown
---
name: backup-coordinator
version: 1.0.0
description: Automatic backup/restore for Agent Teams operations

tools: [Read, Write, Bash]
category: safety
tags: [backup, safety, agent-teams]
---

# Role
You are a backup coordinator responsible for safety during Agent Teams operations.

## Critical Rules
1. **ALWAYS backup** before Agent Teams work
2. **Validate state** after work completes
3. **Rollback on error** automatically

## Algorithm
1. Detect Agent Teams operation starting
2. Create git stash
3. Create filesystem snapshot
4. Monitor work progress
5. Validate state post-work
6. Rollback if validation fails

## Error Handling
| Error | Recovery |
|-------|----------|
| Backup failed | Abort operation |
| Validation failed | Rollback from backup |
| Restore failed | Alert user, provide manual steps |

## @see-also
- [Quick Start](docs/agents/backup-coordinator.quick.md)
- [Agent Teams Integration](docs/reference/agent-teams-integration-plan.md)
```

**Acceptance:**
- [ ] Agent follows AGENT-CREATION-GUIDE format
- [ ] Backup script works (`bash -n` passes)
- [ ] Integration with quality gates

---

### AT-003: Quality Gates Parallelization

**Status:** PLANNED
**Priority:** HIGH
**Files:**
- `scripts/quality-gates.sh` — refactor for parallel execution
- `Makefile` — add `make quality-parallel` target

**Expert Recommendation:** Unix Script Expert

> "Your quality-gates.sh is sequential. Can parallelize with GNU parallel or make -j."

**Implementation:**
```bash
# Add to quality-gates.sh:
run_parallel_gates() {
    local jobs="${1:-4}"
    echo "Running quality gates in parallel (${jobs} jobs)..."
    parallel -j "${jobs}" ::: check_json check_refs check_tokens check_syntax
}

# Add to Makefile:
.PHONY: quality-parallel
quality-parallel: ## Run quality gates in parallel (faster)
	@bash scripts/quality-gates.sh --parallel
```

**Acceptance:**
- [ ] Parallel mode 3-4x faster than sequential
- [ ] All gates still pass
- [ ] Error reporting aggregates results

---

## Phase 2: Agent Teams Skills (Week 2-3, Priority: HIGH)

### AT-004: Create Agent Teams Skills

**Status:** PLANNED
**Priority:** HIGH
**Files:**
- `.claude/skills/agent-teams-parallel.md` (~40 lines)
- `.claude/skills/agent-teams-sequential.md` (~35 lines)
- `.claude/skills/agent-teams-safe-mode.md` (~45 lines)

**Skill Contracts:**

**agent-teams-parallel.md:**
```markdown
# Skill: Agent Teams Parallel Execution

## Description
Execute independent tasks in parallel using multiple agents.

## Input
- tasks: List of 3-5 independent tasks
- max_agents: Maximum parallel agents (default: 4)

## Output
- Results from all agents aggregated
- Execution time (vs sequential baseline)

## Example
> "Update CLAUDE.md, PROJECT.md, TASKS.md, SESSION.md in parallel using 4 agents"

## State Management
Each agent works on isolated files. No shared state.

## Dependencies
- Claude Code 2.1.16+
- Opus 4.6 model
```

**agent-teams-safe-mode.md:**
```markdown
# Skill: Agent Teams Safe Mode

## Description
Execute Agent Teams operations with automatic backup/rollback.

## Input
- operation: Agent Teams workflow to execute
- backup_mode: git-stash | filesystem-snapshot | both

## Output
- Operation results
- Backup location
- Validation status

## Safety Guarantees
1. Pre-work backup ALWAYS created
2. Post-work validation ALWAYS run
3. Automatic rollback on validation failure

## Dependencies
- backup-coordinator agent
- git stash
```

**Acceptance:**
- [ ] All skills follow skill contract format
- [ ] Examples work in practice
- [ ] Documentation links to integration plan

---

### AT-005: Documentation Update Team Skill

**Status:** PLANNED
**Priority:** HIGH
**Files:**
- `.claude/skills/doc-update-team.md` (~50 lines)

**Implementation:**
```markdown
# Skill: Documentation Update Team

## Description
Parallel documentation updates using specialized agents.

## Team Composition
- Agent 1: Documentation Guardian (routes, creates cross-refs)
- Agent 2: Reference Validator (@ref integrity)
- Agent 3: Task Archivist (tasks/archive/*)
- Agent 4: Session Historian (sessions/archive/*)

## Input
- update_scope: core | all | specific files
- validation_mode: strict | permissive

## Output
- Updated files
- Validation report
- Changed @ref links

## Example
> "Update all documentation with Agent Teams: 4 agents for docs/, templates/, scripts/, openclaw/"

## Token Budget
- Agent 1: 200 tokens
- Agent 2: 150 tokens
- Agent 3: 150 tokens
- Agent 4: 150 tokens
- Total: ~650 tokens (vs ~500 sequential)
- Speedup: ~3x faster
```

**Acceptance:**
- [ ] Skill works with 4 agents
- [ ] Token budget monitored
- [ ] Validation catches broken refs

---

## Phase 3: Integration (Week 3-5, Priority: MEDIUM)

### AT-006: GitOps 2.0 Workflow

**Status:** PLANNED
**Priority:** MEDIUM
**Files:**
- `.github/workflows/agent-teams-review.yml` (NEW)
- `.github/workflows/agent-teams-docs.yml` (NEW)

**Expert Recommendation:** GitOps Specialist

> "GitOps 2.0 = Declarative + Agent-driven. Agent Teams can autonomously update repo with oversight."

**Implementation:**
```yaml
# .github/workflows/agent-teams-review.yml
name: Agent Teams Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  agent-teams-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Claude Code
        run: |
          curl -fsSL https://code.anthropic.com/install.sh | sh

      - name: Run Agent Teams Review
        run: |
          claude "Run parallel code review with 4 agents analyzing docs/, templates/, scripts/, openclaw/"

      - name: Comment PR with Results
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('agent-review-report.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
```

**Acceptance:**
- [ ] Workflow triggers on PR
- [ ] Agent Teams review runs
- [ ] Results commented on PR

---

### AT-007: Project Generation Enhancement

**Status:** PLANNED
**Priority:** MEDIUM
**Files:**
- `scripts/new-project.sh` — add Agent Teams option
- `templates/archetypes/*/openclaw/workspace/AGENTS.md` — update

**Expert Recommendation:** AI IDE Expert

> "Your 8 archetypes with 2-8 agents each — perfect foundation for Agent Teams patterns."

**Changes:**
```bash
# Add to new-project.sh:
AGENT_TEAMS_FLAG=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --agent-teams)
      AGENT_TEAMS_FLAG="--agent-teams"
      shift
      ;;
  esac
done

# After project creation:
if [[ -n "$AGENT_TEAMS_FLAG" ]]; then
  echo "🔀 Generating Agent Teams configuration..."
  # Generate agent-teams-specific configs
fi
```

**Acceptance:**
- [ ] `--agent-teams` flag works
- [ ] Generated projects include Agent Teams skills
- [ ] Documentation updated

---

### AT-008: CLAUDE.md Integration Section

**Status:** PLANNED
**Priority:** MEDIUM
**Files:**
- `CLAUDE.md` — add Agent Teams section

**Implementation:**
```markdown
## 🔀 Agent Teams Integration

### When to Use
| Scenario | Approach |
|----------|----------|
| Multi-file documentation updates | "Используй Agent Teams для параллельного обновления" |
| Quality gates | "Запусти parallel quality gates с 4 агентами" |
| Codebase review | "Анализируй docs/, templates/, scripts/ параллельно" |

### Quick Reference
- **Parallel mode:** 2-5x token cost, 3-5x faster
- **Safe mode:** Automatic backup/rollback
- **Decision matrix:** Simple → Custom Agent, Complex → Agent Teams

### Related
- [@ref: docs/reference/agent-teams-integration-plan.md](docs/reference/agent-teams-integration-plan.md)
- [@ref: docs/agents/agent-teams.md](docs/agents/agent-teams.md)
```

**Acceptance:**
- [ ] Section added to CLAUDE.md
- [ ] @ref links validate
- [ ] Examples work in practice

---

## Phase 4: Observability (Week 5-6, Priority: MEDIUM)

### AT-009: Health Check System

**Status:** PLANNED
**Priority:** MEDIUM
**Files:**
- `.claude/commands/agents-health.md` (~50 lines)
- `scripts/check-agent-health.sh` (~100 lines)

**Expert Recommendation:** SRE

> "Production reliability requires health checks, circuit breakers, fallbacks."

**Implementation:**
```markdown
# Command: /agents-health

## Description
Check health status of all agents and Agent Teams.

## Output
| Agent | Status | Last Run | Token Usage | Errors |
|-------|--------|----------|-------------|--------|
| documentation-agent | ✅ Healthy | 5m ago | 1.2K | 0 |
| backup-coordinator | ✅ Healthy | 1h ago | 0.8K | 0 |
| agent-teams-docs | ⚠️ Degraded | 30m ago | 15K | 2 |

## Circuit Breakers
- If agent fails 3x → circuit opens → fallback to single-agent
- If token budget exceeded → stop parallel operations
- If error rate > 20% → alert user
```

**Acceptance:**
- [ ] Health check runs successfully
- [ ] Circuit breaker triggers on failures
- [ ] Fallback mode works

---

### AT-010: Token Budget Monitoring

**Status:** PLANNED
**Priority:** MEDIUM
**Files:**
- `scripts/monitor-token-usage.sh` (~80 lines)
- `.claude/skills/token-monitor.md` (~40 lines)

**Expert Recommendation:** AI IDE Expert

> "Token consumption 2-5x with Agent Teams. Monitor budgets closely."

**Implementation:**
```bash
#!/bin/bash
# scripts/monitor-token-usage.sh

# Track token usage for Agent Teams operations
log_token_usage() {
    local operation="$1"
    local agent="$2"
    local tokens="$3"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "{\"timestamp\":\"$timestamp\",\"operation\":\"$operation\",\"agent\":\"$agent\",\"tokens\":$tokens}" >> .claude/logs/tokens.jsonl
}

# Report usage
report_token_usage() {
    echo "## Token Usage (Last 7 Days)"
    echo "| Operation | Avg Tokens | Total Runs | Total Cost |"
    echo "|-----------|------------|------------|------------|"
    # Aggregate and report
}
```

**Acceptance:**
- [ ] Token logging works
- [ ] Weekly reports generated
- [ ] Budget alerts trigger

---

## Phase 5: Testing & Validation (Week 6-7, Priority: MEDIUM)

### AT-011: Agent Teams Test Suite

**Status:** PLANNED
**Priority:** MEDIUM
**Files:**
- `tests/agent-teams/` (NEW directory)
- `tests/agent-teams/test-parallel-docs.sh`
- `tests/agent-teams/test-safe-mode.sh`
- `tests/agent-teams/test-quality-gates.sh`

**Expert Recommendation:** TDD Expert

> "TDD requires fast feedback. Agent Teams can generate tests in parallel."

**Test Scenarios:**
1. **Parallel Documentation Update** — 4 agents update different files
2. **Safe Mode** — backup created, work done, validation passes
3. **Quality Gates** — parallel checks complete faster
4. **Token Budget** — usage monitored, alerts trigger
5. **Circuit Breaker** — failures trigger fallback

**Acceptance:**
- [ ] All test scenarios pass
- [ ] Coverage > 80%
- [ ] CI/CD integration works

---

### AT-012: Multi-Persona Testing

**Status:** PLANNED
**Priority:** MEDIUM
**Files:**
- `tests/agent-teams/persona-tests/` (NEW)
- `tests/agent-teams/persona-tests/novice.yml`
- `tests/agent-teams/persona-tests/power-user.yml`
- `tests/agent-teams/persona-tests/edge-case-explorer.yml`

**Expert Recommendation:** UAT Engineer

> "Agent Teams can simulate multiple users: novice, power user, edge case explorer."

**Implementation:**
```yaml
# tests/agent-teams/persona-tests/novice.yml
name: Novice User
scenario: First time using Agent Teams
focus: Documentation clarity
steps:
  1. Read docs/agents/agent-teams.quick.md
  2. Run: "Update docs with Agent Teams"
  3. Verify: Understands output
  4. Verify: Can repeat successfully

# tests/agent-teams/persona-tests/power-user.yml
name: Power User
scenario: Complex workflow with customization
focus: Efficiency and flexibility
steps:
  1. Run: "Parallel code review with custom agents"
  2. Modify: Agent configuration
  3. Verify: Customization works
```

**Acceptance:**
- [ ] All personas tested
- [ ] UX issues identified and fixed
- [ ] Documentation improved

---

## Phase 6: Documentation & Launch (Week 7-8, Priority: NORMAL)

### AT-013: Agent Teams Documentation

**Status:** PLANNED
**Priority:** NORMAL
**Files:**
- `docs/agents/agent-teams.md` — UPDATE with integration details
- `docs/agents/agent-teams.quick.md` — UPDATE
- `docs/agents/agent-teams.examples.md` — CREATE (~100 lines)

**Content:**
- Integration with CodeFoundry architecture
- Decision matrix for choosing Agent Teams vs Custom Agents
- Token budget considerations
- Safety guidelines (backup, validation, rollback)
- Troubleshooting common issues

**Acceptance:**
- [ ] Documentation complete
- [ ] Examples tested
- [ ] Cross-references validated

---

### AT-014: Launch Announcement

**Status:** PLANNED
**Priority:** NORMAL
**Files:**
- `SESSION.md` — add Session #17 entry
- `CHANGELOG.md` — add Agent Teams integration entry

**Content:**
```markdown
## Session #17 - 2026-02-10 ✅

**Фокус:** Agent Teams Integration Planning

### Достижения:
- ✅ CodeFoundry review completed with 3 parallel agents
- ✅ Expert consilium (13 experts) provided recommendations
- ✅ Integration plan created: 14 tasks across 6 phases
- ✅ Architecture validated: @ref + Agent Teams = complementary

### Artefacts:
- docs/reference/agent-teams-integration-plan.md (этот файл)
- TASKS.md: Phase 15 — Agent Teams Integration

### Next Steps:
- Phase 1: Foundation (AT-001 to AT-003)
- Phase 2: Agent Teams Skills (AT-004 to AT-005)
```

**Acceptance:**
- [ ] SESSION.md updated
- [ ] CHANGELOG.md updated
- [ ] Git tag created (optional)

---

## Dependencies

### Inter-Phase Dependencies
```
Phase 1 (Foundation)
    ↓
Phase 2 (Skills) ← depends on Phase 1 routing rules
    ↓
Phase 3 (Integration) ← depends on Phase 2 skills
    ↓
Phase 4 (Observability) ← depends on Phase 3 workflows
    ↓
Phase 5 (Testing) ← depends on Phase 4 monitoring
    ↓
Phase 6 (Documentation) ← depends on Phase 5 validation
```

### Task Dependencies
- AT-002 depends on AT-001 (backup agent needs routing rules)
- AT-005 depends on AT-004 (doc team skill needs base skills)
- AT-009 depends on AT-007 (health check needs project gen)
- AT-012 depends on AT-011 (persona tests need test suite)

---

## Risk Mitigation

### High-Risk Areas

| Risk | Impact | Mitigation | Owner |
|------|--------|------------|-------|
| Token budget overrun | HIGH | Monitoring, alerts, auto-stop | AT-010 |
| File corruption from parallel writes | HIGH | Backup coordinator, validation | AT-002 |
| Conflicting @ref references | MEDIUM | Dependency graph validation | AT-005 |
| Debugging complexity | MEDIUM | Comprehensive logging | AT-009 |
| Rate limiting (API 429) | LOW | Retry logic, backoff | AT-001 |

---

## Expert Consilium Summary

### Supporters (11/13)
- **Solution Architect:** "@ref + Agent Teams = perfect complementary architecture"
- **Unix Script Expert:** "Scripts already ready for parallel execution!"
- **DevOps Engineer:** "GitOps workflow + Agent Teams = autonomous updates"
- **CI/CD Architect:** "Natural extension of CI/CD patterns"
- **GitOps Specialist:** "GitOps 2.0 with AI agents!"
- **Prompt Engineer:** "Prompt orchestration masterpiece!"
- **TDD Expert:** "Test generation acceleration!"
- **UAT Engineer:** "Multi-persona testing capability!"
- **AI IDE Expert:** "Already using correct model (Opus 4.6)"
- **Backup Specialist:** "Critical: backup coordinator needed"
- **SRE:** "Requires safeguards: health checks, circuit breakers"

### Cautious Supporters (2/13)
- **Docker Engineer:** "Watch for port conflicts, network clashes"
- **IaC Expert:** "Parallel IaC gen can create inconsistent state"

### Consensus
**UNANIMOUS:** Proceed with integration, starting with Phase 1 (Foundation) with proper safeguards.

---

## Success Criteria

### Phase 1 Success
- [ ] Agent Teams routing rules work
- [ ] Backup coordinator operational
- [ ] Quality gates 3-4x faster in parallel mode

### Phase 2 Success
- [ ] All skills functional
- [ ] Documentation update team works
- [ ] Token budgets monitored

### Phase 3 Success
- [ ] GitOps 2.0 workflow deployed
- [ ] Project generation includes Agent Teams
- [ ] CLAUDE.md integration complete

### Phase 4 Success
- [ ] Health checks operational
- [ ] Token monitoring active
- [ ] Circuit breakers tested

### Phase 5 Success
- [ ] Test suite passes
- [ ] Multi-persona testing complete
- [ ] CI/CD integration validated

### Phase 6 Success
- [ ] Documentation complete
- [ ] Launch announced
- [ ] User feedback positive

---

## Timeline

| Phase | Duration | Start | End |
|-------|----------|-------|-----|
| Phase 1: Foundation | 1-2 weeks | Week 1 | Week 2 |
| Phase 2: Skills | 1-2 weeks | Week 2 | Week 3 |
| Phase 3: Integration | 2-3 weeks | Week 3 | Week 5 |
| Phase 4: Observability | 1-2 weeks | Week 5 | Week 6 |
| Phase 5: Testing | 1-2 weeks | Week 6 | Week 7 |
| Phase 6: Documentation | 1-2 weeks | Week 7 | Week 8 |

**Total:** 6-8 weeks

---

## Related Documents

- **Main Plan:** This file
- **Task Tracker:** [@ref: ../TASKS.md](../../TASKS.md) — Phase 15
- **Agent Teams Guide:** [@ref: ../agents/agent-teams.md](../agents/agent-teams.md)
- **Agent Creation:** [@ref: ../agents/AGENT-CREATION-GUIDE.md](../agents/AGENT-CREATION-GUIDE.md)
- **Quality Framework:** [@ref: ../instructions/quality-framework.md](../instructions/quality-framework.md)

---

**Version:** 1.0.0
**Last Updated:** 2026-02-10
**Next Review:** After Phase 1 completion (Week 2)

---

*This plan is based on the consilium of 13 experts: Solution Architect, Senior Docker Engineer, Unix Script Expert, DevOps Engineer, CI/CD Architect, GitOps Specialist, IaC Expert, Backup & Disaster Recovery Specialist, SRE, AI IDE Expert, Prompt Engineer, TDD Expert, UAT Engineer.*
