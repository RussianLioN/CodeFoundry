# 🌐 CodeFoundry Remote Server

> ainetic.tech remote testing infrastructure for CodeFoundry system-prompts

---

## 📋 Overview

This directory contains server-side scripts and configuration for running CodeFoundry on a remote VPS (ainetic.tech). The infrastructure enables:

- **Manual sync** from GitHub via SSH
- **Ephemeral test containers** with session-based lifecycle
- **Telegram bot testing** with real API
- **AI IDE remote integration** (optional)

---

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────────┐
│ Local Machine   │ ──▶ │ GitHub Repo     │ ──▶ │ ainetic.tech        │
│ (Development)   │     │ (git push)      │     │ (VPS Server)        │
└─────────────────┘     └─────────────────┘     │                     │
                                                 │  ┌───────────────┐  │
                                                 │  │ git pull      │  │
                                                 │  └───────┬───────┘  │
                                                 │          │          │
                                                 │          ▼          │
                                                 │  ┌───────────────┐  │
                                                 │  │ Docker        │  │
                                                 │  │ Compose       │  │
                                                 │  └───────┬───────┘  │
                                                 │          │          │
                                                 │          ▼          │
                                                 │  ┌───────────────┐  │
                                                 │  │ Ephemeral     │  │
                                                 │  │ Containers    │  │
                                                 │  │ (Session)     │  │
                                                 │  └───────────────┘  │
                                                 └─────────────────────┘
```

---

## 🚀 Quick Start

### 1. Initial Setup (First Time Only)

SSH into ainetic.tech and run:

```bash
# Clone repository (if not already done)
git clone git@github.com:your-username/system-prompts.git ~/projects/system-prompts

# Run setup script
cd ~/projects/system-prompts/server
./setup.sh
```

The setup script will install:
- Docker & Docker Compose
- Git
- Node.js 20.x LTS
- Additional tools (htop, tmux, jq, etc.)

### 2. Configure Environment

Edit `.env.test` with your actual values:

```bash
cd ~/projects/system-prompts/server
nano .env.test
```

**Required values:**
```bash
GITHUB_REPO=git@github.com:your-username/system-prompts.git
TELEGRAM_BOT_TOKEN=your_actual_bot_token
AUTHORIZED_USER_IDS=your_telegram_user_id
```

### 3. Sync from GitHub

From your local machine:

```bash
# Push changes to GitHub
git push origin main
```

Then on ainetic.tech:

```bash
cd ~/projects/system-prompts
make sync
```

### 4. Start Test Container

```bash
cd ~/projects/system-prompts
make start-test
```

### 5. View Logs

```bash
make logs              # All logs
make logs-gateway      # Gateway only
make logs-bot          # Telegram bot only
```

---

## 📚 Available Commands

All commands are run from `~/projects/system-prompts` on ainetic.tech.

### Sync Commands

| Command | Description |
|---------|-------------|
| `make sync` | Sync from GitHub |
| `make sync-force` | Force sync (discard local changes) |
| `make sync-status` | Check sync status |
| `make sync-recreate` | Sync and recreate containers |

### Container Lifecycle

| Command | Description |
|---------|-------------|
| `make start-test` | Start ephemeral test container |
| `make stop-test` | Stop test container |
| `make restart-test` | Restart test container |
| `make status` | Show container status |
| `make health` | Check container health |

### Session Management

| Command | Description |
|---------|-------------|
| `make start-session SESSION=name` | Start named session |
| `make stop-session SESSION=name` | Stop named session |
| `make list-sessions` | List active sessions |
| `make attach-session SESSION=name` | Attach to session |

### Interactive Access

| Command | Description |
|---------|-------------|
| `make shell` | Enter container shell (user) |
| `make shell-root` | Enter container shell (root) |

### Logging

| Command | Description |
|---------|-------------|
| `make logs` | Follow all logs |
| `make logs-short` | Last 50 lines |
| `make logs-gateway` | Gateway logs only |
| `make logs-bot` | Telegram bot logs only |

### Testing

| Command | Description |
|---------|-------------|
| `make test-telegram` | Test Telegram bot |
| `make test-gateway` | Test Gateway connection |

### Cleanup

| Command | Description |
|---------|-------------|
| `make clean` | Remove containers (keep volumes) |
| `make clean-all` | Remove containers and volumes |
| `make clean-images` | Remove dangling images |

### Development

| Command | Description |
|---------|-------------|
| `make dev-start` | Start long-running dev container |
| `make dev-stop` | Stop dev container |

### Info

| Command | Description |
|---------|-------------|
| `make info` | Show system information |
| `make stats` | Show container resource usage |
| `make version` | Show version info |

---

## 📁 File Structure

```
server/
├── setup.sh                  # Initial setup script
├── sync.sh                   # GitHub sync script
├── Makefile                  # Management commands
├── .env.test                 # Environment configuration
├── container-manager.sh      # Session lifecycle manager
├── docker-compose.test.yml   # Testing stack
├── docker-compose.dev.yml    # Dev stack (optional)
├── test-telegram.sh          # Telegram bot test script
└── README.md                 # This file
```

---

## 🔧 Configuration

### Environment Variables (.env.test)

```bash
# Project
PROJECT_NAME=system-prompts
PROJECT_DIR=/root/projects/system-prompts
GITHUB_REPO=git@github.com:your-username/system-prompts.git

# Containers
CONTAINER_PREFIX=test
SESSION_TIMEOUT=86400  # 24 hours

# Telegram
TELEGRAM_BOT_TOKEN=your_token
AUTHORIZED_USER_IDS=123456789

# Gateway
GATEWAY_HOST=0.0.0.0
GATEWAY_PORT=18789
GATEWAY_HEALTH_PORT=18790

# Ollama (optional)
OLLAMA_ENABLED=false
OLLAMA_MODEL=gemini-3-flash-preview
```

---

## 🔄 Workflow

### Typical Development Workflow

1. **Local:** Make changes → `git commit` → `git push`
2. **Remote:** `ssh ainetic.tech`
3. **Remote:** `cd ~/projects/system-prompts`
4. **Remote:** `make sync`
5. **Remote:** `make stop-test` (if running)
6. **Remote:** `make start-test`
7. **Remote:** `make logs` (monitor)
8. **Local:** Test via Telegram bot or curl

### Testing Workflow

```bash
# On ainetic.tech
make sync                      # Get latest code
make start-test                # Start container
make test-telegram             # Test bot
make logs-bot                  # Check logs
make shell                     # Debug interactively
make stop-test                 # Cleanup
```

---

## 🐛 Troubleshooting

### Container won't start

```bash
# Check logs
make logs

# Check health
make health

# Rebuild
make rebuild
```

### Sync fails

```bash
# Check git status
git status

# Force sync (discards local changes)
make sync-force
```

### Telegram bot not responding

```bash
# Check bot container
make logs-bot

# Verify token
grep TELEGRAM_BOT_TOKEN .env.test

# Test connection
make test-telegram
```

### Permission denied

```bash
# Fix script permissions
chmod +x server/*.sh

# Fix Makefile
chmod +x server/Makefile
```

---

## 🔒 Security Notes

1. **SSH Keys:** Setup requires SSH key for GitHub access
2. **Bot Token:** Never commit `.env.test` with real tokens
3. **User IDs:** Only authorized users can interact with bot
4. **Firewall:** Ensure only necessary ports are exposed

---

## 📊 Monitoring

### Container Health

```bash
make health              # Check all containers
make stats               # Resource usage
make top                 # Running processes
```

### Logs Location

- **Container logs:** `docker logs` (via `make logs`)
- **Host logs:** `/var/log/codefoundry/` (if configured)

---

## 🚦 Next Steps

After setup:

1. ✅ Test sync: `make sync-status`
2. ✅ Start container: `make start-test`
3. ✅ Test bot: `make test-telegram`
4. ✅ Check logs: `make logs`

For detailed runbooks, see:
- [docs/remote-testing/QUICKSTART.md](../docs/remote-testing/QUICKSTART.md)
- [docs/remote-testing/TROUBLESHOOTING.md](../docs/remote-testing/TROUBLESHOOTING.md)

---

**Version:** 1.0.0
**Server:** ainetic.tech
**Last Updated:** 2025-02-03
