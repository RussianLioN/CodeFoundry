# 📕 token-optimizer — Troubleshooting

> 🏠 [Главная](../../README.md) → [🤖 Агенты](index.md) → **📕 token-optimizer**

---

## Quick Diagnostics

```
# Check if instruction files exist
ls CLAUDE.md instructions/

# Check file count
ls instructions/*.md | wc -l

# Quick token estimate for one file
wc -m CLAUDE.md | awk '{print int($1/4), "tokens"}'
```

---

## Common Issues

### Issue: "No files found"

**Symptoms:** Agent reports 0 files discovered
**Cause:** Working directory is not project root
**Solution:** Ensure you are in the CodeFoundry project root (where CLAUDE.md exists)

---

### Issue: Token count seems wrong

**Symptoms:** Token estimate doesn't match expected
**Cause:** Token estimation uses chars/4 (approximation)
**Solution:** This is expected. Actual tokenization varies by model. The estimate is accurate for relative comparisons between files.

**Note:** For Cyrillic text, `wc -m` (multi-byte) is used instead of `wc -c` (bytes) for accurate character counting.

---

### Issue: Broken @ref links reported

**Symptoms:** Report shows broken @ref links that exist
**Cause:** @ref path may include section anchors (`#section-name`) which are not file paths
**Solution:** Section anchors are not validated (by design). Only file-level links are checked.

---

### Issue: Fix mode didn't apply changes

**Symptoms:** Ran `--fix` but files unchanged
**Cause:** User declined confirmation prompt
**Solution:** Confirm changes when prompted. Review the diff preview first.

---

### Issue: Circular reference detected

**Symptoms:** Report flags circular @ref chain
**Cause:** File A references File B which references File A
**Solution:** Review the chain, break the cycle by choosing one canonical direction.

---

### Issue: Score seems unfair

**Symptoms:** File has low score but seems well-optimized
**Cause:** Scoring weights P0 files 3x more heavily
**Solution:** P0 files need to be extra compact. Consider if file should be P1 instead.

---

## Error Codes

| Code | Meaning | Recovery |
|------|---------|----------|
| `NO_FILES` | No instruction files found | Check working directory |
| `BACKUP_FAIL` | Cannot create .bak backup | Check disk space |
| `CIRCULAR_REF` | Circular @ref chain | Break the cycle |
| `EMPTY_FILE` | File exists but is empty | Delete or populate |

---

## Getting Help

- [Full Usage Guide](token-optimizer.usage.md)
- [Examples](token-optimizer.examples.md)
- [Agent Creation Guide](AGENT-CREATION-GUIDE.md)

---

*← [Back to Agents Index](index.md) | [Usage](token-optimizer.usage.md) →*
