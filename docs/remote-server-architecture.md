> [🏠 Главная](../README.md) → **🖥️ Remote Server**

---
# Remote Server Architecture for OpenClaw + Telegram Bot

> **Критическая адаптация:** Перенос с localhost на удалённый сервер

**Дата:** 2025-02-02
**Статус:** Требуется доработка

---

## ❌ Проблема

Текущая архитектура рассчитана на **локальный запуск**:
- Docker volumes: `./workspace:/workspace` (локальная папка)
- Доступ к коду: только через локальную файловую систему
- Нет синхронизации с Git репозиторием

**А нужно:**
- 🌐 Удалённый сервер (VPS/dedicated)
- 📱 Управление через Telegram откуда угодно
- 💾 Доступ к коду через Git/GitHub
- 🔄 CI/CD для деплоя

---

## ✅ Целевая архитектура

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   Developer     │         │   Remote Server  │         │     GitHub      │
│   (anywhere)    │         │  (VPS/Dedicated) │         │   Repository    │
├─────────────────┤         ├──────────────────┤         ├─────────────────┤
│ • Laptop        │◄───────►│ • Telegram Bot   │◄────────►│ • Source code   │
│ • Desktop       │  Git   │ • OpenClaw GW    │  Webhook│ • Auto-deploy   │
│ • Phone (TG)    │         │ • Ollama         │         │ • Backups       │
│                 │         │ • Workspace      │         │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
                                      │
                                      ▼
                               ┌──────────────┐
                               │  Persistent  │
                               │   Storage    │
                               │  (Volumes)   │
                               └──────────────┘
```

---

## 🔧 Необходимые изменения

### 1. Workspace на сервере

**Было (локально):**
```yaml
# docker-compose.yml
volumes:
  - ${WORKSPACE_DIR:-./workspace}:/workspace
```

**Стало (сервер):**
```yaml
volumes:
  # Named volume for persistence
  - workspace_data:/workspace

  # Или bind mount to server directory
  - /opt/openclaw/workspace:/workspace
```

### 2. Git интеграция

**Каждое действие → Git commit:**

```typescript
// После создания проекта
async function createProjectViaGateway(name: string, type: string) {
  // 1. Создать проект через Gateway
  const project = await gateway.createProject(name, type);

  // 2. Инициализировать Git
  await exec('git init', { cwd: project.path });
  await exec('git add .', { cwd: project.path });
  await exec('git commit -m "feat: Initial commit from OpenClaw"', {
    cwd: project.path,
  });

  // 3. Создать GitHub репозиторий
  await github.createRepo(name, {
    private: true,
    description: `OpenClaw project: ${type}`,
  });

  // 4. Добавить remote и push
  await exec(`git remote add origin ${repoUrl}`, { cwd: project.path });
  await exec('git push -u origin main', { cwd: project.path });

  return {
    project,
    repoUrl,
    message: `✅ Проект создан и отправлен в GitHub:\n${repoUrl}`,
  };
}
```

### 3. CI/CD Pipeline

**GitHub Actions для автоматического деплоя:**

```yaml
# .github/workflows/openclaw-sync.yml
name: OpenClaw Remote Sync

on:
  push:
    branches: [main]

jobs:
  sync-to-remote:
    runs-on: ubuntu-latest
    steps:
      - name: Pull changes on remote server
        uses: appleboy/ssh-action@master
        with:
          host: ${{secrets.REMOTE_HOST}}
          username: ${{secrets.REMOTE_USER}}
          key: ${{secrets.SSH_PRIVATE_KEY}}
          script: |
            cd /opt/openclaw/workspace/${{github.event.repository.name}}
            git pull origin main

      - name: Restart services if needed
        uses: appleboy/ssh-action@master
        with:
          host: ${{secrets.REMOTE_HOST}}
          username: ${{secrets.REMOTE_USER}}
          key: ${{secrets.SSH_PRIVATE_KEY}}
          script: |
            docker-compose -f /opt/openclaw/docker-compose.yml restart
```

### 4. Доступ к файлам

**Варианты получения доступа к коду:**

#### A) Git pull (рекомендуется)
```bash
# На локальной машине
git clone git@github.com:username/my-bot.git
cd my-bot
# Работайте локально
git add . && git commit -m "changes" && git push
# На сервере автоматически pull
```

#### B) SSH + SFTP
```bash
# Прямой доступ к серверу
ssh user@server
cd /opt/openclaw/workspace/my-bot
# Редактировать файлы
```

#### C) Telegram Bot file commands
```
/download my-bot — получить файлы архивом
/upload my-bot main.py — загрузить файл на сервер
```

### 5. Backup стратегия

**Сервер → GitHub + Cloud:**

```bash
#!/bin/bash
# scripts/server-backup.sh

# 1. Git push (primary backup)
cd /opt/openclaw/workspace
for dir in */; do
  cd "$dir"
  git add .
  git commit -m "Auto-backup $(date)"
  git push origin main
  cd ..
done

# 2. Workspace snapshot
tar -czf /backups/workspace_$(date +%Y%m%d).tar.gz /opt/openclaw/workspace

# 3. Upload to cloud (rsync to S3, Backblaze, etc.)
rclone copy /backups/ remote:openclaw-backups

# 4. Cleanup (keep 30 days)
find /backups -mtime +30 -delete
```

---

## 📋 План миграции

### Phase 1: Server Setup (1 день)

**Задачи:**
- [ ] Арендовать VPS (DigitalOcean, Hetzner, etc.)
- [ ] Установить Docker + Docker Compose
- [ ] Настроить firewall (UFW)
- [ ] Настроить SSH ключи
- [ ] Установить Nginx (reverse proxy, optional)

**Требования к серверу:**
```
CPU: 2+ cores
RAM: 4+ GB
Disk: 40+ GB SSD
OS: Ubuntu 22.04 LTS
```

### Phase 2: Docker Adaptation (1 день)

**Изменения в docker-compose.yml:**

```yaml
services:
  telegram-bot:
    # ... existing config ...
    volumes:
      # Изменить на server volumes
      - workspace_data:/workspace
      - bot_data:/bot/data

  gateway:
    volumes:
      - workspace_data:/workspace

  ollama-service:
    volumes:
      # Models persistent
      - ollama_models:/root/.ollama

volumes:
  workspace_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /opt/openclaw/workspace

  ollama_models:
    driver: local

  bot_data:
    driver: local
```

### Phase 3: Git Integration (2 дня)

**Добавить в Gateway:**
- [ ] Git init после создания проекта
- [ ] Автоматический commit
- [ ] GitHub API integration (создание репо)
- [ ] Git push после изменений

**Новые скиллы:**
```yaml
# workspace/skills/git-operations.md
name: Git Operations
actions:
  - git_init
  - git_commit
  - git_push
  - github_create_repo
```

### Phase 4: CI/CD Setup (1 день)

**GitHub Actions:**
- [ ] Webhook на push
- [ ] SSH deploy на сервер
- [ ] Health check после деплоя
- [ ] Rollback при ошибке

### Phase 5: Monitoring & Backups (1 день)

**Мониторинг:**
- [ ] Prometheus + Grafana
- [ ] Telegram alerts при ошибках
- [ ] Uptime monitoring

**Бэкапы:**
- [ ] Daily git push
- [ ] Weekly snapshots
- [ ] Cloud backup (S3/Backblaze)

---

## 🚀 Quick Start (Remote)

### 1. Подготовка сервера

```bash
# SSH на сервер
ssh root@your-server-ip

# Обновить систему
apt update && apt upgrade -y

# Установить Docker
curl -fsSL https://get.docker.com | sh
curl -fsSL https://get.docker.com/compose.sh | sh

# Создать директории
mkdir -p /opt/openclaw/workspace
mkdir -p /opt/openclaw/logs

# Клонировать репозиторий
cd /opt
git clone git@github.com:RussianLioN/CodeFoundry.git openclaw
cd openclaw
```

### 2. Настроить .env

```bash
cd openclaw/docker
cp .env.example .env
nano .env

# Добавить:
TELEGRAM_BOT_TOKEN=xxx
AUTHORIZED_USER_IDS=xxx
WORKSPACE_DIR=/opt/openclaw/workspace
```

### 3. Запустить

```bash
docker-compose up -d
```

### 4. Проверить

```bash
# Логи
docker-compose logs -f

# Статус
docker-compose ps
```

---

## ⚠️ Критические различия

| Аспект | Local | Remote |
|--------|-------|--------|
| **Workspace** | `./workspace` | `/opt/openclaw/workspace` |
| **Доступ к коду** | Файловая система | Git pull / SSH |
| **Бэкапы** | Не нужны | Обязательны |
| **CI/CD** | Нет | GitHub Actions |
| **Мониторинг** | Опционально | Обязательно |
| **HTTPS** | Нет | Nginx + Let's Encrypt |

---

## 📊 Expert consensus update

После обсуждения с экспертами:

> **"Remote server architecture — это ПРАВИЛЬНЫЙ путь для production. Local setup только для разработки. Обязательно добавьте: Git sync, backups, monitoring, CI/CD."**

**Key recommendations:**
1. **Git as primary storage** — весь код в GitHub
2. **Auto-sync on every change** — webhook → server pull
3. **Daily backups to cloud** — belt + suspenders
4. **Monitoring with alerts** — знать когда сервер упадёт
5. **Rollback capability** — ability to revert quickly

---

**Next:** Implement Git integration + CI/CD pipeline
