# 🔄 GitOps 2.0 с ArgoCD — Полное Руководство

> [🏠 Главная](../README.md) → [📚 Документация](docs/INDEX.md) → [🔄 GitOps](#)

---

## Overview

**GitOps 2.0** — современный подход к управлению инфраструктурой и приложениями через Git.

**Ключевые принципы:**
- 📦 **Декларативность** — всё состояние описано в YAML манифестах
- 🔄 **Автоматическая синхронизация** — Git push → автоматический деплой
- 🔒 **Версионирование** — каждое изменение зафиксировано в Git
- 📊 **Diff visibility** — видимость изменений до применения
- ⏪ **Лёгкий rollback** — откат через `git revert`

---

## 🚀 Quick Start

### 1. Установка GitOps инфраструктуры

```bash
# Перейти в CodeFoundry
cd CodeFoundry

# Запустить bootstrap скрипт
./templates/archetypes/shared/gitops/scripts/gitops-bootstrap.sh
```

**Что происходит:**
1. ✅ Создаётся namespace `argocd`
2. ✅ Установится ArgoCD
3. ✅ Установится SealedSecrets controller
4. ✅ Создадутся ArgoCD проекты (default, staging, production)
5. ✅ Будет предоставлен доступ к ArgoCD UI

### 2. Доступ к ArgoCD UI

```bash
# Port-forward для локального доступа
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Открыть в браузере
open https://localhost:8080

# Получить initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

**Login credentials:**
- Username: `admin`
- Password: (see command above)

### 3. Создание Application

```bash
# Применить application manifest для архетипа
kubectl apply -f templates/archetypes/web-service/gitops/application.yaml

# Проверить статус
argocd app get web-service

# Синхронизировать приложение
argocd app sync web-service
```

---

## 📁 Структура GitOps в CodeFoundry

```
templates/archetypes/shared/gitops/
├── README.md                    # Обзор GitOps
├── argocd/
│   ├── argocd-install.yaml      # Installation manifest
│   ├── app-of-apps.yaml         # Root ApplicationSet (все архетипы)
│   └── projects/
│       ├── default.yaml         # Default project
│       ├── staging.yaml         # Staging environment
│       └── production.yaml      # Production environment
├── sealed-secrets/
│   ├── controller.yaml          # SealedSecrets controller
│   ├── kustomization.yaml       # Kustomize конфигурация
│   └── examples/
│       ├── database-secret.yaml # Пример DB secret
│       └── app-secrets.yaml     # Пример app secrets
├── ci/.github/workflows/
│   ├── gitops-sync.yml          # Авто-обновление image tags
│   └── gitops-pr-review.yml     # Preview окружения для PR
└── scripts/
    ├── gitops-bootstrap.sh      # Initial setup
    ├── argocd-login.sh          # Login helper
    └── seal-secret.sh           # Secret encryption

templates/archetypes/{archetype}/gitops/
└── application.yaml             # ArgoCD Application manifest
```

---

## 🎯 ArgoCD Projects

### Default Project

Политики по умолчанию для всех приложений:
- **Source repos:** `*` (любые репозитории)
- **Destinations:** любой namespace
- **Sync:** автоматическая синхронизация включена

### Staging Project

Политики для staging окружения:
- **Source repos:** только CodeFoundry
- **Destinations:** `*-staging` namespaces
- **Sync:** автоматическая синхронизация
- **Sync window:** 24/7 (любое время)

### Production Project

Политики для production окружения:
- **Source repos:** только CodeFoundry
- **Destinations:** `*-prod`, `*-production` namespaces
- **Sync:** автоматическая синхронизация с manual approval
- **Sync window:** только рабочие часы (9:00-21:00 UTC)
- **Ресурсы:** Whitelist только безопасных ресурсов

---

## 🔒 SealedSecrets

### Что такое SealedSecrets?

**SealedSecrets** — решение для шифрования Kubernetes Secrets прямо в Git.

**Проблема:**
```yaml
# ❌ ПЛОХО - секреты в открытом виде
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
stringData:
  password: "supersecret123"  # НЕБЕЗОПАСНО!
```

**Решение:**
```yaml
# ✅ ХОРОШО - зашифрованный секрет
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: database-credentials
spec:
  encryptedData:
    # Зашифрованные данные (безопасно для Git)
    password: AgBy3qE... (base64)
```

### Как зашифровать secret?

```bash
# 1. Создать template secret
cat > database-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
type: Opaque
stringData:
  password: "my-secure-password"
EOF

# 2. Зашифровать через kubeseal
./templates/archetypes/shared/gitops/scripts/seal-secret.sh \
  database-secret.yaml default strict

# 3. Получится database-secret-sealed.yaml - безопасен для Git!
```

---

## 🔄 GitOps Workflow

### 1. Разработчик вносит изменения

```bash
# Изменяем конфигурацию
vim templates/archetypes/web-service/k8s/base/deployment.yaml

# Commit и push
git add . && git commit -m "Increase replicas to 5" && git push
```

### 2. ArgoCD автоматически синхронизирует

```bash
# Смотрим статус
argocd app list

# Смотрим детали
argocd app get web-service

# Смотрим историю
argocd app history web-service
```

### 3. При проблемах — откат

```bash
# Rollback на предыдущую версию
argocd app rollback web-service

# Rollback на конкретную ревизию
argocd app rollback web-service --revision 3

# Или через Git (GitOps way!)
git revert HEAD
git push
```

---

## 🌐 Preview Environments для Pull Requests

Каждый PR получает своё изолированное окружение для тестирования:

```
PR #123 → preview-pr-123 namespace
PR #124 → preview-pr-124 namespace
```

**Автоматическое:**
- ✅ Создаётся preview namespace при открытии PR
- ✅ Деплоится версия из ветки PR
- ✅ Прокомментируется PR с preview URL
- ✅ Удалится preview namespace при закрытии PR

---

## 📊 Monitoring GitOps

### ArgoCD Application Status

```bash
# Список всех приложений
argocd app list

# Детали приложения
argocd app get web-service

# Синхронизация в реальном времени
argocd app watch web-service
```

### Health Checks

```bash
# Проверить health всех приложений
for app in $(argocd app list -o name); do
  echo "Checking $app..."
  argocd app get "$app" -o jsonpath='{.status.health.status}'
done
```

### Логи

```bash
# Application controller logs
kubectl logs -f -n argocd argocd-application-controller-0

# ApplicationSet controller logs
kubectl logs -f -n argocd argocd-applicationset-controller-0
```

---

## 🔧 Troubleshooting

### Application не синхронизируется

```bash
# Обновить статус
argocd app get web-service --refresh

# Ручная синхронизация
argocd app sync web-service

# Принудительная синхронизация
argocd app sync web-service --force

# Смотреть ошибки
argocd app get web-service --hard-refresh
```

### Out-of-sync состояние

```bash
# Смотреть diff
argocd app diff web-service

# Синхронизировать с pruning
argocd app sync web-service --prune
```

### SealedSecret не создаёт Secret

```bash
# Проверить controller
kubectl get pods -n kube-system | grep sealed-secrets

# Логи controller
kubectl logs -n kube-system -l app.kubernetes.io/name=sealed-secrets

# Проверить SealedSecret
kubectl get sealedsecret database-credentials -o yaml
```

### Lost SealedSecrets Key

```bash
# ⚠️ CRITICAL: Backup ключ перед началом работы!
kubectl get secret -n kube-system sealed-secrets-key -o yaml > backup.yaml

# Восстановить ключ
kubectl apply -f backup.yaml

# Пересоздать все sealed secrets
kubectl delete sealedsecret --all -A
kubectl apply -f templates/archetypes/*/gitops/sealed-secrets/
```

---

## 📋 Best Practices

### 1. Всегда бэкапьте SealedSecrets ключ

```bash
# After installation
kubectl get secret -n kube-system sealed-secrets-key -o yaml > \
  sealed-secrets-key-$(date +%Y%m%d).yaml

# Храните бэкап безопасно (не в Git!)
```

### 2. Используйте namespace isolation

```yaml
# Production apps → *-prod namespaces
# Staging apps → *-staging namespaces
# Preview apps → preview-pr-* namespaces
```

### 3. Определяйте RTO/RPO для бэкапов

```
RTO (Recovery Time Objective): 1 hour
RPO (Recovery Point Objective): 15 minutes
Backup Retention: 30 days daily, 12 weeks weekly
```

### 4. Используйте GitOps для всего

```yaml
# Infrastructure → Git
# Applications → Git
# Policies → Git
# Secrets → SealedSecrets → Git
# Config → Git
```

### 5. Автоматизируйте через CI/CD

```yaml
# Docker build → push image → GitOps sync workflow
# GitOps sync → kubectl edit image → ArgoCD syncs
```

---

## 📚 Дополнительные Ресурсы

### Official Documentation
- [ArgoCD Documentation](https://argocd.readthedocs.io/)
- [SealedSecrets Documentation](https://sealed-secrets.netlify.app/)
- [GitOps Patterns](https://www.weave.works/blog/gitops-operations-by-pull-request/)

### CodeFoundry
- [🏠 Главная](../README.md)
- [🚀 Quick Start](../QUICKSTART.md)
- [🎨 Archetypes](templates/archetypes/README.md)
- [🦞 OpenClaw](openclaw/README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-01-31 | Первая версия GitOps 2.0 руководства |

---

> [🏠 Главная](../README.md) → [📚 Документация](docs/INDEX.md) → [🔄 GitOps](#)
