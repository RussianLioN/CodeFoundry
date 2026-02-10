---
> [🏠 Главная](README.md) → [📄 Project Description](#)
---

# CodeFoundry - Project Description

## 🎯 What This Project Does

This is **CodeFoundry** — an industrial-strength project generation system that creates complete, production-ready IT applications of any complexity.

### Core Capability

Creates complete IT projects from archetypes:
- **8 Project Archetypes** — covering 95% of IT use cases
- **Project Generation Scripts** — one-command project creation
- **OpenClaw Integration** — AI-assisted development
- **CI/CD Pipelines** — automated testing and deployment
- **Observability Stack** — Prometheus, Grafana, Alerting

## How It Works

### Token Optimization Strategy

```
Single Monolithic Prompt (5000+ tokens)
    ❌ All loaded always
    ❌ Wasted context on irrelevant sections
    
Hub + Modular System (500 + 800 tokens as needed)
    ✅ Hub loaded once (500 tokens)
    ✅ Modules loaded on-demand (800 tokens each)
    ✅ 60-80% token savings
```

### File Loading Logic

The central hub (`QODER.md`) contains decision logic:

```
User asks about architecture
    → Hub recognizes "architecture" keyword
    → Loads @ref: instructions/blocks-reference.md
    → AI has context without loading workflow, quality, etc.
```

### Inter-File Reference System

Uses semantic @-prefixed links for structured relationships:

- **@ref:** - "See this file/section for details"
- **@depends:** - "This requires completion of that first"
- **@extends:** - "This inherits from that template"
- **@see-also:** - "Related information available here"

Example:
```markdown
## Architecture Phase
When implementing architecture:
1. Review @ref: instructions/blocks-reference.md#core-blocks
2. Ensure @depends: TASKS.md#SETUP-001 is complete
3. Validate against @ref: instructions/quality-framework.md#clarity
```

## Instruction System Structure

### Current Project Files

```
system-prompts.md                   # ИСТОЧНИК ИСТИНЫ - Central hub template
├── IDE-specific copies/            # Копии system-prompts.md для разных AI-IDE
│   ├── .qoder/rules/QODER.md      # для Qoder IDE
│   ├── .cursorrules               # для Cursor IDE
│   ├── .clinerules                # для VS Code + Cline addon
│   ├── QWEN.md                    # для QWEN Code CLI
│   └── CLAUDE.md                  # для Claude Code CLI
│
├── instructions/                   # Modular instruction files (12 файлов)
│   ├── session-init.md            # Session initialization (всегда первым)
│   ├── first-session-workflow.md  # First session workflow
│   ├── continuation-workflow.md   # Continuation workflow
│   ├── prompt-generation.md       # Single prompt generation mode
│   ├── project-generation.md      # Instruction system generation mode
│   ├── blocks-reference.md        # Prompt building blocks catalog
│   ├── modes-guide.md             # Interaction modes (Express/Guided/Hybrid)
│   ├── decision-matrix.md         # Mode selection logic
│   ├── quality-framework.md       # Quality standards and techniques
│   ├── session-closure.md         # Session closure workflow
│   ├── git-operations.md          # Git sync/commit/push operations
│   └── compact-instruction.md     # Compressed version for Perplexity
│
├── templates/                      # Generation templates
│   ├── hub-template.md            # Blueprint for hub files
│   └── instruction-module-template.md  # Blueprint for instruction modules
│
└── doc-templates/                  # Documentation templates
    ├── project-template.md        # PROJECT.md template
    ├── tasks-template.md          # TASKS.md template
    ├── changelog-template.md      # CHANGELOG.md template
    ├── session-template.md        # SESSION.md template
    └── readme-template.md         # README.md template
```

### When AI Loads Which File

| User Intent | Hub Action |
|-------------|------------|
| "How do I structure a prompt?" | Load @ref: instructions/blocks-reference.md |
| "Use Express mode" | Load @ref: instructions/modes-guide.md#express-mode |
| "What mode should I use?" | Load @ref: instructions/decision-matrix.md |
| "Improve quality" | Load @ref: instructions/quality-framework.md |
| "Generate new project" | Load @ref: templates/hub-template.md |
| "Check progress" | Load @ref: TASKS.md |

## Generated Artifacts

When this system generates a new instruction system, it creates:

### Instruction Files
- `hub.md` - Central routing file
- `@architecture.md` - Architectural guidelines
- `@workflow.md` - Process flows
- `@quality.md` - Quality standards
- `@constraints.md` - Limitations and boundaries

### Documentation Files
- `PROJECT.md` - Project description (like this file)
- `TASKS.md` - Task tracker with status
- `CHANGELOG.md` - Change history
- `SESSION.md` - Session summaries (optional)
- `README.md` - Usage instructions

## Communication Protocol

- **Internal thinking:** English
- **User dialogue:** Russian only
- **Final prompts:** English only
- **Documentation:** Russian for user-facing, English for technical

## Three Interaction Modes

### Express Mode (~5-10 min)
- Quick generation with minimal back-and-forth
- 3-5 focused questions
- Single review cycle
- Best for: prototypes, simple tasks, experiments

### Guided Mode (~15-30 min)
- Step-by-step collaborative creation
- 8-12 deep questions
- Block-by-block approval
- Best for: critical systems, complex tasks, high-stakes

### Hybrid Mode (~10-20 min)
- Balance of speed and control
- 5-7 targeted questions
- Draft + 2-3 key checkpoints
- Best for: most production use cases

Mode selection driven by:
- **Criticality:** Experimental → Production → Critical
- **Complexity:** Simple → Medium → Complex
- **User experience:** Beginner → Intermediate → Advanced

@ref: instructions/decision-matrix.md for detailed selection logic

---

## 🤖 Agent Inheritance System

### Overview

CodeFoundry implements a **recursive 3-level agent system** where each new project can have its own specialized AI agents.

```
CodeFoundry (meta-generator)
    ↓ [generates projects]
New Project (with base structure)
    ↓ [analyzes needs + generates]
Project's AI Agents (specialized)
    ↓ [execute tasks]
Code, Tests, Documentation
```

### Components

**1. Agent Needs Analyzer** (`scripts/analyze-agent-needs.py`)
- Analyzes 8 project types for agent requirements
- Recommends 13 agent types (Coordinator, Code Assistant, Reviewer, etc.)
- Provides cost estimates (tokens/session)

**2. Agent Templates** (`templates/agents/`)
- 7 Jinja2 templates for different agent types
- Language-specific defaults (Python, JavaScript, TypeScript, Go)
- Framework-specific configurations (FastAPI, Django, React, Next.js, aiogram)
- 5 default categories: code style, testing, documentation, error handling, metadata

**3. Agent Generator** (`scripts/generate-agents.py`)
- Renders templates with project context
- Generates `.claude/AGENTS.md` (orchestration)
- Creates individual agent files (coordinator.md, code_assistant.md, etc.)
- Multi-format output (.claude/, .cursorrules, .qoder/, etc.)

### Agent Types

| Agent ID | Role | When Used |
|----------|------|-----------|
| `coordinator` | Orchestrates all agents | Multi-agent workflows |
| `code_assistant` | Code writing specialist | Writing code, refactoring |
| `reviewer` | Code review specialist | Quality assurance |
| `documentation` | Technical writing | API docs, guides |
| `tester` | Testing specialist | Test generation |
| `debugger` | Debugging specialist | Troubleshooting |

### Usage

```bash
# Analyze agent needs for a project type
make analyze-needs TYPE=web-service

# Generate agents for a project
make generate-agents NAME=MyBot TYPE=telegram-bot LANG=python FW=aiogram

# Test the agent generation system
make test-agents
```

### Integration with Project Initializer

When creating a new project via `make new`, the Project Initializer Agent now includes **Stage 3.5: Agent Generation Phase**:

1. Analyzes project type for agent needs
2. Presents recommendations to user
3. Generates agents on user confirmation
4. Validates generated files

This ensures every new project has appropriate AI agents from day one.

@ref: openclaw/workspace/agents/project-initializer.md#stage-35-agent-generation-phase

---

## Quality Standards

Three pillars of quality:

1. **Clarity** - Unambiguous, specific, concrete instructions (95%+ clarity target)
2. **Completeness** - All necessary context, constraints, edge cases included
3. **Testability** - Clear, measurable success criteria

Universal techniques:
- Chain-of-thought reasoning for complex tasks
- Few-shot learning (2-5 examples)
- Role definition with expertise specification
- Structured output (JSON/markdown/tags)
- Explicit constraints

@ref: instructions/quality-framework.md for detailed techniques

## Self-Replication Capability

This system generates instruction systems that can themselves generate further systems:

```
Meta-Generator (this project)
    ↓ generates
API Service Instruction System
    ↓ can generate
Specific API Service Project
    ↓ can generate
API Client Libraries
```

Each generation inherits capabilities from its parent while specializing for its domain.

## Use Cases

### For Prompt Engineers
- Generate production-ready system prompts efficiently
- Maintain consistency across multiple AI projects
- Iterate quickly with modular architecture

### For Development Teams
- Create AI coding assistants with project-specific knowledge
- Generate onboarding documentation systems
- Build specialized AI agents for domain tasks

### For AI Researchers
- Experiment with prompt architectures
- Test token optimization strategies
- Study multi-file instruction systems

## 🦞 OpenClaw Integration (Новое в v2.0.0)

**Что нового:**
- ✅ Полноценная OpenClaw интеграция для VDS
- ✅ Telegram бота с voice командами
- ✅ Multi-agent система (Dev, DevOps, Prompt agents)
- ✅ Skills для автоматизации (git-workflow, docker-deploy)
- ✅ Tailscale VPN для безопасного доступа
- ✅ Docker sandbox mode

**Установка на VDS:**
```bash
curl -fsSL https://raw.githubusercontent.com/RussianLioN/system-prompts/main/openclaw/scripts/install-openclaw.sh | bash
```

**Подробнее:** [🦞 OpenClaw README](openclaw/README.md)

---

## Version

- **Current Version:** 2.0.0 (с OpenClaw)
- **Previous Version:** 1.1.0
- **Generated By:** Manual creation (bootstrap)
- **Last Updated:** 2025-11-05

**Changes in 2.0.0:**
- ✅ Полноценная OpenClaw интеграция
- ✅ VDS-first архитектура
- ✅ Telegram voice команды
- ✅ Multi-agent skills system

**Changes in 1.1.0:**
- Added multi-IDE support (.cursorrules, .clinerules, QWEN.md, CLAUDE.md)
- Updated documentation (README.md, CHANGELOG.md, SESSION.md)
- Synchronized system-prompts.md and QODER.md

---
## 🔗 Быстрые Ссылки

- [🏠 Главная](README.md)
- [📋 Задачи (TASKS.md)](TASKS.md)
- [📝 История (CHANGELOG.md)](CHANGELOG.md)
- [💬 Сессии (SESSION.md)](SESSION.md)
- [🦞 OpenClaw (openclaw/README.md)](openclaw/README.md)
- [📚 Документация (docs/INDEX.md)](docs/INDEX.md)

---
## 📚 См. Также

- [🗺️ Карта навигации (docs/nav/nav-map.md)](docs/nav/nav-map.md)
- [📖 Правила документации (docs/rules/documentation-rules.md)](docs/rules/documentation-rules.md)
- [🎯 Templates (templates/README.md)](templates/README.md)

---
## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 2.0.0 | 2025-11-05 | OpenClaw интеграция, VDS-first |
| 1.1.0 | 2025-11-05 | Multi-IDE поддержка |
| 1.0.0 | 2025-10-31 | Первая версия |

---
> [🏠 Главная](README.md) → [📄 Project Description](#)

## References

- Main Hub Template: @ref: system-prompts.md (ИСТОЧНИК ИСТИНЫ)
- IDE-Specific Copies:
  - @ref: .qoder/rules/QODER.md (Qoder IDE)
  - @ref: .cursorrules (Cursor IDE)
  - @ref: .clinerules (VS Code + Cline)
  - @ref: QWEN.md (QWEN Code CLI)
  - @ref: CLAUDE.md (Claude Code CLI)
- Task Tracker: @ref: TASKS.md
- Change History: @ref: CHANGELOG.md
- Usage Guide: @ref: README.md
