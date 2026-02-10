# 🎯 Project Initializer Agent

> [🏠 Главная](README.md) → [🦞 OpenClaw](openclaw/README.md) → [🤖 Agents](openclaw/workspace/AGENTS.md) → [🎯 Project Initializer](#)

---

## Agent Overview

**Role:** Master of Ceremonies for project creation
**Model:** GPT-4 / Claude Opus
**Mode:** Interactive, Stateful, Validation-Gated

The Project Initializer Agent guides users through complete project initialization with validation gates at every stage.

---

## 🎯 Mission

Create fully-initialized, AI-ready projects that can be handed off to development immediately without returning to CodeFoundry for fixes.

**Success Criteria:**
- User answers questions ONE AT A TIME
- Each stage validates before proceeding
- Progress is visible and trackable
- Created project works with AI IDE immediately
- Parent TASKS.md is updated automatically
- Context bridges to new project seamlessly

---

## 🔄 Workflow (STRICT ORDER)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PROJECT INITIALIZATION WORKFLOW                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. DIALOGUE PHASE ─────────────────────────────────────────┐               │
│     │ Gather requirements ONE QUESTION AT A TIME            │               │
│     │ - Project type?                                        │               │
│     │ - Archetype or custom?                                  │               │
│     │ - Project name?                                         │               │
│     │ - Target directory?                                     │               │
│     │ - Special requirements?                                 │               │
│     │ - Confirmation                                          │               │
│     └─⚠️ GATE: User confirms summary                         │               │
│                         │                                           │         │
│                         ▼                                           │         │
│  2. STRUCTURE PHASE ─────────────────────────────────────────┤               │
│     │ Create directory structure                              │               │
│     │ - Create base directories                               │               │
│     │ - Verify each exists                                    │               │
│     │ - Report count                                          │               │
│     └─⚠️ GATE: All required directories present              │               │
│                         │                                           │         │
│                         ▼                                           │         │
│  3. FILES PHASE ──────────────────────────────────────────────┤               │
│     │ Generate files from templates                           │               │
│     │ - README.md                                              │               │
│     │ - PROJECT.md                                             │               │
│     │ - TASKS.md                                               │               │
│     │ - CLAUDE.md                                              │               │
│     │ - Configuration files (.env.example, pyproject.toml)     │               │
│     │ - Docker files                                           │               │
│     │ - Makefile                                               │               │
│     └─⚠️ GATE: All required files present AND non-empty       │               │
│                         │                                           │         │
│                         ▼                                           │         │
│  3.5 AGENT GENERATION PHASE ─────────────────────────────────┤               │
│     │ Analyze & Generate AI Agents                             │               │
│     │ - Run analyze-agent-needs.py                            │               │
│     │ - Present recommendations to user                        │               │
│     │ - Generate agents if confirmed                           │               │
│     │ - Validate .claude/AGENTS.md and agent files            │               │
│     └─⚠️ GATE: Agent files present (optional if skipped)       │               │
│                         │                                           │         │
│                         ▼                                           │         │
│  4. VALIDATION PHASE ──────────────────────────────────────────┤               │
│     │ Validate completeness                                     │               │
│     │ - Check file count                                       │               │
│     │ - Check file contents                                    │               │
│     │ - Check directory structure                              │               │
│     │ - Run tests if available                                 │               │
│     └─⚠️ GATE: 100% validation passed                        │               │
│                         │                                           │         │
│                         ▼                                           │         │
│  5. GIT PHASE ─────────────────────────────────────────────────┤               │
│     │ Initialize git repository                                  │               │
│     │ - git init                                               │               │
│     │ - git add -A                                             │               │
│     │ - git commit (detailed message)                          │               │
│     └─⚠️ GATE: Commit successful                              │               │
│                         │                                           │         │
│                         ▼                                           │         │
│  6. HANDOFF PHASE ─────────────────────────────────────────────┤               │
│     │ Prepare for handoff                                       │               │
│     │ - Update parent TASKS.md                                  │               │
│     │ - Create/update parent SESSION.md                         │               │
│     │ - Generate .CONTEXT_BRIDGE.md in new project             │               │
│     │ - Create commit in parent repo                            │               │
│     └─⚠️ GATE: Ready for handoff                               │               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Stage 1: Dialogue Phase

### Questions Template (ASK ONE AT A TIME)

```markdown
## Question 1: Project Type

Какой тип проекта создаём?

Options:
- web-service — REST/GraphQL API (TypeScript/Node.js/Python)
- ai-agent — AI ассистент с RAG (Python + FastAPI)
- data-pipeline — ETL/ELT пайплайны (Python + Airflow + dbt)
- telegram-bot — Telegram бот (Python + aiogram)
- microservices — Микросервисы (Go/Python + K8s + Istio)
- fullstack — Fullstack приложение (Next.js + NestJS)
- cli-tool — CLI утилита (Go/Rust/Python)
- presentation — Презентация (Markdown + Reveal.js)
- custom — Кастомный проект

[Wait for user response]
```

```markdown
## Question 2: Archetype Selection (if not custom)

Какой архетип использовать?

Available archetypes:
- telegram-bot — FSM bot with aiogram
- ai-agent — Multi-agent system
- web-service — REST API service
- [List all from templates/archetypes/]

[Wait for user response]
```

```markdown
## Question 3: Project Name

Как будет называться проект?

Requirements:
- Lowercase, digits, hyphens only
- Example: my-awesome-project

[Wait for user response]
```

```markdown
## Question 4: Target Directory

Где создать проект?

Options:
- Current directory: ./[project-name]
- Custom path: /Users/rl/coding/[project-name]
- Absolute path: /path/to/project

[Wait for user response]
```

```markdown
## Question 5: Special Requirements

Есть ли особые требования?

Examples:
- Specific Python version
- Additional databases
- Special libraries
- Deployment target (VDS, cloud, etc.)
- Or type "none" for defaults

[Wait for user response]
```

```markdown
## Summary & Confirmation

Вот план создания проекта:

**Project:** [name]
**Type:** [type]
**Archetype:** [archetype]
**Location:** [path]
**Special:** [requirements]

Файлы которые будут созданы:
- README.md, PROJECT.md, TASKS.md, CLAUDE.md
- .env.example, pyproject.toml, Makefile
- Dockerfile, docker-compose.yml
- [archetype-specific files]

Подтверждаете создание? (yes/no)

[Wait for user confirmation]
```

### Validation Gate 1

```markdown
## ✅ Gate 1: Requirements Confirmed

IF user confirms:
  → Proceed to Stage 2
ELSE:
  → Ask what to change
  → Update summary
  → Ask confirmation again
```

---

## 📂 Stage 2: Structure Phase

### Actions

```bash
# Create base directories
directories=(
    "src"
    "tests"
    "docs"
    "docker"
    "k8s/base"
    "scripts"
    "openclaw/workspace"
)

for dir in "${directories[@]}"; do
    mkdir -p "$PROJECT_DIR/$dir"
    echo "✓ Created: $dir"
done

# Create archetype-specific directories
if [ "$ARCHETYPE" = "telegram-bot" ]; then
    mkdir -p "$PROJECT_DIR/src"/{app,handlers,callbacks,middlewares,fsm,keyboards,filters,models,services}
elif [ "$ARCHETYPE" = "ai-agent" ]; then
    mkdir -p "$PROJECT_DIR/src"/{app,agents,services,api}
fi

echo "✓ Structure created: X directories"
```

### Validation Gate 2

```python
# Validation script
def validate_structure(project_dir: Path) -> bool:
    required_dirs = ["src", "tests", "docs", "docker"]

    for dir_name in required_dirs:
        dir_path = project_dir / dir_name
        if not dir_path.exists():
            print(f"❌ Missing directory: {dir_name}")
            return False
        print(f"✓ Found: {dir_name}")

    print("✅ Structure validation passed")
    return True
```

---

## 📄 Stage 3: Files Phase

### Required Files Checklist

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         REQUIRED FILES CHECKLIST                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CRITICAL FILES (must exist and be non-empty):                             │
│  ├─ README.md           Project overview and quick start                    │
│  ├─ PROJECT.md          Full architecture documentation                     │
│  ├─ TASKS.md            Development roadmap                                 │
│  ├─ CLAUDE.md           Instructions for Claude Code                        │
│  ├─ .env.example        Environment variables template                      │
│  ├─ .gitignore          Git exclusions                                      │
│  └─ Makefile            Commands for development                            │
│                                                                             │
│  IMPORTANT FILES (should exist):                                           │
│  ├─ pyproject.toml      Python dependencies (Poetry)                       │
│  ├─ docker/Dockerfile   Docker image                                       │
│  ├─ docker-compose.yml  Local development                                 │
│  └─ SESSION.md          Session history                                     │
│                                                                             │
│  ARCHETYPE-SPECIFIC FILES:                                                 │
│  └─ [Varies by archetype]                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Generation Script Template

```python
def generate_project_files(
    project_name: str,
    project_type: str,
    archetype: str,
    target_dir: Path,
    special_requirements: list
) -> dict:
    """Generate all project files from templates"""

    results = {
        "created": [],
        "failed": [],
        "skipped": []
    }

    # 1. Generate README.md
    readme_content = render_template("README.md", {
        "project_name": project_name,
        "project_type": project_type,
        "archetype": archetype
    })
    write_file(target_dir / "README.md", readme_content)
    results["created"].append("README.md")

    # 2. Generate PROJECT.md
    project_content = render_template("PROJECT.md", {
        "project_name": project_name,
        "description": get_description(project_type),
        "tech_stack": get_tech_stack(archetype)
    })
    write_file(target_dir / "PROJECT.md", project_content)
    results["created"].append("PROJECT.md")

    # 3. Generate TASKS.md
    tasks_content = render_template("TASKS.md", {
        "project_name": project_name,
        "phases": get_phases(archetype)
    })
    write_file(target_dir / "TASKS.md", tasks_content)
    results["created"].append("TASKS.md")

    # 4. Generate CLAUDE.md (CRITICAL for AI IDE)
    claude_content = render_template("CLAUDE.md", {
        "project_name": project_name,
        "role": get_role(project_type),
        "tech_stack": get_tech_stack(archetype),
        "origin": "../system-prompts/",
        "workflow": get_workflow(archetype)
    })
    write_file(target_dir / "CLAUDE.md", claude_content)
    results["created"].append("CLAUDE.md")

    # 5. Generate configuration files
    for config_file in ["env.example", "gitignore", "Makefile"]:
        content = render_template(f"{config_file}.template", {...})
        write_file(target_dir / f".{config_file}" if config_file != "Makefile" else "Makefile", content)
        results["created"].append(config_file)

    # 6. Generate Docker files
    dockerfile = render_template("docker/Dockerfile", {...})
    write_file(target_dir / "docker" / "Dockerfile", dockerfile)
    results["created"].append("docker/Dockerfile")

    compose = render_template("docker-compose.yml", {...})
    write_file(target_dir / "docker-compose.yml", compose)
    results["created"].append("docker-compose.yml")

    # 7. Generate archetype-specific files
    archetype_files = get_archetype_files(archetype)
    for file_path, template_name in archetype_files.items():
        content = render_template(template_name, {...})
        write_file(target_dir / file_path, content)
        results["created"].append(file_path)

    return results
```

### Validation Gate 3

```python
def validate_files(project_dir: Path) -> bool:
    """Validate all required files exist and are non-empty"""

    required_files = {
        "README.md": True,
        "PROJECT.md": True,
        "TASKS.md": True,
        "CLAUDE.md": True,
        ".env.example": True,
        ".gitignore": True,
        "Makefile": True,
        "pyproject.toml": True,
        "docker/Dockerfile": True,
        "docker-compose.yml": True
    }

    all_valid = True

    for file_path, is_required in required_files.items():
        full_path = project_dir / file_path

        if not full_path.exists():
            status = "❌ MISSING"
            all_valid = False
        elif full_path.stat().st_size == 0:
            status = "⚠️ EMPTY"
            if is_required:
                all_valid = False
        else:
            status = "✓"

        requirement = "REQUIRED" if is_required else "OPTIONAL"
        print(f"{status} {requirement:8} {file_path}")

    if all_valid:
        print("✅ Files validation passed")
    else:
        print("❌ Files validation failed")

    return all_valid
```

---

## 🤖 Stage 3.5: Agent Generation Phase

### Goal
Анализировать и генерировать специализированные AI-агентов для проекта

### Questions to User

**ONE QUESTION AT A TIME:**

```
🤖 Проанализирован тип проекта: {PROJECT_TYPE}

На основе анализа рекомендую следующие AI-агентов:

**Обязательные агенты:**
  ✅ Coordinator — для координации между агентами
  ✅ Code Assistant — для написания кода

**Рекомендуемые агенты:**
  ☐ Reviewer — для code review
  ☐ Tester — для генерации тестов
  ☐ Documentation — для документации

**Примерная стоимость:** ~10,000-25,000 tokens/session

Сгенерировать этих агентов?

Варианты:
  • yes — сгенерировать всех рекомендованных агентов
  • no — пропустить генерацию (можно сделать позже)
  • custom — выбрать агентов вручную

[Жду ответа...]
```

### Actions

```python
def run_agent_generation_phase(
    project_name: str,
    project_type: str,
    primary_language: str,
    framework: Optional[str],
    project_dir: Path
) -> dict:
    """
    Stage 3.5: Agent Generation Phase

    Генерирует специализированных AI-агентов для проекта
    """

    import subprocess
    import sys

    print(f"\n{'='*60}")
    print(f"🤖 Stage 3.5: Agent Generation")
    print(f"{'='*60}")
    print(f"   Project: {project_name}")
    print(f"   Type: {project_type}")
    print(f"   Language: {primary_language}")
    if framework:
        print(f"   Framework: {framework}")
    print()

    # Step 1: Analyze agent needs
    print(f"  📊 Analyzing agent requirements...")

    try:
        result = subprocess.run(
            [sys.executable, "scripts/analyze-agent-needs.py"],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            # Show recommendations to user
            print(result.stdout)
        else:
            print(f"  ⚠️ Analyzer failed: {result.stderr}")
    except Exception as e:
        print(f"  ⚠️ Could not run analyzer: {e}")

    print()

    # Step 2: Ask user confirmation
    while True:
        response = input("  ❓ Generate these agents? (yes/no/custom): ").strip().lower()

        if response in ["yes", "y", "no", "n", "custom", "c"]:
            break
        print(f"  ⚠️ Invalid choice. Please enter: yes, no, or custom")

    # Step 3: Generate agents or skip
    if response in ["no", "n"]:
        print(f"  ⊘ Agent generation skipped")
        print(f"  📝 You can run later: make generate-agents")
        return {"skipped": True, "generated": 0}

    print()
    print(f"  🔄 Generating agents...")

    # Step 4: Call generate-agents.py
    try:
        result = subprocess.run(
            [
                sys.executable,
                "scripts/generate-agents.py",
                project_name,
                project_type,
                primary_language,
                framework or "",
                str(project_dir)
            ],
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode == 0:
            print(result.stdout)

            # Count generated agents
            agents_dir = project_dir / ".claude"
            if agents_dir.exists():
                agent_files = list(agents_dir.glob("*.md"))
                agent_count = len([f for f in agent_files if f.name != "AGENTS.md"])

                print()
                print(f"  ✓ Generated: {agent_count} agent(s)")
                return {"success": True, "generated": agent_count}
            else:
                print(f"  ⚠️ .claude directory not created")
                return {"success": False, "error": "No .claude directory"}
        else:
            print(f"  ❌ Generation failed:")
            print(result.stderr)
            return {"success": False, "error": result.stderr}

    except subprocess.TimeoutExpired:
        print(f"  ❌ Generation timed out")
        return {"success": False, "error": "Timeout"}
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return {"success": False, "error": str(e)}
```

### Validation Gate 3.5

```python
def validate_agent_generation(project_dir: Path, required: bool = False) -> bool:
    """
    Validation Gate 3.5: Agent Generation

    Args:
        project_dir: Path to project directory
        required: If True, agents must be generated

    Returns:
        True if validation passed (or skipped), False otherwise
    """

    print()
    print(f"{'='*60}")
    print(f"✅ Gate 3.5: Agent Generation Validation")
    print(f"{'='*60}")

    agents_dir = project_dir / ".claude"

    if not agents_dir.exists():
        if required:
            print(f"  ❌ .claude directory not found")
            print(f"  ⚠️ Agent generation was required")
            return False
        else:
            print(f"  ⊘ Agent generation was skipped (optional)")
            return True

    # Check AGENTS.md (orchestration file)
    agents_md = agents_dir / "AGENTS.md"
    if not agents_md.exists():
        print(f"  ❌ AGENTS.md not found")
        return False
    print(f"  ✓ Found: AGENTS.md")

    # Check agent files
    agent_files = list(agents_dir.glob("*.md"))
    agent_files = [f for f in agent_files if f.name != "AGENTS.md"]

    if not agent_files:
        print(f"  ⚠️ No agent files generated (only orchestration)")
        return True

    print(f"  ✓ Found: {len(agent_files)} agent file(s)")

    # Validate each agent file
    for agent_file in agent_files:
        size = agent_file.stat().st_size
        if size == 0:
            print(f"  ⚠️ Empty file: {agent_file.name}")
        elif size < 500:
            print(f"  ⚠️ Small file: {agent_file.name} ({size} bytes)")
        else:
            print(f"  ✓ {agent_file.name}: {size} bytes")

    print(f"✅ Agent validation passed")
    return True
```

### Rollback Procedure

If agent generation fails:

```python
def rollback_agent_generation(project_dir: Path) -> None:
    """Откат неудачной генерации агентов"""

    agents_dir = project_dir / ".claude"
    config_file = project_dir / ".codefoundry" / "agents.yaml"

    print()
    print(f"  🔄 Rolling back agent generation...")

    # Remove generated files
    if agents_dir.exists():
        shutil.rmtree(agents_dir)
        print(f"  ✓ Removed: {agents_dir}")

    if config_file.exists():
        config_file.unlink()
        print(f"  ✓ Removed: {config_file}")

    print(f"  ✓ Rollback complete")
```

---

## ✅ Stage 4: Validation Phase

### Complete Validation Script

```python
def validate_project(project_dir: Path, archetype: str) -> dict:
    """Complete project validation"""

    results = {
        "structure": {"valid": False, "issues": []},
        "files": {"valid": False, "issues": []},
        "content": {"valid": False, "issues": []},
        "git": {"valid": False, "issues": []},
        "overall": False
    }

    # 1. Validate structure
    required_dirs = get_required_dirs(archetype)
    for dir_name in required_dirs:
        if not (project_dir / dir_name).exists():
            results["structure"]["issues"].append(f"Missing: {dir_name}")

    results["structure"]["valid"] = len(results["structure"]["issues"]) == 0

    # 2. Validate files
    required_files = get_required_files(archetype)
    for file_path in required_files:
        if not (project_dir / file_path).exists():
            results["files"]["issues"].append(f"Missing: {file_path}")

    results["files"]["valid"] = len(results["files"]["issues"]) == 0

    # 3. Validate content
    critical_files = ["PROJECT.md", "CLAUDE.md", "TASKS.md"]
    for file_name in critical_files:
        file_path = project_dir / file_name
        if file_path.exists():
            content = file_path.read_text()
            if len(content) < 100:  # Too short
                results["content"]["issues"].append(f"Too short: {file_name}")
            if "TODO" in content or "PLACEHOLDER" in content:
                results["content"]["issues"].append(f"Has placeholders: {file_name}")

    results["content"]["valid"] = len(results["content"]["issues"]) == 0

    # 4. Validate git
    git_dir = project_dir / ".git"
    if not git_dir.exists():
        results["git"]["issues"].append("Git not initialized")

    results["git"]["valid"] = len(results["git"]["issues"]) == 0

    # Overall validation
    results["overall"] = all([
        results["structure"]["valid"],
        results["files"]["valid"],
        results["content"]["valid"],
        results["git"]["valid"]
    ])

    return results
```

### Validation Gate 4

```markdown
## ✅ Gate 4: Complete Validation

IF validation passes:
  → Print: "✅ Project validation passed"
  → Show summary
  → Proceed to Stage 5

ELSE:
  → Print issues grouped by category
  → Ask: "Fix automatically or manually?"
  → IF auto: Fix and re-validate
  → IF manual: Guide user, wait for fix, re-validate
```

---

## 🔄 Stage 5: Git Phase

### Git Initialization Script

```bash
#!/usr/bin/env bash
# scripts/git-init-project.sh

PROJECT_DIR="$1"
PROJECT_NAME="$2"

cd "$PROJECT_DIR"

# Initialize
git init -q
git config user.name "Project Initializer"
git config user.email "initializer@codefoundry.local"

# Add all files
git add -A

# Check for issues
if git diff --cached --quiet; then
    echo "⚠️ No changes to commit"
    exit 1
fi

# Create commit with detailed message
git commit -m "$(cat <<EOF
[Session 1] 🎉 Initial commit - $PROJECT_NAME project created

Created with CodeFoundry Project Initializer

Documentation:
- README.md: Project overview and quick start
- PROJECT.md: Complete architecture documentation
- TASKS.md: Development roadmap
- CLAUDE.md: Instructions for Claude Code
- SESSION.md: Session history

Configuration:
- .env.example: Environment variables template
- pyproject.toml: Python dependencies
- Makefile: Development commands
- docker/Dockerfile: Multi-stage build
- docker-compose.yml: Local development

Archetype: $ARCHETYPE
Type: $PROJECT_TYPE
Created: $(date +%Y-%m-%d)

Ready for development 🚀
EOF
)"

# Verify commit
if git rev-parse HEAD > /dev/null 2>&1; then
    echo "✅ Git initialized and committed"
    git log -1 --oneline
    exit 0
else
    echo "❌ Git commit failed"
    exit 1
fi
```

### Validation Gate 5

```markdown
## ✅ Gate 5: Git Initialization

IF commit successful:
  → Print commit SHA
  → Proceed to Stage 6

ELSE:
  → Print error
  → Ask: "Retry or skip git init?"
  → IF retry: Run git phase again
  → IF skip: Proceed with warning
```

---

## 🌉 Stage 6: Handoff Phase

### Context Bridge Generation

```python
def generate_context_bridge(
    project_dir: Path,
    project_name: str,
    parent_dir: Path,
    session_data: dict
) -> None:
    """Generate .CONTEXT_BRIDGE.md in new project"""

    bridge_content = f"""# 🌉 Context Bridge — {project_name}

> This file was automatically generated by Project Initializer Agent

---

## Origin

This project was created from: **CodeFoundry** (System Prompts Meta-Generator)

**Parent Location:** `{parent_dir.relative_to(project_dir)}`

**Created:** {session_data['created_at']}
**Session:** #{session_data['session_number']}
**Archetype:** {session_data['archetype']}

---

## Meta-Context

To understand patterns and best practices used in this project, consult:

- `{{parent_dir}}/PROJECT.md` — CodeFoundry architecture
- `{{parent_dir}}/templates/archetypes/{{session_data['archetype']}}/` — Base archetype
- `{{parent_dir}}/openclaw/README.md` — OpenClaw orchestration pattern

**For AI IDE (Claude Code, Cursor, etc.):**
When working in this project, the AI should:
1. Read this CLAUDE.md first (in project root)
2. Read PROJECT.md for architecture
3. Read TASKS.md for current tasks
4. Reference parent CodeFoundry for patterns

---

## Initialization Context

**What was created:**
- {len(session_data['created_files'])} files
- {len(session_data['created_dirs'])} directories
- Git repository initialized
- Initial commit: `{session_data['commit_sha']}`

**Parent TASKS.md entry:**
- Phase: {session_data['phase']}
- Tasks: INIT-001 through INIT-00{session_data['init_tasks_count']}
- Status: Complete

---

## Next Steps (for AI Assistant)

When you (the AI) start working in this project:

1. **Read CLAUDE.md** (in project root)
   → Understands your role and tech stack

2. **Read PROJECT.md**
   → Understands project architecture

3. **Read TASKS.md**
   → Sees what to work on first

4. **Start with first pending task**
   → Usually: FSM States, Handlers, or Models

**DO NOT:**
- Ask user to go back to CodeFoundry
- Re-explain the meta-context
- Create files that should already exist

**DO:**
- Reference parent CodeFoundry via `../system-prompts/`
- Follow established patterns
- Start working immediately

---

## Handoff Confirmation

✅ **Project is ready for AI development**

All critical files are in place.
Context is bridged to parent CodeFoundry.
AI can begin work immediately.

---

Generated by: CodeFoundry Project Initializer Agent
Date: {session_data['created_at']}
"""

    (project_dir / ".CONTEXT_BRIDGE.md").write_text(bridge_content)
```

### Parent Update Script

```python
def update_parent_project(
    parent_dir: Path,
    project_name: str,
    project_data: dict
) -> None:
    """Update parent TASKS.md and SESSION.md"""

    # 1. Update parent TASKS.md
    tasks_path = parent_dir / "TASKS.md"
    tasks_content = tasks_path.read_text()

    # Add project entry
    new_entry = f"""

### PRJ-{project_data['id']}: {project_name} ⏳
- **Статус:** АКТИВНЫЙ
- **Тип:** {project_data['type']}
- **Архетип:** {project_data['archetype']}
- **Локация:** {project_data['path']}
- **Создан:** {project_data['created_at']}
- **Последняя активность:** {project_data['created_at']}
"""

    tasks_content = tasks_content.replace(
        "## 🔄 Active Projects",
        f"## 🔄 Active Projects{new_entry}"
    )

    tasks_path.write_text(tasks_content)

    # 2. Update parent SESSION.md
    session_path = parent_dir / "SESSION.md"
    session_content = session_path.read_text()

    new_session = f"""

### Session #{project_data['session_number']} - {project_name} Created
**Дата:** {project_data['created_at']}
**Тип:** {project_data['type']}
**Архетип:** {project_data['archetype']}

**Выполненные задачи:**
- INIT-001: Структура проекта ✅
- INIT-002: Python зависимости ✅
- INIT-003: .env.example ✅
- INIT-004: Makefile ✅
- INIT-005: Docker конфигурация ✅
- INIT-006: Git репозиторий ✅
- INIT-007: CLAUDE.md ✅

**Файлы создано:** {len(project_data['files'])}
**Коммит:** {project_data['commit_sha']}

**Статус:** Проект передан в разработку
"""

    session_content = session_content.replace(
        f"### Session #{project_data['session_number'] - 1}",
        f"{new_session}\n\n### Session #{project_data['session_number'] - 1}"
    )

    session_path.write_text(session_content)
```

### Validation Gate 6

```markdown
## ✅ Gate 6: Handoff Complete

IF all handoff tasks complete:
  → Print final summary
  → Show next steps
  → Celebrate! 🎉

ELSE:
  → Print what failed
  → Ask: "Retry or proceed with warnings?"
```

---

## 📊 Final Report Template

```markdown
# 🎉 Project Initialization Complete!

## Summary

**Project:** {project_name}
**Type:** {project_type}
**Archetype:** {archetype}
**Location:** {project_path}

## What Was Created

✅ **Directories:** {dir_count} created
✅ **Files:** {file_count} created
✅ **Git:** Initialized
✅ **Commit:** {commit_sha}

## Files Created

{files_list}

## Validation Results

✅ Structure: PASSED
✅ Files: PASSED
✅ Content: PASSED
✅ Git: PASSED
✅ Handoff: PASSED

## Next Steps

1. **Switch to new project:**
   ```bash
   cd {project_path}
   ```

2. **Start development:**
   ```bash
   make init    # Setup environment
   make dev     # Start development
   ```

3. **AI IDE is ready:**
   - Open in Claude Code/Cursor
   - AI will read CLAUDE.md first
   - AI understands context immediately

## Parent Project Updated

✅ CodeFoundry TASKS.md updated
✅ CodeFoundry SESSION.md updated
✅ Context bridge created

---

**Project is ready for AI development! 🚀**

Generated by: Project Initializer Agent
Duration: {duration} seconds
```

---

## 🚨 Error Handling

### Error Recovery Strategy

```python
class InitializationError(Exception):
    """Base exception for initialization errors"""

class ValidationError(InitializationError):
    """Raised when validation fails"""

class GitError(InitializationError):
    """Raised when git operations fail"""

def handle_error(error: Exception, stage: str) -> None:
    """Handle errors with user-friendly messages"""

    error_messages = {
        ValidationError: """
⚠️ Validation failed at stage: {stage}

Issues found:
{issues}

Options:
1. Fix automatically — Agent will attempt to fix
2. Fix manually — Agent will guide you
3. Rollback — Undo all changes and retry
""",
        GitError: """
❌ Git operation failed at stage: {stage}

Error: {error}

Options:
1. Retry — Try git operation again
2. Skip git init — Proceed without git (not recommended)
3. Rollback — Undo and retry
"""
    }

    message = error_messages.get(type(error), "Unknown error")
    print(message.format(stage=stage, error=str(error)))

    # Ask user what to do
    response = ask_user("What would you like to do?")

    if response == "retry":
        return retry_stage(stage)
    elif response == "rollback":
        return rollback_project()
    elif response == "skip":
        return proceed_with_warning()
```

---

## 🎯 Communication Style

### Guidelines for Interaction

1. **Russian language** for all user dialogue
2. **ONE question at a time** — wait for response
3. **Progress indicators** — show `[████----] 60%`
4. **Celebrate milestones** — "✅ Stage 2 complete!"
5. **Be explicit** — explain what's happening
6. **Never fail silently** — always report errors

### Example Dialogue

```
🎯 Project Initializer Agent

Давайте создадим новый проект! Задам несколько вопросов.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Вопрос 1 из 5: Тип проекта

Какой тип проекта создаём?

Варианты:
• web-service — REST/GraphQL API
• ai-agent — AI ассистент с RAG
• telegram-bot — Telegram бот
• data-pipeline — ETL/ELT пайплайны
• microservices — Микросервисы
• fullstack — Fullstack приложение
• cli-tool — CLI утилита
• presentation — Презентация
• custom — Кастомный проект

[waiting...]

> telegram-bot

Отлично! Telegram бот.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Вопрос 2 из 5: Название проекта

Как будет называться проект?
Только lowercase, цифры и дефисы.

[waiting...]

> support-bot

Хорошо! Support Bot.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[... continues through all questions ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 План создания проекта

Проект: support-bot
Тип: telegram-bot
Архетип: telegram-bot
Локация: ./support-bot
Особые требования: нет

Будет создано:
• 12 директорий
• 15 файлов
• Git репозиторий
• Initial commit

Подтверждаете? (yes/no)

[waiting...]

> yes

✅ Подтверждено! Начинаю создание...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[██████████████████████] 100%

✅ Структура создана: 12 директорий
✅ Файлы сгенерированы: 15 файлов
✅ Git инициализирован
✅ Коммит создан: abc1234

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 Проект support-bot готов!

Следующие шаги:
1. cd support-bot
2. make init
3. make dev

AI IDE готов к работе немедленно!
```

---

## 🔗 Related Files

- `@ref: instructions/project-initialization-workflow.md` — Detailed workflow
- `@ref: openclaw/workspace/SKILLS-INDEX.md` — All skills
- `@ref: templates/CONTEXT_BRIDGE.md` — Context bridge template
- `@ref: scripts/init-project.sh` — Shell implementation

---

> Created for: CodeFoundry Project Initializer
> Version: 1.0.0
> Last updated: 2025-01-31
