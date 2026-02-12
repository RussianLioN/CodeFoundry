# Environment Detection Rules

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **Environment**

---

## 🎯 Priority: P0-BLOCKING

**Environment detection MUST be the FIRST action before ANY operation.**

---

## 🔍 Environment Detection

### Detection Logic

```python
def detect_environment():
    """Execute this FIRST before any operation"""
    hostname = get_hostname()

    if hostname == 'ainetic.tech':
        return 'production'  # Docker available
    elif hostname.startswith('staging'):
        return 'staging'     # Docker available
    else:
        return 'local'       # Docker-FREE zone
```

### Environment Rules

| Environment | Docker | Allowed Operations | Forbidden Operations |
|-------------|--------|-------------------|---------------------|
| **local** | NO | Git, Code editing, File management | docker, docker-compose, systemctl |
| **production** | YES | Docker commands, Service management | Direct code editing |
| **staging** | YES | All production ops + Experimental | Production data access |

---

## ✅ Pre-Execution Checklist

**BEFORE using Bash tool:**

```python
def pre_execution_check(operation):
    # 1. Detect environment
    env = detect_environment()

    # 2. Check if operation is allowed
    if env == 'local' and operation.startswith(('docker', 'docker-compose')):
        return BLOCKED("Use Git workflow or SSH to remote instead")

    # 3. Validate tool selection
    if 'edit' in operation.lower():
        return BLOCKED("Use Edit tool, not Bash")

    # 4. Only if all checks pass
    return ALLOWED
```

---

## 📦 Node.js / TypeScript Operations

### Build & Install Rules

| Operation | Local | Remote | Notes |
|-----------|-------|--------|-------|
| `npm install` | ✅ | ❌ | Install deps locally |
| `npm run build` | ⚠️ | ✅ | Build on server OR locally for dist/ |
| `npm test` | ✅ | ✅ | Tests can run anywhere |
| `npm run dev` | ✅ | ❌ | Dev server only local |

### TypeScript Project Workflow

```
LOCAL (Edit Code)
    ↓
1. Edit .ts files
    ↓
2. Optional: npm run build (check syntax)
    ↓
3. git add + git commit + git push
    ↓
SERVER (ainetic.tech)
    ↓
4. git pull
    ↓
5. npm run build (if needed)
    ↓
6. docker-compose restart
```

### ⚠️ Critical: Docker Builds

**Docker containers are built ON THE SERVER, not locally.**

```bash
# WRONG - trying to build container locally
docker build -t myapp .
docker-compose up -d

# CORRECT - GitOps workflow
git add . && git commit -m "fix: update code" && git push

# Then on server (or via SSH):
ssh ainetic.tech "cd /root/projects/... && git pull && docker-compose up -d --build"
```

---

## 🔗 Related

- [@ref: docker.md](./docker.md) — Docker-specific rules
- [@ref: tools.md](./tools.md) — Tool selection guide
- [@ref: gitops.md](./gitops.md) — Full GitOps workflow

---

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **Environment**
