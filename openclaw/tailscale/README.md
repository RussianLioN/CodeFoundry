# 🔒 Tailscale VPN Configuration

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🔒 Tailscale](#)

---

## Обзор

Настройка Tailscale VPN для безопасного удалённого доступа к OpenClaw Gateway.

---

## 🎯 Зачем Tailscale?

### Проблемы Открытого Доступа

| Метод | Проблема |
|-------|----------|
| **Открытый порт 18789** | ⚠️ Любой может попытаться подключиться |
| **HTTP без шифрования** | ⚠️ Перехват данных |
| **Пароль в URL** | ⚠️ Может быть записан в логах |

### Решение: Tailscale

```
┌─────────────────────────────────────────────────────────────┐
│                      VPS Server                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              OpenClaw Gateway                         │  │
│  │         ws://127.0.0.1:18789 (loopback only!)      │  │
│  └──────────────────────────────────────────────────────┘  │
│                          │                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Tailscale Daemon                        │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  Serve Mode (tailnet-only)                 │   │  │
│  │  │  Funnel Mode (public HTTPS + password)     │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │    Tailscale VPN        │
              │  Encrypted Tunnel       │
              └─────────────────────────┘
                          │
         ┌────────────────┼────────────────┐
         ▼                ▼                ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │ Laptop  │     │ Phone   │     │ Desktop │
   └─────────┘     └─────────┘     └─────────┘
```

---

## 🚀 Быстрая Настройка

### Шаг 1: Установка Tailscale

```bash
# Linux (VPS)
curl -fsSL https://tailscale.com/install.sh | sh

# macOS
brew install tailscale

# Windows
# Скачать с https://tailscale.com/download
```

### Шаг 2: Аутентификация

```bash
# С auth key (рекомендуется для VPS)
tailscale up --authkey=${TS_AUTH_KEY} \
    --hostname=openclaw-vds \
    --advertise-exit-node=false

# Или интерактивно (для локальной машины)
tailscale up
```

### Шаг 3: Настройка OpenClaw

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
      "password": "${GATEWAY_PASSWORD}"
    }
  }
}
```

### Шаг 4: Проверка

```bash
# Статус Tailscale
tailscale status

# Проверка IP
tailscale ip -4

# Проверка Funnel URL
tailscale funnel status
```

---

## ⚙️ Режимы Tailscale

### Mode: "off" (По умолчанию)

Tailscale не используется.

**Когда использовать:**
- Локальная разработка
- Внутренняя сеть
- Тестирование

```json
{
  "gateway": {
    "tailscale": {
      "mode": "off"
    }
  }
}
```

---

### Mode: "serve" (Tailnet-Only)

Доступ только из вашей Tailscale сети.

**Когда использовать:**
- Доступ только для ваших устройств
- Без публичного доступа
- Максимальная безопасность

```json
{
  "gateway": {
    "tailscale": {
      "mode": "serve"
    }
  }
}
```

**Доступ:**
```
https://openclaw-vds.your-tailnet.ts.net
```

**Безопасность:**
- ✅ Доступ только авторизованным устройствам
- ✅ Tailscale identity headers
- ✅ Можно добавить password дополнительно

---

### Mode: "funnel" (Public HTTPS)

Публичный доступ через Tailscale Funnel с паролем.

**Когда использовать:**
- Доступ из любого места
- Через Telegram (даже если ваше устройство offline)
- Публичный API (с защитой)

```json
{
  "gateway": {
    "tailscale": {
      "mode": "funnel"
    },
    "auth": {
      "mode": "password",
      "password": "secure-password-here"
    }
  }
}
```

**Доступ:**
```
https://openclaw-vds.ts.net

С паролем: https://user:password@openclaw-vds.ts.net
```

**⚠️ Требования:**
- Обязателен `auth.mode: "password"`
- OpenClaw не запустится без пароля в funnel mode

---

## 🔧 Детальная Конфигурация

### serve-config.yaml

```yaml
# Tailscale Serve/Funnel Configuration

# Serve Mode (Tailnet-only HTTPS)
serve:
  mode: serve
  https: "443"
  auth:
    provider: tailscale
    # Дополнительный пароль (опционально)
    password:
      enabled: false
      value: "${GATEWAY_PASSWORD}"
    # Allowlist (опционально)
    allowlist:
      emails:
        - your-email@domain.com
        - teammate@domain.com
      tailnet:
        - "your-tailnet.ts.net"

# Funnel Mode (Public HTTPS with password)
funnel:
  mode: funnel
  https: "443"
  auth:
    provider: password
    password:
      enabled: true
      value: "${GATEWAY_PASSWORD}"
    # Tailscale identity + password
    allowTailscale: true

# Gateway binding
gateway:
  bind: "127.0.0.1:18789"
  # Funnel URL (автоматически генерируется)
  funnel_url: "https://openclaw-vds.ts.net"

# Node configuration
node:
  name: "openclaw-vds"
  # Exit node (опционально)
  exit_node: false
  # Advertise routes (опционально)
  advertise_routes:
    - "192.168.1.0/24"
  # Accept routes
  accept_routes: true
```

### Переменные Среды

```bash
# Auth key (для автоматической аутентификации)
export TS_AUTH_KEY="tskey-auth-xxxxx"

# Funnel password
export GATEWAY_PASSWORD="your-secure-password"

# Tailscale coordination server
export TS_COORDINATE_SERVER="https://controlplane.tailscale.com"
```

---

## 🛡️ Безопасность

### 1. Пароль для Funnel

**КРИТИЧНО:** Funnel mode требует пароль!

```bash
# Генерация надёжного пароля
openssl rand -base64 32

# Или через Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 2. Tailnet ACLs

Ограничьте доступ в Tailscale консоли:

```json
// ACL в Tailscale консоли
{
  "acls": [
    {
      "action": "accept",
      "users": ["your-email@domain.com"],
      "ports": ["openclaw-vds:18789"]
    }
  ]
}
```

### 3. IP Whitelist (опционально)

```json
{
  "gateway": {
    "auth": {
      "mode": "password",
      "password": "...",
      "allowlist": [
        "100.0.0.0/8",     // Ваша подсеть
        "10.0.0.0/8"       // Внутренняя сеть
      ]
    }
  }
}
```

---

## 🔗 Доступ к Gateway

### Через Tailscale IP

```bash
# Получение Tailnet IP
TAILNET_IP=$(tailscale ip -4)

# Доступ к Gateway
curl http://$TAILNET_IP:18789/health
```

### Через Funnel URL

```bash
# Получение Funnel URL
FUNNEL_URL=$(tailscale funnel --url)

# Доступ с паролем
curl https://user:password@$FUNNEL_URL/health
```

### Через Tailscale DNS

```bash
# Если включены MagicDNS
curl https://openclaw-vds.your-tailnet.ts.net/health

# С паролем
curl https://user:password@openclaw-vds.your-tailnet.ts.net/health
```

---

## 📊 Мониторинг

### Статус Tailscale

```bash
# Полный статус
tailscale status

# Краткий статус
tailscale status --json

# Peer status
tailscale status --peers
```

### Funnel Статус

```bash
# Проверка Funnel
tailscale funnel status

# Включение Funnel
tailscale funnel --https=443 localhost:18789

# Отключение Funnel
tailscale funnel off
```

### Логи

```bash
# Логи Tailscale
sudo journalctl -u tailscaled -f

# Логи с OpenClaw
sudo journalctl -u openclaw -f | grep tailscale
```

---

## 🔧 Troubleshooting

### Проблема: Tailscale не подключается

```bash
# Проверка статуса
tailscale status

# Проверка соединения
ping 100.x.y.z  # Tailscale DERP server

# Перезапуск
sudo systemctl restart tailscaled
```

### Проблема: Funnel не работает

```bash
# Проверка режима
tailscale funnel status

# Проверка пароля
cat ~/.openclaw/openclaw.json | grep password

# Проверка bind (должен быть loopback!)
cat ~/.openclaw/openclaw.json | grep bind
```

### Проблема: "Funnel refuses to start without password"

```
Error: Funnel refuses to start unless auth.mode is "password"
```

**Решение:** Добавьте пароль в конфигурацию:

```json
{
  "gateway": {
    "auth": {
      "mode": "password",
      "password": "your-password-here"
    },
    "tailscale": {
      "mode": "funnel"
    }
  }
}
```

---

## 🌐 Извне Tailnet

Доступ к OpenClaw с устройств, не в Tailscale:

### Через Telegram

Самый простой способ! OpenClaw работает через Telegram бота без необходимости прямого доступа к Gateway.

### Через Funnel URL

```bash
# Из любого места
curl https://user:password@openclaw-vds.ts.net/health

# Или через браузер
https://user:password@openclaw-vds.ts.net
```

### Через Reverse Proxy (опционально)

```nginx
# nginx.conf
location /openclaw/ {
    proxy_pass http://localhost:18789/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;

    # Базовая аутентификация
    auth_basic "OpenClaw Gateway";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

---

## 📚 См. Также

- [🦞 OpenClaw README](../README.md)
- [⚙️ Config](../config/README.md)
- [📥 VDS Setup](../install/VDS-SETUP.md)
- [📱 Telegram](../telegram/README.md)
- [🐳 Docker](../docker/README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия |

---

> [🏠 Главная](../../README.md) → [🦞 OpenClaw](../README.md) → [🔒 Tailscale](#)
