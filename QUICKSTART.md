# 🚀 Quick Start — Создание нового проекта с CodeFoundry

> [🏠 Главная](README.md) → [🚀 Quick Start](#)

---

## 🎯 Одна Команда — Готовый Проект

CodeFoundry создаёт полноценные IT-проекты одной командой.

```bash
cd CodeFoundry
make new ARCHETYPE=fullstack NAME=my-saas
```

**Всё!** Ваш новый проект готов в `./my-saas/` со всеми необходимыми файлами.

---

## ✅ Перед Началом: Что Вам Нужно

### Минимальные Требования

| Инструмент | Зачем Нужен | Минимальная Версия | Проверка |
|------------|-------------|-------------------|----------|
| **Git** | Клонирование, коммиты | 2.30+ | `git --version` |
| **Make** | Команды CodeFoundry | 3.81+ | `make --version` |
| **Docker** | Контейнеризация | 20.10+ | `docker --version` |

### Опциональные Инструменты

| Инструмент | Когда Нужен | Минимальная Версия | Проверка |
|------------|-------------|-------------------|----------|
| **GitHub CLI** | `make sync-github` | 2.0+ | `gh --version` |
| **kubectl** | GitOps деплой | 1.25+ | `kubectl version` |
| **Node.js** | web-service, fullstack | 18 LTS | `node --version` |
| **Python** | ai-agent, data-pipeline, telegram-bot | 3.11+ | `python --version` |
| **Go** | web-service, cli-tool, microservices | 1.21+ | `go version` |
| **Poetry** | Python проекты | 1.6+ | `poetry --version` |

---

### 📥 Инструкция по Установке

#### macOS (Homebrew)

```bash
# Установить Homebrew (если нет)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Минимальные инструменты
brew install git make docker docker-compose

# GitHub CLI (опционально)
brew install gh

# kubectl для GitOps (опционально)
brew install kubectl

# Node.js (если нужен)
brew install node@18

# Python 3.11+ (если нужен)
brew install python@3.11

# Go (если нужен)
brew install go

# Poetry для Python (если нужен)
curl -sSL https://install.python-poetry.org | python3 -
```

#### Linux (Ubuntu/Debian)

```bash
# Обновить пакеты
sudo apt update && sudo apt upgrade -y

# Минимальные инструменты
sudo apt install -y git build-essential

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# GitHub CLI (опционально)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# kubectl для GitOps (опционально)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Node.js 18 LTS (если нужен)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Python 3.11+ (если нужен)
sudo apt install -y python3.11 python3.11-venv python3-pip

# Go 1.21+ (если нужен)
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Poetry для Python (если нужен)
curl -sSL https://install.python-poetry.org | python3 -
```

#### Windows (WSL2)

```powershell
# 1. Включить WSL2 в PowerShell (Admin)
wsl --install

# 2. После перезагрузки, установить Ubuntu из Microsoft Store

# 3. В WSL2 терминале выполнить команды Linux выше
```

> **Важно:** CodeFoundry **не поддерживает** нативную Windows. Используйте WSL2 или Docker Desktop.

---

### 🔍 Проверка Установки

После установки инструментов выполните проверку:

```bash
# Минимальная проверка
git --version  && echo "✅ Git OK"
make --version  && echo "✅ Make OK"
docker --version  && echo "✅ Docker OK"

# Проверка опциональных инструментов
gh --version 2>/dev/null && echo "✅ GitHub CLI OK" || echo "⚠️  GitHub CLI не установлен"
kubectl version --client 2>/dev/null && echo "✅ kubectl OK" || echo "⚠️  kubectl не установлен"
node --version 2>/dev/null && echo "✅ Node.js OK" || echo "⚠️  Node.js не установлен"
python --version 2>/dev/null && echo "✅ Python OK" || echo "⚠️  Python не установлен"
go version 2>/dev/null && echo "✅ Go OK" || echo "⚠️  Go не установлен"
poetry --version 2>/dev/null && echo "✅ Poetry OK" || echo "⚠️  Poetry не установлен"
```

**Ожидаемый результат:**
```
git version 2.39.0
✅ Git OK
GNU Make 4.3
✅ Make OK
Docker version 24.0.0
✅ Docker OK
```

---

### 🚀 Quick Install (Сценарии)

#### Сценарий 1: Минимум (только создание проектов)

```bash
# Вам нужны только: Git + Make
# Работает для всех архетипов кроме AI/ML
```

#### Сценарий 2: Разработка Node.js

```bash
# Дополнительно: Node.js 18 LTS
# Для: web-service, fullstack
```

#### Сценарий 3: AI/ML Разработка

```bash
# Дополнительно: Python 3.11+ + Poetry
# Для: ai-agent, data-pipeline, telegram-bot
```

#### Сценарий 4: GitOps Deployment

```bash
# Дополнительно: kubectl + Kubernetes кластер
# Для: production деплой через ArgoCD
```

---

### ❓ Что Если Чего-то Не Установлено?

**Нет Make?** Используйте скрипты напрямую:
```bash
./scripts/new-project.sh fullstack my-project
./scripts/sync-github.sh
```

**Нет Docker?** Локальная разработка всё равно работает:
```bash
cd my-project
make install  # Установит зависимости локально
make dev      # Запустит без Docker
```

**Нет GitHub CLI?** Создайте репозиторий вручную:
1. Перейдите на https://github.com/new
2. Создайте пустой репозиторий
3. Выполните команды из GitHub Quick Setup

**Нет kubectl?** Пропустите GitOps секцию, деплойте вручную через Docker:
```bash
docker build -t my-app:latest .
docker run -p 3000:3000 my-app:latest
```

---

## 📋 8 Готовых Архетипов

| Архетип | Описание | Стек | Команда |
|---------|----------|------|---------|
| 🌐 **Web Service** | REST/GraphQL API | Node.js/Python/Go | `make new ARCHETYPE=web-service NAME=my-api` |
| 🤖 **AI Agent** | AI assistant + RAG | Python + FastAPI + Qdrant | `make new ARCHETYPE=ai-agent NAME=my-bot` |
| 📊 **Data Pipeline** | ETL/ELT + Airflow + dbt | Python + PostgreSQL + Redis | `make new ARCHETYPE=data-pipeline NAME=my-etl` |
| 📱 **Telegram Bot** | aiogram + FSM | Python + PostgreSQL + Redis | `make new ARCHETYPE=telegram-bot NAME=my-bot` |
| 📽️ **Presentation** | Markdown + Reveal.js | Markdown + Reveal.js | `make new ARCHETYPE=presentation NAME=my-talk` |
| 🖥️ **CLI Tool** | Go/Rust/Python CLI | Cobra/Clap/Typer | `make new ARCHETYPE=cli-tool NAME=my-tool` |
| 🏗️ **Microservices** | Istio + gRPC + Kong | Go/Python + Kong + Istio | `make new ARCHETYPE=microservices NAME=my-ms` |
| 💻 **Fullstack** | Next.js + NestJS + Nx | React + Node.js + PostgreSQL | `make new ARCHETYPE=fullstack NAME=my-saas` |

---

## 🔄 Полный Рабочий Процесс

### Шаг 1: Создать проект

```bash
# Перейти в CodeFoundry
cd CodeFoundry

# Создать проект из архетипа
make new ARCHETYPE=fullstack NAME=my-saas
```

**Что происходит:**
1. ✅ Копируется выбранный archetype
2. ✅ Создаётся директория `my-saas/`
3. ✅ Инициализируется Git репозиторий
4. ✅ Генерируется документация (PROJECT.md, TASKS.md, SESSION.md, CHANGELOG.md)
5. ✅ Копируется OpenClaw конфигурация

### Шаг 2: Перейти в проект

```bash
cd my-saas
```

### Шаг 3: Настроить окружение

```bash
# Скопировать шаблон переменных окружения
cp .env.example .env

# Отредактировать .env
nano .env  # или ваш редактор
```

**Обычно в .env:**
- Database credentials
- API keys
- Service URLs
- Feature flags

### Шаг 4: Установить зависимости

```bash
make install
# или
npm install  # для Node.js
# или
pip install -e .  # для Python
```

### Шаг 5: Запустить разработку

```bash
make dev
```

Приложение запустится на:
- **Web Service:** `http://localhost:3000` или `http://localhost:8000`
- **Fullstack:** `http://localhost:3000` (frontend) + `http://localhost:8000` (API)
- **Telegram Bot:** запускается как процесс
- **CLI Tool:** готов к использованию после `make install`

### Шаг 6: Синхронизировать с GitHub

```bash
make sync-github
```

**Что происходит:**
1. ✅ Создаётся репозиторий на GitHub
2. ✅ Настраивается remote origin
3. ✅ Код запушивается на GitHub
4. ✅ Получаете URL: `https://github.com/username/my-saas`

---

## 🔄 GitOps: Production Deploy с ArgoCD

### Опционально: Настроить GitOps для автоматического деплоя

#### Шаг 1: Установить GitOps инфраструктуру

```bash
# Из директории CodeFoundry
./templates/archetypes/shared/gitops/scripts/gitops-bootstrap.sh
```

**Что происходит:**
1. ✅ Устанавливается ArgoCD
2. ✅ Устанавливается SealedSecrets controller
3. ✅ Создаются ArgoCD проекты (default, staging, production)

#### Шаг 2: Доступ к ArgoCD UI

```bash
# Port-forward для доступа
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Открыть в браузере
open https://localhost:8080

# Получить initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

#### Шаг 3: Создать ArgoCD Application

```bash
# Применить application manifest
kubectl apply -f my-saas/gitops/application.yaml

# Синхронизировать приложение
argocd app sync my-saas
```

#### Шаг 4: Зашифровать секреты

```bash
# Создать secret template
cat > database-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
stringData:
  password: "your-secure-password"
EOF

# Зашифровать секрет
./templates/archetypes/shared/gitops/scripts/seal-secret.sh \
  database-secret.yaml my-saas strict

# Применить sealed secret
kubectl apply -f database-secret-sealed.yaml
```

**Подробнее:** [🔄 GitOps Documentation](docs/gitops-README.md)

---

## 📊 Примеры Создания Проектов

### Пример 1: SaaS Приложение

```bash
# Создаём
make new ARCHETYPE=fullstack NAME=task-manager

# Настраиваем
cd task-manager
cp .env.example .env
# DATABASE_URL=postgresql://user:pass@localhost:5432/taskmanager

# Устанавливаем и запускаем
make install
make dev

# Открываем http://localhost:3000
# Приложение работает!
```

### Пример 2: Telegram Бот

```bash
# Создаём
make new ARCHETYPE=telegram-bot NAME=weather-bot

# Настраиваем
cd weather-bot
cp .env.example .env
# BOT_TOKEN=токен_от_@BotFather
# DATABASE_URL=postgresql://bot:pass@localhost:5432/weather_bot

# Запускаем
make dev

# Бот запущен и готов!
```

### Пример 3: Микросервисы

```bash
# Создаём
make new ARCHETYPE=microservices NAME=my-platform

# Запускаем инфраструктуру
cd my-platform
docker-compose up -d

# Запускаем сервисы
make services-up

# Все микросервисы работают!
```

---

## 🛠️ Доступные Команды

```bash
# Показать все команды
make help

# Показать все архетипы
make list-archetypes

# Создать проект
make new ARCHETYPE=<archetype> NAME=<project-name>

# Синхронизация с GitHub
make sync-github

# Запустить observability stack
make observability-up

# Показать версию
make version
```

---

## 🐛 Устранение Проблем

### Ошибка: "Архетип не найден"

```bash
# Проверить доступные архетипы
make list-archetypes
```

### Ошибка: "GitHub CLI не установлен"

```bash
# Установить GitHub CLI
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of /usr/share/keyrings/githubcli-archive-keyring.gpg
sudo apt-get install gh

# Авторизация
gh auth login
```

### Ошибка: "Скрипт не исполняется"

```bash
chmod +x scripts/*.sh
```

### Ошибка: "Нет Make"

```bash
# Использовать скрипты напрямую
./scripts/new-project.sh fullstack my-project
./scripts/sync-github.sh
```

---

## 📚 Дополнительно

- [🎨 Все Архетипы](templates/archetypes/README.md) — подробное описание каждого
- [🦞 OpenClaw](openclaw/README.md) — AI-ассистент для разработки
- [📋 Tasks](TASKS.md) — задачи и прогресс проекта

---

## 🎯 Выбор Архетипа

### Для Web API
**Используйте:** `web-service` или `fullstack`

**Когда нужен:**
- RESTful API
- GraphQL API
- Backend для фронтенда
- Microservice backend

### Для AI/ML
**Используйте:** `ai-agent`

**Когда нужен:**
- AI чат-бот
- RAG приложение
- LLM wrapping
- Prompt engineering платформа

### Для Bot
**Используйте:** `telegram-bot`

**Когда нужен:**
- Telegram бот
- Inline keyboards
- FSM диалоги
- Webhook обработка

### Для Аналитики
**Используйте:** `data-pipeline`

**Когда нужен:**
- ETL/ELT процессы
- Data warehouse
- Аналитические дашборды
- Batch задачи

### Для Презентации
**Используйте:** `presentation`

**Когда нужна:**
- Технический доклад
- Конференция
- Обучающие материалы
- Документация как слайды

### Для Инструмента
**Используйте:** `cli-tool`

**Когда нужен:**
- Developer tools
- DevOps утилиты
- System administration
- Automation scripts

### Для Распределённой Системы
**Используйте:** `microservices`

**Когда нужна:**
- Enterprise архитектура
- High-scale приложения
- Service mesh
- Distributed tracing

---

## 🚀 Готово Начинать!

```bash
# 1. Клонируйте или обновите CodeFoundry
git clone https://github.com/RussianLioN/CodeFoundry.git
cd CodeFoundry

# 2. Создайте свой первый проект
make new ARCHETYPE=fullstack NAME=my-first-project

# 3::00 — наслаждаетесь!
```

---

> [🏠 Главная](README.md) → [🚀 Quick Start](#)
