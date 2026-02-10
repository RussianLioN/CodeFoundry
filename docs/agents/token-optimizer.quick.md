# 📙 token-optimizer — Quick Start

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📙 token-optimizer**

> Get started in 5 minutes

---

## Prerequisites

```bash
# Standard Unix tools (already available on macOS/Linux)
wc --version   # word count
# No additional installation needed
```

---

## 3 Steps to Start

### Step 1: Run quick token count

```
/cf-optimize --quick
```

**Expected output:**
```
Files: 22 | Total lines: 4,978 | Total tokens: ~18,500
```

### Step 2: Run full audit

```
/cf-optimize
```

Reviews all instruction files for duplication, broken links, keyword density, and loading chain budgets.

### Step 3: Review recommendations

The report shows top offenders and specific recommendations with estimated token savings.

---

## Verify

After optimization, run again to confirm improvements:
```
/cf-optimize --quick
```

---

## Next Steps

- [Full Usage Guide](token-optimizer.usage.md) — All options and modes
- [Examples](token-optimizer.examples.md) — Real-world usage scenarios
- [Troubleshooting](token-optimizer.trouble.md) — Common issues

---

*← [Back to Agents Index](index.md) | [Full Usage](token-optimizer.usage.md) →*
