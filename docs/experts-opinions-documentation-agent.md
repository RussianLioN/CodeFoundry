> [🏠 Главная](../README.md) → **📝 Documentation Agent**

---
# Мнения Экспертов: Documentation Agent

> **Дата:** 2025-02-01
> **Тема:** Создание AI-агента для автоматического ведения документации

---

## Вопрос для экспертов:

> **"Создать AI-агента, который будет регулярно следить за всеми артефактами проекта, вести и обновлять проектную документацию, проверять доступность всех файлов из корневого документа в три клика, наличием кросс-ссылок, логичностью и завершенностью файлов инструкций и всей документации. Вести документацию согласно лучшим практикам ведения проектной документации ИТ проектов и лучшим практикам ведения документации на GitHub. Что вы об этом думаете?"**

---

## 1. 📝 Technical Writer

```
┌─────────────────────────────────────────────────────────────────┐
│                    TECHNICAL WRITER PERSPECTIVE              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Current State Documentation:                                  │
│    ❌ Outdated README                                        │
│    ❌ Missing installation steps                            │
│    ❌ No API documentation                                   │
│    ❌ Inconsistent terminology                               │
│    ❌ Broken links                                           │
│                                                                  │
│  Documentation Agent to the Rescue:                           │
│    ✅ Automatic README generation                            │
│    ✅ API docs from code (OpenAPI/Swagger)                  │
│    ✅ Installation instructions always current              │
│    ✅ Consistent terminology across all files               │
│    ✅ Link validation and fixes                               │
│    ✅ CHANGELOG auto-update                                  │
│                                                                  │
│  Key Features Needed:                                          │
│    1. Content Analysis                                         │
│       → Detect changes in code/api                          │
│       → Update docs accordingly                             │
│                                                                  │
│    2. Link Checker                                            │
│       → Validate all @ref links                             │
│       → Fix broken links                                    │
│       → Check 3-click accessibility                         │
│                                                                  │
│    3. Style Guide Enforcement                                 │
│       → Consistent formatting                                │
│       → Terminology glossary                                │
│       → Voice and tone guidelines                           │
│                                                                  │
│    4. Template-Based Generation                              │
│       → README.md template                                  │
│       → API docs template                                   │
│       → CHANGELOG template (Keep a Changelog format)        │
│                                                                  │
│  Best Practices to Follow:                                    │
│    • Diátexis Forward (docs before code)                     │
│    • Docs as Code (version controlled)                      │
│    • Single Source of Truth (avoid duplication)             │
│    • User-Centric (organized by user goals)                  │
│    • Searchable (good structure, keywords)                  │
│                                                                  │
│  Recommended Workflow:                                        │
│    1. Scan project for changes                                │
│    2. Identify affected docs                                 │
│    3. Generate updates                                       │
│    4. Validate links and accessibility                        │
│    5. Create PR with changes                                 │
│    6. Track documentation coverage                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Verdict:** ✅ **КРИТИЧЕСКИ НЕОБХОДИМ**

**Priority Features:**
1. Link validation (@ref checker)
2. 3-click accessibility test
3. Auto-README generation
4. CHANGELOG automation
5. Style guide enforcement

---

## 2. 🏗️ Information Architecture Specialist

```
┌─────────────────────────────────────────────────────────────────┐
│              INFORMATION ARCHITECTURE PERSPECTIVE               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Current Documentation Structure:                              │
│    ❌ Flat hierarchy (hard to navigate)                      │
│    ❌ No clear entry points                                  │
│    ❌ Orphaned pages (no links to them)                       │
│    ❌ Deep nesting (>5 levels)                                │
│    ❌ Inconsistent organization                              │
│                                                                  │
│  Documentation Agent Improvements:                             │
│    ✅ 3-Click Navigation Guarantee                            │
│    ✅ Hierarchical sitemap                                  │
│    ✅ Content audit (orphaned pages)                         │
│    ✅ User journey mapping                                    │
│    ✅ Card sorting (content organization)                    │
│    ✅ Navigation testing                                     │
│                                                                  │
│  Information Architecture Principles:                          │
│    1. Hierarchy                                                 │
│       Home → Categories → Content → Details                   │
│       Max 3-4 clicks to any content                           │
│                                                                  │
│    2. Modularity                                              │
│       Self-contained sections                                │
│       Reusable patterns                                     │
│       Clear boundaries                                        │
│                                                                  │
│    3. Findability                                            │
│       Search keywords                                       │
│       Clear labels                                          │
│       Multiple pathways                                     │
│                                                                  │
│    4. Scalability                                            │
│       Easy to add new content                               │
│       Structure remains stable                              │
│       Can grow without reorg                                 │
│                                                                  │
│  3-Click Accessibility Validation:                            │
│    ┌──────────────────────────────────────────────────────┐   │
│    │  Algorithm:                                            │   │
│    │  1. Start from README.md (root)                      │   │
│    │  2. BFS through @ref links                            │   │
│    │  3. Track click depth for each file                   │   │
│    │  4. Report files > 3 clicks                             │   │
│    │  5. Suggest restructure                                │   │
│    └──────────────────────────────────────────────────────┘   │
│                                                                  │
│  Breadcrumb Pattern:                                          │
│    > [🏠 Главная](README.md) → [📚 Docs](docs/) → [📋 Guide](guide.md)│
│                                                                  │
│  Cross-Reference Validation:                                  │
│    ✅ @ref:file.md — check target exists                    │
│    ✅ @ref:file.md#section — check section exists            │
│    ✅ Relative links — check they resolve                   │
│    ✅ External links — check they're valid                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Verdict:** ✅ **КРИТИЧЕСКИ ВАЖНО**

**Priority Features:**
1. Navigation structure validation
2. Orphaned content detection
3. Link depth analysis
4. Breadcrumb completeness
5. Sitemap generation

---

## 3. 🤖 AI/ML Documentation Expert

```
┌─────────────────────────────────────────────────────────────────┐
│                  AI/ML DOCUMENTATION PERSPECTIVE                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Challenge: AI-Powered Documentation Generation                │
│                                                                  │
│  Traditional Approach:                                         │
│    ❌ Manual documentation (forgotten, outdated)              │
│    ❌ Separate from code (diverges over time)                │
│    ❌ Static content (hard to maintain)                        │
│                                                                  │
│  AI-First Approach:                                            │
│    ✅ Docs from code (automated)                            │
│    ✅ Always up-to-date                                       │
│    ✅ Context-aware generation                                 │
│    ✅ Multi-format output (Markdown, HTML, PDF)              │
│                                                                  │
│  Technical Implementation:                                     │
│                                                                 │
│    Code → Docs:                                               │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  Input: Source code                                     │  │
│    │  Process:                                              │  │
│    │    1. Parse AST (abstract syntax tree)               │  │
│    │    2. Extract docstrings                                │  │
│    │    3. Analyze type signatures                          │  │
│    │    4. Infer API structure                              │  │
│    │  5. Generate OpenAPI spec                             │  │
│    │  Output: API documentation                            │  │
│    └────────────────────────────────────────────────────────┘  │
│                                                                  │
│    Docs → Code:                                               │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  Input: Documentation                                │  │
│    │  Process:                                              │  │
│    │    1. Parse docs                                       │  │
│    │    2. Extract requirements                              │  │
│    │    3. Generate code stubs                             │  │
│    │    4. Validate with user                              │  │
│    │  Output: Code with docstrings                        │  │
│    └────────────────────────────────────────────────────────┘  │
│                                                                  │
│  AI Capabilities for Documentation Agent:                    │
│                                                                 │
│    1. Content Analysis                                        │
│       • NLP for understanding code changes                   │
│       • Semantic similarity for finding related docs          │
│       • Intent classification for categorization             │
│                                                                 │
│    2. Quality Assessment                                     │
│       • Completeness check (missing sections?)               │
│       • Consistency check (terminology, format)             │
│       • Clarity score (readability metrics)                  │
│       • Accuracy validation (docs vs code)                  │
│                                                                 │
│    3. Generation                                             │
│       • Template-based doc generation                       │
│       • Multi-language support (Russian + English)           │
│       • Code examples from actual implementation             │
│       • Diagram generation (Mermaid, PlantUML)               │
│                                                                 │
│    4. Maintenance                                           │
│       • Change detection (git diff)                          │
│       • Impact analysis (what docs to update?)               │
│       • Auto-update (pull request with changes)               │
│       • Version tracking (doc versions vs code versions)      │
│                                                                 │
│  Best Practices for AI Documentation:                         │
│    • Diátexis Forward (write docs before implementation)    │
│    • Living Documentation (always up-to-date)                │
│    • Docs as Code (version controlled, testable)             │
│    • Single Source of Truth (avoid duplication)              │
│    • User-Centric (organized by user goals)                 │
│    • Measurable Quality (coverage, freshness, accuracy)      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Verdict:** ✅ **ИДЕАЛЬНО ПОДХОДИТ ДЛЯ AI**

**Priority Features:**
1. Code → Docs (AST parsing, docstrings)
2. Docs quality scoring
3. Automatic updates on git changes
4. Multi-format output
5. Change detection

---

## 4. 🚀 DevOps Documentation Engineer

```
┌─────────────────────────────────────────────────────────────────┐
│                 DEVOPS DOCUMENTATION PERSPECTIVE                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  CI/CD Integration:                                           │
│                                                                 │
│  Documentation Agent in Pipeline:                              │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  Pipeline:                                              │  │
│    │    1. Code pushed                                      │  │
│    │    2. CI builds                                         │  │
│    │    3. Docs Agent checks docs                            │  │
│    │    4. If docs fail: ⛔                               │  │
│    │    5. If docs pass: ✅                               │  │
│    │    6. Deploy                                          │  │
│    └────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Checks in CI:                                                 │
│    ✅ All @ref links valid                                 │
│    ✅ 3-click accessibility                               │
│    ✅ Breadcrumbs present                                   │
│    ✅ No orphaned pages                                      │
│    ✅ README exists and complete                           │
│    ✅ CHANGELOG up to date                                  │
│    ✅ API docs match code                                   │
│                                                                  │
│  GitHub Best Practices:                                       │
│                                                                 │
│    README.md:                                                  │
│    • Project title + badge                                  │
│    • Short description                                       │
│    • Quick start (3-5 commands)                             │
│    • Screenshot (if applicable)                              │
│    • Features list                                          │
│    • Installation instructions                               │
│    • Usage examples                                          │
│    • Contributing guidelines                                │
│    • License                                                 │
│                                                                 │
│    docs/ folder:                                              │
│    • architecture.md                                        │
│    • api/ (OpenAPI specs)                                   │
│    • guides/                                               │
│    • troubleshooting.md                                     │
│                                                                 │
│    CHANGELOG.md:                                              │
│    • Follow Keep a Changelog format                           │
│    • Auto-generated from commits                             │
│    • Categorized: Added, Changed, Deprecated, Removed      │
│                                                                 │
│  Automation:                                                  │
│    • Pre-commit hook: validate docs                           │
│    • Post-commit hook: update docs                             │
│    • Scheduled: nightly full check                            │
│    • On-demand: manual trigger                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Verdict:** ✅ **КРИТИЧЕСКИ ДЛЯ CI/CD**

**Priority Features:**
1. CI/CD integration gates
2. Pre-commit documentation validation
3. CHANGELOG automation
4. GitHub standards compliance
5. Automated documentation testing

---

## 5. 📏 Software Documentation Standards Expert

```
┌─────────────────────────────────────────────────────────────────┐
│            SOFTWARE DOCUMENTATION STANDARDS PERSPECTIVE          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Industry Standards:                                          │
│                                                                 │
│    IEEE 1063:                                                │
│    • Standard for Software User Documentation                 │
│    • Structure: Purpose, audience, scope                     │
│    • Requirements: Tutorial, reference, examples             │
│                                                                 │
│    ISO/IEC 26514:                                            │
│    • Open technical documentation standard                    │
│    • Principles: Accessibility, maintainability              │
│                                                                 │
│    Google Technical Writing:                                  │
│    • Structure: Clear, scannable, searchable                │
│    • Style: Second person ("You can...")                      │
│    • Format: Concept → Task → Reference → Troubleshooting     │
│                                                                 │
│    Microsoft Style Guide:                                     │
│    • Voice: Active, present tense                            │
│    • Clarity: One concept per sentence                       │
│    • Procedures: Step-by-step, numbered                       │
│                                                                 │
│  Documentation Agent Standards:                               │
│                                                                 │
│    Structure Checklist:                                        │
│    ✅ Title (clear, descriptive)                            │
│    ✅ Purpose (why this exists)                              │
│    ✅ Prerequisites (what you need)                          │
│    ✅ Quick Start (fast path to success)                     │
│    ✅ Detailed Instructions (step-by-step)                   │
│    ✅ Examples (real-world use cases)                       │
│    ✅ Troubleshooting (common issues)                         │
│    ✅ Reference (complete details)                           │
│    ✅ Changelog (version history)                            │
│                                                                 │
│    Quality Metrics:                                           │
│    ✅ Completeness: all sections present                      │
│    ✅ Accuracy: docs match implementation                   │
│    ✅ Clarity: Flesch Reading Ease > 60                        │
│    ✅ Accessibility: WCAG 2.1 AA                             │
│    ✅ Findability: search success rate > 80%                 │
│    ✅ Freshness: last update < 30 days                          │
│                                                                 │
│    Templates:                                                 │
│    ✅ README.md template (Google-style)                      │
│    ✅ API docs template (OpenAPI 3.0)                         │
│    ✅ CHANGELOG.md template (Keep a Changelog)                │
│    ✅ CONTRIBUTING.md template                                │
│    ✅ ARCHITECTURE.md template                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Verdict:** ✅ **КРИТИЧЕСКИ ДЛЯ КАЧЕСТВА**

**Priority Features:**
1. Template-based generation
2. Quality metrics dashboard
3. Standards compliance checking
4. Reading level analysis
5. Accessibility validation

---

## 6. 🤖 AI IDE Expert (Claude Code, Cursor, etc.)

```
┌─────────────────────────────────────────────────────────────────┐
│                   AI IDE INTEGRATION PERSPECTIVE                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  IDE-Specific Considerations:                                  │
│                                                                 │
│    Claude Code:                                               │
│    • Works with .claude/ directory                           │
│    • CLAUDE.md as system prompt                              │
│    • Coordinator.md for orchestration                        │
│    • Agents: coordinator, code_assistant, reviewer, etc.    │
│                                                                 │
│    Documentation Agent Integration:                           │
│    • Add .claude/documentation-agent.md                       │
│    • Trigger on file changes                                 │
│    • Auto-update README, API docs                             │
│    • Check links and accessibility                           │
│                                                                 │
│    .claude/settings.json:                                      │
│    {                                                         │
│      "autoDocumentation": true,                               │
│      "docsUpdateFrequency": "on_change",                       │
│      "linkCheck": true,                                       │
│      "accessibilityCheck": true,                               │
│      "standards": ["Google", "Microsoft"]                     │
│    }                                                         │
│                                                                 │
│    Cursor AI:                                                 │
│    • .cursorrules as system prompt                          │
│    • Similar structure to Claude Code                        │
│    • Can share documentation agent template                  │
│                                                                 │
│  Workflow:                                                     │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  1. User writes code                                    │  │
│    │  2. IDE detects file save                               │  │
│    │  3. Documentation Agent notified                       │  │
│    │  4. Agent analyzes changes                              │  │
│    │  5. Agent updates affected docs                         │  │
│    │  6. Agent validates links                               │  │
│    │  7. Agent suggests changes                              │  │
│    │  8. User approves → docs updated                         │  │
│    └────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Integration Points:                                          │
│    • File watcher for .py, .ts, .go, .rs changes               │
│    • Git hooks for commit-time validation                   │
│    • IDE commands: /check-docs, /update-docs, /fix-links     │
│    • Status bar: docs health indicator                        │
│    • Problems tab: doc issues list                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Verdict:** ✅ **КРИТИЧЕСКИ ДЛЯ IDE WORKFLOW**

**Priority Features:**
1. IDE-specific template (Claude Code, Cursor)
2. File watcher integration
3. IDE commands for docs
4. Status bar indicators
5. Problems tab integration

---

## 7. 🎯 Prompt Engineer (Expert Level)

```
┌─────────────────────────────────────────────────────────────────┐
│                  PROMPT ENGINEERING PERSPECTIVE                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Prompt Architecture for Documentation Agent:                 │
│                                                                 │
│    ┌────────────────────────────────────────────────────────┐  │
│    │  SYSTEM PROMPT (Root)                                   │  │
│    │                                                          │  │
│    │  Role: Documentation Guardian                            │  │
│    │  Mission: Ensure documentation excellence              │  │
│    │                                                          │  │
│    │  Core Responsibilities:                                  │  │
│    │  • Monitor project artifacts                            │  │
│    │  • Update documentation proactively                      │  │
│    │  • Validate accessibility (3-click rule)                │  │
│    │  • Check cross-references (@ref links)                   │  │
│    │  • Enforce best practices                               │  │
│    │                                                          │  │
│    │  Quality Standards:                                     │  │
│    │  • Accuracy: docs must match code                       │  │
│    │  • Completeness: no missing sections                      │  │
│    │  • Clarity: Flesch score > 60                            │  │
│    │  • Accessibility: WCAG 2.1 AA                            │  │
│    │  • Findability: searchable, organized                  │  │
│    │                                                          │  │
│    │  Tools Available:                                       │  │
│    │  • read: Read any file                                   │  │
│    │  • write: Create/update files                           │  │
│    │  • edit: Edit existing files                            │  │
│    │  • grep: Search for patterns                             │  │
│    │  • bash: Run validation scripts                         │  │
│    │                                                          │  │
│    └────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Prompt Structure:                                            │
│                                                                 │
│    ## Monitoring Workflow                                     │
│    Every time trigger fires (file change / scheduled):       │
│    1. Scan project for changes                               │
│    2. Identify affected documentation                         │
│    3. For each affected doc:                                  │
│       a. Read current content                                 │
│       b. Analyze what changed                                │
│       c. Determine required updates                          │
│       d. Generate updates                                    │
│       e. Validate quality                                     │
│       f. Create PR or update directly                        │
│                                                                 │
│    ## Validation Workflow                                    │
│    Run daily:                                                 │
│    1. 3-Click Accessibility Test                             │
│       • Start from README.md                                │
│       • BFS through @ref links                               │
│       • Report files > 3 clicks                              │
│    2. Cross-Reference Validation                             │
│       • Validate all @ref:file.md                           │
│       • Validate all @ref:file.md#section                   │
│       • Check for orphaned files                            │
│    3. Completeness Check                                     │
│       • README.md exists?                                   │
│       • CHANGELOG.md up to date?                             │
│       • API docs match code?                                │
│    4. Best Practices Check                                   │
│       • Follow Google style guide?                          │
│       • Terminology consistent?                              │
│       • Examples included?                                  │
│                                                                 │
│    ## Update Workflow                                        │
│    When changes detected:                                   │
│    1. Analyze impact (what docs to update?)                  │
│    2. Generate updates                                       │
│    3. Preview changes                                        │
│    4. Create PR with description:                            │
│       "Docs update: [summary]"                               │
│       "Changed files: [list]"                                │
│       "Reason: [what triggered update]"                      │
│    5. Track PR status                                        │
│                                                                 │
│  Best Practices for Prompt Engineering:                     │
│    • Clear role definition                                   │
│    • Explicit constraints                                    │
│    • Step-by-step workflows                                 │
│    • Examples for each task type                            │
│    • Error handling procedures                              │
│    • Quality criteria                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Verdict:** ✅ **КРИТИЧЕСКИ ДЛЯ ПРОМПТ ДИЗАЙНА**

**Prompt Engineering Best Practices:**
1. Clear role + mission statement
2. Explicit responsibilities
3. Tool usage guidelines
4. Workflow step-by-step
5. Quality criteria checklist
6. Error handling procedures

---

## 🎯 Консенсус Экспертов

```
┌─────────────────────────────────────────────────────────────────┐
│                    EXPERT CONSENSUS MATRIX                    │
├─────────────────────────────────────────────────────────────────┤
│ Expert              │ Vote │ Priority │ Key Concern           │
├─────────────────────┼──────┼──────────┼─────────────────────────┤
│ Technical Writer    │  ✅  │ CRITICAL │ Content completeness    │
│ IA Specialist        │  ✅  │ CRITICAL │ 3-click accessibility    │
│ AI/ML Docs Expert   │  ✅  │ HIGH     │ Code→Docs automation    │
│ DevOps Docs         │  ✅  │ HIGH     │ CI/CD integration         │
│ Standards Expert    │  ✅  │ HIGH     │ Industry standards         │
│ AI IDE Expert       │  ✅  │ HIGH     │ IDE workflow               │
│ Prompt Engineer    │  ✅  │ HIGH     │ Prompt design              │
└─────────────────────┴──────┴──────────┴─────────────────────────┘

CONSENSUS: ✅ IMPLEMENT RECOMMENDED (7/7 votes)
```

---

## 📋 Рекомендации по Реализации

### Phase 1: Template Creation (1-2 дня)

```yaml
documentation_agent_template:
  file: templates/agents/documentation-agent.template
  sections:
    - role: "Documentation Guardian"
    - mission: "Ensure documentation excellence"
    - responsibilities: 7 core responsibilities
    - quality_standards: 5 quality pillars
    - workflows: 3 workflows (monitor, validate, update)
    - best_practices: IT + GitHub standards
```

### Phase 2: Validation Scripts (2-3 дня)

```bash
scripts/
  ├── check-docs-3click.sh      # 3-click accessibility
  ├── check-docs-links.sh       # Cross-reference validation
  ├── check-docs-complete.sh    # Completeness check
  └── fix-docs.sh               # Auto-fix issues
```

### Phase 3: Integration (3-4 дня)

```yaml
integration:
  project_initializer:
    - Add Stage 3.6: Documentation Agent creation

  makefile:
    - make check-docs
    - make fix-docs
    - make generate-api-docs

  ci_cd:
    - Add docs validation job
  - Pre-commit hook for validation
```

---

> **Вывод:** Все 7 экспертов единогласно рекомендуют создать Documentation Agent. Это критически важный компонент для поддержания качества документации в проекте.
