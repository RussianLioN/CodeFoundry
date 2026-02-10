> [🏠 Главная](../README.md) → **🐚 Shell Aliases**

---
# Shell Aliases для CodeFoundry

> 📚 Documentation → **Shell Aliases**
> 🎯 Purpose: Быстрые команды для работы с CodeFoundry

---

## 🚀 Установка

### Шаг 1: Выберите ваш shell

```bash
# Проверить какой shell используется по умолчанию
echo $SHELL

# Если /bin/zsh → редактируйте ~/.zshrc
# Если /bin/bash → редактируйте ~/.bashrc
```

### Шаг 2: Добавьте alias

Откройте ваш конфигурационный файл (`~/.zshrc` или `~/.bashrc`) и добавьте:

```bash
# ═════════════════════════════════════════════════════════════════════════
# CodeFoundry Aliases
# ═════════════════════════════════════════════════════════════════════════

# Git sync перед AI сессией
alias ai-start='git fetch origin && git status && echo "✅ Ready for AI session"'

# Git status с расширенным выводом
alias ai-status='git status && git log -1 --oneline'

# Quick commit для сессии
alias ai-commit='git add -u && git commit -m "[Session] Update" && git push'

# Quality gates
alias ai-check='make gate-blocking'

# Pull latest changes
alias ai-sync='git pull origin main'

# Stash текущие изменения
alias ai-stash='git stash save "AI session WIP"'

# Apply last stash
alias ai-unstash='git stash pop'

# Show last commit
alias ai-last='git log -1 --stat'

# Show changed files in last commit
alias ai-files='git diff-tree --no-commit-id --name-only -r HEAD'
```

### Шаг 3: Примените изменения

```bash
# Перезагрузите конфигурацию
source ~/.zshrc    # для zsh
# или
source ~/.bashrc   # для bash
```

---

## 📋 Использование

### Начало сессии

```bash
# Синхронизировать репозиторий перед началом работы
ai-start

# Ожидаемый вывод:
# 🔄 Git статус: clean (или dirty/behind)
# ✅ Ready for AI session
```

### Проверка статуса

```bash
# Посмотреть текущий статус
ai-status

# Ожидаемый вывод:
# On branch main
# Your branch is up to date with 'origin/main'
# nothing to commit, working tree clean
# abc1234 [commit message]
```

### Сохранение прогресса

```bash
# Быстрый commit + push
ai-commit

# Ожидаемый вывод:
# [main abc1234] [Session] Update
# 3 files changed, 15 insertions(+), 2 deletions(-)
```

### Синхронизация

```bash
# Pull latest changes
ai-sync

# Ожидаемый вывод:
# Updating abc1234..def5678
# Fast-forward
#  files/file.md | 10 +++++-----
#  1 file changed, 5 insertions(+), 5 deletions(-)
```

---

## 🔧 Расширенные alias (опционально)

```bash
# ═════════════════════════════════════════════════════════════════════════
# Advanced CodeFoundry Aliases
# ═════════════════════════════════════════════════════════════════════════

# Показать токеныый бюджет файла
alias ai-tokens='wc -m'

# Показать размер файла в строках
alias ai-lines='wc -l'

# Создать новую ветку для сессии
alias ai-branch='git checkout -b session-$(date +%Y%m%d)'

# Слить текущую сессию в main
alias ai-merge='git checkout main && git merge session-$(date +%Y%m%d) && git branch -d session-$(date +%Y%m%d)'

# Показать последние 5 коммитов
alias ai-log='git log -5 --oneline --decorate'

# Отменить последний коммит (сохраняя изменения)
alias ai-undo='git reset --soft HEAD~1'

# Полностью сбросить к последнему коммиту (ОПАСНО!)
alias ai-reset='git reset --hard HEAD && git clean -fd'

# Показать diff последнего коммита
alias ai-diff='git diff HEAD~1'

# Создать tag для milestone
alias ai-tag='git tag -a milestone-$(date +%Y%m%d) -m "Milestone $(date +%Y%m%d)"'

# Push所有 tags
alias ai-push-tags='git push origin --tags'
```

---

## 🎯 Рекомендуемый workflow

### Начало дня

```bash
# 1. Синхронизировать изменения
ai-sync

# 2. Проверить статус
ai-status

# 3. Запустить AI сессию
ai-start
```

### Во время работы

```bash
# Если нужно временно отложить изменения
ai-stash

# Когда готовы продолжить
ai-unstash
```

### Конец сессии

```bash
# 1. Проверить что изменилось
ai-status

# 2. Запустить quality gates (если применимо)
ai-check

# 3. Сохранить прогресс
ai-commit
```

---

## 🐛 Troubleshooting

### Alias не работает после перезагрузки

**Проблема:** Alias не сохраняется после закрытия терминала

**Решение:**
```bash
# Убедитесь что редактируете правильный файл
echo $SHELL  # проверить какой shell

# Добавьте alias в соответствующий файл
# ~/.zshrc для zsh
# ~/.bashrc для bash

# Перезагрузите конфигурацию
source ~/.zshrc  # или source ~/.bashrc
```

### Команда не найдена

**Проблема:** `command not found: ai-start`

**Решение:**
```bash
# Убедитесь что файл конфигурации существует
ls -la ~/.zshrc  # или ~/.bashrc

# Проверьте что alias добавлен в файл
grep "ai-start" ~/.zshrc

# Перезагрузите shell или выполните
exec $SHELL
```

### Git работает неожиданно

**Проблема:** Alias выполняет не то что ожидается

**Решение:**
```bash
# Проверьте определение alias
type ai-start

# Или
alias ai-start

# Убедитесь что нет конфликта с другими alias
```

---

## 📚 Дополнительные ресурсы

- [Git documentation](https://git-scm.com/docs)
- [Shell aliases](https://wiki.archlinux.org/title/command-line_shell#Aliases)
- [@ref: instructions/git-operations.md](../instructions/git-operations.md) — Git операции
- [@ref: CLAUDE.md](../CLAUDE.md) — Основные инструкции

---

> **Last updated:** 2026-02-10
> **Maintainer:** CodeFoundry Team
