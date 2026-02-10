# Agent Router

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → **Agent Router**

---

## Purpose

Intelligent routing of user requests to the appropriate AI agent based on task type, complexity, and user preferences.

---

## Routing Architecture

```
User Request
      ↓
  Intent Parser
      ↓
  Agent Router
      ↓
┌─────┴─────┬─────────┬─────────┐
│           │         │         │
▼           ▼         ▼         ▼
Main Agent  Dev Agent  DevOps   Prompt
            Agent           Agent
```

---

## Agent Registry

```yaml
agents:
  main:
    id: "main"
    name: "Main Agent"
    model: "gemini-3-flash"
    temperature: 0.7
    tools: ["bash", "read", "write", "edit", "git", "docker", "browser"]
    sandbox: false
    triggers:
      default: true
      keywords: []
    system_prompt: |
      You are OpenClaw Main Agent - orchestrates all development tasks.
      You have full access to the system and can coordinate with other agents.

  dev:
    id: "dev"
    name: "Development Agent"
    model: "gemini-3-flash"
    temperature: 0.5
    tools: ["bash", "read", "write", "edit", "git"]
    sandbox: true
    triggers:
      keywords:
        - "напиши"
        - "создай"
        - "рефактори"
        - "код"
        - "функцию"
        - "class"
        - "function"
      patterns:
        - "/write .+/i"
        - "/create .+/i"
    system_prompt: |
      You are Development Agent - specializes in writing and refactoring code.
      You work in a sandboxed environment and focus on clean, tested code.

  devops:
    id: "devops"
    name: "DevOps Agent"
    model: "gemini-3-flash"
    temperature: 0.5
    tools: ["bash", "docker", "git", "cron"]
    sandbox: false
    triggers:
      keywords:
        - "деплой"
        - "запусти"
        - "перезапусти"
        - "docker"
        - "k8s"
        - "ci"
        - "cd"
        - "infrastructure"
    system_prompt: |
      You are DevOps Agent - specializes in deployment and infrastructure.
      You handle Docker, CI/CD, Kubernetes, and system operations.

  prompt:
    id: "prompt"
    name: "Prompt Engineer Agent"
    model: "gemini-3-flash"
    temperature: 0.7
    tools: ["read", "write", "edit"]
    sandbox: false
    triggers:
      keywords:
        - "промпт"
        - "prompt"
        - "системный промпт"
        - "инструкция"
        - "agent prompt"
    system_prompt: |
      You are Prompt Engineer Agent - creates and optimizes system prompts.
      You understand prompt engineering best practices and patterns.

  codefoundry:
    id: "codefoundry"
    name: "CodeFoundry Agent"
    model: "gemini-3-flash"
    temperature: 0.7
    max_tokens: 8192
    tools: ["bash", "read", "write", "edit", "git"]
    sandbox: false
    triggers:
      keywords:
        - "создай проект"
        - "новый проект"
        - "инициализируй"
        - "сгенерируй агента"
        - "сгенерируй агентов"
    workspace: "/workspace/system-prompts"
    system_prompt: |
      You are CodeFoundry Agent - specializes in project and agent generation.
      You use the CodeFoundry system to create complete project structures.
```

---

## Routing Logic

### 1. Keyword Matching

```typescript
function routeByKeywords(input: string): AgentID | null {
  const scores = new Map<AgentID, number>();

  for (const [agentId, agent] of AGENTS) {
    let score = 0;

    for (const keyword of agent.triggers.keywords) {
      if (input.toLowerCase().includes(keyword.toLowerCase())) {
        score += 10;
      }
    }

    if (score > 0) {
      scores.set(agentId, score);
    }
  }

  // Return agent with highest score
  if (scores.size > 0) {
    return [...scores.entries()].sort((a, b) => b[1] - a[1])[0][0];
  }

  return null; // No match
}
```

### 2. Pattern Matching

```typescript
function routeByPattern(input: string): AgentID | null {
  for (const [agentId, agent] of AGENTS) {
    if (agent.triggers.patterns) {
      for (const pattern of agent.triggers.patterns) {
        const regex = new RegExp(pattern, 'i');
        if (regex.test(input)) {
          return agentId;
        }
      }
    }
  }
  return null;
}
```

### 3. Context-Based Routing

```typescript
function routeByContext(input: string, context: SessionContext): AgentID {
  // Check current directory
  if (context.cwd.includes('/workspace/')) {
    return 'dev';
  }

  // Check git status
  if (context.gitStatus.hasChanges) {
    return 'dev';
  }

  // Check for docker-compose.yml
  if (context.files.includes('docker-compose.yml')) {
    return 'devops';
  }

  // Default
  return 'main';
}
```

### 4. Explicit Agent Selection

```typescript
// User can explicitly select agent
function parseExplicitSelection(input: string): AgentID | null {
  const match = input.match(/\/agent\s+(\w+)/i);
  if (match) {
    const agentId = match[1].toLowerCase();
    if (AGENTS.has(agentId)) {
      return agentId;
    }
  }
  return null;
}
```

---

## Handoff Protocol

### When to Handoff

```yaml
handoff_triggers:
  task_complexity:
    - "Эта задача требует {specialization} опыта"
    - "Передаю {target_agent} для специализации"

  tool_requirement:
    - "Мне нужны инструменты {target_agent}"
    - "Передаю управление {target_agent}"

  user_request:
    - "/agent {target_agent}"
    - "Позови {agent_name}"

  error_recovery:
    - "Не удалось выполнить. Передаю {target_agent}"
```

### Handoff Format

```markdown
## 🔀 Agent Handoff

**From:** Main Agent
**To:** {target_agent}
**Reason:** {reason}

---

### Context

{summary_of_conversation}

### Current Task

{current_task_description}

### Files Involved

{file_list}

### State

{current_state}

---

**Continue from here.**
```

---

## Multi-Agent Coordination

### Sequential Workflow

```yaml
workflow:
  name: "Create and Deploy Project"

  steps:
    - agent: codefoundry
      task: "Create telegram bot project"
      output: "project_path"

    - agent: dev
      task: "Add custom features to bot"
      depends_on: "project_path"
      output: "modified_files"

    - agent: devops
      task: "Deploy to staging"
      depends_on: "modified_files"
      output: "deployment_url"
```

### Parallel Execution

```yaml
workflow:
  name: "Full Stack Review"

  parallel:
    - agent: dev
      task: "Review backend code"
      files: "backend/"

    - agent: dev
      task: "Review frontend code"
      files: "frontend/"

  merge:
    agent: main
    task: "Compile review report"
```

---

## Agent Capabilities

```yaml
capabilities:
  main:
    - orchestration
    - coordination
    - decision_making
    - full_system_access

  dev:
    - code_writing
    - refactoring
    - debugging
    - testing
    - documentation

  devops:
    - deployment
    - infrastructure
    - monitoring
    - ci_cd
    - docker
    - kubernetes

  prompt:
    - prompt_engineering
    - system_prompts
    - agent_prompts
    - instruction_design

  codefoundry:
    - project_generation
    - agent_generation
    - template_rendering
    - architecture_design
```

---

## Fallback Chain

```typescript
function routeWithFallback(input: string, context: SessionContext): AgentID {
  // 1. Explicit selection
  const explicit = parseExplicitSelection(input);
  if (explicit) return explicit;

  // 2. Keyword matching
  const keyword = routeByKeywords(input);
  if (keyword) return keyword;

  // 3. Pattern matching
  const pattern = routeByPattern(input);
  if (pattern) return pattern;

  // 4. Context-based
  const contextRoute = routeByContext(input, context);
  if (contextRoute) return contextRoute;

  // 5. Default
  return 'main';
}
```

---

## Monitoring

```yaml
metrics:
  agent_selection:
    - agent_id
    - routing_method
    - confidence_score
    - handoff_count

  performance:
    - response_time
    - resolution_rate
    - user_satisfaction

  handoff:
    - source_agent
    - target_agent
    - reason
    - success_rate
```

---

## @ref Links

- [🎯 Workspace](../README.md) — All agents
- [🤖 Agents Index](AGENTS.md) — Agent descriptions
- [🛠️ Skills](SKILLS-INDEX.md) — Available skills

---

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → **Agent Router**
