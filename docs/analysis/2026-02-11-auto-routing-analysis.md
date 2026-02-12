# Auto-Routing Rules Analysis

**Date:** 2026-02-11
**Analyst:** Expert Consilium v2.0.3
**Status:** ✅ NO PHANTOM AGENTS (но есть orphan agents)

---

## Executive Summary

Анализ `auto-routing-rules.json` показал:
- **Phantom agents:** 0 (все routing rules легитимны)
- **Orphan agents:** 2 (файлы существуют, но routing отсутствует)
- **Virtual agents:** 3 (system, code_assistant, reviewer — built-in)
- **Total agents:** 10 (3 virtual + 7 specialized)

---

## 1. Phantom Agents Analysis

**Результат:** ✅ НЕТ phantom agents

Все агенты, указанные в `auto-routing-rules.json`, легитимны:

| Agent | Type | Status | Notes |
|-------|------|--------|-------|
| `system` | Virtual | ✅ Valid | Built-in agent для системных команд |
| `code_assistant` | Virtual | ✅ Valid | Built-in agent для работы с кодом |
| `reviewer` | Virtual | ✅ Valid | Built-in agent для ревью |

**Важно:** Эти 3 агента — **виртуальные** (не имеют `.md` файлов), они встроены в Claude Code. Их использование в routing rules корректно.

---

## 2. Orphan Agents Analysis

**Результат:** ⚠️ 2 orphan agents обнаружено

Файлы агентов существуют, но routing rules отсутствуют:

### 2.1 tasks-sync

**File:** `.claude/agents/tasks-sync.md`
**Purpose:** TASKS.md ↔ GitHub Issues synchronization specialist
**Missing:** Routing rule in auto-routing-rules.json

**Suggested trigger keywords:**
- "sync tasks", "github issues", "task synchronization", "синхронизация задач"

**Proposed rule:**
```json
{
  "id": "tasks-sync",
  "name": "Tasks Synchronization",
  "priority": 60,
  "agent": "tasks-sync",
  "triggers": {
    "keywords": [
      "sync tasks",
      "github issues",
      "task sync",
      "синхронизируй задачи",
      "обнови задачи"
    ],
    "patterns": [
      "sync (.+)?(tasks|issues)",
      "(create|update) github issue",
      "sync tasks? to github"
    ]
  },
  "context": {
    "gitRelated": true,
    "taskManagement": true
  }
}
```

### 2.2 ollama-gemini-researcher

**File:** `.claude/agents/ollama-gemini-researcher.md`
**Purpose:** Research specialist for Ollama + gemini-3-flash-preview deployment, Docker, OpenClaw
**Missing:** Routing rule in auto-routing-rules.json

**Suggested trigger keywords:**
- "ollama", "gemini", "docker deployment", "openclaw"

**Proposed rule:**
```json
{
  "id": "ollama-gemini-research",
  "name": "Ollama + Gemini Research",
  "priority": 65,
  "agent": "ollama-gemini-researcher",
  "triggers": {
    "keywords": [
      "ollama",
      "gemini",
      "docker deployment",
      "openclaw",
      "local llm",
      "локальная модель"
    ],
    "patterns": [
      "(deploy|setup) (ollama|gemini)",
      "openclaw (.+)",
      "local (llm|model) deployment"
    ]
  },
  "context": {
    "deploymentRelated": true,
    "llmResearch": true,
    "dockerRelated": true
  }
}
```

---

## 3. Current Agent Inventory

### 3.1 Virtual Agents (Built-in)

| Agent | Rules Count | Priority Range | Domain |
|-------|-------------|----------------|--------|
| `system` | 4 | 100 | System commands |
| `code_assistant` | 8 | 70-92 | Code operations |
| `reviewer` | 2 | 80-98 | Quality & security |

### 3.2 Specialized Agents (with .md files)

| Agent | File | Rules | Priority | Domain |
|--------|------|-------|----------|--------|
| `token-optimizer` | ✅ | 1 | 85 | AI/Token efficiency |
| `backup-coordinator` | ✅ | 1 | 90 | Safety/Backups |
| `documentation-agent` | ✅ | 1 | 5 | Documentation health |
| `expert-consilium` | ✅ | 1 | 95 | Decision making (v1) |
| `expert-consilium-v2` | ✅ | 1 | 96 | Decision making (v2) |
| `tasks-sync` | ✅ | **0** | — | Task management |
| `ollama-gemini-researcher` | ✅ | **0** | — | LLM research |

---

## 4. Optimal Structure for 10+ Agents

### 4.1 Domain-Based Grouping

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENT DOMAINS                         │
├─────────────────────────────────────────────────────────────┤
│                                                       │
│  🏗️ INFRASTRUCTURE (3 agents)                        │
│     ├── backup-coordinator (priority: 90)               │
│     ├── deployment (via system, priority: 100)           │
│     └── ollama-gemini-researcher (priority: 65)       │
│                                                       │
│  📦 DELIVERY (2 agents)                               │
│     ├── tasks-sync (priority: 60)                       │
│     └── project-generation (via system, priority: 100)   │
│                                                       │
│  🔍 QUALITY (3 agents)                                │
│     ├── reviewer/virtual (priority: 80-98)              │
│     ├── documentation-agent (priority: 5)                │
│     └── code_assistant/virtual (priority: 70-92)        │
│                                                       │
│  🤖 AI & ANALYSIS (3 agents)                          │
│     ├── token-optimizer (priority: 85)                  │
│     ├── expert-consilium (priority: 95)                  │
│     └── expert-consilium-v2 (priority: 96)            │
│                                                       │
│  ⚙️ SYSTEM (fallback)                                 │
│     └── system/virtual (priority: 100)                 │
│                                                       │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Priority-Based Conflict Resolution

**Tier 1: Critical (100)**
- System commands (project generation, deployment)
- Override all other agents

**Tier 2: High-Priority (90-99)**
- Safety operations (backup-coordinator: 90)
- Decision making (expert-consilium: 95, expert-consilium-v2: 96)
- Security analysis (reviewer: 98)

**Tier 3: Medium-Priority (70-89)**
- Code operations (code_assistant: 70-92)
- Token optimization (token-optimizer: 85)

**Tier 4: Specialized (60-69)**
- Domain-specific research (ollama-gemini-researcher: 65)
- Task synchronization (tasks-sync: 60)

**Tier 5: Background (<60)**
- Documentation monitoring (documentation-agent: 5)

### 4.3 Fallback Strategy

```json
"fallbackRules": {
  "defaultAgent": "code_assistant",
  "confidenceThreshold": 0.7,
  "allowMultipleAgents": true,
  "maxAgentsPerRequest": 3
}
```

**Rationale:**
- `code_assistant` — most versatile agent
- Confidence threshold 0.7 — avoid false positives
- Max 3 agents — prevent overwhelming responses

---

## 5. Recommendations

### 5.1 Immediate Actions (P0)

1. **Add routing rule for `tasks-sync`**
   - Triggers: "sync tasks", "github issues"
   - Priority: 60 (medium-low)
   - Context: git, task management

2. **Add routing rule for `ollama-gemini-researcher`**
   - Triggers: "ollama", "gemini", "openclaw"
   - Priority: 65 (low-medium)
   - Context: deployment, LLM research

### 5.2 Documentation (P1)

3. **Create `.claude/AGENTS-REGISTRY.md`**
   - Central registry of all agents
   - Track virtual vs specialized
   - Document routing rules

4. **Update schema enum validation**
   - ✅ Already includes all 10 agents
   - Keep in sync with agents directory

### 5.3 Process (P2)

5. **Agent addition checklist:**
   - Create `.claude/agents/{name}.md`
   - Add routing rule to `auto-routing-rules.json`
   - Update schema enum (if needed)
   - Register in AGENTS-REGISTRY.md
   - Test routing with sample queries

---

## 6. Validation Status

| Check | Status | Details |
|-------|--------|---------|
| JSON syntax | ✅ Valid | Passes schema validation |
| Schema enum | ✅ Valid | All 10 agents in enum |
| Agent files exist | ⚠️ 2 orphan | tasks-sync, ollama-gemini-researcher |
| Routing coverage | ⚠️ 80% | 8/10 agents have routing |
| Priority distribution | ✅ Good | 5-100 range, tiered |

---

## Appendix A: Agent Routing Matrix

| Query Type | Primary Agent | Priority | Backup |
|-----------|--------------|-----------|--------|
| "create new project" | system | 100 | — |
| "generate agents for..." | system | 100 | — |
| "optimize tokens" | token-optimizer | 85 | code_assistant |
| "create backup" | backup-coordinator | 90 | system |
| "sync tasks to github" | tasks-sync | **60** | — |
| "deploy ollama" | ollama-gemini-researcher | **65** | backup-coordinator |
| "expert analysis of..." | expert-consilium-v2 | 96 | expert-consilium |
| "review my code" | reviewer | 95 | code_assistant |
| "write function..." | code_assistant | 90 | — |
| "check documentation" | documentation-agent | 5 | code_assistant |

---

**Report Generated:** 2026-02-11
**Expert Consilium Version:** 2.0.3
**Confidence:** 0.95 (HIGH)
