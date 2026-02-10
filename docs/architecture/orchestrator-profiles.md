# Orchestrator Profile Architecture

> ORCH-PROF-001 | Session #15 | 2026-02-06

## Problem

CodeFoundry generates projects from 8 archetypes but does NOT create `.claude/` directory. Every new project starts without AI orchestration — users must configure Claude Code manually.

## Solution: Layered Profile Generation

```
templates/claude-profile/
├── base/                          ← Base layer (all projects)
│   ├── CLAUDE.md.j2
│   ├── settings.json.j2
│   ├── auto-routing-rules.json.j2
│   ├── agents/
│   │   ├── coordinator.md.j2
│   │   └── code-assistant.md.j2
│   ├── commands/
│   │   └── health.md.j2
│   ├── skills/
│   │   └── validate.md.j2
│   └── hooks/
│       └── pre-commit.sh.j2
│
├── overlays/                      ← Archetype-specific additions
│   ├── web-service/
│   │   ├── manifest.json
│   │   ├── agents/
│   │   │   ├── devops.md.j2
│   │   │   └── tester.md.j2
│   │   ├── commands/
│   │   │   └── deploy.md.j2
│   │   └── skills/
│   │       ├── api-development.md.j2
│   │       └── security-check.md.j2
│   ├── ai-agent/
│   │   ├── manifest.json
│   │   ├── agents/
│   │   │   ├── prompt-engineer.md.j2
│   │   │   └── ml-engineer.md.j2
│   │   └── skills/
│   │       ├── prompt-engineering.md.j2
│   │       └── rag-tuning.md.j2
│   ├── data-pipeline/
│   ├── telegram-bot/
│   ├── cli-tool/
│   ├── microservices/
│   ├── fullstack/
│   └── presentation/
│
└── profile-manifest.schema.json   ← Validation schema
```

**Principle:** Base + Overlay = Final `.claude/` directory. Like Docker layers.

---

## Archetype-Component Matrix

| Component | web-service | ai-agent | data-pipeline | telegram-bot | cli-tool | microservices | fullstack | presentation |
|-----------|:-----------:|:--------:|:-------------:|:------------:|:--------:|:-------------:|:---------:|:------------:|
| **Base agents** | | | | | | | | |
| coordinator | + | + | + | + | + | + | + | + |
| code-assistant | + | + | + | + | + | + | + | - |
| reviewer | + | + | + | + | + | + | + | - |
| tester | + | + | + | + | + | + | + | - |
| **Specialized agents** | | | | | | | | |
| devops | + | - | - | - | - | + | + | - |
| prompt-engineer | - | + | - | - | - | - | - | - |
| ml-engineer | - | + | + | - | - | - | - | - |
| architect | - | - | - | - | - | + | - | - |
| sre | - | - | - | - | - | + | - | - |
| frontend | - | - | - | - | - | - | + | - |
| backend | - | - | - | - | - | - | + | - |
| data-engineer | - | - | + | - | - | - | - | - |
| content-generator | - | - | - | - | - | - | - | + |
| slide-designer | - | - | - | - | - | - | - | + |
| **Commands** | | | | | | | | |
| health | + | + | + | + | + | + | + | + |
| deploy | + | + | + | + | + | + | + | - |
| test | + | + | + | + | + | + | + | - |
| **Skills** | | | | | | | | |
| validate | + | + | + | + | + | + | + | + |
| api-development | + | - | - | - | - | - | - | - |
| security-check | + | - | - | - | - | + | + | - |
| prompt-engineering | - | + | - | - | - | - | - | - |
| rag-tuning | - | + | - | - | - | - | - | - |
| etl-patterns | - | - | + | - | - | - | - | - |
| bot-development | - | - | - | + | - | - | - | - |
| cli-patterns | - | - | - | - | + | - | - | - |
| e2e-testing | - | - | - | - | - | - | + | - |
| content-generator | - | - | - | - | - | - | - | + |
| **Hooks** | | | | | | | | |
| pre-commit | + | + | + | + | + | + | + | + |
| **Total agents** | 6 | 6 | 6 | 4 | 4 | 8 | 7 | 3 |

---

## Profile Manifest Schema

Each overlay directory contains `manifest.json`:

```json
{
  "archetype": "web-service",
  "version": "1.0.0",
  "description": "REST/GraphQL API service profile",
  "extends": "base",
  "agents": {
    "add": ["devops", "tester"],
    "remove": [],
    "configure": {
      "code-assistant": {
        "specialization": "REST API development, Express/FastAPI/NestJS",
        "languages": ["typescript", "python", "go"]
      }
    }
  },
  "skills": {
    "add": ["api-development", "security-check"]
  },
  "commands": {
    "add": ["deploy", "test"]
  },
  "routing": {
    "overrides": {
      "api|endpoint|route|middleware": "code-assistant",
      "deploy|docker|k8s|helm": "devops",
      "test|spec|coverage": "tester",
      "review|pr|quality": "reviewer"
    }
  },
  "variables": {
    "default_language": "typescript",
    "default_framework": "express",
    "docker_enabled": true,
    "k8s_enabled": true
  }
}
```

---

## Generation Flow

```
new-project.sh
  │
  ├── 1. Copy archetype files
  ├── 2. Copy OpenClaw workspace
  ├── 3. Generate PROJECT.md, TASKS.md, SESSION.md
  │
  ├── 4. [NEW] Generate .claude/ profile ◄────────────────────┐
  │       │                                                     │
  │       ├── Read base/ templates                              │
  │       ├── Read overlays/{archetype}/manifest.json           │
  │       ├── Merge: base + overlay                             │
  │       ├── Render Jinja2 templates with variables:           │
  │       │   - project_name, archetype, language               │
  │       │   - agent list, skill list, command list            │
  │       ├── Generate auto-routing-rules.json from agents      │
  │       ├── Set permissions (hooks +x)                        │
  │       └── Validate (quality gates)                          │
  │                                                             │
  ├── 5. Git init + first commit                    generate-claude-profile.py
  └── Done
```

**Opt-out:** `cf-new --no-claude-profile` skips step 4.

---

## Template Variables

All `.j2` templates receive:

| Variable | Source | Example |
|----------|--------|---------|
| `project_name` | CLI arg | "my-api" |
| `project_description` | CLI arg | "REST API for..." |
| `archetype` | CLI arg | "web-service" |
| `language` | CLI arg / manifest default | "typescript" |
| `framework` | manifest default | "express" |
| `agents` | base + overlay merge | ["coordinator", "code-assistant", ...] |
| `skills` | base + overlay merge | ["validate", "api-development"] |
| `commands` | base + overlay merge | ["health", "deploy", "test"] |
| `docker_enabled` | manifest | true |
| `k8s_enabled` | manifest | true |
| `year` | auto | "2026" |

---

## File Counts per Archetype

| Archetype | Agents | Skills | Commands | Hooks | Total .claude/ files |
|-----------|:------:|:------:|:--------:|:-----:|:-------------------:|
| web-service | 6 | 3 | 4 | 1 | ~17 |
| ai-agent | 6 | 3 | 3 | 1 | ~16 |
| data-pipeline | 6 | 2 | 3 | 1 | ~15 |
| telegram-bot | 4 | 2 | 3 | 1 | ~13 |
| cli-tool | 4 | 2 | 3 | 1 | ~13 |
| microservices | 8 | 3 | 4 | 1 | ~19 |
| fullstack | 7 | 3 | 4 | 1 | ~18 |
| presentation | 3 | 2 | 2 | 1 | ~11 |

---

## Constraints

1. **Token budget:** Generated CLAUDE.md must stay under P0 budget (400 tokens)
2. **Self-consistent:** auto-routing-rules.json must reference only agents that exist in generated profile
3. **No local Docker:** Generated profiles must not assume Docker availability
4. **Jinja2 reuse:** Use same template engine as `generate-agents.py`
5. **Opt-out:** `--no-claude-profile` flag for projects that don't need it
6. **Idempotent:** Running generation twice produces same result

---

## Next Steps

- ORCH-PROF-002: Create base profile templates (Jinja2)
- ORCH-PROF-003: Create 8 archetype overlay manifests + templates
- ORCH-PROF-004: Integrate into `new-project.sh`
