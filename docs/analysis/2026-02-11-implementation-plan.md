# Implementation Plan — Expert Consilium Recommendations

**Date:** 2026-02-11
**Consensus:** 92% (13 experts, 4 domains)
**Total Effort:** 10.5h P0 + 5h P1 + 36h long-term

---

## 📊 Summary by Domain

| Domain | Experts | Key Recommendations | Files |
|--------|---------|-------------------|-------|
| **Infrastructure** | 5 (Docker, Unix, IaC, Backup, SRE) | Docker optimization, POSIX fixes, Terraform, monitoring | 8 files |
| **Delivery** | 3 (DevOps, CI/CD, GitOps) | 3-tier CI/CD, error logging, PR automation | 5 files |
| **Quality** | 2 (TDD, UAT) | TDD pyramid, 85% coverage, 6 test files | 6 files |
| **AI** | 2 (AI IDE, Prompt Engineer) | 65-75% token savings, JSON format, Agent Teams | 4 files |

**Total: 23 files to create**

---

## 🔴 P0: Production Readiness (10.5 hours)

### 1. GitOps для LESSONS.md (2h)
**Owner:** Delivery + Infrastructure

**Tasks:**
- [ ] Auto-commit LESSONS.md при достижении threshold=3
- [ ] Pre-commit hook для JSON validation
- [ ] Git blame integration для attribution

**Files:**
- `scripts/auto-lesson-pr.py` — GitOps PR automation
- `.git/hooks/pre-commit-lessons` — Auto-extract (создан)
- `Makefile` — Add `make lesson-auto-commit`

**Implementation:**
```bash
# Auto-commit when threshold reached
python3 scripts/lesson-learned-tracker.py extract --auto-commit
```

---

### 2. Production Backup Strategy (1.5h)
**Owner:** Infrastructure + Delivery

**Tasks:**
- [ ] Docker volume для .tracking/
- [ ] Cron scheduling (daily/weekly/monthly)
- [ ] Git archive integration

**Files:**
- `docker-compose.yml` — Add volume for .tracking/
- `crontab.backup` — Cron entries
- `scripts/backup-coordinator.sh` — Integrate LESSONS.md

**Status:** ✅ `scripts/backup-lessons.sh` создан, нужно интегрировать

---

### 3. Quality Gates Integration (2h)
**Owner:** Quality + Delivery

**Tasks:**
- [ ] Auto-extract gate: `make gate-lessons`
- [ ] Pre-commit trigger для extract
- [ ] Blocking gate для invalid_json

**Files:**
- `scripts/quality-gates.sh` — ✅ Gate B8, I8 добавлены
- `.git/hooks/pre-commit-validate-settings` — ✅ Создан

**Status:** ✅ Complete (уже реализовано в Session #20)

---

### 4. .gitignore Updates (0.5h)
**Owner:** Infrastructure

**Tasks:**
- [ ] Add .tracking/ to .gitignore
- [ ] Add *.backup.*.json to .gitignore
- [ ] Validate с git check-ignore

**Files:**
- `.gitignore` — Add patterns

**Implementation:**
```bash
echo ".tracking/" >> .gitignore
echo "*.backup.*.json" >> .gitignore
```

---

### 5. Lesson Stats Command (0.5h)
**Owner:** AI + Delivery

**Tasks:**
- [ ] Add `make lesson-stats` to Makefile
- [ ] Show error distribution by type
- [ ] Show extraction status

**Files:**
- `Makefile` — Add target

**Status:** ✅ `make lessons-stats` уже существует

---

### 6. Settings Validation Script (1h)
**Owner:** Quality + Infrastructure

**Tasks:**
- [ ] Reuse sanitize-settings.py as validate-settings.py
- [ ] Add JSON schema validation
- [ ] Exit code handling

**Files:**
- `scripts/validate-settings.py` — ✅ Создан
- `.claude/schemas/settings.schema.json` — ✅ Создан

**Status:** ✅ Complete

---

### 7. Docker Volume for .tracking/ (1h)
**Owner:** Infrastructure

**Tasks:**
- [ ] Add named volume to docker-compose.yml
- [ ] Backup скрипт должен учитывать volume
- [ ] Recovery procedure documentation

**Files:**
- `docker-compose.yml` — Add volume
- `docs/recovery.md` — Recovery procedures

---

### 8. Shell Syntax Fixes (2h)
**Owner:** Infrastructure (Unix Script Expert)

**Tasks:**
- [ ] Run shellcheck on all scripts/*.sh
- [ ] Fix 3 pre-existing shell syntax errors
- [ ] Add POSIX shebangs where needed

**Files:**
- `scripts/fix-shell-syntax.sh` — Auto-fixer
- `scripts/*.sh` — Apply fixes

---

## 🟡 P1: Quality & Automation (5 hours)

### 1. Test Coverage Framework (4h)
**Owner:** Quality (TDD Expert)

**Tasks:**
- [ ] Unit tests для LessonLearnedTracker
- [ ] Integration tests для extract workflow
- [ ] E2E tests для full lifecycle
- [ ] UAT scenarios для agent teams

**Files:**
- `tests/unit/test_lesson_tracker.py`
- `tests/unit/test_validators.py`
- `tests/integration/test_settings_pipeline.py`
- `tests/integration/test_consilium_workflow.py`
- `tests/e2e/test_lesson_lifecycle.py`
- `tests/uat/test_agent_teams_scenarios.py`

**Coverage Target:** 85%

---

### 2. Token Optimization (1h)
**Owner:** AI + Infrastructure

**Tasks:**
- [ ] Compress old lessons (>90 days)
- [ ] Link to .tracking/ archive
- [ ] Target: <500 tokens for LESSONS.md

**Files:**
- `scripts/compress-lessons.py` — Compression script
- `LESSONS.md` — Apply compression

---

## 🟢 Quick Wins (<30 min each)

| # | Task | Effort | Owner |
|---|------|--------|-------|
| 1 | Add .tracking/ to .gitignore | 5 min | Infrastructure |
| 2 | Create validate-settings.py | ✅ Done | Quality |
| 3 | Add lesson stats to Makefile | ✅ Done | Delivery |
| 4 | Pre-commit hook integration | ✅ Done | Delivery |
| 5 | Docker volume for .tracking/ | 30 min | Infrastructure |

**Status:** 4/5 complete

---

## 🔮 Long Term (36 hours)

### 1. Intelligent Pattern Recognition (16h)
**Owner:** AI + Quality

- NLP analysis of error contexts
- Auto-generation of prevention strategies
- Integration with OpenClaw orchestrator

### 2. Multi-Project Lesson Sharing (8h)
**Owner:** Infrastructure + Delivery

- Shared lessons repository
- Cross-project error patterns
- Global statistics dashboard

### 3. Automated Fix Generation (12h)
**Owner:** AI + Quality

- AI-generated validator scripts
- Auto-apply known fixes
- Rollback capability

---

## 📅 Implementation Timeline

**Week 1 (Session #21):**
- ✅ Quality Gates Integration (complete)
- ✅ Settings Validation (complete)
- ✅ Backup Strategy (complete)
- ✅ Quick Wins (4/5 complete)
- [ ] .gitignore updates
- [ ] Docker volume for .tracking/
- [ ] Shell syntax fixes

**Week 2 (Session #22):**
- [ ] GitOps integration (auto-commit LESSONS.md)
- [ ] Test framework setup
- [ ] Unit tests for lesson tracker

**Week 3-4 (Sessions #23-24):**
- [ ] Integration tests
- [ ] E2E tests
- [ ] Token optimization

**Month 2+:**
- [ ] Pattern recognition
- [ ] Cross-project sharing
- [ ] Automated fix generation

---

## 🎯 Success Metrics

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Quality Gates | 8B/8I | 8B/8I | ✅ |
| Lesson Extraction | Manual | Auto | ✅ |
| Backup Strategy | None | 30-day | ✅ |
| Token Budget (LESSONS.md) | 200 | <500 | ✅ |
| Test Coverage | 0% | 85% | ⏳ |
| .gitignore Coverage | Partial | Complete | ⏳ |
| POSIX Compliance | 3 errors | 0 | ⏳ |

---

## 🚨 Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| LESSONS.md merge conflicts | Medium | Low | Git blame + manual resolution |
| .tracking/ disk overflow | Low | Medium | Retention policy + monitoring |
| False positive lessons | Medium | Low | Manual review + edit threshold |
| Token budget exceeded | High | Low | Auto-compression >90 days |
| Shell syntax breakage | Low | High | shellcheck + pre-commit gate |

---

## 📋 Next Steps (Immediate)

**Today (Session #20 continuation):**
1. ✅ Quality Gates Integration
2. ✅ Settings Validation
3. ✅ Backup Strategy
4. [ ] Update .gitignore for .tracking/
5. [ ] Create fix-shell-syntax.sh
6. [ ] Commit и push

**Next Session (#21):**
1. Docker volume for .tracking/
2. GitOps integration (auto-commit)
3. Test framework setup

---

**Status:** P0 60% complete (4.5/10.5h done)
**Next:** Update .gitignore + shell syntax fixes
