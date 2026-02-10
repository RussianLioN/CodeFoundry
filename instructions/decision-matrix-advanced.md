# Decision Matrix - Advanced Guide

**Purpose:** Detailed mode selection framework beyond P1 essentials.

---

## Criticality Indicators

### Experimental
- Prototyping, learning exploration
- Personal projects, one-off tasks
- Low stakes, easy to retry
- Example: "Draft a blog post outline"

### Production
- Business processes, customer-facing
- Regular use, team workflows
- Some rework acceptable but costly
- Example: "Generate customer email responses"

### Critical
- Regulated industries (finance, health, legal)
- Safety systems, high-value transactions
- Compliance requirements
- Example: "Medical diagnosis assistance"

---

## Complexity Examples

### Simple Tasks
- Format this text as JSON
- Summarize article in 3 sentences
- Translate English to Spanish
- Extract dates from text

### Medium Tasks
- Analyze feedback → sentiment + topic categories
- Generate SEO-optimized product descriptions
- Create quiz questions from educational content
- Multi-step data transformation

### Complex Tasks
- Multi-turn conversation agent with context
- Code review bot with style guide enforcement
- Content moderation with nuanced policy
- Adaptive learning system

---

## Mode Selection Rationale

| Criticality | Complexity | Mode | Why |
|-------------|------------|------|-----|
| Experimental | Simple | Express | Fast iteration, low cost of failure |
| Experimental | Medium | Express | Learn quickly, refine in next iteration |
| Experimental | Complex | Hybrid | Some guidance prevents expensive mistakes |
| Production | Simple | Express | Efficiency, clear requirements |
| Production | Medium | Standard | Cost-effective, good balance |
| Production | Complex | Careful | Thoroughness justified by impact |
| Critical | Simple | Careful | Even simple tasks need rigor |
| Critical | Medium | Careful | High stakes require thoroughness |
| Critical | Complex | Careful+Review | Maximum rigor, human review required |

---

## Hybrid Mode

When to use:
- Experimental + Complex: Need guidance but can iterate
- Learning + Production: Building new production capability

Hybrid approach:
- Start with Standard mode thoroughness
- Add Express mode iteration for refinement
- Document decisions for future reference

---

## Careful+Review Mode

When to use:
- Critical + Complex: Maximum risk mitigation

Process:
1. Use Careful mode for initial output
2. Add human review step before delivery
3. Create review checklist based on critical success factors
4. Document review decision rationale

---
