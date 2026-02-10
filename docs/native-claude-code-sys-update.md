> [🏠 Главная](../README.md) → **⬆️ System Update**

---
# Руководство: установка Claude Code (native) и миграция с npm (macOS + Debian-slim)

**Цель:** поставить нативный Claude Code на macOS и в Debian-slim контейнер, корректно сохранить настройки и **зафиксировать канал обновлений `stable`**, чтобы избежать известной проблемы автообновления на Apple Silicon (установка x86_64 вместо arm64 при `latest`).

**Дата:** 31.01.2026

***

## 0. Важный факт про автообновления (Apple Silicon)

На Apple Silicon (M1/M2/M3) при переключении **Auto-update channel = `latest`** иногда происходит автообновление с установкой **x86_64**-бинарника. Это проявляется предупреждением `CPU lacks AVX support` при запуске и выводом команды `file ~/.local/bin/claude` → `x86_64`.

**Официально подтвержденная настройка:** `autoUpdatesChannel` (значения `"stable"` или `"latest"`). Она хранится в файле `~/.claude/settings.json`.

**Рекомендация для macOS Apple Silicon:** держать `autoUpdatesChannel: "stable"` и при необходимости обновляться вручную до тех пор, пока баг автообновления не будет исправлен разработчиками.

***

## 1. Пререквизиты

### macOS
- `curl`
- `jq` (не обязательно, но удобно для проверки JSON)

Установка `jq` через Homebrew (если есть):
```bash
brew install jq
```

### Linux / Debian-slim контейнер
- `curl` + `ca-certificates`

***

## 2. Где хранятся настройки

- **User settings:** `~/.claude/settings.json` (здесь находится `autoUpdatesChannel`).
- **User data/config:** `~/.claude.json` (авторизация, MCP) и директория `~/.claude/`.
- **Project-level:** `.claude/` в корне репозитория проекта.

***

## 3. Бэкап перед миграцией/переустановкой (macOS/Linux)

Создайте резервную копию пользовательских файлов перед любыми действиями:

```bash
BACKUP_DIR=~/claude-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

# Копируем основные конфиги
cp -f ~/.claude.json "$BACKUP_DIR/" 2>/dev/null || true
cp -rf ~/.claude "$BACKUP_DIR/" 2>/dev/null || true

# Явно копируем settings.json, если он есть
cp -f ~/.claude/settings.json "$BACKUP_DIR/" 2>/dev/null || true

echo "Backup created in: $BACKUP_DIR"
ls -la "$BACKUP_DIR"
```

***

## 4. Миграция с npm на native (macOS/Linux)

### 4.1 Удалить npm-установку (если была)

1. Проверить наличие npm-версии:
```bash
npm list -g | grep -i claude || true
```

2. Удалить найденный пакет (обычно `@anthropic-ai/claude-code`):
```bash
npm uninstall -g @anthropic-ai/claude-code
```

***

## 5. Нативная установка (официальный способ)

Этот скрипт автоматически определяет ОС и архитектуру.

### 5.1 macOS (native)

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

После установки убедитесь, что бинарник находится в `~/.local/bin/claude` и доступен в PATH:
```bash
which claude
```

### 5.2 Linux / Debian (native)

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

***

## 6. Фиксация канала обновлений на stable

Это критически важный шаг для Apple Silicon, чтобы избежать скачивания x86_64 версии.

### 6.1 Установить `stable` в user settings

Целевой файл: `~/.claude/settings.json`

**Проверка текущего значения:**
```bash
# Если установлен jq
jq -r '.autoUpdatesChannel // "latest (default)"' ~/.claude/settings.json 2>/dev/null || echo "File not found or jq missing"
```

**Установка значения `stable`:**

Если файл существует:
```bash
# С использованием jq
tmp=$(mktemp)
jq '.autoUpdatesChannel="stable"' ~/.claude/settings.json > "$tmp" && mv "$tmp" ~/.claude/settings.json
chmod 600 ~/.claude/settings.json
```

Если файла нет или нет `jq` (ручное создание):
```bash
mkdir -p ~/.claude
echo '{ "autoUpdatesChannel": "stable" }' > ~/.claude/settings.json
chmod 600 ~/.claude/settings.json
```

**Повторная проверка:**
```bash
cat ~/.claude/settings.json
```

***

## 7. Проверки корректности (особенно важны на Apple Silicon)

### 7.1 Проверка архитектуры

На macOS Apple Silicon (M1/M2/M3) ожидается **arm64**:
```bash
file ~/.local/bin/claude
```

**Ожидаемый результат:**
- `Mach-O 64-bit executable arm64` (Apple Silicon) — **OK**
- `Mach-O 64-bit executable x86_64` (Intel Mac) — **OK**
- `Mach-O 64-bit executable x86_64` (на Apple Silicon) — **ОШИБКА** (нужна переустановка)

### 7.2 Проверка предупреждения AVX

Запустите:
```bash
claude --version
```

Если появляется строка `warn: CPU lacks AVX support` на чипе M1/M2/M3 — значит установлен x86_64 бинарник через Rosetta 2.

***

## 8. Что делать, если случайно обновились до x86_64 на Apple Silicon

1. Вернуть настройку `stable` в `~/.claude/settings.json` (см. раздел 6).

2. Переустановить `stable` версию поверх текущей:
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

3. Проверить архитектуру заново:
```bash
file ~/.local/bin/claude
```

***

## 9. Debian-slim контейнер: пример Dockerfile

Минимальный Dockerfile для запуска Claude Code в контейнере.

```dockerfile
FROM debian:bookworm-slim

# Установка curl и ca-certificates (обязательно для скрипта установки)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# Установка Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Добавление в PATH
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /workspace
CMD ["claude", "--help"]
```

***

## 10. Чистка временных файлов (опционально)

После успешной установки можно удалить кэш загрузок:

```bash
rm -rf /tmp/claude-* ~/.claude/downloads/claude-* 2>/dev/null || true
```
