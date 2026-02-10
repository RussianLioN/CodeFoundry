# Expert Consilium — Quick Start

> **Быстрый старт:** Анализ сложных решений группой из 13 экспертов за одну команду

---

## Что это?

**Expert Consilium** — это команда `/expert-consilium`, которая запускает структурированные дебаты между 13 виртуальными экспертами для анализа вашей проблемы и выдачи консолидированной рекомендации.

## Когда использовать?

| ✅ Используйте | ❌ Не используйте |
|----------------|-------------------|
| Архитектурные решения | Простые баг-фиксы |
| Выбор технологий | Очевидные изменения |
| Оценка рисков | Срочные hotfix |
| Trade-off анализ | 2-3 файловых обновления |

## Быстрый запуск

```bash
# Базовый пример
/expert-consilium "Should I migrate from Bash to Python for automation?"

# С выбором экспертов
/expert-consilium --experts=devops,sre,iac "Is this Docker setup production-ready?"

# Краткая сводка
/expert-consilium --format=summary "Should I adopt microservices?"

# Высокий консенсус
/expert-consilium --consensus=strong "Parallelize quality gates?"
```

## 13 экспертов

### Архитектура (1-3)
1. **Solution Architect** — System design (weight: 1.5x)
2. **Docker Engineer** — Containers
3. **Unix Script Expert** — Bash/Zsh

### DevOps (4-6)
4. **DevOps Engineer** — Automation
5. **CI/CD Architect** — Pipelines
6. **GitOps Specialist** — Git-driven ops

### Infrastructure (7-9)
7. **IaC Expert** — Infrastructure as Code
8. **Backup Specialist** — Data safety
9. **SRE** — Production reliability

### AI & Development (10-13)
10. **AI IDE Expert** — Claude Code
11. **Prompt Engineer** — AI instructions
12. **TDD Expert** — Testing
13. **UAT Engineer** — User scenarios

## Результат

```markdown
Expert Consilium Analysis
========================

Problem: Migrate Bash to Python?

✅ Support (7/13): solution-architect, devops, ...
❌ Oppose (3/13): unix-script-expert, ...
⚖️ Neutral (3/13): iac-expert, ...

Consensus: Majority (7/13)
Recommendation: Hybrid — Bash for <50 lines, Python for >100 lines
Confidence: 0.72

Report: docs/analysis/2026-02-10-consilium-bash-python.md
```

## Стоимость

| Эксперты | Токены | Время |
|----------|--------|-------|
| 13 (все) | ~3000-5000 | ~2-3 мин |
| 8 (отбор) | ~2000-3500 | ~1-2 мин |
| 3-5 | ~1000-2000 | ~1 мин |

## Консенсус

| Уровень | Порог | Действие |
|---------|-------|----------|
| Unanimous | 13/13 | Действуйте уверенно |
| Strong | 10-12 | С мониторингом |
| Majority | 7-9 | С safeguards |
| Split/No | <7 | Соберите更多信息 |

## Документация

- **Full docs:** [expert-consilium.md](../../.claude/skills/expert-consilium.md)
- **Command:** [.claude/commands/expert-consilium.md](../../.claude/commands/expert-consilium.md)
- **Examples:** [docs/examples/expert-consilium-example.md](../examples/expert-consilium-example.md)

---

**Version:** 1.0.0 | **Ready to use:** ✅
