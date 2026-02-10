#!/usr/bin/env python3
"""
CodeFoundry - Auto-Tracking Documentation System

Automatically updates TASKS.md, SESSION.md, CHANGELOG.md
as work progresses.

Usage:
    python3 scripts/auto-track.py track-commit [commit-hash]
    python3 scripts/auto-track.py finalize-session
    python3 scripts/auto-track.py update-progress
"""

import re
import sys
import json
import subprocess
from pathlib import Path
from datetime import datetime, timedelta
from typing import Optional, Dict, List


class DocumentationTracker:
    """Auto-tracker for project documentation"""

    def __init__(self, project_root: Optional[Path] = None):
        self.root = project_root or Path.cwd()
        self.tasks_path = self.root / "TASKS.md"
        self.session_path = self.root / "SESSION.md"
        self.changelog_path = self.root / "CHANGELOG.md"
        self.tracking_dir = self.root / ".tracking"
        self.state_file = self.tracking_dir / "session_state.json"

        # Ensure tracking dir exists
        self.tracking_dir.mkdir(exist_ok=True)

    def track_commit(self, commit_hash: str = "HEAD") -> Dict:
        """Track a single commit and update docs"""

        commit_info = self.get_commit_info(commit_hash)

        updates = {
            "task_updated": False,
            "changelog_updated": False,
            "progress_updated": False
        }

        # Extract and update task
        if task_id := self.extract_task_id(commit_info["message"]):
            if self.update_task_from_commit(task_id, commit_info):
                updates["task_updated"] = True
                updates["progress_updated"] = True

        # Update changelog
        if self.should_add_to_changelog(commit_info):
            self.add_changelog_entry(commit_info)
            updates["changelog_updated"] = True

        # Save state
        self.save_state(commit_info)

        return updates

    def get_commit_info(self, commit_hash: str = "HEAD") -> Dict:
        """Get detailed commit info from git"""

        # Get commit details
        result = subprocess.run(
            ["git", "show", "--format=%H%n%s%n%an%n%ad", "--date=iso", commit_hash],
            capture_output=True,
            text=True,
            cwd=self.root
        )

        if result.returncode != 0:
            return {"hash": "unknown", "message": "", "author": "", "date": ""}

        lines = result.stdout.split("\n")

        # Get changed files
        files_result = subprocess.run(
            ["git", "show", "--name-only", "--format=", commit_hash],
            capture_output=True,
            text=True,
            cwd=self.root
        )

        files_changed = []
        if files_result.returncode == 0 and files_result.stdout.strip():
            files_changed = [
                f for f in files_result.stdout.strip().split("\n")
                if f and not f.startswith(".tracking/")
            ]

        return {
            "hash": lines[0] if len(lines) > 0 else "",
            "message": lines[1] if len(lines) > 1 else "",
            "author": lines[2] if len(lines) > 2 else "",
            "date": lines[3] if len(lines) > 3 else "",
            "files_changed": files_changed
        }

    def extract_task_id(self, message: str) -> Optional[str]:
        """Extract task ID from commit message"""

        patterns = [
            r"TASK-(\d+)",          # TASK-001
            r"INIT-(\d+)",          # INIT-001
            r"PRJ-(\d+)",           # PRJ-001
            r"#(\d+)",              # #001
        ]

        for pattern in patterns:
            if match := re.search(pattern, message):
                return match.group(0)

        return None

    def update_task_from_commit(self, task_id: str, commit: Dict) -> bool:
        """Update task in TASKS.md based on commit"""

        if not self.tasks_path.exists():
            return False

        content = self.tasks_path.read_text()

        # Find task section
        task_pattern = rf"### {re.escape(task_id)}:"

        if not re.search(task_pattern, content):
            return False  # Task not found

        # Determine status from commit message
        status = self.determine_task_status(commit["message"])

        # Update status line
        old_status_pattern = rf"### {re.escape(task_id)}: .* (⏳|🔄)"
        new_status = f"### {task_id}: {self.extract_task_title(commit['message'])} {status}"

        new_content = re.sub(old_status_pattern, new_status, content)

        if status == "✅ ВЫПОЛНЕНО":
            # Add completion info
            new_content = self.add_completion_info(new_content, task_id, commit)

        # Recalculate progress
        new_content = self.recalculate_progress(new_content)

        self.tasks_path.write_text(new_content)
        return True

    def determine_task_status(self, message: str) -> str:
        """Determine task status from commit message"""

        message_lower = message.lower()

        if any(word in message_lower for word in ["complete", "done", "готово", "заверш"]):
            return "✅ ВЫПОЛНЕНО"
        elif any(word in message_lower for word in ["fix", "start", "начало"]):
            return "🔄 В_РАБОТЕ"
        else:
            return "🔄 В_РАБОТЕ"

    def extract_task_title(self, message: str) -> str:
        """Extract clean task title from commit message"""

        # Remove task ID, prefixes, etc.
        title = message

        # Remove task IDs
        for pattern in [r"TASK-\d+:\s*", r"INIT-\d+:\s*", r"PRJ-\d+:\s*", r"#\d+\s*"]:
            title = re.sub(pattern, "", title)

        # Remove common prefixes
        for prefix in ["[Session N]", "fix:", "feat:", "chore:"]:
            title = title.replace(prefix, "").strip()

        return title[:50] + "..." if len(title) > 50 else title

    def add_completion_info(self, content: str, task_id: str, commit: Dict) -> str:
        """Add completion info to task in TASKS.md"""

        task_section = re.search(
            rf"### {re.escape(task_id)}:.*?(?=###\n|\Z)",
            content,
            re.DOTALL
        )

        if not task_section:
            return content

        section_text = task_section.group(0)

        # Check if already has completion info
        if "**Завершено:**" in section_text:
            return content

        # Find the line after status line and add completion
        completion_line = f"- **Завершено:** {datetime.now().strftime('%Y-%m-%d')}\n"
        commit_line = f"- **Коммит:** {commit['hash'][:7]}\n"

        # Insert after status line
        new_section = re.sub(
            rf"(### {re.escape(task_id)}: .* ✅ ВЫПОЛНЕНО\n)",
            rf"\1{completion_line}{commit_line}",
            section_text
        )

        # Replace in content
        return content.replace(section_text, new_section)

    def recalculate_progress(self, content: str) -> str:
        """Recalculate overall progress percentage"""

        # Count total and completed tasks
        all_tasks = len(re.findall(r"### (?:TASK|INIT|PRJ|PHASE)-[\d:]+", content))
        completed = len(re.findall(r"✅ ВЫПОЛНЕНО", content))

        progress = int((completed / all_tasks * 100)) if all_tasks > 0 else 0

        # Update progress line
        progress_pattern = r"\*\*Общий Прогресс:\*\*\s*\d+%"
        progress_line = f"**Общий Прогресс:** {progress}%"

        new_content = re.sub(progress_pattern, progress_line, content)

        # Also update phase progress bars
        new_content = self.update_phase_progress(new_content)

        return new_content

    def update_phase_progress(self, content: str) -> str:
        """Update individual phase progress bars"""

        phases = re.findall(r"## 🎯 Фаза \d+: (.+?) \| (.+?) \| (\d+)%", content)

        for phase_name, _, _ in phases:
            # Find phase section
            phase_section = re.search(
                rf"## 🎯 Фаза \d+: {re.escape(phase_name)}.*?(?=## 🎯 Фаза|\Z)",
                content,
                re.DOTALL
            )

            if not phase_section:
                continue

            section_text = phase_section.group(0)

            # Count tasks in phase
            phase_tasks = len(re.findall(r"### [\w-]+:", section_text))
            phase_completed = len(re.findall(r"✅ ВЫПОЛНЕНО", section_text))

            phase_progress = int((phase_completed / phase_tasks * 100)) if phase_tasks > 0 else 0

            # Update progress bar
            old_bar = rf"## 🎯 Фаза \d+: {re.escape(phase_name)} \| (.+?) \| \d+%"
            new_bar = f"## 🎯 Фаза \\#: {phase_name} | {'✅ Завершена' if phase_progress == 100 else '🔄 В работе'} | {phase_progress}%"

            content = re.sub(old_bar, new_bar, content)

        return content

    def should_add_to_changelog(self, commit: Dict) -> bool:
        """Determine if commit should be in CHANGELOG"""

        message = commit["message"].lower()

        # Skip if:
        if "merge" in message:
            return False

        if message.startswith(("docs:", "chore:", "style:", "refactor:")):
            # Only add if significant (many files changed)
            return len(commit["files_changed"]) > 3

        # Include if:
        return any([
            "add" in message or "созда" in message or "новы" in message,
            "fix" in message or "исправл" in message or "ошибк" in message,
            "update" in message or "обновл" in message or "изменен" in message,
            len(commit["files_changed"]) > 2
        ])

    def add_changelog_entry(self, commit: Dict) -> None:
        """Add entry to CHANGELOG.md"""

        if not self.changelog_path.exists():
            self.create_changelog()

        content = self.changelog_path.read_text()

        # Determine category
        category = self.categorize_commit(commit["message"])

        # Format entry
        short_hash = commit['hash'][:7]
        entry = f"- {commit['message'].strip()} ({short_hash})\n"

        # Insert in [Unreleased] section
        if "## [Unreleased]" not in content:
            # Add [Unreleased] section
            content = re.sub(
                "(# 📝 Changelog.*?\n\n)",
                r"\1## [Unreleased]\n\n",
                content
            )

        # Check if category exists in [Unreleased]
        unreleased_section = re.search(
            r"## \[Unreleased\](.*?)(?=## \[|\Z)",
            content,
            re.DOTALL
        )

        if not unreleased_section:
            return

        unreleased_text = unreleased_section.group(1)

        if f"### {category}" in unreleased_text:
            # Append to existing category
            pattern = rf"(## \[Unreleased\].*?### {category}\n)"
            replacement = rf"\1{entry}"
            content = re.sub(pattern, replacement, content, count=1)
        else:
            # Add new category after ## [Unreleased]
            pattern = r"(## \[Unreleased\]\n\n)"
            replacement = rf"\1### {category}\n{entry}\n\n"
            content = re.sub(pattern, replacement, content)

        self.changelog_path.write_text(content)

    def categorize_commit(self, message: str) -> str:
        """Categorize commit for changelog"""

        message_lower = message.lower()

        if any(word in message_lower for word in ["add", "create", "новы", "созда", "генерирова"]):
            return "Added"
        elif any(word in message_lower for word in ["fix", "bug", "исправл", "ошибк"]):
            return "Fixed"
        elif any(word in message_lower for word in ["remove", "delete", "удален"]):
            return "Removed"
        else:
            return "Changed"

    def create_changelog(self):
        """Create new CHANGELOG.md"""

        content = """# 📝 Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/ru-RU/1.0.0/).

## [Unreleased]

### Added
- Initial project setup

---

## 🔄 History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | TBD | Initial release |

---
"""
        self.changelog_path.write_text(content)

    def finalize_session(self) -> str:
        """Generate session entry when ending"""

        commits = self.get_commits_since_last_session()
        tasks_completed = self.get_completed_tasks()
        files_changed_count = self.get_changed_files_count()

        session_number = self.get_next_session_number()
        date = datetime.now().strftime("%Y-%m-%d")
        duration = self.get_session_duration()

        entry = f"""
### Session #{session_number} - {date}
**Длительность:** ~{duration}
**Фокус:** {self.get_main_focus(commits)}

**Выполненные задачи:**
{self.format_completed_tasks(tasks_completed)}

**Файлы изменено:** {files_changed_count}
**Коммитов:** {len(commits)}

**Решения:**
{self.extract_decisions(commits)}

**Следующие шаги:**
{self.suggest_next_steps()}

---

*Generated by Session Tracker Agent*
"""

        # Append to SESSION.md
        if not self.session_path.exists():
            self.create_session()

        content = self.session_path.read_text()

        # Check if session already exists
        if f"### Session #{session_number}" in content:
            return content  # Already exists

        # Insert before Session History
        content = content.replace(
            "## Session History",
            f"{entry}\n\n## Session History"
        )

        self.session_path.write_text(content)

        return entry

    def create_session(self):
        """Create new SESSION.md"""

        content = """# 💬 Session History - System Prompts

> [🏠 Главная](README.md) → [💬 Sessions](#)

---

## Session History

### Session #1 - Project Initialization
**Дата:** 2025-01-31

**Что было сделано:**
- Project Initializer Agent создан
- Auto-tracking system реализован

---

"""
        self.session_path.write_text(content)

    def get_next_session_number(self) -> int:
        """Get next session number"""

        if not self.session_path.exists():
            return 1

        content = self.session_path.read_text()

        sessions = re.findall(r"### Session #(\d+)", content)
        return max([int(s) for s in sessions]) + 1 if sessions else 1

    def get_commits_since_last_session(self) -> List[Dict]:
        """Get commits since last session"""

        # Simple implementation: get last 10 commits
        result = subprocess.run(
            ["git", "log", "-10", "--format=%H|%s|%an"],
            capture_output=True,
            text=True,
            cwd=self.root
        )

        commits = []
        for line in result.stdout.strip().split("\n"):
            if line:
                parts = line.split("|")
                commits.append({
                    "hash": parts[0],
                    "message": parts[1] if len(parts) > 1 else "",
                    "author": parts[2] if len(parts) > 2 else ""
                })

        return commits

    def get_completed_tasks(self) -> List[str]:
        """Get completed tasks from TASKS.md"""

        if not self.tasks_path.exists():
            return []

        content = self.tasks_path.read_text()

        # Find recently completed tasks
        completed = re.findall(r"### ([\w-]+): .* ✅ ВЫПОЛНЕНО", content)
        return completed[-5:] if completed else []

    def format_completed_tasks(self, tasks: List[str]) -> str:
        """Format completed tasks list"""

        if not tasks:
            return "- Нет завершённых задач"

        return "\n".join(f"- {task} ✅" for task in tasks)

    def get_session_duration(self) -> str:
        """Calculate session duration"""

        if not self.state_file.exists():
            return "0 мин"

        state = json.loads(self.state_file.read_text())
        start = datetime.fromisoformat(state["session_start"])
        duration = datetime.now() - start

        hours = int(duration.total_seconds() // 3600)
        mins = int((duration.total_seconds() % 3600) // 60)

        if hours > 0:
            return f"~{hours}ч {mins}мин"
        return f"~{mins}мин"

    def get_main_focus(self, commits: List[Dict]) -> str:
        """Determine main focus from commits"""

        if not commits:
            return "Разработка"

        # Analyze commit messages
        messages = " ".join([c["message"] for c in commits])

        if "initialization" in messages.lower() or "инициализа" in messages.lower():
            return "Инициализация проекта"
        elif "agent" in messages.lower():
            return "Разработка агентов"
        elif "fix" in messages.lower():
            return "Исправление ошибок"
        else:
            return "Разработка"

    def extract_decisions(self, commits: List[Dict]) -> str:
        """Extract decisions from commits"""

        if not commits:
            return "- Решений не зафиксировано"

        decisions = []
        for commit in commits:
            if "decision" in commit["message"].lower() or "решени" in commit["message"].lower():
                decisions.append(f"- {commit['message'][:60]}...")

        return "\n".join(decisions) if decisions else "- Решений не зафиксировано"

    def suggest_next_steps(self) -> str:
        """Suggest next steps based on TASKS.md"""

        if not self.tasks_path.exists():
            return "- Создать TASKS.md"

        content = self.tasks_path.read_text()

        # Find first pending task
        pending = re.search(r"### ([\w-]+): .* ⏳\n", content)

        if pending:
            task_id = pending.group(1)
            return f"- Продолжить с {task_id}"

        return "- Определить следующие задачи"

    def get_changed_files_count(self) -> int:
        """Get count of changed files in session"""

        # Simple implementation
        result = subprocess.run(
            ["git", "diff", "--name-only", "HEAD~10"],
            capture_output=True,
            text=True,
            cwd=self.root
        )

        if result.returncode != 0:
            return 0

        files = [f for f in result.stdout.strip().split("\n") if f]
        return len(files)

    def save_state(self, commit: Dict):
        """Save session state"""

        state = {
            "last_commit": commit["hash"],
            "last_commit_date": commit["date"],
            "files_changed": commit["files_changed"]
        }

        # If new session, initialize
        if not self.state_file.exists():
            state["session_start"] = datetime.now().isoformat()
            state["session_number"] = self.get_next_session_number()

        self.state_file.write_text(json.dumps(state, indent=2))

    def get_state(self) -> Dict:
        """Get current session state"""

        if not self.state_file.exists():
            return {}

        return json.loads(self.state_file.read_text())


# CLI interface
def main():
    """CLI interface for auto-tracker"""

    if len(sys.argv) < 2:
        print("Usage:")
        print("  auto-track.py track-commit [commit-hash]")
        print("  auto-track.py finalize-session")
        print("  auto-track.py update-progress")
        sys.exit(1)

    tracker = DocumentationTracker()
    command = sys.argv[1]

    if command == "track-commit":
        commit = sys.argv[2] if len(sys.argv) > 2 else "HEAD"
        result = tracker.track_commit(commit)

        if result["task_updated"]:
            print(f"✓ Task updated")
        if result["changelog_updated"]:
            print(f"✓ CHANGELOG.md updated")
        if result["progress_updated"]:
            print(f"✓ Progress recalculated")

    elif command == "finalize-session":
        entry = tracker.finalize_session()
        print("✓ SESSION.md updated")
        print(entry[:200] + "...")

    elif command == "update-progress":
        if tracker.tasks_path.exists():
            content = tracker.tasks_path.read_text()
            new_content = tracker.recalculate_progress(content)
            tracker.tasks_path.write_text(new_content)
            print("✓ Progress updated")
        else:
            print("✗ TASKS.md not found")

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
