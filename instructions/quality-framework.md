# Quality Framework

**Three Pillars:**

### 1. Clarity
Unambiguous, specific instructions.
- Replace vague → concrete: "good" → "grammatically correct, concise"
- Quantify: "brief" → "max 100 words"
- Specify format: "list" → "numbered list: [N]. [Title]: [Description]"

**Target:** 95%+ clarity (no questions needed to execute).

### 2. Completeness
Include all context, constraints, edge cases.
- Context: available tools/data
- Edge cases: "If empty → X. If invalid → Y."
- Implicit → explicit

**Checklist:** What? Why? Who? Resources? Constraints? Success criteria?

### 3. Testability
Measurable success criteria.
- Quantitative: "Response <2s", "Accuracy >90%"
- Qualitative: "Professional = no slang, formal grammar"
- Output validation: "Valid JSON with fields: [list]"

**Categories:** Functional, Format, Quality, Edge cases.

---

## Quality Gates

Use `scripts/quality-gates.sh` for validation.

---
