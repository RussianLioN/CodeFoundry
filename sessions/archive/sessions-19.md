# Session #19: OpenClaw Orchestrator - Performance & Critical Bug

**Date:** 2026-02-10
**Focus:** Webhook Performance Optimization
**Result:** 🔴 CRITICAL BUG DISCOVERED

---

## Executive Summary

Изучал медленные ответы Telegram Bot, обнаружил и исправил несколько проблем производительности, но в процессе сломал базовую архитектуру OpenClaw Orchestrator.

### Что сделано
✅ Webhook через Traefik настроен
✅ Intent Pre-Classifier добавлен (50% быстрее)
✅ CLI Bridge permission error исправлен
✅ Telegram Bot отвечает на сообщения

### Критическая ошибка
🔴 **Intent Pre-Classifier обходит OpenClaw для свободных сообщений**

**Проблема:** Вместо использования AI для NLP распознавания intent (как задумано в архитектуре), теперь сообщения без явных keywords идут напрямую в free-form chat.

**Пример:**
- "Создай проект myapp" → теперь free-form chat (было: command generation)
- "Какой статус системы?" → теперь free-form chat (было: command generation)

**Влияние:** OpenClaw превратился из оркестратора команд в обычный чат-бот.

---

## Technical Details

### 1. Intent Pre-Classifier (commit `1d4a1aa`)

**Код:** `openclaw/gateway/src/gateway.ts:371-405`

```typescript
const COMMAND_KEYWORDS = [
  'create', 'new', 'созда', 'новый', 'проект',
  'status', 'статус', 'состояни',
  ...
];

const hasCommandIntent = COMMAND_KEYWORDS.some(k => lowerContent.includes(k));

if (!hasCommandIntent) {
  // Direct to free-form chat - BYPASSES OPENCLAW!
  const response = await this.ollama.chat(chatMessages);
  return { type: 'complete', content: response };
}
```

**Проблема:** OpenClaw Command Generator **не вызывается** для сообщений без keywords.

### 2. CLI Bridge Fix (commit `3beba4b`)

**Проблема:** `LOG_FILE=/app/logs/gateway.log` env var наследовался CLI wrapper, вызывая permission denied.

**Решение:** Убрал `LOG_FILE` из docker-compose.orchestrator.yml.

---

## Root Cause Analysis

### Почему Intent Pre-Classifier сломал архитектуру?

**OpenClaw Orchestrator Architecture (правильная):**
```
User Message → CommandGenerator (AI/NLP) → Command Protocol → CLI Bridge → Result
```

**После моей оптимизации (сломанная):**
```
User Message → Pre-classifier (regex) → Free-form chat (AI) → Response
              ↓ (has keywords)
          CommandGenerator → Command Protocol → CLI Bridge → Result
```

**Ключевая ошибка:** Я заменил AI-based NLP на regex keywords, что противоречит самой идее OpenClaw.

---

## Required Fixes

### Option 1: Remove Intent Pre-Classifier
- Плюсы: Восстанавливает архитектуру
- Минусы: Возвращает двойные AI calls для свободного общения

### Option 2: Improve Command Generator System Prompt
- Сделать prompt умнее для обработки свободного текста
- Добавить fallback на free-form chat ТОЛЬКО если не определён intent
- Плюсы: Сохраняет производительность И архитектуру

### Option 3: Hybrid Approach
- Pre-classifier ТОЛЬКО для явных slash команд (/status, /help)
- Всё остальное через Command Generator
- Плюсы: Быстрые slash команды + умная NLP для остального

---

## Deployment Status

```
✅ Gateway: healthy
✅ Webhook: https://ainetic.tech/telegram working
✅ CLI Bridge: fixed
⚠️  OpenClaw: BROKEN - bypassed for free-form messages
```

---

## Next Steps

1. **CRITICAL:** Fix ORCH-007.5 - Choose fix option
2. Update system prompts for better NLP
3. Test with real user scenarios
4. Update documentation with correct architecture

---

## Commits

1. `1d4a1aa` - perf(gateway): add intent pre-classifier ⚠️ BREAKS ARCHITECTURE
2. `3beba4b` - fix(docker): remove LOG_FILE env var
3. `d7a426f` - fix(webhook): add HTTP endpoint for Telegram

---

## Files Modified

- `openclaw/gateway/src/gateway.ts` - Intent pre-classifier added
- `openclaw/docker/docker-compose.orchestrator.yml` - LOG_FILE removed
- `TASKS.md` - ORCH-007.5 added as blocking issue
- `SESSION.md` - Updated with current context
