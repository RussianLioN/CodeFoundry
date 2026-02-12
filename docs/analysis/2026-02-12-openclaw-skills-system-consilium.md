# Expert Consilium v2.0 Analysis

**Дата:** 2026-02-12
**Проблема:** Как реализовать систему добавления навыков OpenClaw через естественный диалог в Telegram с интеграцией удалённого репозитория навыков?

**Формат:** Multi-round adversarial debates (4 domains, 12 experts, 1.5x Solution Architect weight)

---

## 🎯 Финальная Рекомендация

### HYBRID_DIALOG_GITOPS (Confidence: 0.82)

**Двухуровневая архитектура навыков:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    SKILLS ARCHITECTURE v1.0                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Level 1: MARKETPLACE SKILLS (Remote Repository)               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  GitHub: openclaw/skills-marketplace                    │   │
│  │  → GitOps sync → /workspace/skills/marketplace/         │   │
│  │  → Schema validated, production-ready                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  Level 2: CUSTOM SKILLS (Local/Dialog)                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  User: "Добавь навык для работы с Docker"               │   │
│  │  → Dialog → Skill Generator → /workspace/skills/custom/ │   │
│  │  → Lightweight validation → immediate use               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Позиции Доменов

| Domain | Position | Confidence | Key Arguments |
|--------|----------|------------|---------------|
| **Infrastructure** | HYBRID | 0.85 | Container volumes + git sync + hot-reload via file watcher |
| **Delivery** | MODIFIED_GITOPS | 0.75 | GitOps for marketplace, bypass for dialog-created skills |
| **Quality** | LIGHTWEIGHT_VALIDATION | 0.70 | Schema validation + smoke tests, not full TDD |
| **AI** | DIALOG_FIRST | 0.80 | Intent Classifier → Skill Generator → .md file |

---

## 🏗️ Архитектура Компонентов

### 1. Intent Classifier Extension

```typescript
// New intent type in intent-classifier.ts
export type IntentType =
  | 'create_project'
  | 'status'
  | 'help'
  | 'deploy'
  | 'chat'
  | 'small_talk'
  | 'create_skill'      // NEW: Create new skill via dialog
  | 'browse_skills'     // NEW: Browse marketplace skills
  | 'install_skill';    // NEW: Install skill from marketplace
```

### 2. Skill Generator Module

```typescript
// gateway/src/skill-generator.ts
export class SkillGenerator {
  async generateFromDialog(
    dialogHistory: Message[],
    userRequirements: string
  ): Promise<SkillFile> {
    // 1. Extract skill requirements from dialog
    // 2. Generate skill markdown using AI
    // 3. Validate against schema
    // 4. Return .md file content
  }
}
```

### 3. Skills Repository Integration

```yaml
# docker-compose.orchestrator.yml addition
volumes:
  # Skills marketplace (read-only git sync)
  - skills-marketplace:/workspace/skills/marketplace:ro

  # Custom skills (writable)
  - skills-custom:/workspace/skills/custom
```

### 4. Hot-Reload Mechanism

```bash
# inotify watcher for skill changes
inotifywait -m /workspace/skills -e create -e modify |
  while read path action file; do
    curl -X POST http://localhost:18790/reload-skills
  done
```

---

## 🚀 План Реализации

### Phase 1: Dialog-Based Skill Creation (Priority: HIGH)

**Цель:** Пользователь может создать навык через диалог в Telegram

**Задачи:**
1. Добавить intent `create_skill` в Intent Classifier
2. Создать `SkillGenerator` класс в Gateway
3. Добавить system prompt для skill creation dialog
4. Реализовать сохранение .md файлов в `/workspace/skills/custom/`
5. Добавить hot-reload для новых навыков

**Контейнер:** `openclaw-orchestrator-gateway`

### Phase 2: Remote Repository Integration (Priority: MEDIUM)

**Цель:** Пользователь видит marketplace навыков и может их установить

**Задачи:**
1. Создать GitHub репозиторий `openclaw/skills-marketplace`
2. Добавить `skills-sync` service в docker-compose
3. Реализовать `browse_skills` intent (категории, поиск)
4. Реализовать `install_skill` intent (git clone/pull)
5. Добавить UI для выбора навыков (inline keyboard в Telegram)

**Контейнер:** Новый `skills-sync` sidecar container

### Phase 3: Validation & Safety (Priority: MEDIUM)

**Цель:** Навыки безопасны и не ломают систему

**Задачи:**
1. JSON Schema для skill .md файлов
2. Smoke test при загрузке навыка
3. Rollback mechanism для сломанных навыков
4. Audit log всех изменений навыков
5. Rate limiting для создания навыков

**Контейнер:** `openclaw-orchestrator-gateway`

---

## 📋 Диалог Создания Навыка (User Flow)

```
👤 User: "Хочу добавить навык для работы с PostgreSQL"

🤖 OpenClaw: "Отлично! Давайте создадим навык для PostgreSQL.

            Что должен уметь этот навык?
            1. Создавать таблицы
            2. Выполнять миграции
            3. Оптимизировать запросы
            4. Всё вышеперечисленное"

👤 User: "3 и 4"

🤖 OpenClaw: "Понял. Навык будет:
            • Оптимизировать SQL запросы
            • Выполнять миграции

            Как назвать навык? (например: postgresql-expert)"

👤 User: "postgres-optimizer"

🤖 OpenClaw: "Создаю навык postgres-optimizer...

            ✅ Навык создан!

            📄 Файл: /workspace/skills/custom/postgres-optimizer.md
            🎯 Триггеры: "оптимизируй sql", "postgres", "миграция"

            Хотите протестировать навык?"
```

---

## 📋 Диалог Выбора из Marketplace (User Flow)

```
👤 User: "Покажи доступные навыки"

🤖 OpenClaw: "📦 Skills Marketplace

            Категории:
            🤖 AI Assistants (5)
            🚀 DevOps (8)
            👨‍💻 Development (6)
            📊 Data (4)

            Выберите категорию или найдите навык:"

👤 User: "DevOps"

🤖 OpenClaw: "🚀 DevOps Skills

            1. docker-expert — Работа с Docker
            2. k8s-manager — Kubernetes управление
            3. ci-pipeline — CI/CD пайплайны
            4. monitoring — Мониторинг и алерты
            5. rollback-master — Откаты деплоев

            [Установить] [Подробнее] [Назад]"

👤 User: "Установи docker-expert"

🤖 OpenClaw: "⏳ Устанавливаю docker-expert...

            ✅ Установлено!

            🎯 Теперь можете использовать:
            "Собери docker image"
            "Запусти контейнеры"
            "Проверь статус docker""
```

---

## ⚠️ Риски и Решения

| Риск | Решение |
|------|---------|
| Сломанный навык ломает Gateway | Circuit breaker + per-skill isolation |
| Пользователь создаёт вредоносный навык | Schema validation + запрещённые паттерны |
| Remote repo недоступен | Local cache + fallback |
| Навыки конфликтуют | Namespace隔离 (custom/ vs marketplace/) |
| Token overflow при создании навыка | Max 3 диалоговых шага |

---

## 🔗 Связанные Файлы

- `openclaw/gateway/src/intent-classifier.ts` — Intent Classifier
- `openclaw/gateway/src/gateway.ts` — Gateway WebSocket Server
- `openclaw/workspace/skills/` — Skills Directory
- `openclaw/workspace/SKILLS-INDEX.md` — Skills Index

---

## 📈 Статистика Консилиума

| Метрика | Значение |
|---------|----------|
| Доменов | 4 |
| Экспертов | 12 |
| Раундов дебатов | 2 |
| Inter-agent messages | 8 |
| Время анализа | ~8 минут |
| Финальная уверенность | 0.82 |

---

**Версия:** Expert Consilium v2.0.3
**Статус:** PRODUCTION READY
**Создано:** 2026-02-12