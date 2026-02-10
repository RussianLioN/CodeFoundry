> [🏠 Главная](../README.md) → **🔌 Remote Paths**

---
# 🔗 Remote Paths - Single Source of Truth

> **🚨 MANDATORY DOCUMENT — READ BEFORE ANY SSH OPERATION**
>
> **Версия:** 1.1.0
> **Дата:** 2025-02-05
> **Статус:** ACTIVE — SINGLE SOURCE OF TRUTH
>
> **🆕 v1.1.0 (Session #13):** Добавлена секция "API Keys & Secrets Location" после инцидента с потерей TELEGRAM_BOT_TOKEN

---

## 🚨 КРИТИЧЕСКОЕ ПРАВИЛО

```
┌─────────────────────────────────────────────────────────────┐
│  🚨 ПЕРЕД ЛЮБОЙ SSH КОМАНДОЙ — ЧИТАЙ ЭТОТ ФАЙЛ!           │
│                                                              │
│  DON'T:                                                      │
│  ❌ Использовать hardcoded paths                            │
│  ❌ Делать find/ls каждый раз                                │
│  ❌ Угадывать где что лежит                                 │
│                                                              │
│  DO:                                                         │
│  ✅ Load @ref: docs/REMOTE-PATHS.md                          │
│  ✅ Use variables from this file                            │
│  ✅ Update when paths change                                │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 ainetic.tech — Remote Infrastructure

### Git Repository

```bash
REMOTE_GIT_REPO=/root/projects/CodeFoundry
```

**Description:** Основной git репозиторий проекта
**Usage:** `ssh ainetic.tech "cd ${REMOTE_GIT_REPO} && git pull"`
**Last verified:** 2025-02-05

---

### 🚨 API Keys & Secrets Location (CRITICAL)

> **🚨 LESSON LEARNED (Session #13):**
> API keys were previously shared but NOT documented in Single Source of Truth.
> This caused repeated requests for the same credentials. NEVER AGAIN.

```bash
# Telegram Bot Configuration (PRIMARY SOURCE)
REMOTE_TELEGRAM_ENV=${REMOTE_GIT_REPO}/server/.env.test

# Contains:
#   - TELEGRAM_BOT_TOKEN (from @BotFather)
#   - AUTHORIZED_USER_IDS (comma-separated Telegram user IDs)
#   - Other Telegram bot settings

# Orchestrator Stack Configuration (ORCH-008+)
REMOTE_ORCHESTRATOR_ENV=${REMOTE_GIT_REPO}/server/.env

# Contains:
#   - OLLAMA_API_KEY (from https://ollama.com/settings/keys)
#   - TELEGRAM_BOT_TOKEN (synced from .env.test)
#   - AUTHORIZED_USER_IDS (synced from .env.test)
#   - Other orchestrator settings
```

**🚨 CRITICAL RULES:**
1. ✅ **NEVER** commit actual API keys to Git repository
2. ✅ **NEVER** print API keys in LLM conversation logs
3. ✅ **ALWAYS** reference `${REMOTE_TELEGRAM_ENV}` for keys
4. ✅ **WHEN** new keys are obtained → **IMMEDIATELY** update this file
5. ✅ **IF** keys are lost → check `${REMOTE_TELEGRAM_ENV}` on server first

**Usage Pattern:**
```bash
# WRONG ❌ - Asking user for keys every time
"Please provide TELEGRAM_BOT_TOKEN"

# RIGHT ✅ - Using documented source
ssh ainetic.tech "cat ${REMOTE_TELEGRAM_ENV} | grep TELEGRAM_BOT_TOKEN"

# RIGHT ✅ - Syncing keys between environments
ssh ainetic.tech "grep -E '(TELEGRAM_BOT_TOKEN|AUTHORIZED_USER_IDS)' ${REMOTE_TELEGRAM_ENV} >> ${REMOTE_ORCHESTRATOR_ENV}"
```

**Current Keys Status (2025-02-05):**
- ✅ TELEGRAM_BOT_TOKEN: Stored in `${REMOTE_TELEGRAM_ENV}`
- ✅ AUTHORIZED_USER_IDS: Stored in `${REMOTE_TELEGRAM_ENV}`
- ✅ OLLAMA_API_KEY: Stored in `${REMOTE_ORCHESTRATOR_ENV}`

**Retrieving Keys (Never Ask User):**
```bash
# Telegram keys
ssh ainetic.tech "cat ${REMOTE_TELEGRAM_ENV} | grep -E '(TELEGRAM_BOT_TOKEN|AUTHORIZED_USER_IDS)'"

# Ollama key
ssh ainetic.tech "cat ${REMOTE_ORCHESTRATOR_ENV} | grep OLLAMA_API_KEY"
```

---

### Workspace (Containers)

```bash
REMOTE_WORKSPACE=/workspace/openclaw
```

**Description:** Рабочая директория для Docker контейнеров
**Contains:**
- `gateway/` — OpenClaw Gateway container
- `telegram-bot/` — Telegram Bot container
- `docker-compose.test.yml` — Test stack definition

**Usage:** `ssh ainetic.tech "cd ${REMOTE_WORKSPACE} && docker-compose ps"`

---

### Scripts Directory

```bash
REMOTE_SCRIPTS=${REMOTE_GIT_REPO}/server/scripts
```

**Description:** Bash скрипты для управления
**Contains:**
- `claude-wrapper.sh` — CLI Bridge (320+ lines)
- `test-commands.sh` — Test suite
- `container-manager.sh` — Session lifecycle manager

**Usage:** `ssh ainetic.tech "cd ${REMOTE_SCRIPTS} && ./test-commands.sh"`

---

### Docker Compose Files

```bash
# Test stack (in server/ directory of git repo)
REMOTE_DOCKER_COMPOSE_TEST=${REMOTE_GIT_REPO}/server/docker-compose.test.yml

# Monitoring stack (in server/ directory of git repo)
REMOTE_DOCKER_COMPOSE_MONITORING=${REMOTE_GIT_REPO}/server/docker-compose.monitoring.yml
```

**Usage:**
```bash
# Test stack
ssh ainetic.tech "cd ${REMOTE_GIT_REPO}/server && docker-compose -f docker-compose.test.yml ps"

# Monitoring stack
ssh ainetic.tech "cd ${REMOTE_GIT_REPO}/server && docker-compose -f docker-compose.monitoring.yml ps"
```

---

### Logs Directory

```bash
REMOTE_LOGS=/var/log/codefoundry
```

**Contains:**
- `all-YYYY-MM-DD.log` — All logs
- `errors-YYYY-MM-DD.log` — Errors only
- `gateway-YYYY-MM-DD.log` — Gateway logs
- `bot-YYYY-MM-DD.log` — Telegram Bot logs

**Usage:** `ssh ainetic.tech "tail -f ${REMOTE_LOGS}/gateway-$(date +%Y-%m-%d).log"`

---

### Projects Directory

```bash
REMOTE_PROJECTS=/workspace
```

**Description:** Где Claude Code создаёт проекты
**Usage:** `ssh ainetic.tech "ls ${REMOTE_PROJECTS}"`

---

## 🔧 Environment Variables (Source These)

```bash
# Add to your shell profile or source before SSH
export REMOTE_HOST="ainetic.tech"
export REMOTE_USER="root"
export REMOTE_GIT_REPO="/root/projects/CodeFoundry"
export REMOTE_WORKSPACE="/workspace/openclaw"
export REMOTE_SCRIPTS="${REMOTE_GIT_REPO}/server/scripts"
export REMOTE_LOGS="/var/log/codefoundry"
export REMOTE_DOCKER_COMPOSE_TEST="${REMOTE_WORKSPACE}/docker-compose.test.yml"
```

**Usage in scripts:**
```bash
#!/bin/bash
source ./REMOTE-PATHS.md  # or source from docs/

ssh ${REMOTE_HOST} "cd ${REMOTE_GIT_REPO} && git pull"
```

---

## 🧪 Verification

### Verify all paths exist:

```bash
ssh ainetic.tech "
  echo 'Verifying remote paths...'
  [ -d '${REMOTE_GIT_REPO}' ] && echo '✅ GIT_REPO' || echo '❌ GIT_REPO'
  [ -d '${REMOTE_WORKSPACE}' ] && echo '✅ WORKSPACE' || echo '❌ WORKSPACE'
  [ -d '${REMOTE_SCRIPTS}' ] && echo '✅ SCRIPTS' || echo '❌ SCRIPTS'
  [ -d '${REMOTE_LOGS}' ] && echo '✅ LOGS' || echo '❌ LOGS'
"
```

### Quick status check:

```bash
# Git status
ssh ainetic.tech "cd ${REMOTE_GIT_REPO} && git status"

# Docker status
ssh ainetic.tech "cd ${REMOTE_WORKSPACE} && docker-compose ps"

# Recent logs
ssh ainetic.tech "tail -20 ${REMOTE_LOGS}/gateway-$(date +%Y-%m-%d).log"
```

---

## 📝 Usage Examples

### Example 1: Sync and restart

```bash
# Load paths
source ./docs/REMOTE-PATHS.md  # or use variables directly

# Sync code
ssh ainetic.tech "cd ${REMOTE_GIT_REPO} && git pull"

# Restart containers
ssh ainetic.tech "cd ${REMOTE_WORKSPACE} && docker-compose restart"
```

### Example 2: Run tests

```bash
# Copy test script
scp ${REMOTE_SCRIPTS}/test-commands.sh ainetic.tech:${REMOTE_SCRIPTS}/

# Run tests
ssh ainetic.tech "cd ${REMOTE_SCRIPTS} && ./test-commands.sh"
```

### Example 3: View logs

```bash
# Gateway logs
ssh ainetic.tech "tail -f ${REMOTE_LOGS}/gateway-$(date +%Y-%m-%d).log"

# Error logs
ssh ainetic.tech "tail -f ${REMOTE_LOGS}/errors-$(date +%Y-%m-%d).log"
```

---

## 🔄 Updating This Document

**When to update:**
- ✅ New directory created on remote
- ✅ Paths restructured
- ✅ New environment added
- ✅ Verification fails

**How to update:**
1. Update the path in this file
2. Verify: `ssh ainetic.tech "[ -d 'NEW_PATH' ] && echo OK"`
3. Commit and push: `git add docs/REMOTE-PATHS.md && git commit -m "docs: update remote paths"`
4. Update SESSION.md with change

---

## 🔗 Related Documents

- [@ref: docs/TESTING.md](./TESTING.md) — Mandatory testing workflow
- [@ref: docs/remote-testing/ARCHITECTURE.md](./remote-testing/ARCHITECTURE.md) — Remote infrastructure
- [@ref: docs/remote-testing/QUICKSTART.md](./remote-testing/QUICKSTART.md) — Quick reference

---

## 📊 History

| Date | Change | Verified |
|------|--------|----------|
| 2025-02-05 | Initial creation (Session #11) | ✅ Yes |

---

**Версия:** 1.0.0
**Статус:** MANDATORY — ОБЯЗАТЕЛЬНО К ИСПОЛНЕНИЮ
**Автор:** Claude Code (Lesson from Session #11 — Remote Paths Discovery Problem)
**Дата:** 2025-02-05

---

## 🚨 Enforcement

**This document is MANDATORY:**

1. ✅ Load BEFORE any SSH operation
2. ✅ Use variables in all scripts
3. ✅ Verify paths after changes
4. ❌ NEVER hardcode paths
5. ❌ NEVER guess locations

**Next SSH operation?**
→ Read this file FIRST
→ Use documented paths
→ Update if changed
