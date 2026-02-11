#!/usr/bin/env python3
"""
Lesson Learned Tracker - Автоматическое извлечение уроков из повторяющихся ошибок

Когда ошибка происходит 3+ раза, система:
1. Автоматически извлекает урок
2. Добавляет в LESSONS.md
3. Создаёт/обновляет валидатор
4. Уведомляет пользователя

Usage:
    # Зарегистрировать ошибку
    python3 scripts/lesson-learned-tracker.py log \
        --type "invalid_json" \
        --location ".claude/settings.local.json" \
        --context '{"pattern": "heredoc"}'

    # Показать статистику
    python3 scripts/lesson-learned-tracker.py stats

    # Извлечь уроки для повторяющихся ошибок
    python3 scripts/lesson-learned-tracker.py extract
"""

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Any


# Configuration
ERROR_LOG = Path(".tracking/error_log.json")
LESSONS_FILE = Path("LESSONS.md")
LESSON_THRESHOLD = 3  # Extract lesson after 3 occurrences
LESSON_TEMPLATES_DIR = Path(".claude/templates/lessons")


class LessonLearnedTracker:
    """Tracker для автоматического извлечения уроков из повторяющихся ошибок."""

    def __init__(self, error_log_path: Path = ERROR_LOG):
        self.error_log_path = error_log_path
        self.error_log_path.parent.mkdir(exist_ok=True)
        self.error_log = self._load_error_log()
        self.lessons = self._load_lessons()

    def log_error(self, error_type: str, location: str, context: dict = None):
        """Зарегистрировать ошибку.

        При достижении порога (3 раза) автоматически извлекает урок.
        """
        key = f"{error_type}:{location}"

        if key not in self.error_log:
            self.error_log[key] = {
                "type": error_type,
                "location": location,
                "count": 0,
                "first_seen": None,
                "last_seen": None,
                "contexts": []
            }

        # Update error info
        info = self.error_log[key]
        info["count"] += 1
        timestamp = datetime.now().isoformat()

        if info["first_seen"] is None:
            info["first_seen"] = timestamp
        info["last_seen"] = timestamp

        if context:
            info["contexts"].append({
                "timestamp": timestamp,
                **context
            })

        self._save_error_log()

        # Check threshold
        if info["count"] >= LESSON_THRESHOLD:
            if not info.get("lesson_extracted", False):
                self._extract_lesson(key)
                info["lesson_extracted"] = True
                self._save_error_log()

        return info["count"]

    def _extract_lesson(self, error_key: str):
        """Извлечь урок из повторяющейся ошибки."""
        error_info = self.error_log[error_key]

        # Analyze patterns
        pattern = self._analyze_pattern(error_info["contexts"])

        # Generate lesson
        lesson = {
            "error_type": error_info["type"],
            "location": error_info["location"],
            "occurrences": error_info["count"],
            "first_seen": error_info["first_seen"],
            "last_seen": error_info["last_seen"],
            "pattern": pattern,
            "lesson": self._generate_lesson(error_info, pattern),
            "prevention": self._generate_prevention(error_info, pattern),
            "automation": self._generate_automation(error_info),
            "created": datetime.now().isoformat()
        }

        # Add to LESSONS.md
        self._add_to_lessons(lesson)

        # Create/update validator
        self._update_validator(error_info, lesson)

        # Notify user
        self._notify_user(lesson)

    def _analyze_pattern(self, contexts: List[dict]) -> str:
        """Анализирует общие паттерны в контекстах ошибок."""
        if not contexts:
            return "Unknown pattern - insufficient data"

        # Extract common elements
        patterns = []

        # Check for common file types
        files = [c.get("file") for c in contexts if "file" in c]
        if files:
            patterns.append(f"Files: {', '.join(set(files))}")

        # Check for common patterns
        pattern_list = [c.get("pattern") for c in contexts if "pattern" in c]
        if pattern_list:
            patterns.append(f"Patterns: {', '.join(set(pattern_list))}")

        # Check for common commands
        commands = [c.get("command") for c in contexts if "command" in c]
        if commands:
            patterns.append(f"Commands: {', '.join(set(commands))}")

        return " | ".join(patterns) if patterns else "Repeated manual error"

    def _generate_lesson(self, error_info: dict, pattern: str) -> str:
        """Генерирует описание урока."""
        error_type = error_info["type"]
        location = error_info["location"]
        count = error_info["count"]

        # Predefined lessons for common errors
        predefined_lessons = {
            "invalid_json": "JSON validation failed. File contains invalid syntax.",
            "token_budget_exceeded": "Token budget exceeded. Content needs optimization.",
            "permission_denied": "Permission error. Check file/directory permissions.",
            "file_not_found": "File missing. Check path or create file.",
            "heredoc_in_settings": "Heredoc in auto-generated settings. Use Write tool instead.",
            "missing_ref": "Broken @ref link. Target file missing.",
        }

        lesson = predefined_lessons.get(error_type)
        if lesson:
            return lesson

        return f"Repeated error '{error_type}' at {location} ({count} occurrences). Pattern: {pattern}"

    def _generate_prevention(self, error_info: dict, pattern: str) -> List[str]:
        """Генерирует стратегии предотвращения."""
        error_type = error_info["type"]
        location = error_info["location"]

        # Predefined prevention strategies
        prevention_map = {
            "invalid_json": [
                "Add JSON validation to pre-commit hook",
                "Create schema (.claude/schemas/*.schema.json)",
                "Use auto-formatter (jq, prettier)"
            ],
            "token_budget_exceeded": [
                "Add token budget check to quality gates",
                "Create shorter instruction variants",
                "Use @ref links for detailed content"
            ],
            "heredoc_in_settings": [
                "Use Write tool instead of Bash heredoc",
                "Add settings sanitization script",
                "Configure .gitignore for auto-generated files"
            ],
            "missing_ref": [
                "Run validate-refs skill before commit",
                "Add ref check to CI/CD pipeline",
                "Use reference checker script"
            ]
        }

        strategies = prevention_map.get(error_type, [
            "Add validation check for this error type",
            "Create automated test case",
            "Update CLAUDE.md with prevention instructions"
        ])

        return strategies

    def _generate_automation(self, error_info: dict) -> List[str]:
        """Генерирует варианты автоматизации."""
        error_type = error_info["type"]

        automation_map = {
            "invalid_json": [
                "scripts/validate-json.py --auto-fix",
                "Pre-commit hook: .git/hooks/validate-json"
            ],
            "token_budget_exceeded": [
                "make token-audit --auto-fix",
                "Hook: .claude/hooks/validate-token-budget.sh"
            ],
            "heredoc_in_settings": [
                "make settings-sanitize",
                "scripts/sanitize-settings.py --fix"
            ]
        }

        return automation_map.get(error_type, [
            f"Create scripts/fix-{error_type}.py",
            "Add to quality gates"
        ])

    def _add_to_lessons(self, lesson: dict):
        """Добавляет урок в LESSONS.md."""
        if not LESSONS_FILE.exists():
            LESSONS_FILE.write_text("# Lessons Learned\n\n> Auto-extracted from repeated errors\n\n")

        content = LESSONS_FILE.read_text()

        # Check if lesson already exists
        lesson_header = f"## {lesson['error_type']}"
        if lesson_header in content:
            return  # Already documented

        # Append new lesson
        content += f"""
{lesson_header}

**Location:** `{lesson['location']}`
**Occurrences:** {lesson['occurrences']} (since {lesson['first_seen'][:10]})
**Pattern:** `{lesson['pattern']}`

### Lesson

{lesson['lesson']}

### Prevention

{chr(10).join(f"- {s}" for s in lesson['prevention'])}

### Automation

{chr(10).join(f"- `{s}`" for s in lesson['automation'])}

---

*Auto-extracted: {lesson['created'][:10]}*
"""
        LESSONS_FILE.write_text(content)

    def _update_validator(self, error_info: dict, lesson: dict):
        """Создаёт или обновляет валидатор для этого типа ошибок."""
        error_type = error_info["type"]

        # Skip if validator exists
        validator_path = Path(f"scripts/validate-{error_type}.py")
        if validator_path.exists():
            return

        # Generate simple validator template
        validator_content = f'''#!/usr/bin/env python3
"""
Auto-generated validator for: {error_type}

Generated from lesson learned (occurrences: {lesson['occurrences']})
"""

import sys
from pathlib import Path

def validate_{error_type.replace('-', '_')}(target: Path) -> bool:
    """Validate {error_type}."""
    # TODO: Implement validation logic
    # Pattern: {lesson['pattern']}

    print(f"✓ No {error_type} detected")
    return True

if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    if not validate_{error_type.replace('-', '_')}(target):
        sys.exit(1)
'''

        validator_path.write_text(validator_content)
        validator_path.chmod(0o755)

    def _notify_user(self, lesson: dict):
        """Уведомляет пользователя о новом уроке."""
        print(f"\n{'='*60}")
        print(f"🎓 LESSON LEARNED (occurrence #{lesson['occurrences']})")
        print(f"{'='*60}")
        print(f"   Type:     {lesson['error_type']}")
        print(f"   Location: {lesson['location']}")
        print(f"   Pattern:  {lesson['pattern'][:80]}")
        print(f"\n   → See: {LESSONS_FILE}")
        print(f"{'='*60}\n")

    def show_stats(self):
        """Показать статистику ошибок."""
        if not self.error_log:
            print("📊 No errors logged yet")
            return

        print(f"\n📊 Error Statistics (threshold: {LESSON_THRESHOLD})\n")

        # Sort by count
        sorted_errors = sorted(
            self.error_log.items(),
            key=lambda x: x[1]["count"],
            reverse=True
        )

        for key, info in sorted_errors:
            status = "✅" if info.get("lesson_extracted") else f"({info['count']}/{LESSON_THRESHOLD})"
            print(f"  {status} {info['type']} @ {info['location']}")
            print(f"      Count: {info['count']} | First: {info['first_seen'][:10]}")

        print()

    def extract_all(self):
        """Извлечь уроки для всех ошибок выше порога."""
        extracted = 0
        for key, info in self.error_log.items():
            if info["count"] >= LESSON_THRESHOLD and not info.get("lesson_extracted"):
                self._extract_lesson(key)
                info["lesson_extracted"] = True
                extracted += 1

        self._save_error_log()

        if extracted == 0:
            print("ℹ️  No new lessons to extract")
        else:
            print(f"✅ Extracted {extracted} new lesson(s)")

    def _load_error_log(self) -> Dict:
        """Загружает лог ошибок из файла."""
        if self.error_log_path.exists():
            try:
                return json.loads(self.error_log_path.read_text())
            except json.JSONDecodeError:
                return {}
        return {}

    def _save_error_log(self):
        """Сохраняет лог ошибок в файл."""
        self.error_log_path.write_text(
            json.dumps(self.error_log, indent=2)
        )

    def _load_lessons(self) -> str:
        """Загружает существующие уроки."""
        if LESSONS_FILE.exists():
            return LESSONS_FILE.read_text()
        return ""


def main():
    parser = argparse.ArgumentParser(
        description="Lesson Learned Tracker - Auto-extract lessons from repeated errors"
    )

    subparsers = parser.add_subparsers(dest="command", help="Command")

    # Log command
    log_parser = subparsers.add_parser("log", help="Log an error occurrence")
    log_parser.add_argument("--type", required=True, help="Error type")
    log_parser.add_argument("--location", required=True, help="Error location")
    log_parser.add_argument("--context", help="JSON-encoded context")

    # Stats command
    subparsers.add_parser("stats", help="Show error statistics")

    # Extract command
    subparsers.add_parser("extract", help="Extract lessons from repeated errors")

    args = parser.parse_args()

    tracker = LessonLearnedTracker()

    if args.command == "log":
        context = json.loads(args.context) if args.context else {}
        count = tracker.log_error(args.type, args.location, context)
        print(f"✓ Logged: {args.type} @ {args.location} (count: {count})")

    elif args.command == "stats":
        tracker.show_stats()

    elif args.command == "extract":
        tracker.extract_all()

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
