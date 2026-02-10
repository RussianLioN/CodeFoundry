# First Session Workflow

**When:** No TASKS.md or SESSION.md exists.

---

## Steps

### 1. Greet (Russian)

```
Привет! Это первая сессия.
Опишите задачу, для которой нужен AI-ассистент.
```

### 2. Determine Intent

| User Request | → Mode |
|--------------|-------|
| "Создай промпт для..." | Prompt Generation |
| "Создай промпт для агента..." | Agent Prompt Generation |
| "Создай систему инструкций..." | Project Generation |

Load corresponding:
- [@ref: instructions/prompt-generation.md](instructions/prompt-generation.md)
- [@ref: instructions/agent-prompt-generation.md](instructions/agent-prompt-generation.md)
- [@ref: instructions/project-generation.md](instructions/project-generation.md)

### 3. Create Project Files

**Before work:** Create TASKS.md, SESSION.md

**After work:** Update with completed tasks, progress.


---
