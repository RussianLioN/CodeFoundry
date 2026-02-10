# 📚 Session Tracker Agent

> [🏠 Главная](README.md) → [🦞 OpenClaw](openclaw/README.md) → [🤖 Agents](workspace/AGENTS.md) → [📚 Session Tracker](#)

---

## Agent Overview

**Role:** Documentation Tracking & Auto-Update Agent
**Model:** GPT-4 / Claude Sonnet
**Mode:** Passive observer + Active updater

The Session Tracker Agent automatically updates project documentation (TASKS.md, SESSION.md, CHANGELOG.md) as work progresses.

---

## 🎯 Mission

Ensure project documentation is **always in sync** with actual work without requiring manual updates from developers.

**Success Criteria:**
- TASKS.md updates automatically when tasks complete
- SESSION.md generates entry at session end
- CHANGELOG.md generates entries from commits
- Developer never needs to manually update these files

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AUTO-TRACKING WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  WORK HAPPENS ─────────────────────────────────────────────────┐             │
│  │ Developer writes code, makes commits, etc.             │             │
│  └──────────────────────────┬─────────────────────────────────┘             │
│                             │                                                │
│                             ▼                                                │
│  TRACKER OBSERVES ───────────────────────────────────────────┐              │
│  │ Monitor: git commits, file changes, task completion    │              │
│  └──────────────────────────┬─────────────────────────────────┘              │
│                             │                                                │
│                             ▼                                                │
│  DETECT EVENTS ──────────────────────────────────────────────┤              │
│  │ Event types:                                              │              │
│  │ • Task marked as DONE (TASKS.md comment)                  │              │
│  │ • Commit created with task ID                            │              │
│  │ • Session end signal ("завершить сессию")                │              │
│  │ • File changes detected                                   │              │
│  └──────────────────────────┬─────────────────────────────────┘              │
│                             │                                                │
│                             ▼                                                │
│  UPDATE DOCUMENTS ────────────────────────────────────────────┤              │
│  │ • TASKS.md: Update task status, progress %              │              │
│  │ • SESSION.md: Generate/append session entry              │              │
│  │ • CHANGELOG.md: Generate entry from commit              │              │
│  └──────────────────────────┬─────────────────────────────────┘              │
│                             │                                                │
│                             ▼                                                │
│  COMMIT CHANGES ──────────────────────────────────────────────┤              │
│  │ git add TASKS.md SESSION.md CHANGELOG.md                │              │
│  │ git commit "docs: Auto-update documentation"            │              │
│  └──────────────────────────┬─────────────────────────────────┘              │
│                             │                                                │
│                             ▼                                                │
│  NOTIFY ───────────────────────────────────────────────────────┤              │
│  │ Show summary: "Updated 3 tasks, +15% progress"        │              │
│  └─────────────────────────────────────────────────────────────┘              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Event Types & Triggers

### Event 1: Task Completed

**Trigger:** One of:
```python
# Commit message contains task ID
git commit -m "TASK-001: Implement user authentication"

# Comment in TASKS.md
# TASK-001: Implement user authentication ✅ DONE

# File pattern
# Created/modified file matches task in TASKS.md
```

**Action:** Update TASKS.md
```python
def update_task_status(task_id: str, status: str) -> None:
    """Update task status in TASKS.md"""

    tasks_path = Path("TASKS.md")
    content = tasks_path.read_text()

    # Find task section
    pattern = f"### {task_id}:"

    # Update status line
    old_status = f"### {task_id}: .* ⏳"
    new_status = f"### {task_id}: .* ✅"

    content = re.sub(old_status, new_status, content)

    # Update progress percentage
    progress = calculate_progress()
    content = update_progress_bar(content, progress)

    tasks_path.write_text(content)
```

---

### Event 2: Commit Created

**Trigger:** Git commit created

**Action:** Parse commit and potentially update CHANGELOG.md

```python
def on_commit(commit: dict) -> None:
    """Handle git commit event"""

    message = commit["message"]

    # Check if commit matches task pattern
    if task_id := extract_task_id(message):
        update_task_status(task_id, "IN_PROGRESS")

    # Check if significant for changelog
    if is_significant_commit(message):
        add_changelog_entry(commit)
```

---

### Event 3: Session End

**Trigger:** User says "завершить сессию", "готово", "finish"

**Action:** Generate complete session entry in SESSION.md

```python
def on_session_end() -> dict:
    """Generate session summary from current state"""

    # Collect data
    commits = get_commits_since_last_session()
    tasks_completed = get_completed_tasks()
    files_changed = get_changed_files()
    duration = get_session_duration()

    # Generate entry
    entry = f"""
### Session #{session_number} - {date}

**Duration:** {duration}
**Focus:** {main_focus}

**What was accomplished:**
{generate_accomplishments(tasks_completed)}

**Files changed:** {len(files_changed)}
**Commits:** {len(commits)}

**Decisions made:**
{generate_decisions(commits)}

**Next steps:**
{generate_next_steps(tasks_md)}
"""

    return entry
```

---

### Event 4: File Changes

**Trigger:** Files in monitored paths change

**Action:** Update relevant tasks

```python
def on_file_change(file_path: Path) -> None:
    """Handle file change event"""

    # Map files to tasks
    file_to_task = {
        "src/fsm/states.py": "BOT-001",
        "src/handlers/": "BOT-002",
        # ...
    }

    # Find matching task
    for pattern, task_id in file_to_task.items():
        if str(file_path).startswith(pattern):
            mark_task_in_progress(task_id)
            break
```

---

## 📝 Update Rules

### TASKS.md Updates

**When to update:**
1. Task started → Change status to `🔄 В_РАБОТЕ`
2. Task completed → Change status to `✅ ВЫПОЛНЕНО`
3. Progress changes → Update percentage

**Format:**
```markdown
### TASK-001: Some Task ✅
- **Статус:** ВЫПОЛНЕНО
- **Завершено:** 2025-01-31
- **Коммит:** abc1234
```

---

### SESSION.md Updates

**When to update:**
- Session starts → Create new session header
- Significant action → Add to "What was accomplished"
- Decision made → Add to "Key decisions"
- Session ends → Finalize entry

**Format:**
```markdown
### Session #N - Date

**Duration:** X hours
**Focus:** Topic

**What was accomplished:**
- Task 1 ✅
- Task 2 ✅

**Decisions made:**
- Decision 1: ...

**Next steps:**
- Continue with Task 3
```

---

### CHANGELOG.md Updates

**When to update:**
- Major commit → Add entry
- Session ends → Compile session commits into entry
- Version release → Create version section

**Format:**
```markdown
## [Unreleased]

### Added
- Feature from commit abc123

### Changed
- Modification from commit def456

### Fixed
- Bug fix from commit 789xyz
```

---

## 🔧 Implementation

### Script: auto-track.py

```python
#!/usr/bin/env python3
"""
Auto-Tracking Documentation System

Monitors project activity and updates TASKS.md, SESSION.md, CHANGELOG.md
"""

import re
from pathlib import Path
from datetime import datetime
import subprocess
import json

class DocumentationTracker:
    """Auto-tracker for project documentation"""

    def __init__(self, project_root: Path):
        self.root = project_root
        self.tasks_path = project_root / "TASKS.md"
        self.session_path = project_root / "SESSION.md"
        self.changelog_path = project_root / "CHANGELOG.md"

    def track_commit(self, commit_hash: str) -> dict:
        """Track a single commit"""

        # Get commit info
        commit_info = self.get_commit_info(commit_hash)

        # Extract task ID from message
        task_id = self.extract_task_id(commit_info["message"])

        # Update TASKS.md
        if task_id:
            self.update_task_from_commit(task_id, commit_info)

        # Update CHANGELOG.md
        if self.should_add_to_changelog(commit_info):
            self.add_changelog_entry(commit_info)

        return {
            "task_updated": task_id is not None,
            "changelog_updated": self.should_add_to_changelog(commit_info)
        }

    def extract_task_id(self, message: str) -> str | None:
        """Extract task ID from commit message"""

        patterns = [
            r"TASK-(\d+)",          # TASK-001
            r"INIT-(\d+)",          # INIT-001
            r"#(\d+)",              # #001
            r"\[(\d+)\]",           # [001]
        ]

        for pattern in patterns:
            if match := re.search(pattern, message):
                return match.group(1)

        return None

    def update_task_from_commit(self, task_id: str, commit: dict) -> None:
        """Update task in TASKS.md based on commit"""

        content = self.tasks_path.read_text()

        # Find task section
        task_pattern = f"### (?:TASK|INIT)-{task_id.lstrip('0')}:"

        if not re.search(task_pattern, content):
            return  # Task not found

        # Determine status from commit message
        if "complete" in commit["message"].lower():
            status = "✅ ВЫПОЛНЕНО"
        elif "fix" in commit["message"].lower():
            status = "🔄 В_РАБОТЕ"
        else:
            status = "🔄 В_РАБОТЕ"

        # Update status line
        old_line = f"### (?:TASK|INIT)-{task_id.lstrip('0')}: .* (⏳|🔄)"
        new_line = f"### {task_id}: {commit['message'].split(':')[0]} {status}"

        content = re.sub(old_line, new_line, content)

        # Add completion info if done
        if status == "✅ ВЫПОЛНЕНО":
            task_section = re.search(
                f"### {task_id}:.*?(?=###|\Z)",
                content,
                re.DOTALL
            )
            if task_section and "Завершено:" not in task_section.group():
                # Add completion line
                completion = f"- **Завершено:** {datetime.now().strftime('%Y-%m-%d')}\n"
                content = re.sub(
                    f"(### {task_id}:.*?- \\*\\*Описание:\\*\\*.+?\\n)",
                    f"\\1{completion}",
                    content,
                    flags=re.DOTALL
                )

        # Recalculate progress
        content = self.recalculate_progress(content)

        self.tasks_path.write_text(content)

    def recalculate_progress(self, content: str) -> str:
        """Recalculate overall progress percentage"""

        # Count total and completed tasks
        all_tasks = len(re.findall(r"### (?:TASK|INIT)-\d+:", content))
        completed = len(re.findall(r"### .+? ✅ ВЫПОЛНЕНО", content))

        progress = int((completed / all_tasks * 100)) if all_tasks > 0 else 0

        # Update progress line
        progress_pattern = r"\\*\\*Общий Прогресс:\\*\\*\\s*\\d+%"
        progress_line = f"**Общий Прогресс:** {progress}%"

        content = re.sub(progress_pattern, progress_line, content)

        return content

    def should_add_to_changelog(self, commit: dict) -> bool:
        """Determine if commit should be in CHANGELOG"""

        # Skip if:
        # - Merge commit
        # - "docs:" prefix only
        # - "chore:" prefix
        # - Empty commit

        if "Merge" in commit["message"]:
            return False

        if commit["message"].startswith(("docs:", "chore:", "style:")):
            # Only add if significant
            return len(commit["files_changed"]) > 3

        return True

    def add_changelog_entry(self, commit: dict) -> None:
        """Add entry to CHANGELOG.md"""

        content = self.changelog_path.read_text()

        # Determine category
        message = commit["message"].lower()

        if any(word in message for word in ["add", "create", "новы", "созда"]):
            category = "### Added"
        elif any(word in message for word in ["fix", "bug", "исправл", "ошибк"]):
            category = "### Fixed"
        elif any(word in message for word in ["change", "update", "обновл", "изменен"]):
            category = "### Changed"
        else:
            category = "### Changed"

        # Format entry
        entry = f"- {commit['message'].strip()} ({commit['hash'][:7]})\n"

        # Insert in [Unreleased] section
        pattern = r"(## \[Unreleased\]\n)"
        replacement = f"\\1\n{category}\n{entry}\n"

        if category not in content:
            content = re.sub(pattern, replacement, content)
        else:
            # Append to existing category
            pattern = f"(## \\[Unreleased\\]\n{category}\n)"
            replacement = f"\\1{entry}"
            content = re.sub(pattern, replacement, content)

        self.changelog_path.write_text(content)

    def finalize_session(self) -> str:
        """Generate session entry when ending"""

        commits = self.get_commits_since_last_session()
        tasks_completed = self.get_completed_tasks()

        session_number = self.get_next_session_number()
        date = datetime.now().strftime("%Y-%m-%d")
        duration = self.get_session_duration()

        entry = f"""
### Session #{session_number} - {date}
**Длительность:** ~{duration}
**Фокус:** {self.get_main_focus()}

**Выполненные задачи:**
{self.format_completed_tasks(tasks_completed)}

**Файлы изменено:** {len(self.get_changed_files())}
**Коммитов:** {len(commits)}

**Решения:**
{self.extract_decisions(commits)}

**Следующие шаги:**
{self.suggest_next_steps()}

---

*Generated by Session Tracker Agent*
"""

        # Append to SESSION.md
        content = self.session_path.read_text()
        content = content.replace(
            "## Session History",
            f"{entry}\n\n## Session History"
        )
        self.session_path.write_text(content)

        return entry

    def get_commit_info(self, commit_hash: str) -> dict:
        """Get detailed commit info"""

        result = subprocess.run(
            ["git", "show", "--format=%H%n%s%n%an%n%ad", "--date=short"],
            capture_output=True,
            text=True
        )

        lines = result.stdout.split("\n")
        files_result = subprocess.run(
            ["git", "show", "--name-only", "--format=", commit_hash],
            capture_output=True,
            text=True
        )

        return {
            "hash": lines[0],
            "message": lines[1],
            "author": lines[2],
            "date": lines[3],
            "files_changed": files_result.stdout.strip().split("\n") if files_result.stdout.strip() else []
        }


# CLI interface
def main():
    """CLI interface for auto-tracker"""

    import sys

    tracker = DocumentationTracker(Path.cwd())

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == "track-commit":
            commit = sys.argv[2] if len(sys.argv) > 2 else "HEAD"
            result = tracker.track_commit(commit)
            print(json.dumps(result, indent=2))

        elif command == "finalize-session":
            entry = tracker.finalize_session()
            print(entry)

        elif command == "update-progress":
            tracker.recalculate_progress(tracker.tasks_path.read_text())
            print("Progress updated")


if __name__ == "__main__":
    main()
```

---

## 🎯 Integration Points

### 1. Git Post-Commit Hook

```bash
#!/bin/bash
# .git/hooks/post-commit

# Run auto-tracker
python3 scripts/auto-track.py track-commit HEAD

# Stage updated docs
git add TASKS.md CHANGELOG.md 2>/dev/null || true

# Amend if docs changed (optional, use with caution)
if ! git diff --cached --quiet; then
    git commit --amend --no-edit
fi
```

### 2. Git Alias

```bash
# In .gitconfig
[alias]
    session-end = "!f() { python3 scripts/auto-track.py finalize-session; git add SESSION.md; git commit -m \"docs: Session ended\"; }; f"
```

### 3. Makefile Integration

```makefile
# Makefile

.PHONY: session-end track-update

session-end:
	@echo "📚 Finalizing session..."
	@python3 scripts/auto-track.py finalize-session
	@git add SESSION.md TASKS.md CHANGELOG.md
	@git commit -m "docs: Session ended"

track-update:
	@echo "📊 Updating documentation tracking..."
	@python3 scripts/auto-track.py track-commit HEAD
```

---

## 📊 Tracking Data Structure

```python
# Stored in .tracking/session_state.json

{
    "session_number": 3,
    "session_start": "2025-01-31T10:00:00Z",
    "last_commit": "abc1234",
    "tasks_completed": ["TASK-001", "TASK-003"],
    "files_changed": 15,
    "commits_count": 7
}
```

---

## 🔗 Related Files

- `@ref: scripts/auto-track.py` — Implementation script
- `@ref: openclaw/workspace/agents/session-tracker.md` — This agent
- `@ref: scripts/git-hooks/post-commit` — Git hook
- `@ref: Makefile` — make commands

---

## 🚨 Error Handling

### If TASKS.md is corrupted

```python
def validate_tasks_md(content: str) -> bool:
    """Validate TASKS.md structure"""

    required_sections = [
        "## Статус Проекта:",
        "## 📊 Сводка Прогресса",
        "## 📋 Легенда Статусов"
    ]

    for section in required_sections:
        if section not in content:
            print(f"⚠️ Missing section: {section}")
            return False

    return True
```

### If git operations fail

```python
def safe_git_operation(operation, *args, **kwargs):
    """Execute git operation with error handling"""

    try:
        result = subprocess.run(
            ["git"] + list(args),
            capture_output=True,
            text=True,
            **kwargs
        )

        if result.returncode != 0:
            print(f"⚠️ Git failed: {result.stderr}")
            return None

        return result

    except Exception as e:
        print(f"❌ Error: {e}")
        return None
```

---

## 📝 Communication Style

When updating docs:
- Show what changed: "Updated TASK-001 status to ✅"
- Show progress: "Progress: 60% → 65%"
- Be concise: one line updates
- Don't interrupt flow unless error

---

> Created for: CodeFoundry Auto-Tracking System
> Version: 1.0.0
> Last updated: 2025-01-31
