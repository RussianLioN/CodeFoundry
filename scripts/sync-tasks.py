#!/usr/bin/env python3
"""
TASKS.md ↔ GitHub Issues Sync Script

Unidirectional synchronization: TASKS.md (source of truth) → GitHub Issues (mirror)

Usage:
    python sync-tasks.py --dry-run          # Preview changes
    python sync-tasks.py --push             # Create/update issues
    python sync-tasks.py --validate         # Check consistency
    python sync-tasks.py --status           # Show comparison

Safety:
    - Dry-run mode by default
    - Automatic backup before write
    - Interactive confirmation
    - Conflict logging
"""

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from subprocess import run, PIPE
from typing import Optional, List, Dict, Tuple


# =============================================================================
# Configuration
# =============================================================================

TASKS_MD_PATH = Path("TASKS.md")
BACKUP_DIR = Path("scripts/backups")
CONFLICTS_FILE = Path("scripts/conflicts.json")

# Status mapping
STATUS_MAP = {
    "✅": ("done", "Done"),
    "🔄": ("in_progress", "In Progress"),
    "⏳": ("pending", "Pending"),
    "❌": ("blocked", "Blocked"),
}

# Priority mapping (from context)
PRIORITY_MAP = {
    "critical": "priority:critical",
    "high": "priority:high",
    "medium": "priority:medium",
    "low": "priority:low",
}


# =============================================================================
# Data Classes
# =============================================================================

@dataclass
class Task:
    """Task from TASKS.md"""
    id: str
    title: str
    status: str
    progress: str
    dependencies: List[str]
    phase: Optional[str] = None
    priority: Optional[str] = None
    description: Optional[str] = None
    files: List[str] = field(default_factory=list)
    issue_number: Optional[int] = None

    def __hash__(self):
        return hash(self.id)


# =============================================================================
# TASKS.md Parser
# =============================================================================

class TasksParser:
    """Parse TASKS.md structured headers format"""

    def __init__(self, content: str):
        self.content = content
        self.tasks: Dict[str, Task] = {}
        self.current_phase: Optional[str] = None

    def parse(self) -> Dict[str, Task]:
        """Parse TASKS.md and return tasks dictionary"""
        lines = self.content.split('\n')
        i = 0

        while i < len(lines):
            line = lines[i]

            # Detect phase headers (Фаза 1, Фаза 2, etc.)
            phase_match = re.match(r'##\s+.*?Фаза\s+(\d+[.\d+]*)', line)
            if phase_match:
                self.current_phase = phase_match.group(1)
                i += 1
                continue

            # Detect task headers: ### TASK-ID: Task Title [STATUS]
            task_match = re.match(r'###\s+([A-Z]+-\d+):\s+(.+?)\s+([✅🔄⏳❌])', line)
            if task_match:
                task = self._parse_task_header(task_match, lines, i)
                if task:
                    self.tasks[task.id] = task
                i += 1
                continue

            i += 1

        return self.tasks

    def _parse_task_header(self, match, lines: List[str], start_idx: int) -> Optional[Task]:
        """Parse a task from its header and following lines"""
        task_id = match.group(1)
        title = match.group(2).strip()
        status_emoji = match.group(3)

        # Map status emoji to label
        status_key, status_label = STATUS_MAP.get(status_emoji, ("pending", "Unknown"))

        # Parse task details from following lines
        description = None
        priority = None
        files = []
        dependencies = []
        completed_date = None
        progress = "100%" if status_key == "done" else ("0%" if status_key == "pending" else "50%")

        i = start_idx + 1
        while i < len(lines):
            line = lines[i].strip()

            # Stop at next task or section
            if line.startswith("###") or line.startswith("##"):
                break

            # Parse fields
            if line.startswith("- **Описание:**"):
                description = line.split(":", 1)[1].strip()
            elif line.startswith("- **Приоритет:**"):
                priority = line.split(":", 1)[1].strip().lower()
                # Map Russian priority to English
                priority_map = {
                    "критический": "critical",
                    "высокий": "high",
                    "средний": "medium",
                    "низкий": "low",
                }
                priority = priority_map.get(priority, priority)
            elif line.startswith("- **Завершено:**"):
                completed_date = line.split(":", 1)[1].strip()
            elif line.startswith("- **Файлы:**"):
                # Parse file list (next lines with - ✅ or - ⏳)
                i += 1
                while i < len(lines):
                    file_line = lines[i].strip()
                    if not file_line.startswith("-") or file_line.startswith("- **"):
                        break
                    # Extract filename from "- ✅ filename" or "- ⏳ filename"
                    file_match = re.match(r'-\s+[✅⏳❌]\s+(.+)', file_line)
                    if file_match:
                        files.append(file_match.group(1).strip())
                    i += 1
                continue
            elif line.startswith("- **Зависимости:**"):
                deps_str = line.split(":", 1)[1].strip()
                dependencies = re.findall(r'([A-Z]+-\d+)', deps_str)

            i += 1

        # Extract issue number if present
        issue_number = None
        issue_match = re.search(r'#(\d+)', title)
        if issue_match:
            issue_number = int(issue_match.group(1))

        return Task(
            id=task_id,
            title=title,
            status=status_key,
            progress=progress,
            dependencies=dependencies,
            phase=self.current_phase,
            priority=priority,
            description=description,
            files=files,
            issue_number=issue_number,
        )


# =============================================================================
# GitHub API Client
# =============================================================================

class GitHubClient:
    """GitHub API client using gh CLI"""

    def __init__(self, dry_run: bool = False):
        self.dry_run = dry_run

    def _run_gh(self, args: List[str]) -> str:
        """Run gh CLI command and return output"""
        cmd = ["gh"] + args
        if self.dry_run:
            print(f"[DRY RUN] Would run: {' '.join(cmd)}")
            return ""

        result = run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"gh command failed: {result.stderr}")
        return result.stdout

    def get_issues(self) -> List[Dict]:
        """Get all issues in the repository"""
        try:
            output = self._run_gh([
                "issue", "list",
                "--limit", "1000",
                "--json", "number,title,state,labels,body"
            ])
            if self.dry_run:
                return []

            return json.loads(output)
        except RuntimeError:
            return []

    def create_issue(self, title: str, body: str, labels: List[str]) -> int:
        """Create a new issue and return its number"""
        labels_arg = ",".join(labels)
        output = self._run_gh([
            "issue", "create",
            "--title", title,
            "--body", body,
            "--label", labels_arg
        ])
        # Extract issue number from output
        match = re.search(r'https://github.com/[^/]+/[^/]+/issues/(\d+)', output)
        if match:
            return int(match.group(1))
        raise RuntimeError(f"Failed to extract issue number from: {output}")

    def update_issue(self, number: int, title: Optional[str] = None,
                     body: Optional[str] = None, labels: Optional[List[str]] = None,
                     state: Optional[str] = None) -> None:
        """Update an existing issue"""
        args = ["issue", "edit", str(number)]

        if title:
            args.extend(["--title", title])
        if body:
            args.extend(["--body", body])
        if labels:
            args.extend(["--add-label", ",".join(labels)])
        if state:
            args.extend(["--state", state])

        self._run_gh(args)

    def close_issue(self, number: int, comment: str) -> None:
        """Close an issue with a comment"""
        self._run_gh(["issue", "close", str(number), "--comment", comment])


# =============================================================================
# Issue Mapper
# =============================================================================

class IssueMapper:
    """Map tasks to GitHub issues"""

    def __init__(self, github_client: GitHubClient):
        self.gh = github_client

    def task_to_issue(self, task: Task) -> Tuple[str, str, List[str]]:
        """Convert task to issue (title, body, labels)"""
        # Title
        title = f"[{task.id}] {task.title}"

        # Labels
        labels = [
            f"status:{task.status}",
            f"phase:{task.phase or 'unknown'}",
        ]
        if task.priority:
            labels.append(PRIORITY_MAP.get(task.priority, f"priority:{task.priority}"))

        # Body
        body = f"""## [{task.id}] {task.title}

**Status:** {STATUS_MAP.get(task.status, ('', task.status))[1]}
**Progress:** {task.progress}
**Phase:** {task.phase or 'Unknown'}

{f"**Priority:** {task.priority.capitalize()}" if task.priority else ""}

### Dependencies
{', '.join(task.dependencies) if task.dependencies else 'None'}

{f"### Files\n" + '\n'.join(f'- {f}' for f in task.files) if task.files else ""}

---

_Synced from TASKS.md on {datetime.now().strftime('%Y-%m-%d')}_
"""

        return title, body, labels

    def get_issue_status(self, issue: Dict) -> Optional[str]:
        """Extract status from issue labels"""
        for label in issue.get("labels", []):
            if label.get("name", "").startswith("status:"):
                return label["name"].replace("status:", "")
        return None


# =============================================================================
# Backup Manager
# =============================================================================

class BackupManager:
    """Manage TASKS.md backups"""

    def __init__(self):
        self.backup_dir = BACKUP_DIR
        self.backup_dir.mkdir(parents=True, exist_ok=True)

    def create_backup(self, content: str) -> Path:
        """Create a timestamped backup"""
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        backup_path = self.backup_dir / f"TASKS.md.backup-{timestamp}"

        with open(backup_path, 'w') as f:
            f.write(content)

        return backup_path

    def list_backups(self) -> List[Path]:
        """List all backups"""
        return sorted(self.backup_dir.glob("TASKS.md.backup-*"), reverse=True)


# =============================================================================
# Conflict Logger
# =============================================================================

class ConflictLogger:
    """Log sync conflicts"""

    def __init__(self):
        self.conflicts: List[Dict] = []

    def add_conflict(self, task_id: str, local_status: str,
                     remote_status: str, resolution: str) -> None:
        """Add a conflict entry"""
        self.conflicts.append({
            "timestamp": datetime.now().isoformat(),
            "task_id": task_id,
            "local_status": local_status,
            "remote_status": remote_status,
            "resolution": resolution,
        })

    def save(self) -> None:
        """Save conflicts to file"""
        with open(CONFLICTS_FILE, 'w') as f:
            json.dump({
                "timestamp": datetime.now().isoformat(),
                "conflicts": self.conflicts,
            }, f, indent=2)


# =============================================================================
# Sync Operations
# =============================================================================

class TasksSync:
    """Main sync operations"""

    def __init__(self, dry_run: bool = False):
        self.dry_run = dry_run
        self.gh_client = GitHubClient(dry_run=dry_run)
        self.mapper = IssueMapper(self.gh_client)
        self.backup_manager = BackupManager()
        self.conflict_logger = ConflictLogger()

        # Load TASKS.md
        with open(TASKS_MD_PATH, 'r') as f:
            self.tasks_md_content = f.read()

        parser = TasksParser(self.tasks_md_content)
        self.tasks = parser.parse()

    def validate(self) -> bool:
        """Validate consistency between TASKS.md and GitHub Issues"""
        issues = self.gh_client.get_issues()
        issues_by_title = {issue["title"]: issue for issue in issues}

        all_valid = True
        orphaned_issues = []

        # Check all tasks have issues
        for task in self.tasks.values():
            title = f"[{task.id}] {task.title}"
            if title not in issues_by_title:
                print(f"⚠ Task {task.id} has no corresponding issue")
                all_valid = False
            else:
                issue = issues_by_title[title]
                issue_status = self.mapper.get_issue_status(issue)
                if issue_status != task.status:
                    print(f"⚠ Status mismatch for {task.id}: TASKS.md={task.status}, Issue={issue_status}")
                    all_valid = False

        # Check for orphaned issues
        for issue in issues:
            # Extract task ID from title
            match = re.match(r'\[([A-Z]+-\d+)\]', issue["title"])
            if match:
                task_id = match.group(1)
                if task_id not in self.tasks:
                    orphaned_issues.append(f"#{issue['number']}: {issue['title']}")

        if orphaned_issues:
            print(f"\n⚠ {len(orphaned_issues)} orphaned issues found:")
            for issue in orphaned_issues:
                print(f"  - {issue}")

        if all_valid and not orphaned_issues:
            print("✓ Validation passed: All tasks in sync")
        else:
            print(f"\n{'✓' if all_valid else '✗'} Validation result: {'PASS' if all_valid else 'FAIL'}")

        return all_valid

    def status(self) -> None:
        """Show status comparison"""
        issues = self.gh_client.get_issues()
        issues_by_title = {issue["title"]: issue for issue in issues}

        print("\nTASKS.md vs GitHub Issues Status:\n")
        print("┌─────────────┬──────────────┬──────────────┬─────────┐")
        print("│ Task ID     │ TASKS.md     │ Issue #      │ Match   │")
        print("├─────────────┼──────────────┼──────────────┼─────────┤")

        mismatches = 0
        for task in sorted(self.tasks.values(), key=lambda t: t.id):
            title = f"[{task.id}] {task.title}"
            issue = issues_by_title.get(title)

            if issue:
                issue_status = self.mapper.get_issue_status(issue)
                match = "✓" if issue_status == task.status else "⚠"
                if issue_status != task.status:
                    mismatches += 1
                print(f"│ {task.id:<11} │ {task.status:<12} │ #{issue['number']:<12} │ {match:<7} │")
            else:
                print(f"│ {task.id:<11} │ {task.status:<12} │ {'N/A':<12} │ ✗ │")

        print("└─────────────┴──────────────┴──────────────┴─────────┘")

        if mismatches > 0:
            print(f"\n⚠ Mismatches: {mismatches}")
            print("Run `/sync-tasks push` to sync.")
        else:
            print("\n✓ All statuses match!")

    def push(self) -> None:
        """Push tasks to GitHub Issues"""
        # Backup first
        backup_path = self.backup_manager.create_backup(self.tasks_md_content)
        print(f"✓ Backup created: {backup_path}")

        # Get existing issues
        issues = self.gh_client.get_issues()
        issues_by_title = {issue["title"]: issue for issue in issues}

        # Plan changes
        to_create = []
        to_update = []
        to_skip = []

        for task in self.tasks.values():
            title = f"[{task.id}] {task.title}"

            if title not in issues_by_title:
                to_create.append(task)
            else:
                issue = issues_by_title[title]
                issue_status = self.mapper.get_issue_status(issue)

                if issue_status != task.status:
                    to_update.append((task, issue))
                else:
                    to_skip.append(task)

        # Show summary
        print(f"\n✓ Parsed {len(self.tasks)} tasks from TASKS.md")
        print(f"✓ Fetched {len(issues)} existing issues")
        print(f"\nPlanned changes:")
        print(f"  New issues to create: {len(to_create)}")
        print(f"  Issues to update: {len(to_update)}")
        print(f"  Unchanged: {len(to_skip)}")

        if self.dry_run:
            print("\n[DRY RUN] Changes would be:")
            for task in to_create:
                print(f"  [NEW] {task.id}: {task.title}")
            for task, issue in to_update:
                print(f"  [UPDATE] {task.id} (#{issue['number']}): {task.status} → {issue['state']}")
            return

        # Confirm
        if to_create or to_update:
            response = input(f"\nContinue with sync? (y/n): ")
            if response.lower() != 'y':
                print("Sync cancelled.")
                return

        # Create new issues
        for task in to_create:
            try:
                title, body, labels = self.mapper.task_to_issue(task)
                issue_number = self.gh_client.create_issue(title, body, labels)
                print(f"✓ Created issue #{issue_number} for {task.id}")
            except Exception as e:
                print(f"✗ Failed to create issue for {task.id}: {e}")

        # Update existing issues
        for task, issue in to_update:
            try:
                title, body, labels = self.mapper.task_to_issue(task)
                self.gh_client.update_issue(issue['number'], body=body, labels=labels)
                print(f"✓ Updated issue #{issue['number']} for {task.id}")
            except Exception as e:
                print(f"✗ Failed to update issue for {task.id}: {e}")

        # Save conflicts
        if self.conflict_logger.conflicts:
            self.conflict_logger.save()
            print(f"\n⚠ {len(self.conflict_logger.conflicts)} conflicts logged to {CONFLICTS_FILE}")

        print("\n✓ Sync complete!")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="TASKS.md ↔ GitHub Issues Sync",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python sync-tasks.py --dry-run       # Preview changes
  python sync-tasks.py --push          # Create/update issues
  python sync-tasks.py --validate      # Check consistency
  python sync-tasks.py --status        # Show comparison
        """
    )

    parser.add_argument("--dry-run", action="store_true",
                        help="Preview changes without making them")
    parser.add_argument("--push", action="store_true",
                        help="Push TASKS.md to GitHub Issues")
    parser.add_argument("--validate", action="store_true",
                        help="Validate consistency")
    parser.add_argument("--status", action="store_true",
                        help="Show status comparison")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Verbose output")

    args = parser.parse_args()

    # Default to dry-run if no action specified
    if not (args.push or args.validate or args.status):
        args.dry_run = True
        args.push = True
        print("No action specified, running in dry-run mode...\n")

    try:
        sync = TasksSync(dry_run=args.dry_run)

        if args.validate:
            valid = sync.validate()
            sys.exit(0 if valid else 1)
        elif args.status:
            sync.status()
        elif args.push:
            sync.push()

    except FileNotFoundError as e:
        print(f"Error: {e}")
        print(f"Make sure {TASKS_MD_PATH} exists in the current directory.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        if args.verbose:
            import traceback
            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
