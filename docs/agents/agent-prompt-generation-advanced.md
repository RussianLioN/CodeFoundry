# Agent Prompt Generation - Advanced Workflow

**Purpose:** Detailed agent creation process beyond P1 essentials.

---

## Step 1: Requirements Gathering (Russian Dialogue)

Sequential questions (one at a time):

```
🤖 Создаём промпт для AI-агента

**Вопрос 1: Роль агента**
Какую задачу выполняет агент?
Пример: "Анализирует код и ищет уязвимости"

**Вопрос 2: Специализация**
В чём эксперт?
Пример: "Python безопасность, OWASP Top 10"

**Вопрос 3: Тип проекта**
telegram-bot, web-service, ai-agent, data-pipeline,
microservices, fullstack, cli-tool, presentation?

**Вопрос 4: Взаимодействие**
С чем работает?
Код, документация, тесты, пользовательский ввод?

**Вопрос 5: Критерий успеха**
Как понять что агент работает?
Пример: "Находит не менее 80% уязвимостей"

**Вопрос 6: Ограничения**
Что агент НЕ должен делать?
Пример: "Не модифицировать код без разрешения"
```

---

## Step 2: Agent Archetype Selection

### Code Assistant
**Role:** Writes, refactors, reviews code
**Blocks:** Role + Task + Context + Tech Stack + Output Format + Examples

### Reviewer
**Role:** Code quality assessment
**Blocks:** Role + Review Framework + Quality Gates + Output Format

### Tester
**Role:** Test generation and coverage
**Blocks:** Role + Test Strategy + Coverage + Examples

### Documentation
**Role:** Doc creation and maintenance
**Blocks:** Role + Doc Style + Templates + Examples

### Debugger
**Role:** Issue diagnosis and resolution
**Blocks:** Role + Debug Process + Techniques + Tools

### Security
**Role:** Security vulnerability detection
**Blocks:** Role + OWASP Framework + Checklist + Severity

### DevOps
**Role:** Infrastructure and deployment
**Blocks:** Role + CI/CD + Infrastructure + Monitoring

### Coordinator
**Role:** Multi-agent orchestration
**Blocks:** Role + Agent Registry + Routing + Handoff

---

## Step 3: Structure Template

```yaml
agent_name: string
version: "1.0.0"

role: |
  [Concise role definition]

expertise:
  - [Area 1]
  - [Area 2]

task: |
  [What agent does]

context: |
  [When/how agent is used]

tech_stack:
  languages: [list]
  frameworks: [list]
  tools: [list]

output_format: |
  [Expected output structure]

examples:
  - input: "[example input]"
    output: "[example output]"

constraints:
  - [What NOT to do]

success_criteria:
  - [Measurable outcomes]
```

---

## Step 4: Generation Guidelines

1. **Role definition:** Clear, specific, domain-focused
2. **Expertise:** List 3-5 key areas
3. **Task:** Action-oriented, specific scope
4. **Context:** When to invoke this agent
5. **Output format:** Structured, parseable if possible
6. **Examples:** 2-3 representative examples
7. **Constraints:** Safety boundaries
8. **Success criteria:** Measurable outcomes

---

## Quality Checklist

- [ ] Role is specific (not "AI assistant")
- [ ] Expertise areas are domain-relevant
- [ ] Task has clear boundaries
- [ ] Output format is structured
- [ ] Examples cover main use cases
- [ ] Constraints prevent misuse
- [ ] Success criteria are measurable

---
