# Expert Consilium — Примеры использования

> Реальные примеры анализа сложных решений группой из 13 экспертов

---

## Пример 1: Параллелизация Quality Gates

### Контекст
В проекте CodeFoundry есть скрипт `quality-gates.sh`, который выполняет проверки последовательно. Разработчик хочет ускорить их, запуская параллельно.

### Запуск Expert Consilium
```
/expert-consilium "Should I parallelize quality-gates.sh? Current execution time: 45 seconds sequential."
```

### Результаты анализа

#### ✅ Supporters (8/13)

**Solution Architect:**
> "Parallel execution is a well-established pattern for independent checks. 3-5x speedup is realistic."

**Unix Script Expert:**
> "Your script already has separate functions. Can use `parallel` or `make -j` easily. No rewrite needed!"

**DevOps Engineer:**
> "Faster feedback = better developer experience. CI/CD will benefit significantly."

**CI/CD Architect:**
> "Independent checks are perfect for parallelization. No dependencies between gates."

**GitOps Specialist:**
> "GitOps 2.0 requires fast validation loops. Parallel gates support this."

**AI IDE Expert:**
> "Token cost increases 2-3x, but time savings 3-5x. Worth it for frequent runs."

**TDD Expert:**
> "Fast quality gates = faster TDD cycle. Critical for test-driven development."

**Prompt Engineer:**
> "Current gates are token-optimized. Parallel execution won't break @ref pattern."

#### ❌ Opponents (2/13)

**SRE:**
> "Concerned about race conditions in shared state. Need proper isolation."

**IaC Expert:**
> "If gates write to same files, parallel execution risks corruption. Need file locking."

#### ⚖️ Neutral (3/13)

**Backup Specialist:**
> "Support if pre-work backup added. Parallel = more files at risk."

**Docker Engineer:**
> "If gates run in Docker, ensure no port conflicts. Otherwise fine."

**UAT Engineer:**
> "Test with novice users. Error messages from parallel failures must be clear."

### Синтез

**Consensus:** Strong Majority (8/13 support, 2 oppose, 3 neutral)

**Recommendation:** Proceed with parallelization using backup-coordinator

**Confidence:** 0.78

**Implementation Plan:**
1. Add `--parallel` flag to `quality-gates.sh`
2. Integrate with `backup-coordinator` agent for pre-work backup
3. Use GNU parallel or make -j for execution
4. Aggregate error messages for clarity
5. Add circuit breaker: stop on first failure if needed

**Mitigations for Opponents' Concerns:**
- **SRE:** Add circuit breaker, monitor for race conditions
- **IaC:** Ensure gates are read-only or use file locking

### Final Decision
✅ **ПРОЙТИ С ПАРАЛЛЕЛИЗАЦИЕЙ** с safeguards

---

## Пример 2: Миграция с Bash на Python

### Контекст
Проект имеет ~20 bash scripts для автоматизации. Team lead рассматривает миграцию на Python для лучшей maintainability.

### Запуск Expert Consilium
```
/expert-consilium "Should I migrate automation scripts from Bash to Python? Current: ~20 scripts, 2000 lines total."
```

### Результаты анализа

#### ✅ Supporters (6/13)

**Solution Architect:**
> "Python better for complex logic >100 lines. Your scripts likely grew organically."

**TDD Expert:**
> "Python has built-in testing (pytest). Bash testing is painful."

**DevOps Engineer:**
> "If team knows Python, better long-term. Easier to hire Python devs."

**AI IDE Expert:**
> "Claude Code handles Python better than Bash for complex refactorings."

**CI/CD Architect:**
> "Python scripts easier to debug in CI. Stack traces vs set -x output."

**Prompt Engineer:**
> "Python patterns more consistent. Bash has too many dialects (GNU vs BSD)."

#### ❌ Opponents (4/13)

**Unix Script Expert:**
> "Bash is POSIX-standard. Python requires install. For <50 line scripts, Bash is simpler."

**Docker Engineer:**
> "Python adds image size. Alpine with Bash = 5MB, with Python = 50MB."

**GitOps Specialist:**
> "Bash scripts are portable across Linux. Python version compatibility issues."

**SRE:**
> "Production debugging harder if Python not installed. Bash always there."

#### ⚖️ Neutral (3/13)

**IaC Expert:**
> "Hybrid approach: Bash for glue, Python for business logic."

**Backup Specialist:**
> "Migration risk is high. Need backup + rollback plan."

**UAT Engineer:**
> "Team familiarity matters. What do devs prefer?"

### Синтез

**Consensus:** Split (6 support, 4 oppose, 3 neutral)

**Recommendation:** Hybrid approach based on script complexity

**Confidence:** 0.68

**Decision Framework:**

| Script Type | Use Bash | Use Python |
|-------------|----------|------------|
| <50 lines, glue, orchestration | ✅ Yes | ❌ No |
| >100 lines, complex logic | ❌ No | ✅ Yes |
| 50-100 lines | ⚠️ Maybe | ⚠️ Case-by-case |

**Implementation Plan:**
1. Audit scripts: categorize by complexity
2. Migrate complex scripts (>100 lines) to Python
3. Keep simple scripts (<50 lines) in Bash
4. Document decision criteria for future scripts
5. Add script size check to quality gates

### Final Decision
⚠️ **ГИБРИДНЫЙ ПОДХОД** — Bash для простого, Python для сложного

---

## Пример 3: Интеграция Agent Teams

### Контекст
CodeFoundry — meta-project с токен-оптимизацией через @ref. Рассматривается интеграция Claude Code Agent Teams для параллельных операций.

### Запуск Expert Consilium
```
/expert-consilium "Should I integrate Agent Teams into CodeFoundry? Concern: 2-5x token cost vs @ref optimization."
```

### Результаты анализа

#### ✅ Supporters (11/13)

**Solution Architect:**
> "@ref + Agent Teams = complementary architecture. @ref for static structure, Agents for dynamic workflows."

**Prompt Engineer:**
> "Prompt orchestration masterpiece! Static @refs + dynamic agents = optimal token usage."

**DevOps Engineer:**
> "GitOps workflow + Agent Teams = autonomous repo updates with oversight."

**CI/CD Architect:**
> "Natural extension of CI/CD patterns. Parallel review, parallel testing."

**GitOps Specialist:**
> "GitOps 2.0 = Declarative + AI agents. This is the future!"

**Unix Script Expert:**
> "Scripts already ready for parallel execution. Just need coordination layer."

**AI IDE Expert:**
> "Already using Opus 4.6 — correct model for Agent Teams. No migration needed."

**TDD Expert:**
> "Test generation acceleration! Parallel test scenarios."

**UAT Engineer:**
> "Multi-persona testing: novice, power user, edge case explorer in parallel."

**Docker Engineer:**
> "Teams need coordination for Docker ops. Prevents port conflicts."

**Backup Specialist:**
> "CRITICAL: Need backup-coordinator agent. Multi-agent work = higher corruption risk."

#### ⚠️ Cautious Support (2/13)

**SRE:**
> "Requires safeguards: health checks, circuit breakers, fallbacks. Don't skip."

**IaC Expert:**
> "Parallel IaC generation can create inconsistent state. Careful with dependencies."

### Синтез

**Consensus:** UNANIMOUS SUPPORT (11/13 full support, 2/13 cautious)

**Recommendation:** Proceed with phased integration, starting with safeguards

**Confidence:** 0.91

**Implementation Plan (6 phases):**

| Phase | Focus | Duration | Key Deliverables |
|-------|-------|----------|------------------|
| 1 | Foundation | 1-2 weeks | Routing rules, backup-coordinator |
| 2 | Skills | 1-2 weeks | Parallel/sequential/safe-mode skills |
| 3 | Integration | 2-3 weeks | GitOps 2.0 workflow, project gen |
| 4 | Observability | 1-2 weeks | Health checks, token monitoring |
| 5 | Testing | 1-2 weeks | Test suite, multi-persona UAT |
| 6 | Launch | 1-2 weeks | Documentation, announcement |

**Critical Success Factors:**
1. ✅ backup-coordinator agent (AT-002) — PRE-WORK BACKUP ALWAYS
2. ✅ Token budget monitoring (AT-010) — Track 2-5x increase
3. ✅ Health check system (AT-009) — Circuit breakers, fallbacks
4. ✅ Quality gate parallelization (AT-003) — 3-5x speedup

**Risk Mitigation:**
| Risk | Impact | Mitigation |
|------|--------|------------|
| Token overrun | HIGH | Monitoring, alerts, auto-stop |
| File corruption | HIGH | Backup coordinator, validation |
| Debugging complexity | MEDIUM | Comprehensive logging |

### Final Decision
✅ **НЕМЕДЛЕННО НАЧАТЬ ИНТЕГРАЦИЮ** по фазам с safeguards

---

## Пример 4: Выбор между Make и npm scripts

### Контекст
Node.js проект с Docker deployment. Нужно выбрать систему для автоматизации: Makefile или package.json scripts.

### Запуск Expert Consilium
```
/expert-consilium "Should I use Make or npm scripts for automation? Context: Node.js app, Docker deployment, cross-platform team."
```

### Результаты анализа

#### ✅ Make Supporters (5/13)

**Unix Script Expert:**
> "Make is POSIX standard. Works everywhere, even in minimal containers."

**DevOps Engineer:**
> "Make works for Docker builds, npm scripts don't. Need single toolchain."

**Docker Engineer:**
> "Makefiles in Docker, npm scripts fail if node_modules not mounted."

**SRE:**
> "Make has dependency tracking (`make -j`). npm scripts are always sequential."

**CI/CD Architect:**
> "Make portable across projects. Shell, Python, Go — all use Make."

#### ✅ npm scripts Supporters (3/13)

**AI IDE Expert:**
> "Team uses Node.js already. npm scripts = no new tool to learn."

**TDD Expert:**
> "npm test, npm run build: conventions. Devs expect this."

**UAT Engineer:**
> "Windows devs: Make requires WSL or install. npm scripts work natively."

#### ⚖️ Hybrid/Context (5/13)

**Solution Architect:**
> "Context-dependent. Pure Node → npm, cross-tool → Make."

**GitOps Specialist:**
> "Hybrid: npm for Node tasks, Make for cross-tool orchestration."

**IaC Expert:**
> "Make for infrastructure, npm for app. Clear separation."

**Backup Specialist:**
> "Both work. Choose based on team familiarity."

**Prompt Engineer:**
> "Make more powerful, npm simpler. Trade-off decision."

### Синтез

**Consensus:** Context-dependent (no majority for either option)

**Recommendation:** Hybrid approach based on project type

**Confidence:** 0.85

**Decision Matrix:**

| Project Type | Recommended | Rationale |
|--------------|-------------|-----------|
| Pure Node.js app | npm scripts | Team familiarity, conventions |
| Multi-language project | Make | Single orchestration layer |
| Docker-heavy | Make | Works in containers without Node |
| Cross-platform team | Make + npm fallback | Make primary, npm for Windows |

**Implementation Plan (Hybrid):**

```makefile
# Makefile
.PHONY: test build deploy

test:
	npm test

build:
	npm run build

deploy:
	docker-compose up -d
```

```json
// package.json
{
  "scripts": {
    "test": "jest",
    "build": "webpack",
    "lint": "eslint"
  }
}
```

**Usage:**
- Linux/Mac/Docker: `make test`, `make build`
- Windows native: `npm run test`, `npm run build`

### Final Decision
⚖️ **ГИБРИДНЫЙ ПОДХОД** — Make для orchestration, npm для Node-specific задач

---

## Резюме примеров

| Проблема | Консенсус | Решение | Уверенность |
|----------|-----------|---------|-------------|
| Параллельные quality gates | Strong majority (8/13) | ✅ Proceed with safeguards | 0.78 |
| Bash → Python миграция | Split (6/4/3) | ⚠️ Hybrid approach | 0.68 |
| Agent Teams интеграция | Unanimous (11/13) | ✅ Full integration | 0.91 |
| Make vs npm scripts | Context-dependent | ⚠️ Hybrid | 0.85 |

---

**Ключевой вывод:** Expert Consilium особенно полезен для:
1. ✅ Архитектурных решений (Agent Teams пример)
2. ✅ Решений с trade-offs (Bash vs Python)
3. ✅ Выбора инструментов (Make vs npm)
4. ✅ Оценки рисков (Quality gates)

**Не подходит для:**
1. ❌ Очевидных решений (единогласие не нужно)
2. ❌ Простых баг-фиксов (overkill)
3. ❌ Срочных hotfix (слишком медленно)

---

**Version:** 1.0.0
**Last Updated:** 2026-02-10
**See also:** [expert-consilium.md skill](../../.claude/skills/expert-consilium.md)
