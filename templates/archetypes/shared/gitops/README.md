# 🔄 GitOps 2.0 Infrastructure

> [🏠 Главная](../../README.md) → [🎨 Archetypes](../README.md) → [🔄 GitOps](#)

---

## Overview

**GitOps 2.0** — де-факто стандарт для управления Kubernetes кластерами через Git.

**Компоненты:**
- 📦 **ArgoCD** — Continuous Delivery оператор для Kubernetes
- 🔒 **SealedSecrets** — Шифрование секретов в Git
- 🎯 **ApplicationSet** — Управление сотнями микросервисов
- 📊 **Diff visibility** — Визуализация изменений перед деплоем

---

## 🚀 Quick Start

### 1. Установка ArgoCD

```bash
# Создаём namespace
kubectl create namespace argocd

# Устанавливаем ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Проверяем установку
kubectl get pods -n argocd
```

**Ожидаемый результат:**
```
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-application-controller-0       1/1     Running   0          2m
argocd-applicationset-controller-0    1/1     Running   0          2m
argocd-dex-server-6d9c7b4b7f-xxx      1/1     Running   0          2m
argocd-notifications-controller-0     1/1     Running   0          2m
argocd-redis-6c898f8b9f-xxx           1/1     Running   0          2m
argocd-repo-server-7577b6c4fc-xxx     1/1     Running   0          2m
argocd-server-5c7d8d9f5b-xxx          1/1     Running   0          2m
```

### 2. Доступ к ArgoCD UI

```bash
# Port-forward для доступа к UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Открываем в браузере
open https://localhost:8080

# Получаем initial password (username: admin)
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

### 3. Установка SealedSecrets

```bash
# Устанавливаем SealedSecrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Проверяем установку
kubectl get pods -n kube-system | grep sealed-secrets
```

### 4. Настройка CLI

```bash
# Установка ArgoCD CLI
# macOS
brew install argocd

# Linux
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Login в ArgoCD
argocd login localhost:8080 --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d) --insecure
```

---

## 📁 Структура

```
shared/gitops/
├── README.md                    # Этот файл
├── argocd/
│   ├── argocd-install.yaml      # Installation manifest
│   ├── app-of-apps.yaml         # Root ApplicationSet
│   └── projects/
│       ├── default.yaml         # Default project
│       ├── staging.yaml         # Staging environment
│       └── production.yaml      # Production environment
├── sealed-secrets/
│   ├── controller.yaml          # SealedSecrets controller
│   ├── kustomization.yaml       # Kustomize configuration
│   └── examples/
│       └── database-secret.yaml # Пример sealed secret
└── scripts/
    ├── gitops-bootstrap.sh      # Initial setup script
    ├── argocd-login.sh          # Login helper
    └── seal-secret.sh           # Secret encryption script
```

---

## 🎯 ApplicationSet Pattern

ApplicationSet позволяет управлять множеством приложений из одного места:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: codefoundry-apps
  namespace: argocd
spec:
  generators:
  - git:
      repoURL: https://github.com/RussianLioN/CodeFoundry
      revision: main
      directories:
      - path: templates/archetypes/*/k8s/overlays/production
  template:
    metadata:
      name: '{{path.basenameNormalized}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/RussianLioN/CodeFoundry
        targetRevision: main
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{path.basenameNormalized}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

---

## 🔒 SealedSecrets Workflow

### 1. Создаём secret template

```yaml
# database-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
type: Opaque
stringData:
  password: "CHANGE_ME"
```

### 2. Шифруем secret

```bash
# Используем kubeseal CLI
kubeseal -f database-secret.yaml -w database-sealed-secret.yaml

# Результат — зашифрованный secret, безопасный для Git
```

### 3. Применяем sealed secret

```bash
kubectl apply -f database-sealed-secret.yaml

# SealedSecrets controller автоматически создаст обычный Secret
kubectl get secret database-credentials
```

---

## 🔄 GitOps Workflow

### 1. Разработчик вносит изменения

```bash
# Изменяем replicas
vim templates/archetypes/web-service/k8s/overlays/production/deployment.yaml

# Commit и push
git add . && git commit -m "Increase replicas to 5" && git push
```

### 2. ArgoCD автоматически синхронизирует

```bash
# Смотрим статус синхронизации
argocd app list

# Смотрим детали приложения
argocd app get web-service

# Смотрим историю изменений
argocd app history web-service
```

### 3. Откат при проблемах

```bash
# Rollback на предыдущую версию
argocd app rollback web-service

# Rollback на конкретную ревизию
argocd app rollback web-service --revision 3
```

---

## 📊 Мониторинг

### ArgoCD Metrics

```bash
# Смотрим статус всех приложений
argocd app list --output wide

# Смотрим синхронизацию в реальном времени
argocd app watch web-service
```

### Логи ArgoCD

```bash
# Application controller logs
kubectl logs -f -n argocd argocd-application-controller-0

# ApplicationSet controller logs
kubectl logs -f -n argocd argocd-applicationset-controller-0

# API server logs
kubectl logs -f -n argocd argocd-server-5c7d8d9f5b-xxx
```

---

## 🔧 Troubleshooting

### Application не синхронизируется

```bash
# Проверяем статус
argocd app get web-service --refresh

# Ручная синхронизация
argocd app sync web-service

# Проверяем ошибки
argocd app get web-service --hard-refresh
```

### SealedSecret не создаёт Secret

```bash
# Проверяем controller
kubectl get pods -n kube-system | grep sealed-secrets

# Проверяем логи
kubectl logs -n kube-system -l name=sealed-secrets-controller

# Проверяем статус SealedSecret
kubectl get sealedsecret database-credentials -o yaml
```

### Out-of-sync состояние

```bash
# Смотрим diff
argocd app diff web-service

# Принудительно синхронизируем
argocd app sync web-service --force

# Удаём orphaned resources
argocd app sync web-service --prune
```

---

## 📚 См. Также

### Официальная документация
- [ArgoCD Documentation](https://argocd.readthedocs.io/)
- [SealedSecrets Documentation](https://sealed-secrets.netlify.app/)
- [GitOps Patterns](https://www.weave.works/blog/gitops-operations-by-pull-request/)

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [📋 Все Архетипы](../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-01-31 | Первая версия GitOps 2.0 инфраструктуры |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🔄 GitOps](#)
