# Agent Token Limits — Expert Consilium v2 Analysis

**Date:** 2026-02-11
**Team:** agent-token-limits-consilium
**Approach:** Expert Consilium v2.0.2 with 5 parallel experts
**Duration:** ~6 minutes
**Total Tokens:** 142.9k

---

## Executive Summary

**Question:** Требуются ли ограничения в токенах агентов? Какая практика в сообществе и рекомендации от Anthropic?

**Answer:** **Guided Modularity** — использовать soft guidelines, не hard limits.

**Consensus:** MODERATE (64.5% confidence)
**Weighted Vote:** 3.55 / 5.5 experts

---

## Domain Positions (5 Experts)

| Expert | Position | Confidence | Key Arguments |
|---------|-----------|-------------|----------------|
| **Community Practices** | CAUTIOUS | 0.75 | P0/P1/P2 "произвольны", не основаны на рекомендациях |
| **Claude Code Expert** | AGREE | 0.85 | РЕАЛЬНЫе лимиты: Simple<1K, Medium<3K, Complex<8K |
| **Prompt Engineering** | CAUTIOUS | 0.82 | Soft limits > Hard limits, дифференциация по типам агентов |
| **Anthropic Researcher** | CAUTIOUSLY DISAGREE | 0.85 | Anthropic НЕ рекомендует fixed limits, продвигают adaptive |
| **Agent Architect** | CAUTIOUS | 0.78 | Nuanced approach, scale with complexity |

---

## Key Findings

### 1. Anthropic's Position

**Anthropic НЕ рекомендует фиксированные token limits для агентов.**

Вместо этого продвигают:
- **Adaptive approach** — limits scale with agent complexity
- **Compaction** — structured note-taking to reduce redundancy
- **Behavioral validation** — working agent > short broken one

**Quote:** "Token budgets" → "Token guidelines" (advisory, не blocking)

### 2. Claude Code Reality

**Claude Code использует РЕАЛЬНЫЕ лимиты:**
- Tool responses: **25K tokens** (API constraint)
- Agent context: **200K tokens** (model window)
- Rate limits: **Per-agent**, NOT token-based

Это не prompt guidelines — это технические constraints API.

### 3. Community Practice

**CodeFoundry's P0/P1/P2 система (400/800/1500 tokens):**
- Рабочая в продакшене
- Соответствует реальному использованию
- Но "произвольна" — не основана на официальных рекомендациях

### 4. Prompt Engineering Best Practices

**Soft limits > Hard limits:**
- П0: 400-600 tokens → "keep minimal"
- П1: 800-1200 tokens → "modular preferred"
- П2: 1500-2000 tokens → "split if >2× guideline"

**Primary metric:** Behavioral validation, не token counting.

### 5. Architecture Wins

**Modular (@ref) approach экономит ~8.5K tokens:**
- Без @ref: ~10K tokens per agent
- С @ref: ~1.5K tokens per agent
- **Экономия: 85%**

---

## Final Recommendation: "Guided Modularity"

Трёхслойная архитектура:

### Layer 1: HARD LIMITS (Technical Constraints)
```
• Tool responses: 25K tokens (API constraint)
• Agent context: 200K tokens (model window)
• Rate limits: Per-agent, NOT token-based
```

### Layer 2: SOFT GUIDELINES (Advisory Targets)
```
• P0 (Critical):    400-600 tokens  → "keep minimal"
• P1 (Important):   800-1200 tokens → "modular pref"
• P2 (Reference):   1500-2000 tokens → "split if >2×"
• Complex agents:   <8000 tokens   → "sub-agents?"
```

### Layer 3: QUALITY GATES (Validation Strategy)
```
BLOCKING: JSON syntax, @ref integrity, Python/Shell
INFO:     Token guideline exceeded (advisory)
BEHAVIOR: Functional validation > token counting
```

---

## Implementation Plan

### 🔴 P0 — Today
1. ~~"Token budget" → "Token guideline"~~ ✅ Done in MEMORY.md
2. Quality gate: BLOCKING → INFO
3. Update documentation

### 🟡 P1 — This Week
4. Adaptive warning при >2× guideline
5. Modular-first validation (@ref priority)

### 🟢 P2 — Next Sprint
6. Auto-compaction suggestions
7. Quarterly review cycle

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|-------|-----------|-------------|
| Игнорирование guidelines | Medium | Behavioral validation |
| Over-fragmentation | Low | Min 100 lines threshold |
| Token creep | Medium | Auto-warn at 2× |

---

## Key Insights

1. **Modular Wins:** @ref экономит 8.5K tokens (10K → 1.5K)
2. **Behavior > Metrics:** 500-token working agent > 2000-token broken
3. **Production Reality:** Expert Consilium v2 bug = реальный rate limit 429
4. **Terminology shift:** "Token budget" → "Token guideline" (advisory, not blocking)

---

**Confidence:** 0.80
**Solution Architect Weight:** 1.5×

## Next Steps

1. Implement P0 changes today
2. Test batch processing in production
3. Monitor quality gates effectiveness
4. Quarterly review of guideline numbers
