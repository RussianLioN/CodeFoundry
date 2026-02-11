# Expert Consilium — Failure Analysis & Fixes

> **Дата:** 2026-02-10
> **Проблема:** Все 13 экспертов провалились с превышением контекста

---

## 🚨 Проблема

**Ошибка:** `Request input tokens exceeds the model's maximum context length 202750`

**Статистика:**
- Expert 1:  189,321 tokens ❌
- Expert 2:  185,669 tokens ❌
- Expert 3:  203,648 tokens ❌
- Expert 4:  184,776 tokens ❌
- Expert 5:  188,054 tokens ❌
- Expert 6:  202,494 tokens ❌
- Expert 7:  189,321 tokens ❌
- Expert 8:  205,088 tokens ❌
- Expert 9:  206,213 tokens ❌
- Expert 10: 200,998 tokens ❌
- Expert 11: 198,286 tokens ❌
- Expert 12: 199,179 tokens ❌
- Expert 13: 186,652 tokens ❌

**Все 13 экспертов провалились.**

---

## 🔍 Root Cause Analysis

### Причина: Наследование полного контекста сессии

Каждый эксперт получает:
1. **Всю текущую сессию** (~180K tokens)
   - Все предыдущие сообщения
   - Весь созданный код
   - Документацию и примеры

2. **Свой prompt** (~5-10K tokens)
   - Role definition
   - Problem statement
   - Expert-specific instructions

**Итого:** ~180K + 10K = **190K+ tokens** → превышение лимита

### Почему это произошло

В `expert-consilium.md` алгоритм запуска экспертов:

```python
Task(
    subagent_type="general-purpose",
    prompt=f"As {expert}, analyze: {problem}\n{expert_prompt_format}",
    run_in_background=true
)
```

**Проблема:** Каждая задача наследует контекст родительской сессии.

---

## ✅ Решения

### Решение 1: Минимальный контекст (RECOMMENDED)

Изменить prompt для каждого эксперта:

```python
Task(
    subagent_type="general-purpose",
    prompt=f"""You are {expert_name}. Analyze this problem:

PROBLEM:
{problem}

CONTEXT (minimal):
{minimal_context}

Provide:
1. Position (SUPPORT/OPPOSE/NEUTRAL)
2. Arguments FOR (2-3 points)
3. Arguments AGAINST (2-3 points)
4. Confidence (0.0-1.0)

Keep response under 500 tokens.""",
    run_in_background=true,
    # IMPORTANT: Use minimal context only
)
```

**Что убрать:**
- ❌ Role definitions (встроить в prompt)
- ❌ Expert profiles (сократить до 1 строки)
- ❌ Documentation examples
- ❌ Template instructions

### Решение 2: Двухэтапный процесс

**Phase 1: Quick scan** (все 13, haiku, <1000 tokens each)

```python
Task(
    subagent_type="general-purpose",
    model="haiku",  # Cheaper, faster
    prompt=f"Quick analysis: {problem}\nRespond: SUPPORT/OPPOSE/NEUTRAL + 1 sentence",
    run_in_background=true
)
```

**Phase 2: Deep dive** (только релевантные, sonnet)

```python
# После Phase 1:
# Если unanimous → skip Phase 2
# Если split → Phase 2 для dissenting experts
```

### Решение 3: Уменьшить количество экспертов

**Группировка по доменам:**

| Группа | Эксперты | При запуске |
|--------|----------|-------------|
| Infrastructure | Docker, Unix, DevOps, CI/CD, GitOps, IaC, Backup, SRE | 8 |
| Development | TDD, UAT, AI IDE, Prompt Engineer | 4 |
| Architecture | Solution Architect | 1 |

**Оптимизация:**
- Проблемы с инфраструктурой → запускать только группу Infrastructure (8)
- Архитектурные решения → запускать Architecture + Infrastructure (9)
- Вопросы разработки → запускать Development (4)

### Решение 4: Модель haiku для экспертов

```python
Task(
    subagent_type="general-purpose",
    model="haiku",  # 200K context limit instead of 200K (same) but cheaper
    prompt=compact_prompt,
    run_in_background=true
)
```

**Преимущества:**
- ~10x дешевле
- Быстрее
- Достаточно для мнений "за/против"

---

## 🔧 Конкретные изменения в коде

### Изменение 1: Expert prompt template

**Было:**
```python
expert_prompt_format = f"""
You are {expert_name} with expertise in {expertise}.

## Your role
Provide expert analysis...

## Analysis framework
1. Understand...
2. Evaluate...
3. Recommend...

## Response format
{response_format}
"""
```

**Стало:**
```python
expert_prompt = f"""You are {expert}. Analyze: {problem}

Respond in JSON:
{{"position": "SUPPORT|OPPOSE|NEUTRAL", "for": ["arg1", "arg2"], "against": ["arg1"], "confidence": 0.8}}

Keep under 300 tokens."""
```

### Изменение 2: Agent algorithm

**Добавить:**
```python
## CRITICAL: Context budget management

1. **Strip all non-essential context:**
   - Remove: Documentation, examples, templates
   - Keep: Problem statement + expert role (1 line)

2. **Use compact response format:**
   - JSON output (machine-readable)
   - Max 300 tokens per expert

3. **Total budget:**
   - Problem: <1000 tokens
   - Expert prompt: <200 tokens
   - Expected response: <300 tokens
   - **Per expert: <1500 tokens**
```

---

## 📊 Ожидаемые результаты после исправлений

| Метрика | До | После (Solution 1) | После (Solution 2) |
|---------|--------|-------------------|-------------------|
| Tokens per expert | 180K+ | **<2K** | **<1K** (Phase 1) |
| Total tokens (13 experts) | ~2.3M | **<26K** | **<13K** (Phase 1) |
| Стоимость | ~$10-15 | **~$0.10** | **~$0.02** |
| Время | FAIL | **2-3 min** | **1-2 min** |
| Успешность | 0% | **95%+** | **99%+** |

---

## ✅ Action Items

### P0 (Критично)

1. [ ] Обновить `.claude/agents/expert-consilium.md`
   - Изменить prompt template на compact JSON
   - Добавить context budget warnings
   - Убрать verbose instructions

2. [ ] Протестировать с 1 экспертом
   - Проверить токены
   - Убедиться что <200K

3. [ ] Протестировать с 3 экспертами
   - Убедиться что параллельно работают
   - Проверить общее время

### P1 (Оптимизация)

4. [ ] Добавить двухэтапный процесс (optional)
5. [ ] Добавить группировку экспертов по доменам
6. [ ] Добавить флаг `--quick` для haiku mode

---

## 🎯 Recommendation

**Начать с Solution 1 (Minimal Context):**

1. Урезать prompt до минимума (JSON response)
2. Убрать весь неэссенциальный контекст
3. Протестировать с 3 экспертами

**Если работает → масштабировать до 13.**

**Если нет → fallback to Solution 2 (Two-phase).**
