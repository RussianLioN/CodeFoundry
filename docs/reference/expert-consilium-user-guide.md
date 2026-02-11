# Expert Consilium — Практическое руководство

> **Готово к использованию!** Полная система экспертных дебатов теперь доступна в CodeFoundry

---

## 🎉 Что создано

За эту сессию была создана полная система **Expert Consilium** для анализа сложных технических решений группой из 13 виртуальных экспертов.

### 📁 Созданные файлы

```
codefoundry/
├── .claude/
│   ├── skills/
│   │   └── expert-consilium.md          # Основная логика (~450 lines)
│   └── commands/
│       └── expert-consilium.md          # CLI интерфейс (~200 lines)
├── docs/
│   ├── agents/
│   │   └── expert-consilium.quick.md    # Быстрая справка
│   ├── examples/
│   │   └── expert-consilium-example.md  # 4 практических примера
│   └── reference/
│       └── expert-consilium-architecture.md  # Полная архитектура
└── templates/
    └── expert-consilium-template.md     # Шаблон отчётов
```

---

## 🚀 Быстрый старт

### Базовое использование

```bash
# Анализ архитектурного решения
/expert-consilium "Should I adopt microservices architecture for this application?"

# Выбор технологии
/expert-consilium "Should I migrate from Bash to Python for automation scripts?"

# Оценка рисков
/expert-consilium "Is this Docker Compose setup production-ready?"
```

### С опциями

```bash
# Только релевантные эксперты
/expert-consilium --experts=devops,sre,docker-engineer "Optimize Docker setup"

# Краткая сводка
/expert-consilium --format=summary "Add TypeScript to project?"

# Высокий консенсус
/expert-consilium --consensus=strong "Parallelize quality gates?"
```

---

## 👥 13 экспертов

### Архитектура (1-3)
1. **Solution Architect** (weight: 1.5x) — System design, patterns
2. **Docker Engineer** — Container architecture
3. **Unix Script Expert** — Bash/Zsh scripting

### DevOps & Automation (4-6)
4. **DevOps Engineer** — Automation, tooling
5. **CI/CD Architect** — Pipeline design
6. **GitOps Specialist** — GitOps 2.0

### Infrastructure (7-9)
7. **IaC Expert** — Infrastructure as Code
8. **Backup Specialist** — Data safety
9. **SRE** — Production reliability

### AI & Development (10-13)
10. **AI IDE Expert** — Claude Code workflows
11. **Prompt Engineer** — AI prompt optimization
12. **TDD Expert** — Test-driven development
13. **UAT Engineer** — User scenarios

---

## 📊 Результат работы

### Формат вывода

```markdown
Expert Consilium Analysis
========================

Problem: Migrate Bash to Python?

Expert Positions:
  ✅ Support (7/13): solution-architect, devops-engineer, tdd-expert, ...
  ❌ Oppose (3/13): unix-script-expert, docker-engineer, ...
  ⚖️ Neutral (3/13): iac-expert, ...

Consensus: Majority (7/13)
Recommendation: Hybrid approach
  - Bash for scripts <50 lines
  - Python for scripts >100 lines
  - Case-by-case for 50-100 lines

Confidence: 0.72

Key Concerns:
1. Team familiarity (UAT Engineer)
2. Docker image size (Docker Engineer)
3. Production debugging (SRE)

Report saved: docs/analysis/2026-02-10-consilium-bash-python.md
```

### Сохраняемый отчёт

Полный отчёт сохраняется в `docs/analysis/{timestamp}-consilium-{topic}.md` со следующими секциями:

- Executive Summary
- Expert Positions (подробно)
- Debate Synthesis
- Risk Assessment
- Action Plan
- Success Criteria
- Appendix

---

## 💰 Стоимость

| Эксперты | Токены | Время | Стоимость |
|----------|--------|-------|-----------|
| 13 (все) | 3000-5000 | 2-3 мин | ~$0.15-0.25 |
| 8 (фильтр) | 2000-3500 | 1-2 мин | ~$0.10-0.18 |
| 3-5 | 1000-2000 | 1 мин | ~$0.05-0.10 |

*При $0.05 per 1K tokens (Opus 4.6)

---

## ✅ Когда использовать

| ✅ Идеально | ❌ Не подходит |
|-------------|----------------|
| Архитектурные решения | Простые баг-фиксы |
| Выбор технологий | Очевидные изменения |
| Оценка рисков | Срочные hotfix |
| Trade-off анализ | 2-3 файловых обновления |

---

## 📚 Документация

| Документ | Описание |
|----------|----------|
| [expert-consilium.quick.md](../agents/expert-consilium.quick.md) | Быстрая справка ⭐ |
| [expert-consilium.md](../../.claude/skills/expert-consilium.md) | Полная спецификация skill |
| [expert-consilium.md](../../.claude/commands/expert-consilium.md) | Справка по команде |
| [expert-consilium-example.md](../examples/expert-consilium-example.md) | 4 практических примера |
| [expert-consilium-architecture.md](expert-consilium-architecture.md) | Архитектура и интеграция |

---

## 🔄 Интеграция с Agent Teams

Expert Consilium идеально дополняет существующие Agent Teams:

```
Planning Phase:
  /expert-consilium "Should I do X?"
  → Recommendation: Yes with safeguards

Execution Phase:
  /agent-teams-parallel "Execute X with 4 agents"
  → Results

Validation Phase:
  /cf-health
  → Health check
```

**Пример из реального проекта:**

```bash
# 1. Planning: Expert Consilum recommended Agent Teams integration
/expert-consilium "Integrate Agent Teams into CodeFoundry?"
→ Consensus: Unanimous (11/13)
→ Confidence: 0.91

# 2. Execution: Agent Teams created the integration plan
# (См. docs/reference/agent-teams-integration-plan.md)

# 3. Validation: System is ready for use
/cf-health
→ All systems operational
```

---

## 🎓 Примеры из документации

### Пример 1: Параллелизация quality gates

**Проблема:** `quality-gates.sh` работает 45 сек последовательно

**Expert Consilium:**
```
/expert-consilium "Should I parallelize quality-gates.sh?"
```

**Результат:**
- ✅ Strong majority (8/13 support)
- Рекомендация: Proceed with backup-coordinator
- Уверенность: 0.78
- Mitigations: Circuit breaker, file locking

**Итог:** ✅ ПАРАЛЛЕЛИЗАЦИЯ с safeguards

### Пример 2: Миграция Bash → Python

**Проблема:** ~20 bash scripts, 2000 lines total

**Expert Consilium:**
```
/expert-consilium "Migrate automation from Bash to Python?"
```

**Результат:**
- ⚠️ Split (6 support, 4 oppose, 3 neutral)
- Рекомендация: Hybrid approach
- Уверенность: 0.68

**Decision framework:**
| Script Type | Use Bash | Use Python |
|-------------|----------|------------|
| <50 lines | ✅ Yes | ❌ No |
| >100 lines | ❌ No | ✅ Yes |
| 50-100 lines | ⚠️ Maybe | ⚠️ Case-by-case |

**Итог:** ⚠️ ГИБРИДНЫЙ ПОДХОД

### Пример 3: Интеграция Agent Teams

**Проблема:** CodeFoundry + Agent Teams = 2-5x token cost?

**Expert Consilium:**
```
/expert-consilium "Integrate Agent Teams? Concern: token cost vs @ref optimization"
```

**Результат:**
- ✅ Unanimous (11/13 full support, 2 cautious)
- Рекомендация: Full integration, phased approach
- Уверенность: 0.91

**Implementation plan:** 6 phases, 6-8 weeks

**Итог:** ✅ НЕМЕДЛЕННО НАЧАТЬ ИНТЕГРАЦИЮ

---

## 🛠️ Tips & Tricks

### 1. Чёткая формулировка

❌ Плохо:
```
Что делать с этим кодом?
```

✅ Хорошо:
```
Should I refactor this 500-line function into modules,
considering 3 developers frequently modify it and
maintenance time increased 40% in 6 months?
```

### 2. Предоставляйте контекст

```bash
# Прикрепите файлы
/expert-consilium "Analyze this Docker setup" Dockerfile docker-compose.yml

# Опишите ограничения
/expert-consilium "Adopt microservices?" \
  --context="team: 5 devs, timeline: 3 months, budget: constrained"
```

### 3. Выбирайте экспертов

```bash
# Docker вопрос
/expert-consilium --experts=docker-engineer,devops,sre "Production-ready?"

# Архитектура
/expert-consilium --experts=solution-architect,iac-expert,gitops "Microservices?"
```

---

## 🚨 Troubleshooting

| Проблема | Решение |
|----------|---------|
| Timeout на экспертов | `--timeout=180` или меньше экспертов |
| Нет консенсуса | Нормально! Используйте trade-offs из отчёта |
| Слишком дорого | `--experts=3-5` или `--format=summary` |

---

## 🎯 Следующие шаги

### Попробуйте сейчас!

```bash
# Анализ текущего проекта
/expert-consilium "Should I add TypeScript to this project?"

# Инфраструктурный вопрос
/expert-consilium --experts=devops,sre,iac "Is CI/CD setup optimal?"

# Архитектурное решение
/expert-consilium "Should I extract this module to a microservice?"
```

### Изучите примеры

```bash
# Примеры из реального проекта
cat docs/examples/expert-consilium-example.md
```

### Интегрируйте в workflow

```bash
# Planning phase → Expert Consilium
/expert-consilium "Should I implement X?"

# Execution phase → Agent Teams
/agent-teams-parallel "Implement X with 4 agents"

# Validation phase → Health check
/cf-health
```

---

## 📊 Статистика системы

- **Эксперты:** 13 domain experts
- **Линий кода:** ~1500 (skill + command + template)
- **Документация:** ~2500 lines
- **Примеры:** 4 практических кейса
- **Готовность:** ✅ Production Ready

---

## 🙏 Благодарности

Система Expert Consilium создана на основе:

1. **CodeFoundry Agent Teams** — базовая архитектура мульти-агентных систем
2. **Agent Teams Integration Plan** — проверенная методология интеграции
3. **13 domain experts** — виртуальные эксперты с уникальными перспективами

---

**Version:** 1.0.0
**Status:** ✅ Ready for use
**Last Updated:** 2026-02-10

---

*Expert Consilium превращает индивидуальные решения в коллективную мудрость. Используйте ответственно!*
