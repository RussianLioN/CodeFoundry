# Constraints Index

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → **Constraints**

---

## 📋 Описание

Директория содержит детальные ограничения и правила, вынесенные из CLAUDE.md для оптимизации токенов.

**Принцип:** Hub-файл (CLAUDE.md) содержит только ссылки, детали — здесь.

---

## 📁 Содержимое

| Файл | Описание | Приоритет |
|------|----------|-----------|
| [environment.md](./environment.md) | Правила окружения + Node.js/TypeScript operations | P0 |
| [docker.md](./docker.md) | Docker и docker-compose ограничения | P1 |
| [tools.md](./tools.md) | Правила выбора инструментов (Edit vs Bash) | P1 |
| [gitops.md](./gitops.md) | GitOps deployment workflow | P1 |

---

## 🎯 Иерархия Приоритетов

```
P0-BLOCKING: Действие невозможно без этого
├── Environment Detection (ПЕРВЫМ!)
└── Session Initialization

P1-ERROR: Нарушение приведёт к ошибке
├── Docker Constraints (NEVER locally)
├── Git Workflow (all deployments via git push)
└── Tool Selection (Edit for files, Bash for commands)

P2-INFO: Рекомендации
├── Context7 Usage
├── Testing Best Practices
└── Documentation Standards
```

---

## 🔗 Связанные Документы

| Документ | Описание |
|----------|----------|
| [@ref: CLAUDE.md](../../CLAUDE.md) | Hub-файл (ссылается сюда) |
| [@ref: docs/TESTING.md](../../docs/TESTING.md) | Тестирование |
| [@ref: docs/remote-testing/](../../docs/remote-testing/) | Remote testing |

---

> [🏠 Главная](../../README.md) → [📚 Instructions](../README.md) → **Constraints**
