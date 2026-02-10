# Quality Framework - Advanced Techniques

**Purpose:** Detailed quality guidelines beyond P1 essentials.

---

## Clarity Techniques

### Anti-patterns

❌ **Vague:**
- "Create engaging content"
- "Make it fast"
- "Good user experience"

✅ **Specific:**
- "Create content with: 1) conversational tone, 2) 2-3 questions/section, 3) actionable examples"
- "Response time <2 seconds for p95"
- "UX follows WCAG 2.1 AA, keyboard navigation, screen reader compatible"

### Format Specifications

**Instead of:** "List the items"
**Use:** "Numbered list format: [N]. **[Title]:** [Description]"

**Instead of:** "JSON output"
**Use:** "JSON with fields: `{name: string, count: number, status: 'active'|'inactive'}`"

---

## Completeness Techniques

### Context Dump Template

```
**Available:**
- Data: [describe datasets]
- Tools: [list available tools]
- Knowledge: [domain expertise]
- Constraints: [time, resources, limits]
```

### Edge Case Framework

**Input validation:**
- Empty → [action]
- Invalid type → [action]
- Out of range → [action]
- Malformed → [action]

**Output validation:**
- No results → [fallback]
- Too many results → [pagination/filter]
- Error state → [recovery action]

---

## Testability Techniques

### Quantitative Criteria

| Metric | Good Example | Bad Example |
|--------|--------------|-------------|
| Response time | "<2s p95" | "fast" |
| Accuracy | ">90% F1 score" | "accurate" |
| Coverage | ">80% line coverage" | "well tested" |

### Qualitative Rubrics

**Professional tone:**
- No slang or emojis
- Formal grammar (complete sentences)
- Industry-standard terminology
- Neutral to positive voice

**Code quality:**
- Follows project style guide
- No commented-out code
- Descriptive variable names
- Error handling present

---

## Testing Categories

### 1. Functional Testing
Does it produce correct output for valid inputs?

### 2. Format Testing
Is output structured as specified?

### 3. Quality Testing
Does it meet quality bar (clarity, completeness, style)?

### 4. Edge Case Testing
Handles errors, empty inputs, boundary conditions?

---

## Quality Gates Integration

Use `scripts/quality-gates.sh` for automated validation:
- `make gate-blocking` — run only blocking checks
- `make gate-all` — run all checks including non-blocking

---
