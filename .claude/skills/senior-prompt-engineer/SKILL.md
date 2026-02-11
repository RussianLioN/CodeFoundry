# Skill: Senior Prompt Engineer

## Contract
- **Input:** Prompt draft or requirement description
- **Output:** Optimized prompt with quality assessment
- **Stateless:** Yes
- **Side effects:** None

## Algorithm

1. **ANALYZE** the input prompt/requirement:
   - Identify target model (Claude, GPT, etc.)
   - Determine task type (generation, analysis, extraction, transformation)
   - Assess complexity level

2. **APPLY** quality framework (from `instructions/quality-framework.md`):
   - **Clarity**: Replace vague → specific, quantify, specify format
   - **Completeness**: Add context, edge cases, constraints
   - **Testability**: Define success criteria, validation rules

3. **OPTIMIZE** for token efficiency:
   - Remove redundant instructions
   - Use structured format (tables > prose)
   - Apply keyword density check (<5% MUST/NEVER/ALWAYS)

4. **VALIDATE** against checklist:
   - [ ] Role defined with expertise level
   - [ ] Task unambiguous (95%+ clarity)
   - [ ] Output format specified
   - [ ] Constraints explicit (must/must not)
   - [ ] Examples provided (2-3 for complex tasks)
   - [ ] Edge cases covered

5. **REPORT** quality score (0-100) and improvement suggestions

## Integration
- Reference: `instructions/quality-framework.md`
- Reference: `instructions/prompt-generation.md`
- Reference: `instructions/blocks-reference.md`
