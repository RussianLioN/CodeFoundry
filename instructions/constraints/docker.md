# Docker Constraints

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **Docker**

---

## 🎯 Priority: P1-ERROR

**Docker is NOT installed on the local machine. All Docker operations must go through remote SSH or GitOps.**

---

## 🚫 Absolute Prohibitions

**On LOCAL machine, NEVER:**

| Command | Reason | Alternative |
|---------|--------|-------------|
| `docker` | Not installed | `ssh ainetic.tech "docker ..."` |
| `docker-compose` | Not installed | Git workflow |
| `docker ps` | Will fail | `ssh ainetic.tech "docker ps"` |
| `docker logs` | Will fail | `ssh ainetic.tech "docker logs -f"` |
| `docker build` | Not installed | CI/CD or remote build |

---

## ✅ Correct Patterns

### Check Docker Status

```bash
# WRONG (local)
docker ps

# CORRECT (via SSH)
ssh ainetic.tech "docker ps"
```

### View Logs

```bash
# WRONG (local)
docker logs -f container-name

# CORRECT (via SSH)
ssh ainetic.tech "docker logs -f container-name"
```

### Deploy/Restart Service

```bash
# WRONG (local docker-compose)
docker-compose restart

# CORRECT (GitOps workflow)
# 1. Edit docker-compose.yml locally
# 2. git commit -m "deploy: restart service"
# 3. git push
# 4. Verify: ssh ainetic.tech "docker ps"
```

---

## 🔄 GitOps Deployment Workflow

**Git is the single source of truth. Remote server reconciles desired state.**

| User Intent | Forbidden | Correct |
|-------------|-----------|---------|
| Restart service | `docker-compose restart` | `git commit --allow-empty -m "deploy: restart" && git push` |
| Update image | `docker pull` | Edit docker-compose.yml → commit → push |
| Deploy version | `docker build` | Bump version → commit → push |
| Check status | `docker ps` | `ssh ainetic.tech "docker ps"` |

---

## 🔗 Related

- [@ref: environment.md](./environment.md) — Environment detection
- [@ref: gitops.md](./gitops.md) — Full GitOps workflow
- [@ref: docs/remote-testing/ARCHITECTURE.md](../../docs/remote-testing/ARCHITECTURE.md) — Remote infrastructure

---

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → [Constraints](./index.md) → **Docker**
