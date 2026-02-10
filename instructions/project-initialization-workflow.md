# Project Initialization Workflow

**Purpose:** Create new CodeFoundry project ready for immediate development.

**When to use:** User wants to create a new project or asks "how to create a project".

---

## Workflow Overview

```
USER REQUEST → DIALOGUE → STRUCTURE → FILES → VALIDATE → GIT → HANDOFF → READY
```

---

## Step-by-Step

### Step 0: Load Context

Before starting:
1. Load `@ref: openclaw/workspace/agents/project-initializer.md`
2. Load `@ref: templates/CONTEXT_BRIDGE.md`
3. Check `templates/archetypes/` for available archetypes
4. Read parent `TASKS.md`

---

### Step 1: Dialogue Phase (CRITICAL)

**Goal:** Gather requirements ONE QUESTION AT A TIME.

Questions: project type, archetype, name, location, special requirements.
**Example:** See [@ref: docs/examples/project-initialization-dialogue.md](docs/examples/project-initialization-dialogue.md)

**Rules:** Ask one question, wait for response, confirm before proceeding.

---

### Step 2: Structure Phase

**Goal:** Create directory structure.

```bash
# Base directories
mkdir -p "$PROJECT_DIR"/{src,tests,docs,docker,k8s/base,scripts,openclaw/workspace}

# Archetype-specific (example: telegram-bot)
mkdir -p "$PROJECT_DIR/src"/{app,handlers,callbacks,middlewares,fsm,keyboards}
```

**Validate:** Required dirs exist (src, tests, docs, docker).

---

### Step 3: Files Phase

**Goal:** Generate required files.

**CRITICAL files:** README.md, PROJECT.md, TASKS.md, CLAUDE.md, .env.example, .gitignore, Makefile
**IMPORTANT files:** pyproject.toml, docker/Dockerfile, docker-compose.yml, SESSION.md

**Order:** Docs → Config → Python → Docker → Archetype-specific

---

### Step 4: Validation Phase

**Goal:** Complete project validation.

Check:
- All CRITICAL files exist and non-empty
- Directory structure matches archetype
- Configuration files valid syntax
- Git repo initialized

---

### Step 5: Git Phase

```bash
cd "$PROJECT_DIR"
git init
git add .
git commit -m "feat: initial commit"
```

---

### Step 6: Handoff Phase (CRITICAL)

**6.1 Context Bridge:** Update project's CLAUDE.md with parent context
**6.2 Update parent TASKS.md:** Add project task entry
**6.3 Update parent SESSION.md:** Log session with project created

---

## Origin

[@ref: instructions/project-generation.md](instructions/project-generation.md)

---
