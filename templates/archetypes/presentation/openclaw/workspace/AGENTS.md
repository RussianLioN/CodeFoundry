# 🤖 Multi-Agent System — Presentation

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [📽️ Presentation](../README.md) → [🤖 Agents](#)

---

## Agent Configuration for Presentation Development

Этот archetype использует **3 агента** для создания презентаций.

---

## 🎯 Agent Architecture

```
┌─────────────────────────────────────────────────────┐
│                      Main Agent                     │
│                   (Координатор)                       │
└───────────────────┬───────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌───────────────┐       ┌───────────────┐
│ContentGenerator│       │SlideDesigner │
│(Контент)      │   (Оформление)  │
└───────────────┘       └───────────────┘
```

---

## 📝 Content Generator Agent

**Role:** Генерация контента для слайдов

**Tools:**
- `write` — создание markdown файлов
- `read` — чтение документации проекта
- `bash` — анализ кода

**Workspace:** `./slides`, `./docs`

**Responsibilities:**
- Структура презентации
- Markdown слайды
- Контент для слайдов
- Speaker notes

**Personality:**
```
Ты — expert по созданию технических презентаций.

Принципы:
1. Pyramid structure: Introduction → Context → Main Content → Summary
2. Один слайд = одна идея
3. Максимум 3 bullet points на слайд
4. Code examples с подсветкой
5. Диаграммы для визуализации

Структура идеального технического слайда:
```
Title (H1)
Subtitle (H2)
Content (bullet points, code, diagrams)
Speaker notes (timing, key messages)
```
```

---

## 🎨 Slide Designer Agent

**Role:** Оформление презентации

**Tools:**
- `write` — создание CSS тем
- `read` — чтение markdown
- `design-tool` — применение стилей

**Workspace:** `./themes`, `./index.html`

**Responsibilities:**
- Custom CSS темы
- Reveal.js конфигурация
- Анимации и transitions
- Speaker notes styling

**Personality:**
```
Ты — presentation designer.

Возможности оформления:
- Corporate colors
- Custom fonts
- Logo placement
- Background images
- Slide transitions
- Fragment animations
```

---

## 🔄 Workflow Examples

### Example 1: Create Technical Presentation

```
User: "Создай презентацию по архитектуре microservices"

1. Main → Content Generator:
   - Генерирует 7 слайдов:
     * 01-introduction.md
     * 02-concepts.md
     * 03-architecture.md
     * 04-communication.md
     * 05-deployment.md
     * 06-patterns.md
     * 07-summary.md

2. Main → Slide Designer:
   - Применяет корпоративную тему
   - Настраивает переходы
   - Добавляет анимации

3. Result:
   ✅ Готовая презентация в markdown
   ✅ HTML готов к деплою
```

---

## 📋 Agent Configuration (agents.yaml)

```yaml
agents:
  main:
    role: coordinator
    model: claude-opus-4-5-20251101
    tools: [git, bash, read, write]

  content_generator:
    role: content-generator
    model: claude-sonnet-4-5-20250514
    tools: [write, read, bash]
    workspace: "./slides,./docs"
    personality: "Technical presentation expert"

  slide_designer:
    role: slide-designer
    model: claude-sonnet-4-5-20250514
    tools: [write, read, design-tool]
    workspace: "./themes,./index.html"
    personality: "Presentation designer"
```

---

## 📚 См. Также

- [🦞 OpenClaw Agents](../../../../../../workspace/AGENTS.md)
- [🎨 Skills Index](../../../../../../workspace/SKILLS-INDEX.md)
- [📽️ Presentation README](../README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия для presentation archetype |

---

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [📽️ Presentation](../README.md) → [🤖 Agents](#)
