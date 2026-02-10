# 🎨 Qoder Support

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../../README.md) → [🎨 IDE Support](../README.md) → [🎨 Qoder](#)

---

## Description

Интеграция OpenClaw с Qoder AI IDE — минималистичный AI редактор для быстрой разработки.

---

## 🎯 Почему Qoder?

**Преимущества:**
- ✅ **Minimal UI** — чистый интерфейс без лишних панелей
- ✅ **Fast AI** — быстрый AI ответ (меньше overhead)
- ✅ **.qoder/rules/** — автоматическая загрузка промптов
- ✅ **Auto-format** — автоматическое форматирование кода
- ✅ **Quick Actions** — быстрые команды через Cmd+Shift+P
- ✅ **Lightweight** — меньше ресурсов, чем Cursor/VS Code

---

## 📦 Установка

### 1. Установка Qoder

```bash
# macOS
brew install --cask qoder

# Linux
# Скачать с https://qoder.dev/downloads

# Windows
# Скачать с https://qoder.dev/downloads
```

### 2. Настройка OpenClaw

```bash
# Создаём директорию для правил
mkdir -p .qoder/rules

# Создаём основной файл правил
cat > .qoder/rules/QODER.md << 'EOF'
# 🦞 OpenClaw System Prompt

> Загружается из: /opt/openclaw/workspace/SYSTEM.md

**Это автоматическая копия. Источник: openclaw/workspace/**

Для изменений редактируйте: /opt/openclaw/workspace/SYSTEM.md
EOF

# Синхронизация промптов
/opt/openclaw/scripts/sync-ide-rules.sh
```

### 3. Открытие проекта

```bash
# Откройте проект в Qoder
qoder .

# Или через меню: File → Open Project
```

---

## 🔄 Как Это Работает

```
┌─────────────────────────────────────────────────────┐
│              .qoder/rules/QODER.md                   │
│  (автоматически загружается при старте)              │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                   Qoder IDE                          │
│  • Парсит .qoder/rules/                             │
│  • Индексирует проект                               │
│  • Инициализирует агентов OpenClaw                  │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│               OpenClaw Agents                        │
│  Main → Dev → DevOps → Prompt → CodeGen → Debugger  │
└─────────────────────────────────────────────────────┘
```

---

## 🎨 Режимы Работы

### 1. AI Chat (Cmd+Shift+A)

```
👤 "Создай функцию для валидации email"

🤖 Qoder (with OpenClaw):
    [Development Agent activated]
    📦 Using skill: code-generator

    ✅ Created: src/utils/validators.ts

    export function validateEmail(email: string): boolean {
      const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      return regex.test(email);
    }

    Хотите добавить тесты?
```

### 2. Quick Edit (Cmd+Shift+E)

```
1. Выделите код
2. Нажмите Cmd+Shift+E
3. Введите инструкцию: "Добавь error handling"
4. Qoder применит изменения
```

### 3. Refactor Mode (Cmd+Shift+R)

```
1. Откройте файл
2. Нажмите Cmd+Shift+R
3. Выберите тип рефакторинга
4. Qoder применит рефакторинг
```

---

## 🔧 Конфигурация

### .qoder/rules/QODER.md

```markdown
# 🦞 OpenClaw System Prompt

## Role
Ты AI ассистент с agentic архитектурой OpenClaw.

## Agents
- Main Agent (общее управление)
- Development Agent (разработка)
- DevOps Agent (деплой)
- Prompt Engineer (промпты)
- Code Generator (генерация)
- Debugger (отладка)

## Skills Index
@ref: /opt/openclaw/workspace/SKILLS-INDEX.md

## Workflow
1. Анализируй запрос
2. Определи агента
3. Загрузи skill
4. Выполни задачу
5. Попроси подтверждение
```

### Settings.json

```json
{
  "qoder.ai.model": "claude-opus-4-5-20251101",
  "qoder.ai.temperature": 0.7,
  "qoder.ai.maxTokens": 2048,
  "qoder.formatOnSave": true,
  "qoder.autoIndent": true,
  "qoder.rulesPath": ".qoder/rules/"
}
```

---

## 📝 Usage Examples

### Быстрая Генерация

```
👤 "Создай React компонент для карточки товара"

🤖 Qoder (with OpenClaw):
    [Code Generator Agent activated]

    ✅ Created: src/components/ProductCard.tsx

    interface ProductCardProps {
      product: {
        id: string;
        name: string;
        price: number;
        image: string;
      };
    }

    export function ProductCard({ product }: ProductCardProps) {
      return (
        <div className="product-card">
          <img src={product.image} alt={product.name} />
          <h3>{product.name}</h3>
          <p>${product.price}</p>
        </div>
      );
    }

    ✅ Component created with TypeScript
```

### Автоформатирование

```
# При сохранении файла (Cmd+S)

До:
function calculateTotal(items){return items.reduce((a,b)=>a+b.price,0)}

После (автоформат):
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

✅ Formatted with Prettier + TypeScript
```

### Git Commit

```
👤 "Создай коммит"

🤖 Qoder (with OpenClaw):
    [Git Workflow skill activated]

    📊 Changes:
    M src/components/ProductCard.tsx
    M src/types/product.ts

    📝 Commit message:
    feat: add product card component

    - Add ProductCard component with TypeScript
    - Add product type definition
    - Style product card with CSS

    ✅ Commit created
```

---

## 🎯 Keyboard Shortcuts

| Клавиша | Действие |
|---------|----------|
| `Cmd+Shift+A` | Открыть AI Chat |
| `Cmd+Shift+E` | Quick Edit |
| `Cmd+Shift+R` | Refactor Mode |
| `Cmd+S` | Сохранить (с автоформатом) |
| `Cmd+P` | Быстрый поиск файлов |
| `Cmd+Shift+P` | Command Palette |
| `Cmd+B` | Toggle Sidebar |

---

## 🔗 Quick Actions

Через Command Palette (Cmd+Shift+P):

```
"AI: Generate Component"     — Генерация компонента
"AI: Refactor Selection"     — Рефакторинг
"AI: Add Tests"              — Добавить тесты
"AI: Fix Error"              — Исправить ошибку
"AI: Optimize"               — Оптимизировать код
"AI: Document"               — Добавить документацию
"Git: Commit"                — Создать коммит
"Git: Push"                  — Запушить изменения
```

---

## 🛡️ Безопасность

### Permissions

Qoder имеет **доступ только к проекту**:
- ✅ Чтение файлов в проекте
- ✅ Запись в файлы проекта
- ✅ Git операции
- ❌ **Нет** доступа к системе

### Рекомендации

```yaml
Безопасно:
  - Изолированные проекты
  - Персональная разработка
  - Prototyping

С осторожностью:
  - Проекты с API keys
  - Командные репозитории

Рекомендуется:
  - .env в .gitignore
  - Не коммитить секреты
```

---

## 🔗 Интеграция с OpenClaw VDS

### Синхронизация Промптов

```bash
# На VDS
cd /opt/openclaw
git pull origin main

# Локально
cd /path/to/project
/opt/openclaw/scripts/sync-ide-rules.sh

# .qoder/rules/QODER.md обновлён
```

---

## 📊 Сравнение

| Характеристика | Qoder | Cursor | Claude Code |
|----------------|-------|--------|-------------|
| Размер | Минимален | Большой | CLI |
| Ресурсы | Минимум | Средние | Минимум |
| AI Speed | Быстрый | Средний | Быстрый |
| Multi-file | ⚠️ Ограничен | ✅ | ✅ |
| Git | ✅ | ✅ | ✅ |

---

## 📚 См. Также

- [🎨 IDE Support](../README.md) - Общая документация
- [🤖 Claude Code](../claude/README.md) - Claude Code CLI
- [🖱️ Cursor](../cursor/README.md) - Cursor IDE
- [🦞 OpenClaw Main](../../../README.md) - Главная

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия |

---

> [🏠 Главная](../../../../README.md) → [🦞 OpenClaw](../../../README.md) → [🎯 Workspace](../../README.md) → [🎨 IDE Support](../README.md) → [🎨 Qoder](#)
