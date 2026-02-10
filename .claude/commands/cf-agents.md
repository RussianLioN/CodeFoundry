# cf-agents — Generate AI Agents for Project

> **Slash command:** `/cf-agents` or `/agents`
> **Aliases:** `generate agents`, `создай агента`, `сгенерируй агента`
> **Category:** Agent Generation

## Description

Generates specialized AI agents for a project using CodeFoundry Agent Inheritance System.

## Usage

```
/cf-agents [project-name] [options]
```

### Examples

```
# Interactive mode
/cf-agents

# Generate for existing project
/cf-agents my-delivery-bot

# With specific agents
/cf-agents my-bot --agents=coordinator,code_assistant,reviewer

# All available agents
/cf-agents my-bot --all

# Natural language
"Generate agents for my-delivery-bot"
"Сгенерируй агентов для проекта my-bot"
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project-name` | string | Yes | Project name |
| `--agents` / `-a` | list | No | Specific agents (comma-separated) |
| `--all` | flag | No | Generate all available agents |
| `--language` / `-l` | string | No | Override project language |
| `--framework` / `-f` | string | No | Override project framework |
| `--force` | flag | No | Overwrite existing agents |

## Available Agents

| Agent | ID | Description | Complexity |
|-------|-----|-------------|------------|
| **Coordinator** | `coordinator` | Orchestrates other agents, manages context | Medium |
| **Code Assistant** | `code_assistant` | Writes code, implements features | Medium |
| **Reviewer** | `reviewer` | Code review, quality checks | High |
| **Tester** | `tester` | Test generation, coverage | Medium |
| **Documentation** | `documentation` | Auto-documentation | Low |
| **Debugger** | `debugger` | Debugging assistance | High |
| **Security** | `security` | Security analysis | Very High |
| **Performance** | `performance` | Performance optimization | High |

### Agent Descriptions

#### Coordinator
- **Role:** Central orchestrator for multi-agent workflows
- **Capabilities:**
  - Route tasks to appropriate agents
  - Maintain conversation context
  - Aggregate agent responses
  - Handle agent conflicts
- **Best for:** Complex projects requiring multiple agents

#### Code Assistant
- **Role:** Primary coding agent
- **Capabilities:**
  - Write code following project conventions
  - Implement features from requirements
  - Refactor existing code
  - Generate boilerplate
- **Best for:** All projects (REQUIRED)

#### Reviewer
- **Role:** Code quality assurance
- **Capabilities:**
  - Review code changes
  - Check for bugs and anti-patterns
  - Enforce style guidelines
  - Suggest improvements
- **Best for:** Production applications

#### Tester
- **Role:** Test generation and coverage
- **Capabilities:**
  - Generate unit tests
  - Create integration tests
  - Check coverage levels
  - Suggest test scenarios
- **Best for:** Projects with quality requirements

#### Documentation
- **Role:** Automatic documentation
- **Capabilities:**
  - Generate docstrings
  - Create API documentation
  - Update README files
  - Maintain PROJECT.md
- **Best for:** Open source, team projects

#### Debugger
- **Role:** Debugging assistance
- **Capabilities:**
  - Analyze error messages
  - Suggest fixes
  - Trace execution flow
  - Identify root causes
- **Best for:** Complex debugging

#### Security
- **Role:** Security analysis
- **Capabilities:**
  - Scan for vulnerabilities
  - Check for secrets leakage
  - Validate input handling
  - Suggest security fixes
- **Best for:** Production, user-facing apps

#### Performance
- **Role:** Performance optimization
- **Capabilities:**
  - Identify bottlenecks
  - Suggest optimizations
  - Analyze complexity
  - Benchmark code
- **Best for:** High-performance applications

## Workflow

### 1. Project Analysis
```
🔍 Analyzing project: my-delivery-bot

✅ Project type: telegram-bot
✅ Language: Python
✅ Framework: aiogram
✅ Existing agents: None
```

### 2. Agent Selection
```
🤖 Recommended agents:
   ✅ Coordinator — REQUIRED for multi-agent workflows
   ✅ Code Assistant — REQUIRED for development
   ☐ Reviewer — Recommended for production
   ☐ Tester — Recommended for quality assurance

Generate all recommended agents? (yes/no/custom)
> yes
```

### 3. Generation
```
[███████████] 100% ✅

🤖 Agents generated:

   ✅ .claude/coordinator.md (450 lines)
   ✅ .claude/code_assistant.md (380 lines)
   ✅ .claude/reviewer.md (520 lines)
   ✅ .claude/tester.md (410 lines)

📝 AGENTS.md updated
🔗 Cross-references configured
🎯 Ready to use!
```

### 4. Usage
```
💡 Start using agents:

   1. Your project now has specialized AI agents
   2. Agents auto-activate based on context
   3. Or use: "Ask coordinator to review this code"

📖 See: .claude/AGENTS.md for full agent catalog
```

## Agent Registry

After generation, `.claude/AGENTS.md` contains:

```markdown
# AI Agents Registry

## Available Agents

### Coordinator
- **File:** coordinator.md
- **Triggers:** ["coordinate", "orchestrate", "manage agents"]
- **Capabilities:** [routing, context, aggregation]

### Code Assistant
- **File:** code_assistant.md
- **Triggers:** ["write", "implement", "create"]
- **Capabilities:** [coding, refactoring, boilerplate]

...
```

## Configuration

Default agent set in `.claude/settings.json`:

```json
{
  "cf-agents": {
    "defaultAgents": [
      "coordinator",
      "code_assistant"
    ],
    "recommendedAgents": {
      "telegram-bot": ["coordinator", "code_assistant", "reviewer"],
      "web-service": ["coordinator", "code_assistant", "reviewer", "tester"],
      "ai-agent": ["coordinator", "code_assistant", "documentation"],
      "fullstack": ["coordinator", "code_assistant", "reviewer", "tester", "documentation"]
    },
    "generateOnCreate": true
  }
}
```

## Auto-Routing

Agents auto-activate based on keywords:

```javascript
// User message: "Review this function"
// → Routes to Reviewer agent

// User message: "Write a new endpoint"
// → Routes to Code Assistant agent

// User message: "Generate tests for User model"
// → Routes to Tester agent
```

## Integration with Gateway

```javascript
// WebSocket message
{
  type: 'chat',
  content: 'Сгенерируй агента для my-delivery-bot'
}

// Gateway → Agent Generator
{
  intent: 'generate_agents',
  params: {
    project_name: 'my-delivery-bot',
    project_type: 'telegram-bot'
  }
}
```

## Error Handling

| Error | Solution |
|-------|----------|
| `PROJECT_NOT_FOUND` | Verify project exists in workspace/projects/ |
| `AGENT_EXISTS` | Use `--force` to overwrite |
| `INVALID_LANGUAGE` | Check supported languages |
| `TEMPLATE_MISSING` | Report bug to CodeFoundry |

## Output Structure

```
project/.claude/
├── AGENTS.md                    # Agent registry
├── coordinator.md               # Coordinator agent
├── code_assistant.md            # Code Assistant agent
├── reviewer.md                  # Reviewer agent
├── tester.md                    # Tester agent
└── settings.local.json          # Local agent settings
```

## Related Commands

- `/cf-new` — Create new project (can generate agents automatically)
- `/cf-deploy` — Deploy project with agent validation
- `/cf-status` — Check agent status

## Implementation Notes

This command integrates with:
- `scripts/generate-agents.py` — Core agent generation script
- `scripts/analyze-agent-needs.py` — Agent recommendation engine
- `templates/agents/` — Agent template files
- `.claude/AGENTS.md` — Generated agent registry

---

**Version:** 1.0.0
**Last updated:** 2025-02-02
