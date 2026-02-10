# 📥 Установка OpenClaw на VDS

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [📥 Установка](#)

---

## Обзор

Полное руководство по установке OpenClaw на удалённый VDS сервер для 24/7 AI ассистента с доступом через Telegram.

---

## 🎯 Требования

### Минимальные

| Ресурс | Значение |
|--------|----------|
| **CPU** | 2 vCPU |
| **RAM** | 2 GB |
| **Disk** | 20 GB SSD |
| **OS** | Ubuntu 22.04+, Debian 12+, AlmaLinux 9+ |

### Рекомендуемые

| Ресурс | Значение |
|--------|----------|
| **CPU** | 4+ vCPU |
| **RAM** | 4+ GB |
| **Disk** | 40+ GB NVMe |
| **OS** | Ubuntu 24.04 LTS |

### Необходимые аккаунты

- [ ] GitHub аккаунт
- [ ] Telegram аккаунт (для создания бота)
- [ ] Anthropic аккаунт (для Claude API)
- [ ] Tailscale аккаунт (для VPN, опционально)

---

## 🚀 Быстрая Установка (5 минут)

### Метод 1: Автоматический скрипт

```bash
# SSH подключение к VDS
ssh root@your-vps-ip

# Запуск установщика
curl -fsSL https://raw.githubusercontent.com/RussianLioN/system-prompts/main/openclaw/scripts/install-openclaw.sh | bash
```

**Что делает скрипт:**
1. ✅ Устанавливает зависимости (Node.js, Docker, Tailscale)
2. ✅ Устанавливает OpenClaw глобально
3. ✅ Создаёт systemd service
4. ✅ Настраивает firewall
5. ✅ Создаёт workspace директорию
6. ✅ Генерирует базовую конфигурацию

### Метод 2: Пошаговая установка

```bash
# 1. Обновление системы
apt update && apt upgrade -y

# 2. Установка зависимостей
apt install -y curl git nodejs npm docker.io docker-compose python3

# 3. Установка OpenClaw
npm install -g openclaw@latest

# 4. Проверка установки
openclaw --version

# 5. Мастер настройки
openclaw onboard
```

---

## ⚙️ Детальная Конфигурация

### Шаг 1: Мастер Настройки (onboard)

```bash
openclaw onboard --install-daemon
```

**Мастер задаст вопросы:**

1. **Модель AI** — Рекомендуется `anthropic/claude-opus-4-5`
2. **Workspace путь** — По умолчанию `/opt/openclaw/workspace`
3. **Каналы связи** — Выберите `telegram`
4. **Browser control** — Опционально

### Шаг 2: Настройка API ключей

```bash
# Редактируем конфигурацию
nano ~/.openclaw/openclaw.json
```

**Добавьте API ключи:**

```json
{
  "agent": {
    "model": "anthropic/claude-opus-4-5",
    "auth": {
      "anthropic": {
        "apiKey": "sk-ant-...",
        "baseUrl": "https://api.anthropic.com"
      }
    }
  }
}
```

### Шаг 3: Создание Telegram бота

**В Telegram:**

1. Откройте [@BotFather](https://t.me/BotFather)
2. Отправьте `/newbot`
3. Выберите имя бота: `YourProjectBot`
4. Получите `BOT_TOKEN`

**На VDS:**

```bash
# Установите BOT_TOKEN в конфиге
export TELEGRAM_BOT_TOKEN="123456:ABC-DEF1234..."

# Или отредактируйте конфиг
nano ~/.openclaw/openclaw.json
```

```json
{
  "channels": {
    "telegram": {
      "botToken": "123456:ABC-DEF1234...",
      "allowFrom": ["*"],
      "webhookUrl": "https://your-vps-ip:18789/telegram"
    }
  }
}
```

### Шаг 4: Настройка Webhook

```bash
# Установите webhook для Telegram бота
curl -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebHook" \
    -d "url=https://your-vps-ip:18789/telegram" \
    -d "max_connections=100"
```

---

## 🔒 Безопасность

### Firewall

```bash
# Разрешить SSH
ufw allow 22/tcp

# Разрешить OpenClaw Gateway
ufw allow 18789/tcp

# Включить firewall
ufw --force enable

# Проверить статус
ufw status
```

### Fail2Ban

```bash
# Установка
apt install -y fail2ban

# Конфигурация для SSH
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = 22
maxretry = 3
bantime = 3600
EOF

# Запуск
systemctl enable fail2ban
systemctl start fail2ban
```

### Настройка Allowlist (Recommended)

Ограничьте кто может писать боту:

```json
{
  "channels": {
    "telegram": {
      "allowFrom": ["+1234567890", "your-telegram-username"],
      "dmPolicy": "pairing"
    }
  }
}
```

---

## 🌐 Tailscale VPN (Опционально)

### Зачем Tailscale?

- ✅ Безопасный доступ без открытых портов
- ✅ Доступ к боту только из вашей сети
- ✅ Funnel для публичного HTTPS с паролем

### Установка

```bash
# 1. Установка Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# 2. Аутентификация
tailscale up --authkey=<YOUR_AUTH_KEY>

# 3. Включите Funnel (для публичного доступа)
tailscale funnel --https=443 localhost:18789

# 4. Проверьте статус
tailscale status
```

### Конфигурация OpenClaw с Tailscale

```json
{
  "gateway": {
    "bind": "127.0.0.1",
    "port": 18789,
    "tailscale": {
      "mode": "funnel",
      "resetOnExit": false
    },
    "auth": {
      "mode": "password",
      "password": "your-secure-password"
    }
  }
}
```

---

## 🚀 Запуск OpenClaw

### Systemd Service

```bash
# Запуск
systemctl start openclaw

# Автозапуск
systemctl enable openclaw

# Статус
systemctl status openclaw

# Логи
journalctl -u openclaw -f
```

### Ручной запуск

```bash
# Запуск Gateway
openclaw gateway --port 18789 --verbose

# Запуск с выводом в файл
openclaw gateway --port 18789 > /var/log/openclaw.log 2>&1 &
```

---

## ✅ Проверка Установки

### 1. Проверить Gateway

```bash
# Health check
curl http://localhost:18789/health

# Ожидаемый ответ:
# {"status":"ok","version":"..."}
```

### 2. Проверить Telegram бота

```
1. Откройте бота в Telegram
2. Отправьте: /status
3. Бот должен ответить статусом
```

### 3. Проверить Tailscale (если настроен)

```bash
tailscale status

# Должен показать:
# - Your VDS hostname
# - Tailnet IP
# - Funnel URL (если включён)
```

### 4. Диагностика

```bash
# Запуск doctor
openclaw doctor

# Проверит:
# - Установленную версию
# - Конфигурацию
# - Каналы связи
# - API ключи
```

---

## 📱 Первый Запуск

### Через Telegram

```
1. Найдите вашего бота в Telegram
2. Отправьте: /start
3. Бот ответит приветствием
4. Отправьте: Помоги создать проект
5. Начните работу! 🎉
```

### Через CLI

```bash
# Отправить сообщение в Telegram от имени бота
openclaw message send --to +1234567890 --message "Привет! Я готов к работе."

# Запустить агент с сообщением
openclaw agent --message "Проверь статус системы" --thinking high
```

---

## 🔧 Troubleshooting

### Проблема: Gateway не запускается

```bash
# Проверьте логи
journalctl -u openclaw -n 50

# Проверьте порт не занят
netstat -tlnp | grep 18789

# Проверьте конфигурацию
cat ~/.openclaw/openclaw.json | jq .
```

### Проблема: Telegram бот не отвечает

```bash
# Проверьте webhook
curl https://api.telegram.org/bot$TOKEN/getWebhookInfo

# Проверьте OpenClaw логи
journalctl -u openclaw -f | grep telegram

# Пересоздайте webhook
openclaw channels login telegram
```

### Проблема: Tailscale не работает

```bash
# Проверьте статус
tailscale status

# Перезапустите Tailscale
systemctl restart tailscaled

# Проверьте firewall
ufw status
```

---

## 🔄 Обновление

```bash
# Обновление OpenClaw
npm update -g openclaw@latest

# Перезапуск service
systemctl restart openclaw

# Проверка версии
openclaw --version
```

---

## 📚 См. Также

- [🔧 Скрипт установки](../scripts/install-openclaw.sh)
- [⚙️ Конфигурация](../config/README.md)
- [📱 Telegram настройка](../telegram/README.md)
- [🔒 Tailscale настройка](../tailscale/README.md)
- [✅ Проверка установки](verify.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия |

---

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [📥 Установка на VDS](#)
