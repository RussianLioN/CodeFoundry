# ═════════════════════════════════════════════════════════════════════════════
# 🖥️ CLI Tool Archetype
# ═════════════════════════════════════════════════════════════════════════════

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🖥️ CLI Tool](#)

---

## Overview

Архетип для создания CLI-инструментов с professional UX.

**Stack:**
- **Go** (Cobra, Viper) — production CLI
- **Rust** (Clap, Tokio) — performance-critical
- **Python** (Typer, Rich) — developer tools, scripting

---

## 🎯 Когда Использовать

✅ **Подходит для:**
- Developer tools (CLI, devops utilities)
- System administration scripts
- Data processing utilities
- Git hooks and integrations
- Automation tools

❌ **Не подходит для:**
- GUI applications → Desktop Archetype
- Web services → Web Service Archetype
- Mobile apps → Mobile Archetype

---

## 📁 Структура Проекта

```
cli-tool/
├── src/                    # Исходный код
│   ├── cmd/               # Команды (Cobra pattern)
│   │   ├── root.go        # Корневая команда
│   │   ├── serve.go       # Подкоманды
│   │   └── version.go
│   ├── pkg/               # Библиотечный код
│   │   ├── config/        # Configuration
│   │   ├── output/        # Formatters (JSON, YAML, table)
│   │   └── client/        # API clients
│   └── main.go            # Entry point
├── docs/                  # Documentation
│   ├── architecture.md
│   └── usage.md
├── scripts/               # Build & install scripts
│   ├── build.sh
│   └── install.sh
├── docker/                # Container build
│   └── Dockerfile
├── k8s/                   # Kubernetes (if needed)
├── openclaw/              # OpenClaw configuration
│   └── workspace/AGENTS.md
├── .env.example           # Environment variables
├── Makefile               # Build automation
├── pyproject.toml         # Python config (if Python)
├── go.mod                 # Go modules (if Go)
├── Cargo.toml             # Rust config (if Rust)
└── README.md
```

---

## 🚀 Quick Start

**Через CodeFoundry (рекомендуется):**
```bash
cd CodeFoundry
make new ARCHETYPE=cli-tool NAME=my-cli
cd my-cli
```

**Вручную:**
```bash
# Создаём проект из архетипа
mkdir my-cli && cd my-cli
cp -r /path/to/CodeFoundry/templates/archetypes/cli-tool/* .
git init
```

**Установка зависимостей и запуск:**
```bash
# Устанавливаем зависимости
go mod download  # для Go
# или
pip install -e .  # для Python

# Собираем
make build

# Запускаем
./bin/mycli --help
./bin/mycli command --flag value
```

---

## 📝 Command Structure (Cobra Pattern)

```go
// cmd/root.go
package cmd

import (
    "github.com/spf13/cobra"
    "github.com/spf13/viper"
)

var rootCmd = &cobra.Command{
    Use:   "mycli",
    Short: "My CLI tool",
    Long:  `A longer description...`,
    Run: func(cmd *cobra.Command, args []string) {
        // Root command logic
    },
}

func Execute() {
    if err := rootCmd.Execute(); err != nil {
        log.Fatal(err)
    }
}

func init() {
    cobra.OnInitialize(initConfig)
    rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file")
    viper.BindPFlag("config", rootCmd.PersistentFlags().Lookup("config"))
}

// cmd/serve.go
var serveCmd = &cobra.Command{
    Use:   "serve",
    Short: "Start server",
    Run: func(cmd *cobra.Command, args []string) {
        port, _ := cmd.Flags().GetInt("port")
        fmt.Printf("Serving on port %d\n", port)
    },
}

func init() {
    rootCmd.AddCommand(serveCmd)
    serveCmd.Flags().IntP("port", "p", 8080, "Port to listen on")
}
```

---

## 🎨 Rich Output (Python/Typer)

```python
# cli.py
import typer
from rich.console import Console
from rich.table import Table
from rich.progress import track

app = typer.Typer()
console = Console()

@app.command()
def list_items(
    format: str = typer.Option("table", "--format", "-f", help="Output format")
):
    """List all items"""

    data = fetch_items()

    if format == "json":
        import json
        typer.echo(json.dumps(data, indent=2))
    elif format == "table":
        table = Table(title="Items")
        table.add_column("ID", style="cyan")
        table.add_column("Name", style="green")
        table.add_column("Status", style="yellow")

        for item in data:
            table.add_row(item["id"], item["name"], item["status"])

        console.print(table)

@app.command()
def process(
    files: list[str] = typer.Argument(..., help="Files to process"),
    verbose: bool = typer.Option(False, "--verbose", "-v")
):
    """Process files with progress bar"""

    for file in track(files, description="Processing..."):
        process_file(file)
        if verbose:
            typer.echo(f"Processed {file}")

if __name__ == "__main__":
    app()
```

---

## 🔧 Configuration Management

### Go (Viper)

```go
// pkg/config/config.go
package config

import (
    "github.com/spf13/viper"
)

type Config struct {
    APIKey    string `mapstructure:"api_key"`
    Endpoint  string `mapstructure:"endpoint"`
    Timeout   int    `mapstructure:"timeout"`
    Debug     bool   `mapstructure:"debug"`
}

func Load() (*Config, error) {
    viper.SetConfigName("config")
    viper.SetConfigType("yaml")
    viper.AddConfigPath("$HOME/.mycli")
    viper.AddConfigPath(".")

    viper.AutomaticEnv()

    if err := viper.ReadInConfig(); err != nil {
        return nil, err
    }

    var cfg Config
    if err := viper.Unmarshal(&cfg); err != nil {
        return nil, err
    }

    return &cfg, nil
}
```

### Python (Typer)

```python
# config.py
from pathlib import Path
import yaml
from typing import Optional

class Config:
    def __init__(self, config_path: Optional[Path] = None):
        self.config_path = config_path or Path.home() / ".mycli" / "config.yaml"
        self._load()

    def _load(self):
        if self.config_path.exists():
            with open(self.config_path) as f:
                self.data = yaml.safe_load(f)
        else:
            self.data = self._defaults()

    @staticmethod
    def _defaults():
        return {
            "api_key": None,
            "endpoint": "https://api.example.com",
            "timeout": 30,
        }
```

---

## 📦 Build & Distribution

### Go (Single Binary)

```bash
# Build for multiple platforms
make build-all

# Generates:
# bin/mycli-linux-amd64
# bin/mycli-darwin-arm64
# bin/mycli-windows-amd64.exe

# Install to system
make install
# → /usr/local/bin/mycli

# Create Homebrew formula
make brew-formula
```

### Python (PyPI)

```bash
# Build package
python -m build

# Publish to PyPI
twine upload dist/*

# Install via pip
pip install mycli
```

---

## 🧪 Testing CLI

### Go (Cobra testing)

```go
// cmd/root_test.go
package cmd

import (
    "testing"
    "github.com/spf13/cobra"
)

func TestRootCommand(t *testing.T) {
    tests := []struct {
        name     string
        args     []string
        expected string
    }{
        {"help", []string{"--help"}, "A longer description"},
        {"version", []string{"version"}, "version"},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            cmd, _, _ := testCmd(t)
            cmd.SetArgs(tt.args)
            out := captureOutput(cmd)
            if !strings.Contains(out, tt.expected) {
                t.Errorf("expected %q in output", tt.expected)
            }
        })
    }
}
```

### Python (Typer testing)

```python
# tests/test_cli.py
from typer.testing import CliRunner
from click.testing import CliRunner
from cli import app

runner = CliRunner()

def test_list_items():
    result = runner.invoke(app, ["list-items"])
    assert result.exit_code == 0
    assert "Items" in result.stdout

def test_process_files():
    result = runner.invoke(app, ["process", "file1.txt", "file2.txt"])
    assert result.exit_code == 0
    assert "Processed" in result.stdout
```

---

## 🎯 Shell Completion

```bash
# Bash
./mycli completion bash > /etc/bash_completion.d/mycli

# Zsh
./mycli completion zsh > /usr/local/share/zsh/site-functions/_mycli

# Fish
./mycli completion fish > ~/.config/fish/completions/mycli.fish

# PowerShell
./mycli completion powershell | Out-String | Invoke-Expression
```

---

## 🐳 Docker Distribution

```dockerfile
# Multi-stage for minimal image
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 go build -o mycli

FROM alpine:latest
COPY --from=builder /app/mycli /usr/local/bin/
ENTRYPOINT ["mycli"]
```

```bash
# Run in container
docker run --rm mycli:latest version
```

---

## 🤖 OpenClaw Integration

См. [🤖 Agents](openclaw/workspace/AGENTS.md) для multi-agent конфигурации:

**3 агента:**
- **Main Agent** — координатор
- **Dev Agent** — разработка команд
- **Review Agent** — code review

---

## 📋 Make Commands

| Команда | Описание |
|---------|----------|
| `make build` | Собрать binary |
| `make install` | Установить в систему |
| `make test` | Запустить тесты |
| `make lint` | Проверить код |
| `make completion` | Генерировать completion |
| `make build-all` | Собрать для всех платформ |

---

## 📚 См. Также

### CodeFoundry
- [🏠 Главная](../../../README.md)
- [🚀 Quick Start](../../../QUICKSTART.md)
- [📋 Все Архетипы](../README.md)

### OpenClaw Integration
- [🦞 OpenClaw README](../../../openclaw/README.md)
- [🎯 Workspace](../../../openclaw/workspace/README.md)
- [🤖 Agents](../../../openclaw/workspace/AGENTS.md)
- [🎨 Skills Index](../../../openclaw/workspace/SKILLS-INDEX.md)

---

## 🔄 История Изменений

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.1.0 | 2025-01-31 | CodeFoundry branding, обновлённые breadcrumbs |
| 1.0.0 | 2025-11-05 | Первая версия CLI Tool archetype |

---

> [🏠 Главная](../../../README.md) → [🎨 Archetypes](../README.md) → [🖥️ CLI Tool](#)
