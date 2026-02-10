# cf-new — Create New CodeFoundry Project

> **Slash command:** `/cf-new` or `/new`
> **Aliases:** `create project`, `new project`, `создай проект`
> **Category:** Project Generation

## Description

Creates a new IT project using CodeFoundry archetype system with AI-first interface.

## Usage

```
/cf-new [project-type] [project-name] [options]
```

### Examples

```
# Interactive mode
/cf-new

# Direct creation
/cf-new telegram-bot my-delivery-bot

# With options
/cf-new web-service shop-api --language=typescript --framework=express

# Natural language
"Create a telegram bot for food delivery"
"Создай проект telegram-bot для доставки еды"
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project-type` | string | No* | Project archetype (telegram-bot, web-service, ai-agent, fullstack) |
| `project-name` | string | No* | Project name (kebab-case) |
| `--language` / `-l` | string | No | Primary language (python, javascript, typescript, go) |
| `--framework` / `-f` | string | No | Framework (aiogram, fastapi, express, spring, etc.) |
| `--location` / `-o` | string | No | Output directory (default: ./workspace/projects) |
| `--with-ai` | flag | No | Generate AI agents for project |
| `--skip-git` | flag | No | Skip git initialization |

*If not provided, runs in interactive mode.

## Available Archetypes

### telegram-bot
- **Languages:** Python, JavaScript
- **Frameworks:** aiogram, telethon, pyTelegramBotAPI, node-telegram-bot-api
- **Best for:** Telegram bots, automation, notifications

### web-service
- **Languages:** Python, JavaScript, TypeScript, Go
- **Frameworks:** FastAPI, Express, NestJS, Flask, Spring
- **Best for:** REST APIs, microservices, web backends

### ai-agent
- **Languages:** Python, JavaScript, TypeScript
- **Frameworks:** LangChain, LangGraph, crewAI
- **Best for:** AI agents, RAG systems, AI automation

### fullstack
- **Languages:** TypeScript
- **Frameworks:** Next.js, Nuxt, SvelteKit
- **Best for:** Full-stack web applications

## Workflow

### 1. Parameter Collection
```
🤖 CodeFoundry Project Creator

Project type? (telegram-bot/web-service/ai-agent/fullstack)
> telegram-bot

Project name?
> my-delivery-bot

Language? (python/javascript)
> python

Framework? (aiogram/telethon/pyTelegramBotAPI)
> aiogram
```

### 2. Project Generation
```
[███████████] 100% ✅

✅ Project created: ./workspace/projects/my-delivery-bot
   📁 12 files generated
   🤖 AI agents ready
   📦 Dependencies installed
   🔧 Git initialized
```

### 3. Agent Generation (if --with-ai)
```
🤖 Generating AI agents...
   ✅ Coordinator agent
   ✅ Code Assistant agent
   ✅ Reviewer agent
   ✅ Tester agent

📝 Agents saved to: .claude/
```

### 4. Handoff
```
🎯 Next steps:
   1. cd ./workspace/projects/my-delivery-bot
   2. Configure .env file
   3. Run: make dev
   4. Start coding with AI assistance!

💡 Ask me anything about your new project.
```

## Integration with Gateway

When using AI-First interface via Gateway:

```javascript
// WebSocket message
{
  type: 'chat',
  content: 'Создай проект telegram-bot my-bot'
}

// Gateway response
{
  type: 'progress',
  stage: 'generating',
  progress: 50,
  message: 'Создаю файлы проекта...'
}
```

## Configuration

Command uses settings from `.claude/settings.json`:

```json
{
  "cf-new": {
    "defaultLocation": "./workspace/projects",
    "defaultLanguage": "python",
    "generateAgents": true,
    "initializeGit": true
  }
}
```

## Error Handling

| Error | Solution |
|-------|----------|
| `ARCHETYPE_NOT_FOUND` | Check available archetypes with `/cf-archetypes` |
| `PROJECT_EXISTS` | Use `--force` to overwrite or choose different name |
| `INVALID_NAME` | Use kebab-case (my-project, not MyProject) |
| `DEPENDENCY_FAILED` | Check internet connection and try again |

## Examples Output

```
📦 Project: my-delivery-bot
🏷️  Type: telegram-bot
🐍 Language: Python
⚡ Framework: aiogram

📁 Structure:
   my-delivery-bot/
   ├── .claude/              # AI agents
   │   ├── coordinator.md
   │   ├── code_assistant.md
   │   ├── reviewer.md
   │   └── tester.md
   ├── src/
   │   ├── bot.py           # Bot entry point
   │   ├── handlers/
   │   ├── keyboards/
   │   └── config/
   ├── tests/
   ├── .env.example
   ├── requirements.txt
   ├── pyproject.toml
   ├── Makefile
   ├── PROJECT.md           # Project documentation
   └── README.md

🚀 Quick start:
   cd my-delivery-bot
   cp .env.example .env
   # Edit .env with your bot token
   make dev
```

## Related Commands

- `/cf-agents` — Generate AI agents for existing project
- `/cf-deploy` — Deploy project to environment
- `/cf-archetypes` — List available project archetypes
- `/cf-status` — Show project status

## Implementation Notes

This command integrates with:
- `scripts/new-project.sh` — Core project generation script
- `scripts/generate-agents.py` — AI agent generation
- `openclaw/gateway/` — AI-First interface via WebSocket
- `.claude/AGENTS.md` — Agent registry

---

**Version:** 1.0.0
**Last updated:** 2025-02-02
