#!/usr/bin/env python3
"""
Auto-sanitize Claude Code settings.local.json

Removes invalid permission patterns that cause startup errors.
Creates backup before modifying.

Usage:
    python3 scripts/sanitize-settings.py [--fix]
    --fix: Apply changes (default: dry-run)
"""

import json
import argparse
import re
from datetime import datetime
from pathlib import Path

INVALID_PATTERNS = ['<<', '|', '\n', '$(', '`']
MAX_PATTERN_LENGTH = 200


def backup_settings(filepath: Path) -> Path:
    """Create backup with timestamp."""
    timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
    backup_path = filepath.parent / f"settings.backup.{timestamp}.json"
    backup_path.write_text(filepath.read_text())
    return backup_path


def sanitize_permissions(permissions: list) -> list:
    """Remove invalid permission patterns."""
    sanitized = []

    for perm in permissions:
        # Check invalid patterns
        if any(x in perm for x in INVALID_PATTERNS):
            continue

        # Check length
        if len(perm) > MAX_PATTERN_LENGTH:
            continue

        sanitized.append(perm)

    return sanitized


def main():
    parser = argparse.ArgumentParser(description='Sanitize settings.local.json')
    parser.add_argument('--fix', action='store_true', help='Apply changes')
    args = parser.parse_args()

    settings_file = Path('.claude/settings.local.json')

    if not settings_file.exists():
        print("ℹ️  settings.local.json not found")
        return 0

    # Load
    with open(settings_file) as f:
        data = json.load(f)

    original_count = len(data.get('permissions', {}).get('allow', []))
    permissions = data.get('permissions', {}).get('allow', [])

    # Sanitize
    sanitized = sanitize_permissions(permissions)
    removed = original_count - len(sanitized)

    if removed == 0:
        print("✅ No invalid patterns found")
        return 0

    print(f"🔍 Found {removed} invalid pattern(s)")

    if args.fix:
        # Backup
        backup = backup_settings(settings_file)
        print(f"💾 Backup: {backup}")

        # Apply
        data['permissions']['allow'] = sanitized

        with open(settings_file, 'w') as f:
            json.dump(data, f, indent=2)

        print(f"✅ Removed {removed} invalid pattern(s)")
        print(f"✅ Kept {len(sanitized)} valid pattern(s)")
    else:
        print("ℹ️  Dry-run mode. Use --fix to apply changes")


if __name__ == '__main__':
    main()
