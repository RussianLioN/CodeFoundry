#!/usr/bin/env python3
"""
Agent Generator - Генерация файлов агентов из шаблонов

Использует Jinja2 шаблоны для создания файлов агентов в проекте.
"""

import os
import sys
import json
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Any
from datetime import datetime
from dataclasses import dataclass, field
import yaml

try:
    from jinja2 import Environment, FileSystemLoader, Template
except ImportError:
    print("Installing Jinja2...")
    import subprocess
    subprocess.run([sys.executable, "-m", "pip", "install", "jinja2"], check=True)
    from jinja2 import Environment, FileSystemLoader, Template


@dataclass
class AgentConfig:
    """Конфигурация агента"""
    id: str
    name: str
    role: str
    template: str
    trigger: List[str]
    model: str
    specialization: str
    enabled: bool = True
    config: Dict[str, Any] = field(default_factory=dict)


@dataclass
class AgentGenerationRequest:
    """Запрос на генерацию агентов"""
    project_name: str
    project_type: str
    primary_language: str
    framework: Optional[str] = None
    output_dir: Path = field(default_factory=lambda: Path.cwd())
    agents: List[AgentConfig] = field(default_factory=list)
    context: Dict[str, Any] = field(default_factory=dict)


class AgentGenerator:
    """Генератор файлов агентов из шаблонов"""

    def __init__(self, templates_dir: Optional[Path] = None):
        """
        Инициализация генератора

        Args:
            templates_dir: Директория с шаблонами (по умолчанию templates/agents/)
        """
        # Определяем пути
        if templates_dir is None:
            # Ищем templates/agents относительно скрипта
            script_dir = Path(__file__).parent
            templates_dir = script_dir.parent / "templates" / "agents"

        self.templates_dir = Path(templates_dir)
        self.env = Environment(
            loader=FileSystemLoader(str(self.templates_dir)),
            trim_blocks=True,
            lstrip_blocks=True
        )

        # Метаданные версии шаблонов
        self.template_version = "1.0.0"
        self.creation_date = datetime.now().strftime("%Y-%m-%d")

    def generate(
        self,
        request: AgentGenerationRequest,
        format: str = "claude-code"
    ) -> Dict[str, Path]:
        """
        Сгенерировать файлы агентов

        Args:
            request: Запрос на генерацию
            format: Формат выходных файлов (claude-code, cursor, qoder, all)

        Returns:
            Словарь {agent_id: path_to_file}
        """
        if not self.templates_dir.exists():
            raise FileNotFoundError(f"Templates directory not found: {self.templates_dir}")

        # Создаём директорию для агентов
        agents_dir = self._get_agents_dir(request.output_dir, format)
        agents_dir.mkdir(parents=True, exist_ok=True)

        generated_files = {}

        # Генерируем каждого агента
        for agent_config in request.agents:
            if not agent_config.enabled:
                continue

            try:
                agent_file = self._generate_agent(
                    agent_config,
                    request,
                    agents_dir,
                    format
                )
                generated_files[agent_config.id] = agent_file
                print(f"  ✓ Generated: {agent_config.id} → {agent_file.name}")

            except Exception as e:
                print(f"  ✗ Failed: {agent_config.id} - {e}")

        # Генерируем файл оркестрации (AGENTS.md)
        if generated_files:
            orchestration_file = self._generate_orchestration(
                request, agents_dir, generated_files
            )
            print(f"  ✓ Orchestration: {orchestration_file.name}")

        return generated_files

    def _get_agents_dir(self, output_dir: Path, format: str) -> Path:
        """Получить директорию для файлов агентов"""

        format_dirs = {
            "claude-code": ".claude",
            "cursor": ".",  # .cursorrules в корне
            "qoder": ".qoder",
            "cliner": ".cliner",
            "all": ".claude"
        }

        dir_name = format_dirs.get(format, ".claude")
        return output_dir / dir_name

    def _generate_agent(
        self,
        agent_config: AgentConfig,
        request: AgentGenerationRequest,
        agents_dir: Path,
        format: str
    ) -> Path:
        """Сгенерировать файл одного агента"""

        # Загружаем шаблон
        template_path = f"{agent_config.template}.template"
        try:
            template = self.env.get_template(template_path)
        except Exception as e:
            raise FileNotFoundError(f"Template not found: {template_path}") from e

        # Подготавливаем контекст для рендеринга
        context = self._prepare_context(agent_config, request, format)

        # Рендерим
        content = template.render(**context)

        # Определяем имя файла
        filename = self._get_filename(agent_config, format)
        file_path = agents_dir / filename

        # Записываем
        file_path.write_text(content, encoding="utf-8")

        return file_path

    def _prepare_context(
        self,
        agent_config: AgentConfig,
        request: AgentGenerationRequest,
        format: str
    ) -> Dict[str, Any]:
        """Подготовить контекст для рендеринга шаблона"""

        # Базовый контекст
        context = {
            "version": "1.0.0",
            "template_version": self.template_version,
            "creation_date": self.creation_date,
            "project_name": request.project_name,
            "project_type": request.project_type,
            "agent_name": agent_config.name,
            "agent_id": agent_config.id,
            "format": format,
        }

        # Добавляем настройки из конфига агента
        context.update(agent_config.config)

        # Добавляем общий контекст проекта
        context.update(request.context)

        # Технологический стек
        context["primary_language"] = request.primary_language
        if request.framework:
            context["framework"] = request.framework

        # Значения по умолчанию
        defaults = self._get_defaults(request.primary_language, request.framework)
        context.update(defaults)

        return context

    def _get_defaults(self, language: str, framework: Optional[str]) -> Dict[str, Any]:
        """Получить значения по умолчанию для языка/фреймворка"""

        defaults_map = {
            "python": {
                "primary_language": "Python",
                "language_version": "3.11+",
                "package_manager": "poetry",
                "formatter": "black",
                "linter": "ruff",
                "test_framework": "pytest",
                "docstring_format": "Google Style",
                "inline_comments_style": "Explain WHY, not WHAT",
                "use_type_hints": True,
            },
            "javascript": {
                "primary_language": "JavaScript",
                "language_version": "ES2022",
                "package_manager": "npm",
                "formatter": "prettier",
                "linter": "eslint",
                "test_framework": "jest",
                "docstring_format": "JSDoc",
                "inline_comments_style": "JSDoc preferred",
                "use_type_hints": False,  # TypeScript for types
            },
            "typescript": {
                "primary_language": "TypeScript",
                "language_version": "5.0+",
                "package_manager": "npm",
                "formatter": "prettier",
                "linter": "eslint",
                "test_framework": "jest",
                "docstring_format": "TSDoc",
                "inline_comments_style": "TSDoc preferred",
                "use_type_hints": True,
            },
            "go": {
                "primary_language": "Go",
                "language_version": "1.21+",
                "package_manager": "go modules",
                "formatter": "gofmt",
                "linter": "golangci-lint",
                "test_framework": "testing",
                "docstring_format": "Godoc",
                "inline_comments_style": "Godoc comments",
                "use_type_hints": False,  # Go has built-in types
            }
        }

        defaults = defaults_map.get(language.lower(), defaults_map["python"])

        # Добавляем framework-specific настройки
        if framework:
            framework_defaults = self._get_framework_defaults(framework)
            defaults.update(framework_defaults)

        # Добавляем дополнительные категории defaults
        defaults.update(self._get_code_style_defaults(language))
        defaults.update(self._get_testing_defaults(language, framework))
        defaults.update(self._get_documentation_defaults(language))
        defaults.update(self._get_error_defaults(language))
        defaults.update(self._get_metadata_defaults())

        return defaults

    def _get_framework_defaults(self, framework: str) -> Dict[str, Any]:
        """Получить настройки для конкретного фреймворка"""

        framework_map = {
            "fastapi": {
                "framework": "FastAPI",
                "framework_version": "0.100+",
                "addons": ["Pydantic", "SQLAlchemy", "Alembic"],
                "test_framework": "pytest + httpx",
                "style_guide": "PEP 8 + FastAPI conventions",
            },
            "django": {
                "framework": "Django",
                "framework_version": "5.0+",
                "addons": ["DRF", "Celery"],
                "test_framework": "pytest-django",
                "style_guide": "PEP 8 + Django conventions",
            },
            "react": {
                "framework": "React",
                "framework_version": "18+",
                "addons": ["React Router", "Axios", "Zustand"],
                "test_framework": "vitest",
                "style_guide": "Airbnb React Style Guide",
            },
            "next": {
                "framework": "Next.js",
                "framework_version": "14+",
                "addons": ["Next.js Router", "SWR"],
                "test_framework": "vitest + playwright",
                "style_guide": "Next.js conventions",
            },
            "aiogram": {
                "framework": "aiogram",
                "framework_version": "3.x",
                "addons": ["SQLAlchemy", "Redis"],
                "test_framework": "pytest + pytest-asyncio",
                "style_guide": "PEP 8 + async patterns",
            }
        }

        return framework_map.get(framework.lower(), {})

    def _get_code_style_defaults(self, language: str) -> Dict[str, Any]:
        """Получить defaults для стиля кода"""
        naming = {
            "python": {
                "variables": "snake_case",
                "functions": "snake_case",
                "classes": "PascalCase",
                "constants": "UPPER_SNAKE_CASE",
                "files": "snake_case.py"
            },
            "javascript": {
                "variables": "camelCase",
                "functions": "camelCase",
                "classes": "PascalCase",
                "constants": "UPPER_SNAKE_CASE",
                "files": "kebab-case.js"
            },
            "typescript": {
                "variables": "camelCase",
                "functions": "camelCase",
                "classes": "PascalCase",
                "constants": "UPPER_SNAKE_CASE",
                "files": "kebab-case.ts"
            },
            "go": {
                "variables": "camelCase",
                "functions": "PascalCase",
                "classes": "N/A (Go uses structs)",
                "constants": "PascalCase",
                "files": "snake_case.go"
            }
        }

        style_rules = {
            "python": [
                "Follow PEP 8 guidelines",
                "Max line length: 88 characters (black default)",
                "Use type hints for all function parameters and returns",
                "Docstrings follow Google style",
                "Import order: stdlib, third-party, local",
                "Use f-strings for string formatting"
            ],
            "javascript": [
                "Follow Airbnb Style Guide",
                "Use const by default, let when reassignment needed",
                "Use template literals for string interpolation",
                "Prefer arrow functions for callbacks",
                "Destructure objects and arrays when beneficial"
            ],
            "typescript": [
                "Follow Airbnb Style Guide (TypeScript edition)",
                "Strict mode enabled",
                "Use interfaces for object shapes",
                "Prefer 'type' for unions/intersections",
                "No implicit any"
            ],
            "go": [
                "Follow Effective Go guidelines",
                "Use gofmt for formatting",
                "Error handling must be explicit",
                "Use goroutines for concurrency",
                "Prefer interfaces over concrete types"
            ]
        }

        quality_checklist = [
            "Code follows style guide",
            "Docstrings present",
            "Error handling",
            "Type hints used"
        ]

        lang = language.lower()
        if lang not in naming:
            lang = "python"

        return {
            "naming": naming[lang],
            "style_rules": style_rules[lang],
            "quality_checklist": quality_checklist,
            "test_categories": ["Unit tests", "Integration tests", "E2E tests"],
            "common_patterns": [],
            "anti_patterns": [],
            "file_structure": "Standard project structure",
            "caching_strategy": "LRU cache for expensive operations",
            "validate_inputs": "True (Pydantic/Zod schemas)",
            "escape_outputs": "True (auto-escape in templates)"
        }

    def _get_testing_defaults(self, language: str, framework: Optional[str] = None) -> Dict[str, Any]:
        """Получить defaults для тестирования"""
        return {
            "tdd_priority": "high",
            "unit_ratio": 70,
            "integration_ratio": 20,
            "e2e_ratio": 10,
            "line_coverage": 85,
            "branch_coverage": 75,
            "coverage_target": "85%",
            "branch_coverage_target": "75%",
            "package_name": "app",
            "setup_code": "data = create_test_data()",
            "action": "result = process(data)",
            "expected_outcome": "result is not None",
            "error_message": "Expected truthy result",
            "create_fixtures": "fixtures = create_test_fixtures()",
            "call_function": "process_request(data)",
            "state_verification": "assert state == expected",
            "cleanup_resources": "cleanup_fixtures(fixtures)"
        }

    def _get_documentation_defaults(self, language: str) -> Dict[str, Any]:
        """Получить defaults для документации"""
        return {
            "doc_style": "Technical",
            "output_format": "Markdown",
            "tagline": "Building better software",
            "status": "Stable",
            "license": "MIT",
            "license_name": "MIT License",
            "brief_description": "{{ project_name }} application",
            "quickstart_example": "make init && make dev",
            "installation_instructions": "See INSTALL.md",
            "basic_usage": "make dev",
            "documentation_links": "- [API](docs/api.md)",
            "contributing_guidelines": "See CONTRIBUTING.md",
            "badges": [],
            "badges_section": "",
            "component_name": "Service",
            "component_overview": "Core service",
            "subcomponent_1": "Repository",
            "subcomponent_description": "Data access layer",
            "responsibility_1": "Handle database operations",
            "responsibility_2": "Cache frequently accessed data",
            "interface_definition": "interface Repository { find(id: ID): Entity }",
            "constructor_params": "config: Config",
            "constructor_params_list": [{"name": "config", "type": "Config"}],
            "constructor_description": "Initialize with config",
            "method_params": [{"name": "data", "type": "Input"}],
            "method_raises": ["ValidationError"],
            "exc_condition": "When input is invalid",
            "usage_example": "service.process(data)",
            "example_output": '{"status": "ok"}'
        }

    def _get_error_defaults(self, language: str) -> Dict[str, Any]:
        """Получить defaults для error handling"""
        logging_frameworks = {
            "python": "Python logging module",
            "javascript": "Winston",
            "typescript": "Winston",
            "go": "standard log"
        }
        return {
            "error_style": "Explicit with propagation",
            "logging_framework": logging_frameworks.get(language.lower(), "Standard logging"),
            "validate_inputs": True,
            "escape_outputs": True
        }

    def _get_metadata_defaults(self) -> Dict[str, Any]:
        """Получить базовые метаданные для placeholders"""
        return {
            # Code Assistant placeholders
            "module_name": "service",
            "description": "Core service",
            "class_name": "Service",
            "method_name": "process",
            "imports": "",
            "init_params": "",
            "init_params_list": [],
            "return_type": "Any",
            "method_docstring": "Process data",
            "class_docstring": "Service class",
            "method_raises": "Exception",
            "exception_types": "ValueError",
            "return_description": "Result",
            "has_logger": True,
            "include_examples": True,
            # Reviewer
            "review_style": "Thorough",
            "weights": {
                "correctness": 40,
                "security": 25,
                "performance": 15,
                "maintainability": 10,
                "conventions": 10
            },
            "project_rules": "",
            # Coordinator
            "coordinator_keywords": ["coordinate", "orchestrate"],
            "current_task": "Initialization",
            "active_agents": [],
            "conversation_history": [],
            "decisions_made": [],
            "last_updated": self.creation_date,
            # Debugger
            "debug_style": "Analytical",
            "project_config": ""
        }

    def _get_filename(self, agent_config: AgentConfig, format: str) -> str:
        """Получить имя файла для агента"""

        if format == "cursor" and agent_config.id == "main":
            return ".cursorrules"

        if format == "cliner" and agent_config.id == "main":
            return ".clinerules"

        # Для остальных форматов
        return f"{agent_config.id}.md"

    def _generate_orchestration(
        self,
        request: AgentGenerationRequest,
        agents_dir: Path,
        generated_files: Dict[str, Path]
    ) -> Path:
        """Сгенерировать файл оркестрации AGENTS.md"""

        # Загружаем шаблон оркестрации
        template_path = "orchestration.template"
        try:
            template = self.env.get_template(template_path)
        except Exception:
            # Если шаблон не найден, используем встроенный
            content = self._default_orchestration(request, generated_files)
        else:
            context = {
                "project_name": request.project_name,
                "project_type": request.project_type,
                "agents": [
                    {
                        "id": agent_id,
                        "name": file_path.stem,
                        "file": file_path.name
                    }
                    for agent_id, file_path in generated_files.items()
                ],
                "version": "1.0.0",
                "creation_date": self.creation_date
            }
            content = template.render(**context)

        orchestration_path = agents_dir / "AGENTS.md"
        orchestration_path.write_text(content, encoding="utf-8")

        return orchestration_path

    def _default_orchestration(
        self,
        request: AgentGenerationRequest,
        generated_files: Dict[str, Path]
    ) -> str:
        """Встроенный шаблон оркестрации"""

        agents_list = "\n".join([
            f"### {agent_id}\n- **File:** `{file_path.name}`\n"
            for agent_id, file_path in generated_files.items()
        ])

        return f"""# {request.project_name} - Agent Orchestration

> Generated: {self.creation_date}
> Project Type: {request.project_type}

---

## Agent Registry

{agents_list}

---

## Agent Routing

```yaml
routing:
  default: coordinator

  keywords:
    "напиши|создай|рефактори": code_assistant
    "ревью|review|проверь": reviewer
    "документация|docs": documentation
    "тест|test|проверка": tester
    "отладь|debug|ошибка": debugger
```

---

## Usage

Agents are automatically routed based on keywords or can be explicitly selected:

```
/agent code_assistant Write a function for...
/agent reviewer Review PR #123
```

---

> Generated by CodeFoundry Agent Generator v{self.template_version}
"""


def load_agents_config(config_path: Path) -> List[AgentConfig]:
    """Загрузить конфигурацию агентов из YAML файла"""

    if not config_path.exists():
        raise FileNotFoundError(f"Config file not found: {config_path}")

    with open(config_path) as f:
        data = yaml.safe_load(f)

    agents = []
    for agent_data in data.get("agents", []):
        agents.append(AgentConfig(
            id=agent_data["id"],
            name=agent_data["name"],
            role=agent_data["role"],
            template=agent_data["template"],
            trigger=agent_data.get("trigger", []),
            model=agent_data.get("model", "gpt-4"),
            specialization=agent_data["specialization"],
            enabled=agent_data.get("enabled", True),
            config=agent_data.get("config", {})
        ))

    return agents


def create_default_config(project_type: str) -> Dict[str, Any]:
    """Создать конфигурацию агентов по умолчанию для типа проекта"""

    # Базовые агенты для всех проектов
    agents = [
        {
            "id": "coordinator",
            "name": "Coordinator",
            "role": "Orchestrator of all agents",
            "template": "coordinator",
            "trigger": ["coordinate", "orchestrate"],
            "model": "gpt-4",
            "specialization": "Agent coordination",
            "enabled": True,
            "config": {}
        }
    ]

    # Добавляем агентов в зависимости от типа проекта
    if project_type in ["telegram-bot", "web-service", "ai-agent", "fullstack"]:
        agents.extend([
            {
                "id": "code_assistant",
                "name": "Code Assistant",
                "role": "Code writing specialist",
                "template": "code-assistant",
                "trigger": ["write", "create", "implement"],
                "model": "gpt-4",
                "specialization": "Code generation",
                "enabled": True,
                "config": {}
            },
            {
                "id": "reviewer",
                "name": "Code Reviewer",
                "role": "Code review specialist",
                "template": "reviewer",
                "trigger": ["review", "check"],
                "model": "gpt-4",
                "specialization": "Quality assurance",
                "enabled": True,
                "config": {}
            },
            {
                "id": "tester",
                "name": "QA Tester",
                "role": "Testing specialist",
                "template": "tester",
                "trigger": ["test", "verify"],
                "model": "gpt-4",
                "specialization": "Test generation",
                "enabled": True,
                "config": {}
            }
        ])

    if project_type in ["web-service", "ai-agent", "fullstack"]:
        agents.append({
            "id": "documentation",
            "name": "Documentation",
            "role": "Technical writing specialist",
            "template": "documentation",
            "trigger": ["document", "docs"],
            "model": "gpt-4",
            "specialization": "Documentation",
            "enabled": True,
            "config": {}
        })
        agents.append({
            "id": "security",
            "name": "Security",
            "role": "Security specialist",
            "template": "security",
            "trigger": ["security", "auth", "vulnerability"],
            "model": "gpt-4",
            "specialization": "Security review",
            "enabled": True,
            "config": {}
        })

    return {"agents": agents}


def _run_profile_mode():
    """Delegate to generate-claude-profile.py for full .claude/ profile generation."""
    import subprocess

    script_dir = Path(__file__).parent
    profile_script = script_dir / "generate-claude-profile.py"
    template_dir = script_dir.parent / "templates" / "claude-profile"

    if not profile_script.exists():
        print(f"ERROR: {profile_script} not found", file=sys.stderr)
        sys.exit(1)

    # Pass through all args except --profile
    args = [a for a in sys.argv[1:] if a != "--profile"]

    # Add template-dir if not provided
    if "--template-dir" not in args:
        args.extend(["--template-dir", str(template_dir)])

    cmd = [sys.executable, str(profile_script)] + args
    result = subprocess.run(cmd)
    sys.exit(result.returncode)


# CLI interface
def main():
    """CLI для генерации агентов"""

    # Check for --profile mode
    if "--profile" in sys.argv:
        _run_profile_mode()
        return

    if len(sys.argv) < 3:
        print("Usage:")
        print("  generate-agents.py <project_name> <project_type> [language] [framework] [output_dir]")
        print("  generate-agents.py --profile --archetype <type> --project-name <name> --project-dir <dir>")
        print("")
        print("Examples:")
        print("  generate-agents.py MyBot telegram-bot python aiogram /workspace/MyBot")
        print("  generate-agents.py --profile --archetype web-service --project-name my-api --project-dir ./my-api")
        sys.exit(1)

    project_name = sys.argv[1]
    project_type = sys.argv[2]
    language = sys.argv[3] if len(sys.argv) > 3 else "python"
    framework = sys.argv[4] if len(sys.argv) > 4 else None
    output_dir = Path(sys.argv[5]) if len(sys.argv) > 5 else Path.cwd()

    print(f"🤖 Agent Generator")
    print(f"   Project: {project_name}")
    print(f"   Type: {project_type}")
    print(f"   Language: {language}")
    if framework:
        print(f"   Framework: {framework}")
    print(f"   Output: {output_dir}")
    print()

    # Создаём запрос
    request = AgentGenerationRequest(
        project_name=project_name,
        project_type=project_type,
        primary_language=language,
        framework=framework,
        output_dir=output_dir
    )

    # Загружаем конфигурацию агентов
    config_path = output_dir / ".codefoundry" / "agents.yaml"
    if config_path.exists():
        request.agents = load_agents_config(config_path)
        print(f"  Loaded config: {len(request.agents)} agents")
    else:
        # Создаём конфигурацию по умолчанию
        default_config = create_default_config(project_type)
        config_data = default_config

        # Конвертируем в AgentConfig
        for agent_data in config_data["agents"]:
            request.agents.append(AgentConfig(**agent_data))

        print(f"  Using default config: {len(request.agents)} agents")

        # Сохраняем конфигурацию для будущего использования
        config_dir = output_dir / ".codefoundry"
        config_dir.mkdir(parents=True, exist_ok=True)
        with open(config_path, "w") as f:
            yaml.dump(default_config, f, default_flow_style=False)
        print(f"  Saved config: {config_path}")

    print()
    print("  Generating agents...")

    # Генерируем агентов
    generator = AgentGenerator()
    generated = generator.generate(request, format="claude-code")

    print()
    print(f"  ✓ Generated {len(generated)} agent(s)")
    print(f"  ✓ Orchestration: AGENTS.md")
    print()
    print(f"  Next steps:")
    print(f"    1. Review generated files in {output_dir}/.claude/")
    print(f"    2. Customize agent prompts for your project")
    print(f"    3. Test agent routing with Claude Code")


if __name__ == "__main__":
    main()
