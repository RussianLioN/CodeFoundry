# Expert Consilium — Архитектура и Интеграция

> **Полное руководство** по системе экспертных дебатов в CodeFoundry

---

## Обзор

**Expert Consilium** — это систематический метод анализа сложных технических решений через структурированные дебаты между 13 виртуальными экспертами. Система интегрирована в CodeFoundry как команда `/expert-consilium`.

## Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                     User Request                            │
│         "Should I adopt microservices architecture?"         │
└─────────────────────────────┬───────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  Expert Consilium Skill                     │
│  .claude/skills/expert-consilium.md (~450 lines)            │
└─────────────────────────────┬───────────────────────────────┘
                              ↓
         ┌────────────────────┴────────────────────┐
         ↓                                          ↓
┌──────────────────┐                    ┌──────────────────┐
│  Problem         │                    │  Expert          │
│  Definition      │                    │  Selection       │
│  - Context       │                    │  - All 13        │
│  - Criteria      │                    │  - Filtered      │
└──────────────────┘                    └──────────────────┘
         └────────────────────┬────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              Parallel Expert Analysis (13 agents)           │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐               │
│  │ Architect  │ │ DevOps     │ │ SRE        │               │
│  │ (1.5x)     │ │ (4-6)      │ │ (7-9)      │               │
│  └────────────┘ └────────────┘ └────────────┘               │
│                                                              │
│  Each expert receives:                                       │
│  - Problem statement                                         │
│  - Context (code, configs)                                   │
│  - Role-specific perspective                                 │
│  - Output format (support/oppose/neutral)                    │
└─────────────────────────────┬───────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Debate Synthesis                           │
│  Moderator agent analyzes:                                   │
│  - Consensus level (unanimous/strong/majority/split)        │
│  - Supporter/opponent counts                                 │
│  - Key concerns                                              │
│  - Recommended action                                        │
│  - Confidence score                                          │
└─────────────────────────────┬───────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Report Generation                         │
│  templates/expert-consilium-template.md                     │
│  → docs/analysis/{timestamp}-consilium-{topic}.md          │
└─────────────────────────────┬───────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Summary Presentetion                      │
│  - Consensus: X/13 experts                                   │
│  - Recommendation: Action                                    │
│  - Confidence: 0.XX                                          │
│  - Report location                                           │
└─────────────────────────────────────────────────────────────┘
```

## Компоненты системы

### 1. Skill (.claude/skills/expert-consilium.md)

**Назначение:** Основная логика экспертных дебатов

**Ключевые элементы:**
- Контракты (input/output)
- Алгоритм (4 фазы)
- Профили 13 экспертов
- Матрицы решений
- Обработка ошибок

**Токен-бюджет:** ~2900-4900 токенов за полный анализ

### 2. Command (.claude/commands/expert-consilium.md)

**Назначение:** Пользовательский интерфейс

**Опции:**
```bash
/expert-consilium [OPTIONS] <problem-statement>

Options:
  --experts    all | architect,devops,sre,...
  --format     report | summary | debate
  --output     path/to/report.md
  --timeout    seconds per expert
  --consensus  unanimous | strong | majority | any
```

### 3. Template (templates/expert-consilium-template.md)

**Назначение:** Шаблон генерации отчётов

**Секции:**
- Executive Summary
- Expert Positions
- Debate Synthesis
- Risk Assessment
- Action Plan
- Success Criteria

### 4. Quick Reference (docs/agents/expert-consilium.quick.md)

**Назначение:** Быстрая справка для пользователей

**Содержит:**
- Когда использовать
- 13 экспертов (кратко)
- Примеры запуска
- Стоимость (токены/время)

### 5. Examples (docs/examples/expert-consilium-example.md)

**Назначение:** Реальные примеры использования

**Примеры:**
1. Параллелизация quality gates
2. Миграция Bash → Python
3. Интеграция Agent Teams
4. Make vs npm scripts

## Интеграция с CodeFoundry

### Связь с @ref pattern

```
CodeFoundry Architecture:
  CLAUDE.md (hub)
    ↓ @ref
  P0 files (session-init, git-sync)
    ↓ @ref
  P1 files (modes, support)
    ↓ @ref
  P2 files (agents, skills)

Expert Consilium Integration:
  CLAUDE.md
    ↓ @ref
  docs/agents/expert-consilium.quick.md (P2)
    ↓ @ref
  .claude/skills/expert-consilium.md (implementation)
  .claude/commands/expert-consilium.md (interface)
```

### Связь с Agent Teams

```
Agent Teams (existing):
  - Parallel execution (2-5 agents)
  - Sequential workflows
  - Safe mode (backup/rollback)

Expert Consilium (new):
  - Expert debate (13 agents)
  - Synthesis-driven decisions
  - Report generation

Synergy:
  Agent Teams → Execution
  Expert Consilium → Planning
```

**Пример workflow:**
```bash
# 1. Plan with Expert Consilium
/expert-consilium "Should I parallelize quality gates?"
→ Recommendation: Proceed with safeguards

# 2. Execute with Agent Teams
/agent-teams-parallel "Update docs in 4 parallel agents"
→ Execution with backup-coordinator

# 3. Validate
/cf-health
→ Health check confirms success
```

## Экспертные панели

### Архитектура (1-3)
| Эксперт | Вес | Специализация |
|---------|-----|---------------|
| Solution Architect | 1.5x | System design, patterns, trade-offs |
| Docker Engineer | 1.0x | Container architecture |
| Unix Script Expert | 1.0x | Bash/Zsh scripting |

### DevOps & Automation (4-6)
| Эксперт | Вес | Специализация |
|---------|-----|---------------|
| DevOps Engineer | 1.0x | Automation, tooling |
| CI/CD Architect | 1.0x | Pipeline design |
| GitOps Specialist | 1.0x | GitOps 2.0 |

### Infrastructure (7-9)
| Эксперт | Вес | Специализация |
|---------|-----|---------------|
| IaC Expert | 1.0x | Infrastructure as Code |
| Backup Specialist | 1.0x | Data safety |
| SRE | 1.0x | Production reliability |

### AI & Development (10-13)
| Эксперт | Вес | Специализация |
|---------|-----|---------------|
| AI IDE Expert | 1.0x | Claude Code workflows |
| Prompt Engineer | 1.0x | AI prompt optimization |
| TDD Expert | 1.0x | Test-driven development |
| UAT Engineer | 1.0x | User acceptance testing |

## Уровни консенсуса

| Уровень | Порог | Интерпретация | Действие |
|---------|-------|---------------|----------|
| **Unanimous** | 13/13 | Чёткий лучший путь | Действуйте уверенно |
| **Strong Majority** | 10-12 | Хороший путь, мин. риски | С мониторингом |
| **Majority** | 7-9 | Валидный путь, заметные риски | С safeguards |
| **Split** | 4-6 vs 4-6 | Trade-offs, контекст-зависимость | Требуется решение |
| **No Consensus** | <4 | Высокая неопределённость | Отклонить или собрать данные |

## Use Cases

### ✅ Идеально для Expert Consilium

| Сценарий | Почему |
|----------|--------|
| Архитектурные решения | Много перспектив, trade-offs |
| Выбор технологического стека | Каждый эксперт имеет свой взгляд |
| Миграция инфраструктуры | Высокий риск, нужен consensus |
| Изменения в CI/CD | DevOps + SRE input критичен |
| Оптимизация производительности | TDD + SRE + Architect |

### ❌ Не подходит

| Сценарий | Почему |
|----------|--------|
| Простые баг-фиксы | Overkill, используйте agent |
| Очевидные изменения | Единогласие не нужно |
| 2-3 файловых обновления | Напрямую через Edit |
| Срочные hotfix | Слишком медленно (~2-3 мин) |

## Token Cost

| Анализ | Токены | Время | Стоимость* |
|--------|--------|-------|------------|
| Все 13 экспертов | 3000-5000 | 2-3 мин | ~$0.15-0.25 |
| 8 экспертов (фильтр) | 2000-3500 | 1-2 мин | ~$0.10-0.18 |
| 3-5 экспертов | 1000-2000 | 1 мин | ~$0.05-0.10 |

*При $0.05 per 1K tokens (Opus 4.6)

## Мониторинг и Observability

### Логи анализов

```bash
.claude/logs/expert-consilium/
├── 2026-02-10-bash-python-migration.jsonl
├── 2026-02-10-agent-teams-integration.jsonl
└── 2026-02-10-quality-gates-parallel.jsonl
```

### Метрики

```json
{
  "timestamp": "2026-02-10T14:30:00Z",
  "problem": "bash-python-migration",
  "experts": 13,
  "consensus": "majority",
  "confidence": 0.72,
  "tokens_used": 4200,
  "duration_sec": 145,
  "recommendation": "hybrid-approach"
}
```

## Best Practices

### 1. Чёткая формулировка проблемы

❌ Плохо:
```
Что делать с этим кодом?
```

✅ Хорошо:
```
Should I refactor this 500-line function into modules,
considering 3 developers frequently modify it and
maintenance time has increased 40% in 6 months?
```

### 2. Предоставление контекста

```bash
# Прикрепите файлы
/expert-consilium "Analyze this Docker setup" Dockerfile docker-compose.yml

# Опишите ограничения
/expert-consilium "Adopt microservices?" \
  --context="team: 5 devs, timeline: 3 months, budget: constrained"
```

### 3. Выбор релевантных экспертов

```bash
# Docker вопрос
/expert-consilium --experts=docker-engineer,devops,sre "Is this production-ready?"

# Архитектурное решение
/expert-consilium --experts=solution-architect,iac-expert,gitops "Microservices vs monolith?"
```

## Troubleshooting

### Проблема: Timeout на экспертов

**Symptom:** Некоторые эксперты не ответили за 120 сек

**Solution:**
```bash
# Увеличьте timeout
/expert-consilium --timeout=180 "complex-problem"

# Или уменьшите количество экспертов
/expert-consilium --experts=architect,devops,sre "focused-problem"
```

### Проблема: Нет консенсуса

**Symptom:** Consensus = Split или No Consensus

**Solution:** Это нормально! Используйте отчёт для понимания trade-offs.

```markdown
# Extract from report:
## Trade-offs
| Aspect | Benefit | Cost |
|--------|---------|------|
| Microservices | Scalability | Complexity |
| Monolith | Simplicity | Scalability limit |
```

### Проблема: Слишком много токенов

**Symptom:** Анализ стоит >$0.30

**Solution:**
```bash
# Используйте фильтрацию экспертов
/expert-consilium --experts=architect,devops,sre --format=summary "problem"

# Или краткий формат
/expert-consilium --format=summary "quick-question"
```

## Future Enhancements

### Краткосрочно (1-2 недели)
- [ ] Автоматическое сохранение в `.claude/logs/expert-consilium/`
- [ ] Метрики: consensus distribution, token usage
- [ ] Web UI для просмотра результатов

### Среднесрочно (1-2 месяца)
- [ ] Исторические сравнения: "Как эксперты голосовали в прошлом?"
- [ ] Custom expert panels (определение своих экспертов)
- [ ] Интеграция с CI/CD (автоматические expert reviews)

### Долгосрочно (3-6 месяцев)
- [ ] Machine learning: прогнозирование consensus
- [ ] Expert reputation: веса адаптируются по точности
- [ ] Multi-round debates: эксперты видят аргументы друг друга

---

## Связанные документы

- **Quick Start:** [docs/agents/expert-consilium.quick.md](../agents/expert-consilium.quick.md)
- **Full Skill:** [.claude/skills/expert-consilium.md](../../.claude/skills/expert-consilium.md)
- **Command Reference:** [.claude/commands/expert-consilium.md](../../.claude/commands/expert-consilium.md)
- **Examples:** [docs/examples/expert-consilium-example.md](../examples/expert-consilium-example.md)
- **Template:** [templates/expert-consilium-template.md](../../templates/expert-consilium-template.md)
- **Agent Teams:** [docs/agents/agent-teams.md](../agents/agent-teams.md)
- **Agent Teams Integration:** [docs/reference/agent-teams-integration-plan.md](../reference/agent-teams-integration-plan.md)

---

**Version:** 1.0.0
**Last Updated:** 2026-02-10
**Status:** ✅ Production Ready

---

*Expert Consilium превращает индивидуальные решения в коллективный мудрость. Используйте мудро!*
