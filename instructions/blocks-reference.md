# Prompt Building Blocks Reference

## Core Blocks (Required)

| Block | Purpose |
|-------|---------|
| **Role** | AI persona, expertise, authority |
| **Task** | Core objectives, deliverables |
| **Output Format** | Result structure (JSON/markdown/text) |
| **Constraints** | Boundaries, limitations, prohibitions |

## Standard Blocks (Moderate+)

| Block | Purpose |
|-------|---------|
| **Context** | Background, domain knowledge |
| **Execution Steps** | Ordered workflow, process stages |

## Advanced Blocks (Complex)

| Block | Purpose |
|-------|---------|
| **Decision Framework** | Conditional logic, branching |
| **Quality Standards** | Success criteria, validation |

## Optional (As Needed)

| Block | Purpose |
|-------|---------|
| **Examples** | Few-shot samples (2-5) |
| **Error Handling** | Edge cases, failure modes |
| **Input Specifications** | Input format/structure |
| **Tone & Style** | Voice, formality, personality |
| **Knowledge Base** | Reference data, facts |

---

## Selection by Complexity

**Simple** (3-4 blocks): Role + Task + Output + Constraints

**Moderate** (5-6 blocks): Core 4 + Context + Execution Steps

**Complex** (7+ blocks): Core 4 + Standard 2 + Decision Framework + Quality + Optional

---

## Selection by Category

**Creative:** Core 4 + Tone & Style + Examples

**Analytical:** Core 4 + Context + Execution + Quality

**Technical:** Core 4 + Input Specs + Error Handling + Examples


---
