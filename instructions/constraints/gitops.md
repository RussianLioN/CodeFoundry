# GitOps Deployment Workflow

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **GitOps**

---

## 🎯 Priority: P1-ERROR

**Git is the single source of truth. All deployments go through git push.**

---

## 📋 Core Principles

```
1. Git = Single Source of Truth
2. Remote server reconciles desired state
3. Docker commands are implementation detail (not user-facing)
```

---

## 🔄 Mandatory Deployment Workflow

```
1. Edit IaC file locally (docker-compose.yml, etc.)
      ↓
2. Validate syntax (if possible)
      ↓
3. Git commit with descriptive message
   Format: "deploy: [description]"
      ↓
4. Git push
      ↓
5. Remote server detects change → applies new state
      ↓
6. Verify via SSH logs
```

---

## 📊 Intent → Command Mapping

| User Intent | FORBIDDEN | CORRECT |
|-------------|-----------|---------|
| Restart service | `docker-compose restart` | `git commit --allow-empty -m "deploy: restart" && git push` |
| Update image | `docker pull` | Edit docker-compose.yml → commit → push |
| Deploy new version | `docker build && push` | Bump version in compose → push |
| Check status | `docker ps` | `ssh ainetic.tech "docker ps"` |
| View logs | `docker logs` | `ssh ainetic.tech "docker logs -f"` |
| Update config | Edit on server | Edit locally → commit → push |

---

## 🚫 Never Bypass Git

- **NO** SSH to server and run docker commands manually
- **NO** Edit files directly on server
- **NO** Run docker-compose commands locally

---

## ✅ Example: Deploy Config Change

```bash
# 1. Edit file locally
Edit tool: server/docker-compose.yml

# 2. Commit
git add server/docker-compose.yml
git commit -m "deploy: update gateway port to 18790"

# 3. Push
git push

# 4. Verify
ssh ainetic.tech "cd /root/projects/CodeFoundry && git pull && docker-compose up -d"
# Or use automated reconciliation
```

---

## 🔗 Related

- [@ref: docker.md](./docker.md) — Docker constraints
- [@ref: docs/remote-testing/ARCHITECTURE.md](../../docs/remote-testing/ARCHITECTURE.md) — Remote infrastructure
- [@ref: docs/REMOTE-PATHS.md](../../docs/REMOTE-PATHS.md) — Remote paths

---

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **GitOps**
