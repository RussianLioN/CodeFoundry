# 📞 On-Call Procedures

> **Процедуры реагирования на инциденты для ainetic.tech**

**Version:** 1.0.0
**Last Updated:** 2025-02-03
**On-Call: DevOps engineer + optional Security expert

---

## 📋 Содержание

- [Тriage procedure](#triage-процедура)
- [Инциденты и эскалация](#инциденты-и-эскалация)
- [Runbooks по типам инцидентов](#runbooks-по-типам-инцидентов)
- [Communication protocol](#communication-protocol)

---

## 🚨 Triage Procedure

### Step 1: Initial Assessment (5 min)

```bash
# 1. Определить уровень серьёзности
ping -c 3 ainetic.tech
ssh root@ainetic.tech "uptime"

# 2. Собрать диагностическую информацию
cd ~/projects/system-prompts/server
make status
make health
make logs-short

# 3. Оценить scope
echo "=== Incident Summary ==="
echo "Severity: (P0/P1/P2/P3)"
echo "Affected: (gateway/bot/all/none)"
echo "Users impacted: (yes/no)"
echo "Business impact: (critical/high/low/none)"
```

### Step 2: Determine Severity Level

| Severity | Response Time | Examples |
|----------|----------------|----------|
| **P0** | < 15 минут | Complete outage, data loss |
| **P1** | < 1 час | Service down, users affected |
| **P2** | < 4 часа | Degraded performance |
| **P3** | < 1 day | Minor issue |

---

## 🚨 Инциденты и Эскалация

### Category 1: Container Issues

#### P1: Container Crash Loop

**Detection:**
```bash
watch -n 2 'docker ps | grep RESTART'
```

**Quick Fix:**
```bash
make restart-test
```

**Escalation:**
```bash
# Check resource usage
docker stats --no-stream

# Check logs for errors
make logs
```

---

#### P2: Memory Exhaustion

**Detection:**
```bash
docker stats --no-stream | grep -E "MEM|MEMUSAGE"
# Shows >90% memory usage
```

**Quick Fix:**
```bash
make clean
make start-test
```

**Prevention:**
```yaml
# In docker-compose.test.yml add:
deploy:
  resources:
    limits:
      memory: 1G
```

---

### Category 2: Application Issues

#### P2: Gateway Not Responding

**Detection:**
```bash
curl -f http://localhost:18790/health
# Timeout or connection refused
```

**Quick Fix:**
```bash
# Check gateway logs
make logs-gateway

# Restart
docker restart codefoundry-test-gateway-1

# If restart fails:
make stop-test
make start-test
```

---

#### P2: Telegram Bot Not Responding

**Detection:**
```bash
# User reports: "Bot doesn't respond"
# Test via Telegram:
/start
# No response within 30 seconds
```

**Quick Fix:**
```bash
# Check bot logs
make logs-bot

# Test API directly
curl -X POST "https://api.telegram.org/bot$TOKEN/getMe"
```

---

### Category 3: Infrastructure Issues

#### P3: Disk Space Full

**Detection:**
```bash
df -h
# Use >90% on any filesystem
```

**Resolution:**
```bash
# Clean old logs
make prune
docker system prune -a

# Clean backups
make backup-prune
```

---

## 📋 Runbooks по типам инцидентов

### Runbook 1: Complete Outage Recovery

**Scenario:** All services down, server unreachable

**Procedure:**

1. **Assess (5 min)**
   ```bash
   # Check VPS console
   # Check DNS records
   # Check network status
   ```

2. **Diagnose (10 min)**
   ```bash
   # If SSH available:
   ssh root@ainetic.tech "docker ps -a"

   # Check monitoring
   # Check VPS provider status
   ```

3. **Recover (30-60 min)**
   ```bash
   # Option A: Restart services
   ssh ainetic.tech "cd ~/projects/CodeFoundry/server && make restart-test"

   # Option B: Restore from backup
   ssh ainetic.tech "cd ~/projects/CodeFoundry/server && make backup-restore LATEST"
   ```

4. **Validate (5 min)**
   ```bash
   ssh ainetic.tech "cd ~/projects/system-prompts/server && ./test-telegram.sh"
   ```

---

### Runbook 2: Data Loss Recovery

**Scenario:** Accidental data deletion

**Procedure:**

1. **Immediate (5 min)**
   ```bash
   # STOP ALL CONTAINERS
   ssh ainetic.tech "cd ~/projects/CodeFoundry/server && make stop-test"
   ```

2. **Assess Damage (5 min)**
   ```bash
   # Check what was deleted
   ssh ainetic.tech "ls -la ~/projects/system-prompts/"

   # Check Docker volumes
   ssh ainetic.tech "docker volume ls | grep codefoundry"
   ```

3. **Restore (30 min)**
   ```bash
   ssh ainetic.tech "cd ~/projects/CodeFoundry/server && make backup-restore LATEST"
   ```

4. **Validate (10 min)**
   ```bash
   ssh ainetic.tech "cd ~/projects/system-prompts/server && ./test-telegram.sh"
   ```

---

### Runbook 3: Security Incident

**Scenario:** Suspicious activity detected

**Procedure:**

1. **Immediate Isolation (2 min)**
   ```bash
   # Isolate affected systems
   ssh ainetic.tech "docker-compose -f server/docker-compose.test.yml stop"

   # Preserve evidence
   ssh ainetic.tech "docker logs > ~/security-incident-$(date +%s).log"
   ```

2. **Assessment (10 min)**
   ```bash
   # Review logs for anomalies
   ssh ainetic.tech "grep -i 'hack\|inject\|breach' ~/security-incident*.log"

   # Check for unauthorized SSH access
   ssh ainetic.tech "grep 'Accepted' /var/log/auth.log | tail -100"
   ```

3. **Remediation (30 min)**
   ```bash
   # Rotate all secrets
   ssh ainetic.tech "cd ~/projects/system-prompts/server && nano .env.test"
   # Change: TELEGRAM_BOT_TOKEN, AUTHORIZED_USER_IDS

   # Restart services
   ssh ainetic.tech "cd ~/projects/system-prompts/server && make restart-test"
   ```

---

## 🔄 Communication Protocol

### Severity Matrix

| Severity | Notify | Response Time | Escalation |
|----------|--------|----------------|------------|
| P0 | Slack + Phone | Immediate | CTO + DevOps |
| P1 | Slack | 1 hour | DevOps lead |
| P2 | Slack | 4 hours | DevOps lead |
| P3 | Slack | 1 day | DevOps lead |

### Incident Report Template

```markdown
## Incident Report

**Timestamp:** YYYY-MM-DD HH:MM UTC

**Reporter:** Name, role

**Severity:** P0/P1/P2/P3

**Summary:** Brief description

**Impact:**
- Users affected: yes/no
- Services affected: gateway, bot, all
- Business impact: critical/high/low/none

**Timeline:**
- HH:MM - Issue detected
- HH:MM - Triage started
- HH:MM - Mitigation applied
- HH:MM - Service restored

**Root Cause: (determine post-mortem)

**Resolution:** (describe fix)

**Prevention:** (how to prevent recurrence)
```

---

## 📞 On-Call Rotation

| Week | Primary | Secondary |
|------|---------|-----------|
| Week 1 | DevOps Lead | Senior DevOps |
| Week 2 | Senior DevOps | DevOps Lead |
| Week 3 | DevOps Lead | CTO |
| Week 4 | Senior DevOps | DevOps Lead |

---

## 🧪 Testing Recovery Procedures

### Monthly: Test Restore Procedure

```bash
# Test backup integrity
ssh ainetic.tech "cd ~/projects/system-prompts/server && make backup-test"

# Test actual restore (dry-run)
ssh ainetic.tech "cd ~/projects/system-prompts/server && make backup-restore $(ls -t /backups/codefoundry/ | tail -1 | awk '{print $NF}')"

# Verify:
# - Backup integrity (checksum)
# - Volume restore capability
# - Configuration completeness
```

---

## 📊 Success Metrics

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **RTO** | <4 hours | Time from detection to service restored |
| **RPO** | <24 hours | Maximum acceptable data loss |
| **MTTR** | <15 minutes | Mean time to triage |
| **MTBF** | 30 days | Mean time between failures |
| **Pass Rate** | >95% | Percentage of successful recoveries |

---

## 🔗 Related Documents

- [QUICKSTART.md](QUICKSTART.md) — Быстрый старт
- [ARCHITECTURE.md](ARCHITECTURE.md) — Архитектура
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Решение проблем
- [backup.sh](../server/backup.sh) — Backup скрипт

---

**Version:** 1.0.0
**Last Updated:** 2025-02-03
**Next Review:** After first real incident
