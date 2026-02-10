# Command Resolver Skill

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → [Skills](SKILLS-INDEX.md) → **Command Resolver**

---

## Purpose

Convert parsed intent objects into executable system commands (Make targets, scripts, or direct commands).

---

## How It Works

```
Parsed Intent
      ↓
Command Resolver
      ↓
Executable Command + Validation + Execution Plan
      ↓
Executor (Bash tool)
```

---

## Intent-to-Command Mapping

### create_project

```yaml
intent:
  category: create_project
  parameters:
    archetype: telegram-bot
    name: my-bot
    location: ./my-bot

resolution:
  command: make
  args:
    - "new"
    - "ARCHETYPE=telegram-bot"
    - "NAME=my-bot"
  cwd: /workspace/system-prompts
  env: {}
  validation:
    - archetype_exists
    - name_valid
  estimated_time: "30-60s"
```

### generate_agents

```yaml
intent:
  category: generate_agents
  parameters:
    project_name: my-service
    project_type: web-service
    language: python

resolution:
  command: make
  args:
    - "generate-agents"
    - "NAME=my-service"
    - "TYPE=web-service"
    - "LANG=python"
  cwd: /workspace/system-prompts
  env: {}
  validation:
    - project_exists
    - has_agent_templates
  estimated_time: "10-20s"
```

### deploy

```yaml
intent:
  category: deploy
  parameters:
    environment: staging
    project_name: my-service

resolution:
  command: make
  args:
    - "deploy"
    - "ENV=staging"
  cwd: /workspace/my-service
  env:
    DEPLOY_ENV: staging
  validation:
    - environment_exists
    - tests_passing
  estimated_time: "2-5 min"
```

---

## Command Templates

### Template: make_new

```typescript
interface MakeNewCommand {
  executable: "make";
  args: [
    "new",
    `ARCHETYPE=${params.archetype}`,
    `NAME=${params.name}`,
    ...(params.location ? [`LOCATION=${params.location}`] : []),
    ...(params.language ? [`LANG=${params.language}`] : []),
    ...(params.framework ? [`FW=${params.framework}`] : [])
  ];
  cwd: "/workspace/system-prompts";
}
```

### Template: generate_agents

```typescript
interface GenerateAgentsCommand {
  executable: "make";
  args: [
    "generate-agents",
    `NAME=${params.project_name}`,
    `TYPE=${params.project_type}`,
    ...(params.language ? [`LANG=${params.language}`] : []),
    ...(params.framework ? [`FW=${params.framework}`] : [])
  ];
  cwd: "/workspace/system-prompts";
}
```

### Template: git_commit

```typescript
interface GitCommitCommand {
  executable: "git";
  args: [
    "commit",
    "-m",
    params.message || "Auto-commit by OpenClaw"
  ];
  cwd: params.project_dir || process.cwd();
  validation: [
    "has_staged_changes"
  ];
}
```

---

## Validation Layer

### Pre-execution Validation

```yaml
validations:
  archetype_exists:
    check: |
      [ -f "archetypes/${archetype}/template.json" ]
    error: "Archetype ${archetype} not found"
    fix: "Available archetypes: ${list_archetypes()}"

  name_valid:
    check: |
      [[ "$name" =~ ^[a-zA-Z0-9-]+$ ]] && [ ${#name} -ge 3 ]
    error: "Invalid project name: ${name}"
    fix: "Use alphanumeric characters, min 3 chars"

  project_exists:
    check: |
      [ -d "${project_dir}" ]
    error: "Project ${project_name} not found"
    fix: "Create project first or check path"

  tests_passing:
    check: |
      make test > /dev/null 2>&1
    error: "Tests are failing"
    fix: "Fix failing tests before deployment"
```

---

## Execution Plan

### Example: Full Project Creation

```yaml
stage_1_preparation:
  - validate: archetype_exists
  - validate: name_valid
  - check: workspace_is_clean
  duration: "2s"

stage_2_execution:
  - command: make new ARCHETYPE=telegram-bot NAME=my-bot
  - show_output: true
  - duration: "30-60s"

stage_3_validation:
  - check: project_directory_created
  - check: config_files_exist
  - check: git_initialized
  duration: "5s"

stage_4_cleanup:
  - remove: temporary_files
  - log: operation_complete
  duration: "2s"

total_estimated_time: "40-70s"
```

---

## Error Recovery

### Error: Archetype Not Found

```yaml
error:
  code: ARCHETYPE_NOT_FOUND
  message: "Archetype 'xyz' not found"

recovery:
  automatic: false
  suggestions:
    - "Available archetypes: telegram-bot, web-service, ai-agent, fullstack"
    - "Did you mean 'web-service'?"

  user_prompt: |
    Архетип 'xyz' не найден.

    Доступные архетипы:
    • telegram-bot — Telegram бот
    • web-service — REST/GraphQL API
    • ai-agent — AI ассистент
    • fullstack — Fullstack приложение
    • data-pipeline — ETL пайплайн

    Выберите архетип или исправьте команду.
```

### Error: Project Already Exists

```yaml
error:
  code: PROJECT_EXISTS
  message: "Directory 'my-bot' already exists"

recovery:
  automatic: false
  options:
    - label: "Use existing project"
      action: "cd_into_project"

    - label: "Create with different name"
      action: "prompt_new_name"

    - label: "Remove and recreate"
      action: "rm_and_create"
      confirm: true
```

---

## Progress Feedback

```typescript
interface ExecutionProgress {
  stage: "preparation" | "execution" | "validation" | "cleanup";
  progress: number; // 0-100
  message: string;
  duration?: {
    elapsed: number;
    estimated: number;
  };
  output?: string; // Last N lines of command output
}

// Example updates during execution
{
  stage: "execution",
  progress: 45,
  message: "Creating project structure...",
  duration: { elapsed: 15, estimated: 45 }
}

{
  stage: "execution",
  progress: 100,
  message: "✅ Project created successfully!",
  duration: { elapsed: 38, estimated: 45 }
}
```

---

## Rollback on Failure

```yaml
rollback:
  enabled: true
  triggers:
    - execution_failed
    - validation_failed

  actions:
    - remove: created_directories
    - git: reset_changes
    - restore: previous_state

  conditions:
    - only_if: no_external_modifications
    - confirm: true
```

---

## Integration with Make

### Reading Available Targets

```bash
# List all make targets
make -pn | grep '^[^.]*:'

# Parse for documentation
make help
```

### Dynamic Target Discovery

```typescript
interface MakeTarget {
  name: string;
  description: string;
  parameters: Record<string, string>;
  category: string;
}

// Auto-discover targets from Makefile
async function discoverTargets(): Promise<MakeTarget[]> {
  const output = await exec('make help');
  return parseMakeHelp(output);
}
```

---

## @ref Links

- [🎯 Intent Parser](intent-parser.md) — Parse natural language
- [⚙️ Command Executor](command-executor.md) — Execute commands
- [📋 Project Initializer](../agents/project-initializer.md) — Project workflow

---

## Configuration

```yaml
command_resolver:
  make_path: /usr/bin/make
  makefile_dir: /workspace/system-prompts
  default_timeout: 300000  # 5 minutes
  max_output_lines: 1000
  enable_rollback: true
  log_commands: true

  aliases:
    create: new
    generate: new
    init: new

  shortcuts:
    bot: telegram-bot
    api: web-service
    saas: fullstack
```

---

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → [Skills](SKILLS-INDEX.md) → **Command Resolver**
