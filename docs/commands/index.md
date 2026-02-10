# Commands Index

> **OpenClaw Command Protocol Documentation**
>
> **Версия:** 1.0.0
> **Дата:** 2025-02-05

---

## 📚 Документация

| Документ | Описание |
|----------|----------|
| [PROTOCOL-v1.md](./PROTOCOL-v1.md) | Command Protocol v1.0 Specification |
| [EXAMPLES.md](./EXAMPLES.md) | Примеры команд и ответов |
| [TESTING.md](./TESTING.md) | Руководство по тестированию |

---

## 🎯 Быстрый Старт

### 1. Тест CLI Bridge

```bash
# Тест команды help
echo '{"command":"help"}' | ./server/scripts/claude-wrapper.sh

# Тест команды status
echo '{"command":"status"}' | ./server/scripts/claude-wrapper.sh
```

### 2. Интеграция с Gateway

```typescript
// В gateway.ts
import { executeCommand } from './command-executor';

const response = await executeCommand({
  command: 'create_project',
  params: { name: 'my-app', archetype: 'web-service' }
});
```

---

## 📋 Список Команд

| Команда | Описание | Статус |
|---------|----------|--------|
| `create_project` | Создать новый проект | ✅ MVP |
| `status` | Статус системы | ✅ MVP |
| `help` | Показать справку | ✅ MVP |
| `deploy` | Деплой проекта | 🔄 Phase 2 |
| `logs` | Просмотреть логи | 🔄 Phase 2 |
| `test` | Запустить тесты | 🔄 Phase 2 |

---

## 🔗 Связанные Документы

- [OpenClaw Orchestrator Architecture](../OPENCLAW-ORCHESTRATOR-ARCHITECTURE.md)
- [Remote Testing Architecture](../remote-testing/ARCHITECTURE.md)
- [Experts Opinions](../experts-opinions-openclaw-orchestrator.md)

---

**Версия:** 1.0.0
**Статус:** ACTIVE
