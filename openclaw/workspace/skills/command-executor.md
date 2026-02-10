# Command Executor Skill

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → [Skills](SKILLS-INDEX.md) → **Command Executor**

---

## Purpose

Execute resolved commands safely with progress feedback, error handling, and rollback capabilities.

---

## Execution Model

```
Executable Command
        ↓
   Pre-flight Checks
        ↓
   Execution (with monitoring)
        ↓
   Post-flight Validation
        ↓
   Result / Rollback
```

---

## Pre-flight Checks

```yaml
checks:
  executable_exists:
    command: which ${executable}
    required: true

  working_directory:
    command: test -d ${cwd}
    required: true

  disk_space:
    command: df -h ${cwd} | awk 'NR==2 {print $4}'
    min_required: "1G"

  permissions:
    command: test -w ${cwd}
    required: true

  dependencies:
    command: |
      for dep in ${dependencies}; do
        which $dep || exit 1
      done
    required: true
```

---

## Execution Modes

### 1. Streaming (Default)

```typescript
interface StreamingExecution {
  mode: "streaming";
  buffer_size: 8192;
  filters: {
    include: RegExp[];
    exclude: RegExp[];
  };
  on_output: (line: string) => void;
  on_error: (line: string) => void;
  on_complete: (result: ExecutionResult) => void;
}
```

**Use for:** Long-running commands with visible output

```bash
# Example: make new
[████████████░░] 80% Creating project structure...
Created: /workspace/my-bot/
Created: /workspace/my-bot/.env.example
Created: /workspace/my-bot/README.md
✅ Project ready!
```

### 2. Silent

```typescript
interface SilentExecution {
  mode: "silent";
  show_on_completion: boolean;
  max_output_lines: 50;
}
```

**Use for:** Quick status checks, non-critical operations

### 3. Interactive

```typescript
interface InteractiveExecution {
  mode: "interactive";
  stdin: string;
  timeout: number;
  expect_prompt: RegExp;
}
```

**Use for:** Commands requiring user input

---

## Progress Indicators

```yaml
progress:
  format: "[{bar}] {percent}% {message}"

  states:
    running:
      icon: "▶"
      color: "blue"

    success:
      icon: "✅"
      color: "green"

    error:
      icon: "❌"
      color: "red"

    warning:
      icon: "⚠️"
      color: "yellow"

  examples:
    - "[▶        ] 10% Initializing..."
    - "[█████░░░░] 50% Creating files..."
    - "[█████████░] 90% Almost done..."
    - "[██████████] 100% ✅ Complete!"
```

---

## Error Handling

### Error Categories

```yaml
errors:
  command_not_found:
    severity: critical
    recoverable: false
    message: "Команда не найдена: {command}"
    suggestion: "Установите {package} или проверьте PATH"

  permission_denied:
    severity: critical
    recoverable: true
    message: "Недостаточно прав"
    suggestion: "Запустите с sudo или проверьте владельца файлов"

  timeout:
    severity: error
    recoverable: true
    message: "Таймаут выполнения"
    suggestion: "Команда выполнялась слишком долго. Попробуйте снова."

  validation_failed:
    severity: warning
    recoverable: true
    message: "Проверка не пройдена: {check}"
    suggestion: "{fix}"
```

### Error Recovery

```typescript
interface ErrorRecovery {
  error: ExecutionError;
  can_retry: boolean;
  max_retries: number;
  retry_delay: number;

  strategies: {
    fix_permissions: boolean;
    retry_with_sudo: boolean;
    rollback_changes: boolean;
    suggest_alternative: string;
  };
}
```

---

## Output Processing

### Filtering

```yaml
filters:
  # Remove ANSI codes
  ansi: true

  # Highlight keywords
  highlights:
    - pattern: "(error|failed|ERROR)"
      color: "red"
    - pattern: "(success|done|complete)"
      color: "green"
    - pattern: "(warning|warn)"
      color: "yellow"

  # Remove verbose output
  exclude:
    - "^\\s*$"  # empty lines
    - "^DEBUG:"  # debug messages

  # Limit output
  max_lines: 100
  truncate_after: 5000  # characters
```

### Formatting

```typescript
interface OutputFormatter {
  format: "raw" | "markdown" | "json";

  markdown: {
    code_blocks: true;
    line_numbers: false;
    syntax_highlight: "bash";
  };

  json: {
    structured: true;
    include_metadata: true;
  };
}
```

---

## Rollback Mechanism

```yaml
rollback:
  enabled: true

  triggers:
    - command_returned_non_zero
    - validation_failed
    - user_cancelled

  operations:
    remove_created_files:
      - find ${cwd} -type f -newer /tmp/before_marker -delete
      - find ${cwd} -type d -empty -delete

    revert_git_changes:
      - git reset --hard HEAD
      - git clean -fd

    restore_backup:
      - cp -r /tmp/backup/* ${cwd}/

  safety:
    require_confirmation: true
    show_affected_files: true
    max_rollback_time: 30
```

---

## Execution Examples

### Example 1: Simple Command

```typescript
const command: ExecutableCommand = {
  executable: "make",
  args: ["status"],
  cwd: "/workspace/system-prompts"
};

// Output:
📊 Project Status

Phase 7: Agent Inheritance System
  ✅ AGENT-001: Agent Needs Analyzer
  ✅ AGENT-002: Agent Templates
  ✅ AGENT-003: Agent Generator
  ✅ AGENT-004: Integration
  ✅ AGENT-005: Testing
  ✅ AGENT-006: Documentation
  ✅ AGENT-007: Advanced Templates

Progress: 100% complete
```

### Example 2: Long-running with Progress

```typescript
const command: ExecutableCommand = {
  executable: "make",
  args: ["new", "ARCHETYPE=telegram-bot", "NAME=my-bot"],
  cwd: "/workspace/system-prompts",
  show_progress: true
};

// Output during execution:
[▶          ] 5% Validating inputs...
[██▌        ] 25% Creating directory structure...
[█████▌     ] 50% Generating configuration files...
[███████▌   ] 75% Creating documentation...
[█████████▌ ] 90% Initializing git...
[██████████ ] 95% Running post-generation tasks...
[███████████] 100% ✅ Project created successfully!

📁 Location: /workspace/my-bot
📋 Next steps:
  1. cd my-bot
  2. cp .env.example .env
  3. make install
  4. make dev
```

### Example 3: Error with Recovery

```typescript
// Command fails
const result = await execute(command);

// Output:
[█████░░░░] 50% Creating project structure...
❌ Error: Directory already exists

📁 /workspace/my-bot already exists.

Options:
  1️⃣  Use existing project
  2️⃣  Create with different name
  3️⃣  Remove and recreate

Choose option (1-3): _
```

---

## Sandboxing

```yaml
sandbox:
  enabled_for:
    - untrusted_commands
    - test_execution
    - user_scripts

  container:
    image: "openclaw/sandbox:latest"
    timeout: 60000
    memory_limit: "512m"
    cpu_limit: "0.5"

  volume_mounts:
    - /workspace:ro
    - /tmp/sandbox:rw

  network:
    mode: "none"  # no network access

  capabilities:
    drop: ["all"]
    add: ["CHOWN", "DAC_OVERRIDE"]
```

---

## Metrics & Logging

```yaml
logging:
  level: info
  format: json

  log_fields:
    - timestamp
    - command
    - exit_code
    - duration
    - output_size
    - error_message

  metrics:
    - commands_executed_total
    - command_duration_seconds
    - command_success_rate
    - rollback_total
```

---

## @ref Links

- [🎯 Intent Parser](intent-parser.md) — Parse natural language
- [🔧 Command Resolver](command-resolver.md) — Resolve to commands
- [📋 Makefile Reference](../../../Makefile) — Available targets

---

## Configuration

```yaml
executor:
  default_timeout: 300000  # 5 minutes
  max_concurrent: 3
  kill_signal: SIGTERM
  kill_grace_period: 5000

  output:
    buffer_size: 8192
    max_lines: 1000
    truncate_at: 10000

  progress:
    update_interval: 500  # ms
    show_percentage: true
    show_eta: true

  safety:
    confirm_destructive: true
    show_command: true
    dry_run: false
```

---

> [🏠 Главная](../../../README.md) → [🦞 OpenClaw](../README.md) → [🎯 Workspace](../README.md) → [Skills](SKILLS-INDEX.md) → **Command Executor**
