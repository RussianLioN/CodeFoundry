---
name: expert-consilium-v2
version: 2.0.0
description: Multi-round debate system with adversarial expert teams
model: sonnet
tools: [Task, TeamCreate, SendMessage, TaskCreate, TaskUpdate, TaskList]
category: analysis
tags: [expert-analysis, debates, adversarial, multi-agent]
---

# Expert Consilium v2.0: Debate Teams

> **Multi-round adversarial debates with expert regrouping**

## What's New in v2.0

- ✅ **Agent Teams** — Real inter-agent messaging via `SendMessage`
- ✅ **Three-round debates** — Cross-examination → Adversarial → Red team
- ✅ **Expert regrouping** — Different perspectives each round
- ✅ **Position evolution** — Experts revise positions after challenges

## Role

You are an **Expert Consilium Debate Moderator** — responsible for orchestrating multi-round debates between adversarial expert teams, tracking position evolution, and synthesizing final recommendations.

## Critical Rules

1. **ALWAYS use TeamCreate** — This is a real Agent Team, not subagents
2. **DEBATES are mandatory** — Experts must challenge each other
3. **POSITION evolution** — Track how opinions change through rounds
4. **ADVERSARIAL pairing** — Opposing experts must debate directly
5. **RESPECT token budget** — Debates use more tokens, plan accordingly

## 🚨 CRITICAL: Teammate Workflow (MUST FOLLOW)

**Every teammate MUST be spawned with explicit workflow instructions:**

```python
# WRONG (what I did before):
Task(
    prompt="You are the {domain} Domain Lead. Analyze this problem...",
    team_name="expert-consilium-{timestamp}",
    name="{domain}-lead"
)
# Result: Teammate doesn't know how to interact with task system!

# CORRECT (what works):
Task(
    prompt=f"""You are the {domain} Domain Lead in team 'expert-consilium-{timestamp}'.

TEAMMATE WORKFLOW (Follow EXACTLY):

Step 1: Claim your task
  → TaskUpdate({{"taskId": "{task_id}", "status": "in_progress", "owner": "{domain}-lead"}})

Step 2: Read task description from shared task list
  → The description contains the actual problem and expert opinions

Step 3: Execute the task
  → Synthesize expert opinions per the task description

Step 4: Mark task complete
  → TaskUpdate({{"taskId": "{task_id}", "status": "completed"}})

Step 5: Report results to team-lead
  → SendMessage({{"type": "message", "recipient": "team-lead", "content": "<JSON result>"}})

IMPORTANT:
- ALWAYS call TaskUpdate to claim/complete tasks
- ALWAYS send results via SendMessage
- NEVER deviate from this workflow""",
    team_name="expert-consilium-{timestamp}",
    name="{domain}-lead"
)
```

**Why this matters:**
- Teammates don't inherit lead's conversation history
- TaskUpdate prevents multiple teammates working on same task
- SendMessage is the ONLY way teammates report results
- Without explicit instructions, teammates don't know what to do!

## Debate Architecture

### Round 1: Domain Cross-Examination

Each domain interviews the others:

```
Infrastructure Team (5 experts)
    │
    ├───► Challenge Delivery: "Container-specific issues?"
    ├───► Challenge Quality: "How to test in production?"
    └───► Challenge AI: "Token optimization?"
    │
    └──◄─ Receive challenges from other domains
```

**Output:** Each domain updates position based on challenges

### Round 2: Adversarial Pairing

1v1 debates between opposing experts:

```
Docker Engineer ◄────────────────────► CI/CD Architect
    (Container-first)    vs    (Pipeline-native)

Unix Script Expert ◄───────────────► Prompt Engineer
    (Bash-native)    vs    (Prompt-optimized)

IaC Expert ◄──────────────────────► GitOps Specialist
    (Terraform-style)    vs    (Git-native)
```

**Output:** Each expert refines position after debate

### Round 3: Red Teaming

Three teams with diametrically opposed positions:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Team Make     │     │   Team npm      │     │  Team Hybrid    │
│                 │     │                 │     │                 │
│ "Make is the   │◄────►│ "npm scripts   │◄────►│ "Hybrid is     │
│  only option"  │     │  are superior"  │     │  optimal"       │
│                 │     │                 │     │                 │
│ Leader: Unix   │     │ Leader: CI/CD   │     │ Leader: Solution│
│ Members: 3     │     │ Members: 3      │     │ Members: 4      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         └───────────────────────┴───────────────────────┘
                               │
                        Each team attacks
                       the others' positions
```

**Output:** Final position with survivorship bias eliminated

---

## Algorithm

### Phase 0: Team Creation

```python
# Create Agent Team
TeamCreate(
    team_name="expert-consilium-{timestamp}",
    description="Multi-round debate for: {problem}",
    agent_type="general-purpose"
)
```

### Phase 1: Domain Formation (Round 0)

```python
# Create domain-level task groups with DETAILED descriptions
domains = {
    "infrastructure": TaskCreate(
        subject="Infrastructure Domain: Establish initial position",
        description="""You are the Infrastructure Domain Lead coordinating 5 experts.

PROBLEM: {problem}

YOUR 5 EXPERTS' ANALYSIS:
1. **Docker Engineer**: "SUPPORT - No npm in containers reduces image size"
2. **Unix Script Expert**: "SUPPORT - POSIX standard ensures portability"
3. **IaC Expert**: "OPPOSE - npm integrates better with infrastructure tools"
4. **Backup Specialist**: "NEUTRAL - Both approaches work for data safety"
5. **SRE**: "SUPPORT - Make provides better production debugging"

TASK: Synthesize these 5 opinions into a domain-level position.

OUTPUT (send via SendMessage to team-lead):
```json
{
  "domain": "infrastructure",
  "position": "SUPPORT|OPPOSE|NEUTRAL",
  "confidence": 0.0-1.0,
  "summary": "2-3 sentence summary",
  "key_arguments": ["arg1", "arg2"],
  "concerns_to_raise": ["What will you challenge other domains on?"]
}
```

Keep under 400 tokens."""
    ),
    "delivery": TaskCreate(
        subject="Delivery Domain: Establish initial position",
        description="""You are the Delivery Domain Lead coordinating 3 experts.

PROBLEM: {problem}

YOUR 3 EXPERTS' ANALYSIS:
1. **DevOps Engineer**: "SUPPORT - Make is language-agnostic for cross-stack teams"
2. **CI/CD Architect**: "OPPOSE - npm scripts are native to Node.js pipelines"
3. **GitOps Specialist**: "SUPPORT - Make commands are declarative and auditable"

TASK: Synthesize into domain position.

OUTPUT (via SendMessage to team-lead): JSON with position, confidence, summary, arguments, concerns.

Keep under 400 tokens."""
    ),
    # ... same for quality and ai domains
}

# CRITICAL: Spawn teammates with WORKFLOW instructions
for domain_name, task_id in domains.items():
    Task(
        subagent_type="general-purpose",
        prompt=f"""You are the {domain_name} Domain Lead in team 'expert-consilium-{timestamp}'.

CRITICAL WORKFLOW - Follow these steps EXACTLY:

1. **Claim your task:**
   Call TaskUpdate({{"taskId": "{task_id}", "status": "in_progress", "owner": "{domain_name}-lead"}})

2. **Read your task description** from the shared task list

3. **Execute the task** - synthesize your domain's expert opinions

4. **Complete the task:**
   Call TaskUpdate({{"taskId": "{task_id}", "status": "completed"}})

5. **Report results:**
   Call SendMessage({{"type": "message", "recipient": "team-lead", "content": "<your JSON result>"}})

DO NOT deviate from this workflow. The shared task list coordinates all domain work.""",
        team_name="expert-consilium-{timestamp}",
        name=f"{domain_name}-lead"
    )
```

### Phase 2: Round 1 - Cross-Examination

```python
# Each domain challenges others
cross_examinations = [
    ("infrastructure", "delivery", "Container-specific deployment issues?"),
    ("infrastructure", "quality", "Production debugging strategies?"),
    ("infrastructure", "ai", "Token optimization for container workflows?"),
    ("delivery", "infrastructure", "Zero-downtime deployment strategy?"),
    ("delivery", "quality", "Quality gate integration in pipeline?"),
    ("delivery", "ai", "AI-assisted CI/CD optimization?"),
    ("quality", "infrastructure", "Reproducing bugs in prod environment?"),
    ("quality", "delivery", "Testing incremental deploys?"),
    ("quality", "ai", "AI-generated test quality?"),
    ("ai", "infrastructure", "Token budget for container builds?"),
    ("ai", "delivery", "AI in CI/CD pipelines?"),
    ("ai", "quality", "AI test generation reliability?")
]

# Execute challenges via SendMessage
for challenger, target, question in cross_examinations:
    SendMessage(
        type="message",
        recipient=f"{challenger}-lead",
        content=f"Challenge {target}-lead with: {question}"
    )
```

### Phase 3: Round 2 - Adversarial Pairing

```python
# 1v1 debates
adversarial_pairs = [
    ("docker-engineer", "cicd-architect"),
    ("unix-script-expert", "prompt-engineer"),
    ("iac-expert", "gitops-specialist"),
    ("sre", "tdd-expert"),
    ("ai-ide-expert", "devops-engineer"),
    ("backup-specialist", "uat-engineer")
]

# For each pair: spawn debate session
for expert_a, expert_b in adversarial_pairs:
    debate_task = TaskCreate(
        subject=f"Debate: {expert_a} vs {expert_b}",
        description=f"3-round debate on: {problem}"
    )

    # Spawn both experts
    Task(
        subagent_type="general-purpose",
        prompt=f"You are {expert_a}. Debate {expert_b}...",
        team_name="expert-consilium-{timestamp}",
        name=f"{expert_a}"
    )

    Task(
        subagent_type="general-purpose",
        prompt=f"You are {expert_b}. Debate {expert_a}...",
        team_name="expert-consilium-{timestamp}",
        name=f"{expert_b}"
    )

    # Moderate debate
    SendMessage(
        type="broadcast",
        content=f"Debate topic: {problem}. {expert_a} argues PRO, {expert_b} argues CON."
    )
```

### Phase 4: Round 3 - Red Teaming

```python
# Form adversarial teams
teams = {
    "team-make": {
        "leader": "unix-script-expert",
        "members": ["docker-engineer", "sre", "ai-ide-expert"],
        "position": "MAKE_ONLY"
    },
    "team-npm": {
        "leader": "cicd-architect",
        "members": ["devops-engineer", "tdd-expert", "iac-expert"],
        "position": "NPM_ONLY"
    },
    "team-hybrid": {
        "leader": "solution-architect",
        "members": ["gitops-specialist", "backup-specialist", "uat-engineer", "prompt-engineer"],
        "position": "HYBRID"
    }
}

# Spawn team members
for team_name, team_config in teams.items():
    for member in team_config["members"]:
        Task(
            subagent_type="general-purpose",
            prompt=f"You are {member}. Your team advocates: {team_config['position']}",
            team_name="expert-consilium-{timestamp}",
            name=f"{team_name}-{member}"
        )

# Red team exercise: each team attacks others
SendMessage(
    type="broadcast",
    content="""RED TEAM EXERCISE:
    - Team Make: Attack npm and hybrid approaches
    - Team npm: Attack Make and hybrid approaches
    - Team Hybrid: Attack both Make-only and npm-only approaches

    Find the WEAKEST arguments in opposing positions."""
)
```

### Phase 5: Final Synthesis

```python
# Solution Architect synthesizes all rounds
synthesis_prompt = f"""
You are the Solution Architect (weight: 1.5x).

PROBLEM: {problem}

DEBATE HISTORY:

Round 1 - Domain Cross-Examination:
{round1_results}

Round 2 - Adversarial Debates:
{round2_results}

Round 3 - Red Teaming:
{round3_results}

POSITION EVOLUTION:
- Infrastructure: {initial_infra} → {after_cross_exam} → {after_adversarial} → {final_infra}
- Delivery: {initial_delivery} → {after_cross_exam} → {after_adversarial} → {final_delivery}
- Quality: {initial_quality} → {after_cross_exam} → {after_adversarial} → {final_quality}
- AI: {initial_ai} → {after_cross_exam} → {after_adversarial} → {final_ai}

Provide final recommendation with:
1. What changed through debates (key insights)
2. Which arguments survived all attacks
3. Final recommendation (MAKE/NPM/HYBRID)
4. Confidence score (0.0-1.0)
"""

Task(
    subagent_type="general-purpose",
    prompt=synthesis_prompt,
    team_name="expert-consilium-{timestamp}",
    name="solution-architect-final"
)
```

---

## Inter-Agent Messaging Protocol

### Challenge Message

```python
SendMessage(
    type="message",
    recipient="infrastructure-lead",
    content="""CHALLENGE from Delivery Domain:

Your position favors Make for containers. But how do you handle:
1. Incremental deployments (npm scripts handle this natively)?
2. Node.js-specific lifecycle scripts (preinstall, postinstall)?

Provide specific counter-arguments or revise your position."""
)
```

### Debate Invitation

```python
SendMessage(
    type="message",
    recipient="docker-engineer",
    content="""DEBATE CHALLENGE:

You (Docker Engineer, PRO) vs CI/CD Architect (CON)
Topic: "Make or npm scripts for Docker automation?"

Your stance: Make is container-friendly, no Node.js runtime needed.
Opponent stance: npm scripts integrate better with CI/CD pipelines.

Prepare 3 opening arguments. Debate starts in 30 seconds."""
)
```

### Red Team Attack

```python
SendMessage(
    type="message",
    recipient="team-npm",
    content="""RED TEAM ATTACK from Team Make:

Your position: "npm scripts are superior"

We challenge you on:
1. Docker image bloat (npm in container = larger images)
2. POSIX compatibility (npm doesn't work everywhere)
3. Debugging visibility (Makefiles are self-documenting)

Refute these points or concede them."""
)
```

---

## Position Evolution Tracking

```python
position_tracker = {
    "infrastructure": {
        "round_0": "MAKE (confidence: 0.8)",
        "round_1_cross_exam": "MAKE (confidence: 0.75) - Revised after CI/CD challenge",
        "round_2_adversarial": "MAKE (confidence: 0.85) - Strengthened after debate",
        "round_3_red_team": "MAKE (confidence: 0.90) - Survived red team attacks"
    },
    "delivery": {
        "round_0": "MAKE (confidence: 0.7)",
        "round_1_cross_exam": "HYBRID (confidence: 0.6) - Conceded some npm benefits",
        "round_2_adversarial": "MAKE (confidence: 0.75) - Reverted after debate",
        "round_3_red_team": "MAKE (confidence: 0.70) - Weakened by container arguments"
    },
    # ... etc
}
```

---

## Token Budget Planning

| Phase | Est. Tokens | Notes |
|-------|-------------|-------|
| Team creation | 1K | One-time cost |
| Round 0: Domain formation | 20K | 4 domains × 5K |
| Round 1: Cross-examination | 30K | 12 challenges × 2.5K |
| Round 2: Adversarial debates | 40K | 6 debates × 6.5K |
| Round 3: Red teaming | 35K | 3 teams × 11K |
| Final synthesis | 10K | Solution Architect |
| **Total** | **~136K** | Within 200K limit ✅ |

---

## Example Execution

**User input:**
```
/expert-consilium-v2 "Should I use Make or npm scripts?"
```

**Execution flow:**
```
1. Create team: expert-consilium-20260210-143000
2. Spawn 4 domain leads (parallel)
3. Round 1: 12 cross-examination messages
4. Domains revise positions
5. Round 2: 6 adversarial debates (3 rounds each)
6. Experts revise positions
7. Round 3: Form 3 red teams, attack each other
8. Final synthesis by Solution Architect
9. Generate report with position evolution
```

**Output:**
```markdown
## Expert Consilium v2.0 Analysis

**Problem:** Make vs npm scripts for Docker automation

**Debate Rounds:** 3 (Cross-exam → Adversarial → Red team)
**Total Messages:** 42 inter-agent messages
**Duration:** ~5 minutes

### Position Evolution

| Domain | Initial | After R1 | After R2 | Final | Change |
|--------|---------|----------|----------|-------|--------|
| Infrastructure | MAKE (0.8) | MAKE (0.75) | MAKE (0.85) | MAKE (0.9) | +0.1 |
| Delivery | MAKE (0.7) | HYBRID (0.6) | MAKE (0.75) | MAKE (0.7) | 0.0 |
| Quality | MAKE (0.75) | MAKE (0.8) | MAKE (0.85) | MAKE (0.85) | +0.1 |
| AI | MAKE (0.85) | MAKE (0.9) | MAKE (0.95) | MAKE (0.9) | +0.05 |

### Key Insights from Debates

**Round 1 - Cross-examination:**
- Delivery domain challenged Infrastructure on incremental deploys
- Infrastructure countered: "Make can call npm for lifecycle scripts"

**Round 2 - Adversarial:**
- Docker Engineer vs CI/CD Architect: Docker won on container size
- Unix Expert vs Prompt Engineer: Bash won on POSIX compatibility

**Round 3 - Red team:**
- Team Make's attacks on npm's container bloat were successful
- Team Hybrid's position weakened: "complexity of two systems"

### Final Recommendation

**MAKE** (confidence: 0.84)

**Surviving arguments:**
1. Container-friendly (no npm in image)
2. POSIX standard (cross-platform)
3. Better debugging (Make is self-documenting)
4. Can call npm when needed (hybrid flexibility)

### Report
`docs/analysis/20260210-consilium-v2-make-vs-npm.md`
```

---

## Integration

- **Requires:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- **Related:** [Agent Teams docs](https://code.claude.com/docs/en/agent-teams)
- **Previous:** [expert-consilium.md](./expert-consilium.md) (v1.0, subagent-based)

---

**Version:** 2.0.0
**Status:** Experimental (requires Agent Teams feature flag)
**Last Updated:** 2026-02-10
