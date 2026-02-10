# 🚀 Skill: CI Pipeline

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🚀 DevOps Skills](#)

---

## Description

Автоматизация CI/CD пайплайнов с поддержкой GitHub Actions, GitLab CI, Jenkins и других систем.

---

## 🎯 Capabilities

### 🔄 Pipeline Generation

**Использование:**
```
👤 "Создай CI pipeline для этого проекта"
👤 "Настрой GitHub Actions для тестов"
👤 "Добавь CD пайплайн для деплоя"
```

**Действия:**
```bash
1. Анализирует тип проекта (Node.js, Python, Go, etc.)
2. Определяет подходящую CI систему
3. Генерирует YAML конфигурацию
4. Добавляет этапы: lint → test → build → deploy
5. Настраивает secrets и variables
```

---

### 📦 Supported CI Systems

| Система | Файл конфигурации | Особенности |
|---------|-------------------|-------------|
| **GitHub Actions** | `.github/workflows/*.yml` | Интеграция с GitHub, free tier |
| **GitLab CI** | `.gitlab-ci.yml` | Встроенный в GitLab, Docker runners |
| **Jenkins** | `Jenkinsfile` | Гибкость, плагины, self-hosted |
| **CircleCI** | `.circleci/config.yml` | Docker-first, caching |
| **Azure Pipelines** | `azure-pipelines.yml` | Интеграция с Azure |
| **Bitbucket** | `bitbucket-pipelines.yml` | Интеграция с Atlassian |
| **Woodpecker** | `.woodpecker.yml` | Self-hosted, simple |

---

## 🔧 Pipeline Templates

### GitHub Actions - Node.js

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Test
        run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build Docker image
        run: |
          docker build -t myapp:${{ github.sha }} .
          docker tag myapp:${{ github.sha }} myapp:latest

      - name: Push to registry
        run: docker push myapp:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Deploy to staging
        run: |
          kubectl set image deployment/myapp myapp=myapp:${{ github.sha }}
```

---

### GitLab CI - Python

```yaml
stages:
  - lint
  - test
  - build
  - deploy

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

cache:
  paths:
    - .cache/pip
    - venv/

lint:
  stage: lint
  image: python:3.11-slim
  script:
    - pip install ruff
    - ruff check .

test:
  stage: test
  image: python:3.11-slim
  coverage: '/TOTAL.*\s+(\d+%)$/'
  script:
    - pip install -r requirements.txt
    - pip install pytest pytest-cov
    - pytest --cov=src --cov-report=term
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy:staging:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl set image deployment/myapp myapp=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
```

---

### Jenkins - Go

```groovy
pipeline {
    agent any

    environment {
        GO_VERSION = '1.21'
        DOCKER_REGISTRY = 'registry.example.com'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install') {
            steps {
                sh 'go version'
                sh 'go mod download'
                sh 'go mod verify'
            }
        }

        stage('Lint') {
            steps {
                sh 'golangci-lint run'
            }
        }

        stage('Test') {
            steps {
                sh 'go test -v -race -coverprofile=coverage.out -covermode=atomic ./...'
            }
        }

        stage('Build') {
            steps {
                sh 'go build -v -o app ./cmd/server'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/myapp:${BUILD_NUMBER}")
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-credentials') {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'kubectl set image deployment/myapp myapp=${DOCKER_REGISTRY}/myapp:${BUILD_NUMBER}'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            emailext(
                subject: "Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build passed successfully.",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
        failure {
            emailext(
                subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build failed. Check console output.",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

---

## 🎯 Pipeline Stages

### 1. Lint Stage

```yaml
lint:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run linters
      run: |
        npm run lint
        npm run format:check
```

### 2. Test Stage

```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run tests
      run: npm test
    - name: Generate coverage
      run: npm test -- --coverage
```

### 3. Build Stage

```yaml
build:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Build application
      run: npm run build
    - name: Build Docker image
      run: docker build -t myapp:${{ github.sha }} .
```

### 4. Deploy Stage

```yaml
deploy:
  runs-on: ubuntu-latest
  environment:
    name: staging
    url: https://staging.example.com
  steps:
    - name: Deploy to staging
      run: kubectl apply -f k8s/
```

---

## 🧪 Testing Strategies

### Matrix Builds

```yaml
test:
  strategy:
    matrix:
      os: [ubuntu-latest, windows-latest, macos-latest]
      node: [16.x, 18.x, 20.x]
  runs-on: ${{ matrix.os }}
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node }}
```

### Parallel Jobs

```yaml
jobs:
  test-unit:
    runs-on: ubuntu-latest
    steps:
      - run: npm run test:unit

  test-integration:
    runs-on: ubuntu-latest
    steps:
      - run: npm run test:integration

  test-e2e:
    runs-on: ubuntu-latest
    steps:
      - run: npm run test:e2e
```

---

## 🔐 Secrets Management

### GitHub Actions Secrets

```bash
# Через UI
Settings → Secrets and variables → Actions → New repository secret

# Через CLI
gh secret set DB_PASSWORD
gh secret set API_KEY --body "file_with_key.txt"
```

```yaml
steps:
  - name: Deploy
    env:
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
      API_KEY: ${{ secrets.API_KEY }}
    run: |
      echo $DB_PASSWORD | docker login ...
```

### GitLab CI Variables

```bash
# Через UI
Settings → CI/CD → Variables

# или через .gitlab-ci.yml
variables:
  PASSWORD: ${CI_VARIABLE_PASSWORD}
```

---

## 📊 Caching Strategy

### npm Cache

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

# Или вручную
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Docker Layer Cache

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v2

- name: Cache Docker layers
  uses: actions/cache@v3
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

---

## 📝 Usage Examples

### Сценарий 1: GitHub Actions для Node.js

```
👤 "Создай GitHub Actions workflow для моего Node.js проекта"

🤖 CI Pipeline Skill:
    1. 📋 Analysing package.json...
    2. ✅ Detected: Node.js 20, Jest, ESLint
    3. 📝 Creating .github/workflows/ci.yml...
    4. 📦 Workflow includes:
       - Lint stage (ESLint)
       - Test stage (Jest with coverage)
       - Build stage
       - Deploy stage (to staging on main)
    5. ✅ Workflow created
```

### Сценарий 2: GitLab CI для Python

```
👤 "Настрой GitLab CI для Python FastAPI проекта"

🤖 CI Pipeline Skill:
    1. 📋 Analysing requirements.txt...
    2. ✅ Detected: FastAPI, pytest, ruff
    3. 📝 Creating .gitlab-ci.yml...
    4. 📦 Pipeline includes:
       - Lint stage (ruff)
       - Test stage (pytest with coverage)
       - Build stage (Docker)
       - Deploy stage (Kubernetes)
    5. ✅ Pipeline created
```

### Сценарий 3: Voice Command

```
🗣️ "Добавь CD пайплайн для продакшена"

🤖 CI Pipeline Skill:
    1. 📋 Reading current CI config...
    2. 📝 Adding production deployment:
       - New job: deploy:production
       - Environment: production
       - Manual approval required
       - Blue-green deployment strategy
    3. ✅ CD pipeline added
    4. 💬 Don't forget to set production secrets!
```

---

## 🔗 Integration with Tools

Использует инструменты:
- **write** — создание конфигурационных файлов
- **read** — чтение существующих конфигов
- **bash** — выполнение команд CI/CD
- **git** — работа с репозиторием

---

## 🔗 Voice Commands

| Голосовая команда | Действие |
|-------------------|----------|
| "Создай CI pipeline" | Генерация CI конфигурации |
| "Добавь тесты в пайплайн" | Добавление test stage |
| "Настрой деплой" | Добавление deploy stage |
| "Включи кэширование" | Настройка cache |
| "Добавь матричные сборки" | Matrix configuration |

---

## 🛡️ Best Practices

### 1. Fail Fast

```yaml
# ❌ Медленно - последовательное выполнение
jobs:
  lint:
    runs-on: ubuntu-latest
  test:
    runs-on: ubuntu-latest
    needs: lint

# ✅ Быстро - параллельное выполнение
jobs:
  lint:
    runs-on: ubuntu-latest
  test:
    runs-on: ubuntu-latest
  # lint и test запускаются параллельно
```

### 2. Artifacts

```yaml
- name: Upload coverage
  uses: actions/upload-artifact@v3
  with:
    name: coverage-report
    path: coverage/
    retention-days: 30
```

### 3. Dependency Management

```yaml
- name: Check dependencies
  run: npm audit

- name: Update dependencies
  run: npm update
```

---

## 🐛 Troubleshooting

### Проблема: Pipeline падает на тестах

```
👤 "Тесты падают в CI"

🤖 CI Pipeline Skill:
    1. 🔍 Checking logs...
    2. 📋 Found: Tests fail due to missing environment variable
    3. 💬 Solution: Add env variable to CI config or secrets
    4. ✅ Variable added
```

### Проблема: Медленная сборка

```
👤 "Сборка занимает 20 минут"

🤖 CI Pipeline Skill:
    1. 📊 Analysing pipeline...
    2. 💡 Optimizations:
       a) Enable caching (saves ~5 min)
       b) Run tests in parallel (saves ~3 min)
       c) Use Docker layer cache (saves ~2 min)
    3. ✅ Estimated time: ~10 min
```

---

## 📚 См. Также

- [🚀 DevOps Skills Index](../README.md)
- [🐳 Docker Deploy](docker-deploy.md)
- [📊 Monitoring](monitoring.md)
- [↩️ Rollback](rollback.md)
- [🎯 Workspace](../README.md)
- [🤖 Agents](../AGENTS.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия skill |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../README.md) → [🚀 CI Pipeline](#)
