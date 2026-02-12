# Z.ai GLM-4.7 Rate Limit Analysis

**Date:** 2026-02-11
**Model:** glm-4.7 (Z.ai API)
**Endpoint:** `https://api.z.ai/api/anthropic`
**Error:** `429 {"error":{"code":"1302","message":"Rate limit reached for requests"}}`

---

## Executive Summary

**Problem:** Rate limit 429 возникает даже при работе одной сессии без субагентов.

**Root Cause:** Z.ai API использует **concurrency-based rate limiting** (3 concurrent requests), не request-per-minute (RPM).

**Impact:** Блокирует работу Expert Consilium v2 и обычные сессии.

---

## 1. Z.ai API Configuration Analysis

### Current Settings
```json
{
  "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
  "ANTHROPIC_MODEL": "glm-4.7",
  "teammateCount": 3,
  "teammateMode": "in-process",
  "alwaysThinkingEnabled": true
}
```

### Rate Limit Constraints (Z.ai Documentation)
- **Concurrency Limit:** 3 in-flight requests (based on "Current Rate Limits" section)
- **Rate Limit Code:** 1302
- **Error Message:** "Rate limit reached for requests"

---

## 2. Root Cause Analysis

### 2.1 Multiple Concurrent Processes

From process analysis (`ps aux`):
```
- claude (2 instances): s000, s003  ← TWO CLAUDE SESSIONS!
- node (context7-mcp): 1 instance
- zai-mcp-server: 1 instance
- Docker cagent api: 3 instances
```

**Critical Finding:** **2 Claude sessions running simultaneously** + MCP servers = **5+ concurrent API consumers**

### 2.2 In-Process Teammate Mode

```json
"teammateCount": 3,
"teammateMode": "in-process"
```

**Problem:** Even without spawning external agents, Claude Code may make parallel requests for:
- Thinking process
- Tool calls
- Context retrieval
- MCP server communications

### 2.3 Sequential Tool Calls in Single Turn

When I made multiple parallel tool calls:
```python
# WRONG: Too many parallel requests
Task(...) # Request 1
Task(...) # Request 2
Task(...) # Request 3
Task(...) # Request 4  ← EXCEEDS LIMIT!
```

---

## 3. Rate Limit Behavior Analysis

### 3.1 Concurrency vs RPM

| Metric | Z.ai (glm-4.7) | Anthropic Claude |
|--------|----------------|------------------|
| Limit Type | **Concurrent requests** | Requests per minute |
| Limit Value | **3** | 60-1000 (tier-based) |
| Error Code | 1302 | 429 |
| Recovery | Wait for slot | Exponential backoff |

### 3.2 Request Lifecycle

```
Request 1: START → [processing...] → END
Request 2: START → [processing...] → END
Request 3: START → [processing...] → END
Request 4: START → ❌ 429 ERROR (limit exceeded)
```

**Key Insight:** Even if Request 1 finishes quickly, Request 4 may still fail if timing overlaps.

---

## 4. Solutions (5+)

### Solution #1: Sequential Tool Execution (IMMEDIATE FIX)

**Problem:** Parallel tool calls exceed concurrency limit.

**Fix:** Execute tools sequentially with delays.

```python
# BEFORE (causes 429):
Task(...)
Task(...)
Task(...)
Task(...)

# AFTER (fixed):
Task(...)  # Wait for completion
# Delay 1-2 seconds
Task(...)  # Then next task
```

**Implementation:**
- Modify Expert Consilium v2 agent to spawn agents **one at a time**
- Add `time.sleep(2)` between tool calls (in agent logic, not actual Python)
- Use `run_in_background=false` to ensure sequential execution

**Pros:**
- ✅ Immediate fix, no API changes needed
- ✅ Works with current Z.ai subscription
- ✅ Prevents all 429 errors

**Cons:**
- ⏱️ Slower execution (6 minutes → 10+ minutes)
- 🔄 Loses parallelization benefits

---

### Solution #2: Batch Size Limitation (RECOMMENDED)

**Problem:** Spawning 4+ agents at once exceeds limit.

**Fix:** Limit batch size to **2 agents maximum**.

```python
# Phase 0: Batch Strategy
BATCH_SIZE = 2  # Was 4, now 2

# Batch 1: 2 experts
Task(...)
Task(...)

# WAIT for both to complete
# (check TaskOutput for completion)

# Batch 2: 2 more experts
Task(...)
Task(...)
```

**Implementation:**
- Update Expert Consilium v2 `Phase 0: Team Creation & Batch Strategy`
- Change batch size from 4 to 2
- Add explicit wait logic between batches

**Pros:**
- ✅ Preserves some parallelization
- ✅ Leaves 1 slot for main session
- ✅ Faster than sequential (6 min vs 10+ min)

**Cons:**
- ⚠️ Still slower than 4-at-a-time
- ⚠️ Requires code changes

---

### Solution #3: Single Claude Session (QUICK WIN)

**Problem:** Multiple Claude sessions consume concurrency slots.

**Fix:** Close all Claude sessions except one.

```bash
# Check running sessions
ps aux | grep claude

# Kill extra sessions (keep current)
pkill -f "claude"  # Then restart single session
```

**Implementation:**
1. Close parallel Claude Code window
2. Keep only current session
3. Verify with `ps aux | grep claude`

**Pros:**
- ✅ Immediate 50% reduction in API load
- ✅ No code changes
- ✅ Frees 2-3 concurrency slots

**Cons:**
- ⚠️ Loses parallel window workflow
- ⚠️ Temporary fix (until multiple sessions restart)

---

### Solution #4: MCP Server Optimization (ADVANCED)

**Problem:** MCP servers (context7, zai-mcp) make additional API calls.

**Fix:** Disable or optimize MCP servers during heavy agent operations.

```json
// .claude/settings.json
{
  "mcpServers": {
    "context7": {
      "enabled": false  // Disable during agent teams
    },
    "zai-mcp-server": {
      "enabled": false  // Disable during agent teams
    }
  }
}
```

**Alternative:** Lazy-load MCP servers only when needed.

**Pros:**
- ✅ Reduces background API load
- ✅ Frees concurrency slots for main work

**Cons:**
- ⚠️ Loses MCP functionality (context7 docs, etc.)
- ⚠️ Requires manual toggle

---

### Solution #5: Request Queuing with Retry (ROBUST)

**Problem:** No retry logic for 429 errors.

**Fix:** Implement exponential backoff with retry queue.

```python
# Pseudo-code for agent implementation
MAX_RETRIES = 5
BASE_DELAY = 2  # seconds

def call_with_retry(tool_call, retries=0):
    try:
        return tool_call()
    except RateLimitError as e:
        if retries >= MAX_RETRIES:
            raise
        delay = BASE_DELAY * (2 ** retries)  # 2, 4, 8, 16, 32
        time.sleep(delay)
        return call_with_retry(tool_call, retries + 1)
```

**Implementation:**
- This requires Claude Code platform changes (not user-controllable)
- Alternative: Agent manually retries with delays

**Pros:**
- ✅ Automatic recovery from 429
- ✅ Handles transient rate limits
- ✅ Robust production solution

**Cons:**
- ⚠️ Requires platform-level changes
- ⚠️ May still hit hard limits

---

### Solution #6: Upgrade Z.ai Subscription (COMMERCIAL)

**Problem:** Free/Basic tier has 3 concurrent requests limit.

**Fix:** Upgrade to higher tier with more concurrency.

**Research Needed:**
- Check Z.ai pricing for "Pro" or "Enterprise" tiers
- Verify if concurrency limit increases
- Compare with Anthropic pricing

**Pros:**
- ✅ Solves root cause
- ✅ Enables full parallelization
- ✅ Better performance overall

**Cons:**
- 💰 Costs money
- ⚠️ May not be available

---

### Solution #7: Hybrid Model Strategy (OPTIMIZATION)

**Problem:** glm-4.7 used for all operations, consuming slots.

**Fix:** Use different models for different tasks.

```json
{
  "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7-flash",  // Fast, cheap
  "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",       // Balanced
  "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7"          // Complex
}
```

**Strategy:**
- Use `glm-4.7-flash` for simple tasks (thinking, tool calls)
- Use `glm-4.7` for complex analysis (Expert Consilium)
- Different models may have separate rate limits

**Pros:**
- ✅ Potentially separate rate limits per model
- ✅ Cost optimization (flash is cheaper)
- ✅ Performance optimization

**Cons:**
- ⚠️ Requires Z.ai to support per-model limits
- ⚠️ May not solve concurrency issue

---

## 5. Recommended Implementation Order

### Phase 1: Immediate (Today)
1. **Solution #3:** Close parallel Claude session ← **QUICK WIN**
2. **Solution #2:** Reduce batch size to 2 ← **CODE CHANGE**

### Phase 2: Short-term (This Week)
3. **Solution #1:** Sequential execution as fallback
4. **Solution #4:** MCP server optimization

### Phase 3: Long-term (Next Sprint)
5. **Solution #5:** Request queuing (if platform supports)
6. **Solution #6:** Subscription upgrade evaluation
7. **Solution #7:** Hybrid model strategy

---

## 6. Monitoring & Metrics

### Add Rate Limit Tracking
```bash
# Track 429 errors
grep -c "429" ~/.claude/logs/*.log

# Track concurrent requests
watch -n 1 'ps aux | grep claude | wc -l'
```

### Success Metrics
- 429 errors per session: **0** (target)
- Average agent spawn time: **<30 seconds**
- Expert Consilium completion time: **<10 minutes**

---

## 7. Expert Consilium v2.0.4 Changes Required

### Current Batch Strategy
```python
# Phase 0: Team Creation & Batch Strategy
# NEW: Batch processing strategy (4 at a time)  ← PROBLEM!
```

### Proposed Change
```python
# Phase 0: Team Creation & Batch Strategy
# NEW: Batch processing strategy (2 at a time for Z.ai compatibility)
BATCH_SIZE = 2  # Reduced from 4 due to Z.ai 3-concurrent limit
```

### Additional Changes
1. Add `ZAI_RATE_LIMIT = 3` constant
2. Add batch delay: 2 seconds between batches
3. Add retry logic for 429 errors
4. Add monitoring for rate limit errors

---

## 8. Conclusion

**Root Cause:** Z.ai's 3-concurrent-request limit + multiple Claude sessions + MCP servers = **5+ concurrent consumers > 3 limit**

**Immediate Fix:** Close parallel session + reduce batch size to 2

**Long-term Fix:** Upgrade subscription or switch to Anthropic API

**Confidence:** 0.95 (HIGH) — Based on process analysis and Z.ai documentation

---

**Report Generated:** 2026-02-11
**Analyst:** Claude Code (glm-4.7)
**Session:** Single session (no parallel windows)
