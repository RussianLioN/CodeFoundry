#!/usr/bin/env python3
"""
Documentation Validation Script
Validates @ref links, token budgets, stale docs, orphans, and coverage

Usage:
    scripts/validate-docs.py [OPTIONS]

Options:
    --all          Run all checks (default)
    --ref-check    Validate @ref links
    --stale-check  Find stale documentation
    --orphan-check Find orphaned .md files
    --token-check  Validate token budgets
    --coverage     Check documentation coverage
    --report       Generate human-readable report
    --help         Show this help

Examples:
    make doc-check
    scripts/validate-docs.py --ref-check
    scripts/validate-docs.py --stale-check
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Tuple, Dict, Any

# Colors for output
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

# Project root
PROJECT_ROOT = Path(__file__).parent.parent
SCRIPT_DIR = PROJECT_ROOT / "scripts"


class DocValidator:
    """Documentation validator with multiple checks"""

    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.results: List[str] = []
        self.failed = False

    def log_info(self, msg: str):
        print(f"{BLUE}[INFO]{NC} {msg}")

    def log_success(self, msg: str):
        print(f"{GREEN}[PASS]{NC} {msg}")

    def log_warning(self, msg: str):
        print(f"{YELLOW}[WARN]{NC} {msg}")

    def log_error(self, msg: str):
        print(f"{RED}[FAIL]{NC} {msg}")

    def check_refs(self) -> bool:
        """Validate @ref links"""
        self.log_info("Validating @ref links...")

        check_refs = SCRIPT_DIR / "check-refs.py"
        if not check_refs.exists():
            self.log_error("check-refs.py not found")
            return False

        result = subprocess.run(
            ["python3", str(check_refs), "--quiet"],
            capture_output=True,
            text=True,
            cwd=str(self.project_root)
        )

        if result.returncode == 0:
            self.log_success("@ref links: all valid")
            return True
        else:
            self.log_error("@ref links: validation failed")
            print(result.stderr)
            return False

    def check_stale(self, stale_days: int = 30) -> bool:
        """Check for stale documentation"""
        self.log_info(f"Checking for stale documentation (>{stale_days} days)...")

        stale_files = []
        current_time = datetime.now()

        # Find .md files
        md_files = self.project_root.rglob("*.md")
        md_files = [f for f in md_files if "node_modules" not in f.parts
                     and ".git" not in f.parts and "tasks/archive" not in f.parts]

        for file in md_files:
            # Get git modification time
            try:
                git_result = subprocess.run(
                    ["git", "log", "-1", "--format=%ct", str(file)],
                    capture_output=True,
                    text=True,
                    cwd=str(self.project_root)
                )
                file_timestamp = int(git_result.stdout.strip()) if git_result.stdout.strip() else 0
            except:
                # Fallback to file modification time
                file_timestamp = file.stat().st_mtime

            file_age = (current_time - datetime.fromtimestamp(file_timestamp)).days

            if file_age > stale_days:
                stale_files.append(f"{file.relative_to(self.project_root)} ({file_age} days)")

        if not stale_files:
            self.log_success(f"No stale documentation found (>{stale_days} days)")
            return True
        else:
            self.log_warning(f"Found {len(stale_files)} stale documentation files:")
            for f in stale_files:
                print(f"  - {f}")
            return False

    def check_orphans(self) -> bool:
        """Check for orphaned .md files"""
        self.log_info("Checking for orphaned .md files...")

        orphans = []
        md_files = list(self.project_root.rglob("*.md"))
        md_files = [f for f in md_files if "node_modules" not in f.parts
                     and ".git" not in f.parts and "tasks/archive" not in f.parts]

        for file in md_files:
            filename = file.name

            # Skip index files
            if filename in ("INDEX.md", "index.md"):
                continue

            # Check if any other .md file references this file
            has_link = False
            for other_file in md_files:
                if other_file == file:
                    continue

                content = other_file.read_text()
                # Check for @ref or markdown links
                if f"[@ref:" in content or filename in content:
                    has_link = True
                    break

            if not has_link:
                orphans.append(str(file.relative_to(self.project_root)))

        if not orphans:
            self.log_success("No orphaned .md files found")
            return True
        else:
            self.log_warning(f"Found {len(orphans)} orphaned .md files:")
            for f in orphans:
                print(f"  - {f}")
            return False

    def check_tokens(self) -> bool:
        """Validate token budgets (delegates to quality-gates.sh)"""
        self.log_info("Validating token budgets...")

        quality_gates = SCRIPT_DIR / "quality-gates.sh"
        if not quality_gates.exists():
            self.log_error("quality-gates.sh not found")
            return False

        result = subprocess.run(
            ["bash", str(quality_gates), "--check-tokens"],
            capture_output=True,
            text=True,
            cwd=str(self.project_root)
        )

        if "OVER BUDGET" not in result.stdout:
            self.log_success("All files within token budgets")
            return True
        else:
            self.log_error("Token budget validation failed")
            print(result.stdout)
            return False

    def check_coverage(self) -> bool:
        """Check documentation coverage"""
        self.log_info("Checking documentation coverage...")

        missing_docs = []
        count = 0

        # Check that all agents have quick documentation
        agents_dir = self.project_root / ".claude" / "agents"
        if agents_dir.exists():
            for agent_file in agents_dir.glob("*.md"):
                agent_name = agent_file.stem
                quick_doc = self.project_root / "docs" / "agents" / f"{agent_name}.quick.md"

                if not quick_doc.exists():
                    missing_docs.append(f"docs/agents/{agent_name}.quick.md (for .claude/agents/{agent_name}.md)")
                    count += 1

        # Check that all scripts have header comments
        scripts_dir = self.project_root / "scripts"
        if scripts_dir.exists():
            for script_file in scripts_dir.glob("*.sh"):
                content = script_file.read_text()
                # Check first 5 lines for comment
                header = "\n".join(content.split("\n")[:5])
                if not header.startswith(("#", "//")):
                    missing_docs.append(f"{script_file.relative_to(self.project_root)} (missing header comment)")
                    count += 1

        if count == 0:
            self.log_success("Documentation coverage: 100%")
            return True
        else:
            self.log_warning(f"Found {count} missing documentation items:")
            for doc in missing_docs:
                print(f"  - {doc}")
            return False

    def generate_report(self) -> bool:
        """Generate summary report"""
        self.log_info("Generating documentation health report...")

        print("=" * 50)
        print("Documentation Health Report")
        print("=" * 50)
        print()

        checks = {
            "@ref links": self.check_refs,
            "Stale docs": self.check_stale,
            "Orphan files": self.check_orphans,
            "Token budgets": self.check_tokens,
            "Coverage": self.check_coverage
        }

        results = []
        for name, check_func in checks.items():
            if check_func():
                results.append(f"{name}: PASS")
            else:
                results.append(f"{name}: FAIL")
                self.failed = True

        print()
        print("Summary:")
        for r in results:
            print(f"  - {r}")
        print()

        if not self.failed:
            print(f"{GREEN}All documentation checks passed!{NC}")
        else:
            print(f"{RED}Some documentation checks failed.{NC}")
            print("Run with individual flags for details.")

        print("=" * 50)

        return not self.failed


def main():
    parser = argparse.ArgumentParser(
        description="Documentation Validation Script",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument("--all", action="store_true", help="Run all checks")
    parser.add_argument("--ref-check", action="store_true", help="Validate @ref links")
    parser.add_argument("--stale-check", action="store_true", help="Find stale documentation")
    parser.add_argument("--orphan-check", action="store_true", help="Find orphaned .md files")
    parser.add_argument("--token-check", action="store_true", help="Validate token budgets")
    parser.add_argument("--coverage", action="store_true", help="Check documentation coverage")
    parser.add_argument("--report", action="store_true", help="Generate human-readable report")
    parser.add_argument("--stale-days", type=int, default=30, help="Days threshold for stale check")

    args = parser.parse_args()

    validator = DocValidator(PROJECT_ROOT)

    # If no specific checks, run all
    if not any([args.ref_check, args.stale_check, args.orphan_check,
                args.token_check, args.coverage, args.report]):
        args.all = True

    exit_code = 0

    if args.all or args.report:
        if not validator.generate_report():
            exit_code = 1
    else:
        if args.ref_check:
            if not validator.check_refs():
                exit_code = 1
        if args.stale_check:
            if not validator.check_stale(args.stale_days):
                exit_code = 1
        if args.orphan_check:
            if not validator.check_orphans():
                exit_code = 1
        if args.token_check:
            if not validator.check_tokens():
                exit_code = 1
        if args.coverage:
            if not validator.check_coverage():
                exit_code = 1

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
