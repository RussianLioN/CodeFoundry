> [🏠 Главная](../README.md) → **🧪 Testing**

---
# 🧪 Обязательный Testing Workflow

> **MANDATORY INSTRUCTION — MUST FOLLOW BEFORE EVERY COMMIT**
>
> **Версия:** 1.0.0
> **Дата:** 2025-02-05
> **Статус:** ОБЯЗАТЕЛЬНЫЙ (MANDATORY)

---

## 🚨 КРИТИЧЕСКОЕ ПРАВИЛО

```
┌─────────────────────────────────────────────────────────────┐
│  🚨 НИКОГДА не делайте commit БЕЗ запуска тестов!           │
│                                                              │
│  Tests written ≠ Tests executed                             │
│  Code looks good ≠ Code works                               │
│  Pre-commit passed ≠ Full validation                         │
│                                                              │
│  🚨 ВСЕГДА доводите тестирование до ПОЛНОГО ВЫПОЛНЕНИЯ!   │
│                                                              │
│  Partial testing ≠ Complete validation                      │
│  Local tests passed ≠ Remote tests passed                   │
│  Unit tests OK ≠ Integration tested                         │
│                                                              │
│  ⚠️ НЕ ПЕРЕХОДИТЕ К ДРУГИМ ЗАДАЧАМ,                     │
│     ПОКА ВСЕ ТЕСТЫ НЕ ПРОЙДЕНЫ!                            │
└─────────────────────────────────────────────────────────────┘
```

**🚨 GOLDEN RULE (Session #12 Lesson):**

> **"Сначала закончи тестирование ПОЛНОСТЬЮ, потом переходи к другим задачам"**

**Что это значит:**
1. ✅ Unit tests (local) → ALL must pass
2. ✅ Integration tests (if applicable) → ALL must pass
3. ✅ Remote testing (ainetic.tech) → ALL must pass
4. ✅ Manual verification → Result confirmed
5. ✅ ТОЛЬКО ПОСЛЕ ЭТОГО → git commit

**❌ ЗАПРЕЩЕНО:**
- ❌ "Тесты прошли локально, закоммичу, remote потом" → **НЕЛЬЗЯ!**
- ❌ "Unit tests ok, integration потом" → **НЕЛЬЗЯ!**
- ❌ "Закончим быстрее, протестируем в следующей сессии" → **НЕЛЬЗЯ!**

**✅ ДОПУСТИМО:**
- ✅ Полное тестирование → git commit → следующая задача
- ✅ Все тесты pass → amending commit → push
- ✅ Remote testing fail → fix → retest → commit

---

## 🔍 Remote Discovery (MANDATORY FIRST STEP)

**🚨 ПЕРЕД ЛЮБЫМ SSH ОПЕРАЦИЕЙ — ЧИТАЙ ЭТОТ ФАЙЛ:**

> **"Проблема: Каждый раз ищем где что лежит вместо работы"**
>
> **Lesson from Session #11: "Remote paths discovery repeats every session"**

**📖 Mandatory Artifact:** [@ref: docs/REMOTE-PATHS.md](./REMOTE-PATHS.md)

This document contains the **Single Source of Truth** for all remote paths:
- ✅ Git repository location
- ✅ Workspace directory
- ✅ Scripts location
- ✅ Docker compose files
- ✅ Logs directory
- ✅ Environment variables

**When to read (MANDATORY):**
- ✅ BEFORE every SSH command
- ✅ BEFORE remote testing
- ✅ BEFORE deployment
- ✅ BEFORE running scripts on remote

**Quick checklist (before SSH):**
```
□ Load REMOTE-PATHS.md
□ Use variables from file
□ NEVER hardcode paths
□ Update if paths change
```

**Real-world impact:** Session #11 — 5+ minutes wasted on "where is the file?"

---

## 📋 Обязательный Workflow (ДОЛЖЕН ВЫПОЛНЯТЬСЯ КАЖДЫЙ РАЗ)

### Phase 1: Pre-Commit Validation

**✅ Автоматические проверки (pre-commit hook):**
```bash
# Запускается автоматически при git commit
✅ TypeScript compilation
✅ Alpine compatibility (emoji check)
✅ Large file warning
```

**❌ Чего НЕ делает pre-commit hook:**
```bash
❌ Не тестирует bash scripts
❌ Не запускает unit тесты
❌ Не проверяет integration
❌ Не валидирует на target environment
```

---

### Phase 2: Manual Testing (ОБЯЗАТЕЛЬНО!)

**🚨 ЭТАП ОБЯЗАТЕЛЕН ДЛЯ:**
- Bash scripts (.sh)
- Python scripts (.py)
- Docker integration
- CLI tools
- ANY code that affects production

**✅ Чеклист перед коммитом:**

| Проверка | Команда | Статус |
|----------|---------|--------|
| **Syntax check** | `shellcheck script.sh` | ⬜ |
| **Unit tests** | `./test-script.sh` | ⬜ |
| **Integration test** | Запуск на target env | ⬜ |
| **Manual verification** | Проверка результата | ⬜ |

---

## 🔧 Environment-Specific Testing

### Local Development (macOS)

**Что можно тестировать локально:**
- ✅ TypeScript compilation
- ✅ Syntax errors (shellcheck, eslint)
- ✅ Code formatting (prettier)

**Что НЕЛЬЗЯ тестировать локально:**
- ❌ Docker containers (отсутствуют)
- ❌ Linux-specific commands
- ❌ Integration with remote services

---

### Remote Testing (ainetic.tech)

**🚨 ОБЯЗАТЕЛЬНО ДЛЯ:**
- Docker containers
- CLI Bridge scripts
- Integration tests
- E2E scenarios

**Workflow:**
```bash
# 1. Синхронизировать код
ssh ainetic.tech "cd /workspace && make sync"

# 2. Скопировать новые файлы
scp server/scripts/claude-wrapper.sh ainetic.tech:/workspace/server/scripts/

# 3. Установить зависимости (если нужно)
ssh ainetic.tech "apk add --no-cache jq"

# 4. Запустить тесты
ssh ainetic.tech "cd /workspace && ./server/scripts/test-commands.sh"

# 5. Проверить результат
# Если ✅ → можно коммитить
# Если ❌ → исправить → повторить с 1
```

---

## 📊 Testing Matrix

| Тип кода | Local Tests | Remote Tests | Обязательно |
|----------|-------------|--------------|-------------|
| TypeScript | ✅ tsc | ❌ | Да |
| Bash scripts | ✅ shellcheck | ✅ execution | **ДА** |
| Python scripts | ✅ pylint | ✅ execution | **ДА** |
| Docker configs | ❌ | ✅ docker build | **ДА** |
| CLI tools | ❌ | ✅ run | **ДА** |

---

## 🚫 Forbidden Patterns

### ❌ Pattern 1: "Write tests, don't run them"

```bash
# НЕПРАВИЛЬНО
echo '{"command":"help"}' > test-request.json
# ...写出测试代码但从未运行
git commit -m "feat: add CLI Bridge"
```

### ❌ Pattern 2: "Pre-commit passed, must be good"

```bash
# НЕПРАВИЛЬНО
git add .
git commit
# Pre-commit: ✅ PASSED
# → Считать что всё хорошо? НЕТ!
# → Баш скрипты не протестированы!
```

### ❌ Pattern 3: "Will test on production"

```bash
# НЕПРАВИЛЬНО
git push origin main
ssh prod "docker-compose up -d"
# → Тестирование на prod = катастрофа
```

---

## ✅ Correct Pattern

```bash
# ПРАВИЛЬНЫЙ WORKFLOW

# 1. Написать код
vim server/scripts/claude-wrapper.sh

# 2. Написать тесты
vim server/scripts/test-commands.sh

# 3. Локальная валидация (syntax only)
shellcheck server/scripts/claude-wrapper.sh

# 4. Синхронизировать на remote
git add -A
git commit -m "WIP: add CLI Bridge (not tested yet)"
git push

# 5. Remote testing
ssh ainetic.tech "cd /workspace && make sync"
ssh ainetic.tech "cd /workspace && ./server/scripts/test-commands.sh"

# 6. Если тесты pass → amend commit
git commit --amend -m "feat: add CLI Bridge (tests passed)"

# 7. Если тесты fail → исправить → повторить с 4
```

---

## 📋 Quick Reference Card

### 🚨 ЗОЛОТОЕ ПРАВИЛО (Session #12):

> **"Сначала закончи тестирование ПОЛНОСТЬЮ, потом переходи к другим задачам"**

**Workflow:**
1. Unit tests (local) → ALL pass
2. Integration tests → ALL pass
3. Remote testing → ALL pass
4. Manual verification → Confirmed
5. **ТОЛЬКО ПОСЛЕ ЭТОГО** → git commit → следующая задача

**❌ ЗАПРЕЩЕНО:**
- ❌ "Тесты прошли локально, закоммичу" → В remote setup!
- ❌ "Unit ok, integration потом" → Заканчивай интеграцию!
- ❌ "Протестирую в следующей сессии" → Заканчивай сейчас!

### Перед каждым коммитом спроси себя:

```
□ Я запускал тесты? (Да/Нет)
□ Тесты прошли успешно? (Да/Нет)
□ Я протестировал на target environment? (Да/Нет)
□ Я вручную проверил результат? (Да/Нет)
□ ВСЕ тесты прошли? (Да/Нет) ← НОВОЕ!

Если ВСЕ "Да" → Можно коммитить → Следующая задача
Если ХОТЯ БЫ ОДИН "Нет" → НЕЛЬЗЯ коммитить → Заканчивай тестирование
```

---

## 🔗 Связанные Документы

- [Troubleshooting Methodology](./lessons/troubleshooting-methodology.md) — Систематический подход к исправлению ошибок
- [Remote Testing Architecture](./remote-testing/ARCHITECTURE.md) — Инфраструктура ainetic.tech
- [Command Protocol v1.0](./commands/PROTOCOL-v1.md) — Спецификация протокола

---

## 📚 Lessons Learned

**Session #11 (2025-02-05):**
- ❌ Написали test-commands.sh но НЕ запустили
- ❌ Сделали commit БЕЗ валидации работоспособности
- ✅ Эксперты (4.4/10): "Недопустимо для продакшена"
- ✅ Урок создан: TESTING.md

**Запомнить:**
> "Tests written without execution are worse than no tests at all.
>  They give a false sense of security."

---

**Версия:** 1.0.0
**Статус:** MANDATORY — ОБЯЗАТЕЛЬНО К ИСПОЛНЕНИЮ
**Автор:** Claude Code (Lesson from Session #11)
**Дата:** 2025-02-05

---

## 🚨 Enforcement

**Этот документ является MANDATORY:**

1. ✅ Read before EVERY commit
2. ✅ Follow for EVERY code change
3. ✅ Update when finding new gaps
4. ❌ NEVER skip testing step

**Violations detected during retrospective:**
- ⚠️ Session #11: Tests not executed before commit
- ⚠️ Root cause: No mandatory testing instruction
- ✅ Fixed: This document created

**Future violations:**
- Will be documented in SESSION.md
- Will trigger expert review
- Will require process improvement
