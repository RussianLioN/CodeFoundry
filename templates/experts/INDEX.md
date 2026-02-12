# Expert Templates Registry

**Date:** 2026-02-11
**Purpose:** Static prompts for Expert Consilium v2 to avoid API rate limits

---

## Template Structure

All expert prompts are stored as local markdown files. Expert Consilium v2.0.5 uses `Read` tool to load these templates instead of generating prompts dynamically.

### Domain Breakdown

#### Infrastructure & Deployment (5 experts)
1. **solution-architect.md** — System Design, Patterns (weight: 1.5×)
2. **senior-docker-engineer.md** — Container Architecture (weight: 1.0×)
3. **devops-engineer.md** — Automation, Deployment (weight: 1.0×)
4. **cicd-architect.md** — Pipeline Design (weight: 1.0×)
5. **infra-code-expert.md** — IaC Best Practices (weight: 1.0×)

#### Operations & Reliability (3 experts)
6. **gitops-specialist.md** — GitOps 2.0 (weight: 1.0×)
7. **sre.md** — Production Reliability (weight: 1.0×)
8. **backup-specialist.md** — Data Safety, Backup (weight: 1.0×)

#### Development Practices (3 experts)
9. **unix-script-expert.md** — Bash/Zsh Mastery (weight: 1.0×)
10. **tdd-expert.md** — TDD, Testing (weight: 1.0×)
11. **uat-engineer.md** — UAT, UX Validation (weight: 1.0×)

#### AI Integration (3 experts)
12. **ai-ide-expert.md** — Claude Code, AI Workflows (weight: 1.0×)
13. **senior-prompt-engineer.md** — High-Level Prompts (weight: 1.5×)

---

## Usage

Expert Consilium v2.0.5 loads templates using:

```python
# For each expert:
template_content = Read(f"templates/experts/{domain}/{expert_name}.md")
# Use template_content as the expert's system prompt
```

---

## Template Format

Each template follows this structure:

1. **Role & Expertise** — What is this expert's specialty?
2. **Key Questions** — What questions does this expert answer?
3. **Output Format** — JSON structure for position statement
4. **Guidelines** — Token limits and focus areas

---

## Benefits

- ✅ **No API calls for prompt generation** — Eliminates recursive rate limit
- ✅ **Predictable prompts** — Static, version-controlled, testable
- ✅ **Faster agent spawn** — No dynamic generation delay
- ✅ **Better quality** — Templates can be carefully crafted and reviewed
- ✅ **Reusable** — Templates can be shared across multiple agent runs

---

## Maintenance

When updating expert templates:
1. Edit the specific template file in `templates/experts/`
2. Version control changes via git
3. Test with Expert Consilium v2.0.5
4. Update this index if new experts are added

---

**Total Templates:** 13
**Total Domains:** 4
**Latest Version:** 1.0 (2026-02-11)
