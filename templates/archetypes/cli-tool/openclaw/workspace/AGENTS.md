# 🤖 Multi-Agent System — CLI Tool

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [🖥️ CLI Tool](../README.md) → [🤖 Agents](#)

---

## Agent Configuration for CLI Tool Development

Этот archetype использует **3 агента** для создания CLI-инструментов.

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
│   Dev Agent   │       │ Review Agent  │
│  (Команды)    │    (Code Quality)   │
└───────────────┘       └───────────────┘
```

---

## 📝 Dev Agent

**Role:** Разработка CLI команд и логики

**Tools:**
- `write` — создание команд (Go/Cobra, Python/Typer, Rust/Clap)
- `read` — чтение существующего кода
- `bash` — сборка и тестирование

**Workspace:** `./src`, `./cmd`

**Responsibilities:**
- Command structure (Cobra pattern)
- Flag parsing
- Output formatting (JSON, YAML, table)
- Configuration management
- Shell completion

**Personality:**
```
Ты — CLI developer expert.

Принципы:
1. Command composition: nested subcommands
2. POSIX-compliant flags (-short, --long)
3. Rich output: tables, progress bars, colors
4. Error messages: actionable, clear
5. Shell completion: bash, zsh, fish, powershell

Структура команды:
```
mycli [global flags] <command> [command flags] [arguments]

Примеры:
mycli config set key value
mycli items list --format json
mycli process file1.txt file2.txt --verbose
```
```

---

## 🔍 Review Agent

**Role:** Проверка качества CLI-кода

**Tools:**
- `read` — анализ кода
- `bash` — запуск линтеров
- `write` — исправления

**Responsibilities:**
- Flag naming conventions
- Error handling
- Exit codes
- Help text quality
- UX review

**Personality:**
```
Ты — CLI UX reviewer.

Проверяешь:
- Flag names: intuitive, consistent
- Help text: clear, examples included
- Error messages: actionable, not scary
- Exit codes: follow POSIX conventions
- Output: machine-readable when needed
```

---

## 🔄 Workflow Examples

### Example 1: Create CLI Tool

```
User: "Создай CLI tool для управления конфигами"

1. Main → Dev Agent:
   - Создаёт структуру команд:
     * config get <key>
     * config set <key> <value>
     * config list
     * config delete <key>
   - Добавляет флаги: --format, --output, --profile
   - Реализует вывод: table, JSON, YAML

2. Main → Review Agent:
   - Проверяет UX
   - Тестирует флаги
   - Валидирует error handling

3. Result:
   ✅ Готовый CLI инструмент
   ✅ Shell completion
   ✅ Installation instructions
```

---

## 📋 Agent Configuration (agents.yaml)

```yaml
agents:
  main:
    role: coordinator
    model: claude-opus-4-5-20251101
    tools: [git, bash, read, write]

  dev:
    role: cli-developer
    model: claude-sonnet-4-5-20250514
    tools: [write, read, bash]
    workspace: "./src,./cmd"
    personality: "CLI developer expert"

  review:
    role: cli-reviewer
    model: claude-sonnet-4-5-20250514
    tools: [read, bash, write]
    personality: "CLI UX reviewer"
```

---

## 🛠️ Command Patterns

### Cobra Pattern (Go)

```go
var rootCmd = &cobra.Command{
    Use:   "mycli",
    Short: "My CLI tool",
}

var getCmd = &cobra.Command{
    Use:   "get <key>",
    Short: "Get config value",
    Args:  cobra.ExactArgs(1),
    Run: func(cmd *cobra.Command, args []string) {
        // Implementation
    },
}

func init() {
    rootCmd.AddCommand(getCmd)
    getCmd.Flags().String("format", "text", "Output format")
}
```

### Typer Pattern (Python)

```python
import typer

app = typer.Typer()

@app.command()
def get(key: str, format: str = typer.Option("text", "--format")):
    """Get config value"""
    # Implementation

if __name__ == "__main__":
    app()
```

---

## 📚 См. Также

- [🦞 OpenClaw Agents](../../../../../../workspace/AGENTS.md)
- [🎨 Skills Index](../../../../../../workspace/SKILLS-INDEX.md)
- [🖥️ CLI Tool README](../README.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2025-11-05 | Первая версия для CLI Tool archetype |

---

> [🏠 Главная](../../../../../../../README.md) → [🦞 OpenClaw](../../../../../../README.md) → [🎨 Archetypes](../../../../README.md) → [🖥️ CLI Tool](../README.md) → [🤖 Agents](#)
