# cf-optimize — Audit and Optimize Token Usage

> **Slash command:** `/cf-optimize` or `/optimize`
> **Aliases:** `optimize tokens`, `token audit`, `оптимизируй токены`, `аудит токенов`
> **Category:** Optimization

## Description

Audits all instruction files for token efficiency. Measures consumption, detects duplication, validates @ref links, analyzes loading chains, and recommends optimizations.

## Usage

```
/cf-optimize [mode] [options]
```

### Examples

```
# Full audit (default)
/cf-optimize

# Quick token count only
/cf-optimize --quick

# Fix mode — apply optimizations
/cf-optimize --fix

# Audit single file
/cf-optimize --file instructions/git-operations.md

# Check token guideline compliance
/cf-optimize --budget

# Natural language
"How many tokens do my instruction files use?"
"Сколько токенов тратят инструкции?"
"Оптимизируй инструкции"
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mode` | string | No | audit (default), quick, fix |
| `--file` / `-f` | string | No | Single file to audit |
| `--budget` / `-b` | flag | No | Check against token guideline |
| `--top` / `-t` | number | No | Show top N offenders (default: 5) |
| `--threshold` | number | No | Flag files exceeding N tokens (default: 500) |

## Workflow

### 1. Discovery
```
Scanning instruction files...
  Found: 22 files in CLAUDE.md + instructions/
```

### 2. Measurement
```
Measuring tokens...
  CLAUDE.md              199 lines  ~745 tokens
  SESSION.md             102 lines  ~380 tokens
  session-init.md         97 lines  ~362 tokens
  git-operations.md      602 lines  ~2,240 tokens  ⚠️
  ...
```

### 3. Analysis (audit mode only)
```
Analyzing...
  ✅ @ref links: 265 valid, 0 broken
  ⚠️ Duplicates: 3 blocks found
  ⚠️ Loading chain P0: 4,479 tokens (guideline: 1,500)
  ✅ Keyword density: healthy
```

### 4. Report
```
Recommendations:
  #1 [HIGH] git-operations.md → COMPRESS (save ~1,640 tokens)
  #2 [HIGH] project-initialization-workflow.md → SPLIT (save ~1,550 tokens)
  ...
  TOTAL ESTIMATED SAVINGS: ~6,000 tokens
```

## Token Guideline Reference

| Priority | Per-File | Per-Chain |
|----------|----------|-----------|
| P0 | 400-600 tokens | 1,500 tokens |
| P1 | 800-1200 tokens | 3,000 tokens |
| P2 | 1,500-2000 tokens | 5,000 tokens |

## Error Handling

| Error | Solution |
|-------|----------|
| `NO_FILES_FOUND` | Check working directory is project root |
| `BACKUP_FAILED` | Check disk space |
| `BROKEN_LINKS` | Run `/cf-optimize --fix` to resolve |

## Related Commands

- `/cf-new` — Create new project
- `/cf-agents` — Generate AI agents
- `/cf-deploy` — Deploy project

## Implementation

This command uses agent: `.claude/agents/token-optimizer.md`

**Agent Tools:** Read, Bash, Grep, Glob, Write
**Measurement:** `wc -l`, `wc -m`, `wc -w` (UTF-8 aware)

---

**Version:** 1.0.0
**Last updated:** 2025-02-06
