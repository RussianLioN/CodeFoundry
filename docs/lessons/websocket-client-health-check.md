# WebSocket Client Health Check — Lesson Learned

> **🚨 INCIDENT ANALYSIS** — Telegram Bot Health Check Failure
>
> **Date:** 2025-02-05
> **Session:** #13 (ORCH-011)
> **Status:** RESOLVED
> **Severity:** Low (functional but reporting unhealthy)

---

## 🔴 Incident Summary

**Symptom:** Telegram Bot container marked as `unhealthy` despite working correctly.

**Impact:**
- Container was functional (connected to Gateway, processing messages)
- Health check reported `unhealthy` for 72+ consecutive checks
- No actual service degradation

**Duration:** ~36 minutes (from deployment to fix)

---

## 🔍 Root Cause Analysis

### The Problem

```yaml
# ❌ WRONG (original health check)
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000/health', ...)"]
```

**Why it failed:**
- Health check tried to connect to `http://localhost:3000/health`
- Telegram Bot is a **WebSocket CLIENT** (not an HTTP server)
- Bot connects to Gateway at `ws://gateway:18789` (doesn't listen on port 3000)
- Result: `ECONNREFUSED` on every health check

### Error Logs

```
AggregateError [ECONNREFUSED]:
  Error: connect ECONNREFUSED 127.0.0.1:3000
  Error: connect ECONNREFUSED ::1:3000
```

---

## ✅ The Fix

```yaml
# ✅ CORRECT (fixed health check)
healthcheck:
  # Telegram Bot is a WebSocket CLIENT (not HTTP server)
  # Health check verifies: 1) Process running 2) Connected to Gateway
  test: ["CMD", "sh", "-c", "pgrep -f 'node.*bot.js' > /dev/null && netstat -tn | grep -q ':18789.*ESTABLISHED' || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

**What it checks:**
1. **Process running:** `pgrep -f 'node.*bot.js'` — verifies bot process exists
2. **Connection active:** `netstat -tn | grep -q ':18789.*ESTABLISHED'` — verifies WebSocket connection to Gateway

**Result:** `HEALTHY` (confirmed working)

---

## 📚 Lessons Learned

### Lesson 1: Client vs Server Health Checks

| Service Type | Health Check Strategy |
|--------------|---------------------|
| **HTTP Server** | Check HTTP endpoint (`curl http://localhost:3000/health`) |
| **WebSocket Server** | Check WebSocket port listening (`netstat -l | grep :3000`) |
| **WebSocket Client** | Check process + peer connection (`pgrep` + `netstat` ESTABLISHED) |
| **Worker/Cron** | Check recent execution/success (`pgrep` + log check) |

### Lesson 2: Service Architecture Awareness

**Before writing health check, ask:**
1. What type of service is this? (Server/Client/Worker)
2. What does it connect to? (Peers, databases, APIs)
3. How do I know it's working? (Process, connections, logs)

### Lesson 3: Health Check Validation

**Mandatory testing steps:**
```bash
# 1. Test health check command manually
docker exec <container> <health-check-command>

# 2. Verify expected output
docker exec <container> sh -c '<command> && echo "HEALTHY" || echo "UNHEALTHY"'

# 3. Monitor first health check cycle
docker inspect <container> --format='{{json .State.Health}}' | jq
```

---

## 🛠️ Prevention Checklist

### Before Deploying Any Service:

- [ ] **Identify service type** (HTTP server, WebSocket client, worker, etc.)
- [ ] **Check existing health check pattern** for similar services
- [ ] **Write appropriate health check** for service type
- [ ] **Test health check manually** in running container
- [ ] **Verify health check passes** after deployment
- [ ] **Document health check logic** in code comments

### Health Check Templates

#### HTTP Server
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

#### WebSocket Client
```yaml
healthcheck:
  test: ["CMD", "sh", "-c", "pgrep -f 'node.*service.js' && netstat -tn | grep -q ':PORT.*ESTABLISHED'"]
  interval: 30s
  timeout: 10s
  retries: 3
```

#### Worker Process
```yaml
healthcheck:
  test: ["CMD", "sh", "-c", "pgrep -f 'node.*worker.js' && test -f /tmp/worker-last-success"]
  interval: 60s
  timeout: 10s
  retries: 3
```

---

## 📊 Related Incidents

| Date | Incident | Root Cause | Fix |
|------|----------|------------|-----|
| 2025-02-05 | Telegram Bot unhealthy | Wrong health check type | Changed to client-specific check |
| 2025-02-05 | claude-code-runner unhealthy | Wrong file check (package.json) | Changed to PROJECT.md check |

**Pattern:** Mismatched health check strategy for service type

---

## 🔗 Related Documents

- [@ref: docs/TESTING.md](../TESTING.md) — Mandatory testing workflow
- [@ref: docs/REMOTE-PATHS.md](../REMOTE-PATHS.md) — Single Source of Truth for paths
- [@ref: server/docker-compose.orchestrator.yml](../../server/docker-compose.orchestrator.yml) — Fixed configuration

---

## 📝 Implementation Notes

### Commands Used in Fix

```bash
# Test health check manually
docker exec openclaw-orchestrator-telegram-bot sh -c 'pgrep -f "node.*bot.js" > /dev/null && netstat -tn | grep -q ":18789.*ESTABLISHED" && echo "HEALTHY" || echo "UNHEALTHY"'

# Check available commands
docker exec <container> which pgrep
docker exec <container> which netstat

# Verify health status
docker inspect <container> --format='{{json .State.Health}}' | jq
```

### Git History

```bash
9ab0d03 fix(telegram-bot): Fix health check for WebSocket client (not HTTP server)
```

---

## ✅ Resolution Verification

**After fix deployment:**
```bash
$ docker ps --filter name=openclaw-orchestrator --format 'table {{.Names}}\t{{.Status}}'

NAMES                                 STATUS
openclaw-orchestrator-telegram-bot    Up 53 seconds (healthy)     ✅
openclaw-orchestrator-claude-runner   Up 4 minutes (healthy)       ✅
openclaw-orchestrator-gateway         Up 38 minutes (healthy)      ✅
```

**All containers healthy.** ✅

---

**Author:** Claude Code (Session #13)
**Last Updated:** 2025-02-05
**Status:** LESSON DOCUMENTED — PREVENTION MEASURES IN PLACE
