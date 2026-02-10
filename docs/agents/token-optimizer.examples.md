# 📗 token-optimizer — Usage Examples

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📗 token-optimizer**

---

## Example 1: Quick Token Count

**Scenario:** Check how many tokens your instruction files consume.

```
/cf-optimize --quick
```

**Output:**
```
═══════════════════════════════════════
  TOKEN OPTIMIZATION REPORT
  Date: 2025-02-06 | Mode: Quick
═══════════════════════════════════════

| File | Lines | Tokens |
|------|-------|--------|
| CLAUDE.md | 199 | ~745 |
| SESSION.md | 102 | ~380 |
| session-init.md | 97 | ~362 |
| git-operations.md | 602 | ~2,240 |
| ... | ... | ... |

TOTALS:
  Files: 22 | Lines: 4,978 | Tokens: ~18,500
═══════════════════════════════════════
```

---

## Example 2: Full Audit

**Scenario:** Complete analysis with recommendations.

```
/cf-optimize
```

**Output includes:**
```
LOADING CHAINS:
  P0 (every session):
    CLAUDE.md (745t) → SESSION.md (380t) → session-init.md (362t)
    Total: ~1,487 tokens | Budget: 1,500 | Status: AT BUDGET

  Continuation chain:
    → continuation-workflow.md (752t) → git-operations.md (2,240t)
    Total: ~4,479 tokens | Budget: 3,000 | Status: OVER BUDGET +49%

RECOMMENDATIONS:
  #1 [HIGH] git-operations.md → COMPRESS (save ~1,640 tokens)
  #2 [HIGH] project-initialization-workflow.md → SPLIT (save ~1,550 tokens)
  #3 [MED] session-closure.md → COMPRESS (save ~800 tokens)

  TOTAL ESTIMATED SAVINGS: ~3,990 tokens (22% reduction)
```

---

## Example 3: Single File Audit

**Scenario:** Deep dive into the largest file.

```
/cf-optimize --file instructions/git-operations.md
```

**Output:**
```
FILE: instructions/git-operations.md
  Lines: 602 | Tokens: ~2,240 | Score: 34/100

  Priority: P1 | Budget: 800 tokens | Status: OVER by 180%

  Keyword density: 2.8% (healthy)
  Blank line ratio: 18% (normal)
  Duplicate content: 12% (found in session-closure.md)

  RECOMMENDATIONS:
    1. COMPRESS: Reduce verbose examples (save ~800 tokens)
    2. DEDUPLICATE: Git sync section also in session-closure.md (save ~400 tokens)
    3. SPLIT: Session-end vs session-start operations (cleaner loading)
```

---

## Example 4: Budget Compliance Check

**Scenario:** Pre-commit check if token budgets are met.

```
/cf-optimize --budget
```

**Output:**
```
TOKEN BUDGET COMPLIANCE
═══════════════════════

P0 Files (budget: 400 per file):
  ✅ CLAUDE.md: 745t (hub — exempt from per-file budget)
  ✅ SESSION.md: 380t
  ✅ session-init.md: 362t

P1 Files (budget: 800 per file):
  ❌ git-operations.md: 2,240t (OVER by 1,440)
  ❌ project-initialization-workflow.md: 2,350t (OVER by 1,550)
  ❌ session-closure.md: 1,656t (OVER by 856)
  ✅ constraints/docker.md: 317t
  ✅ constraints/tools.md: 380t

P0 Chain (budget: 1,500):
  ⚠️ 1,487t (99% utilized)

RESULT: 3 files over budget, 1 chain at limit
```

---

## Example 5: Natural Language

**Scenario:** Ask in Russian or English.

```
"Сколько токенов тратят мои инструкции?"
→ Runs: /cf-optimize --quick

"Optimize the instruction files"
→ Runs: /cf-optimize

"Which file uses the most tokens?"
→ Runs: /cf-optimize --top 1
```

---

*← [Back to Agents Index](index.md) | [Usage](token-optimizer.usage.md) | [Troubleshooting](token-optimizer.trouble.md) →*
