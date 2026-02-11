#!/usr/bin/env python3
"""
Validate Claude Code settings.local.json

Checks:
1. JSON syntax validity
2. Permission pattern validity (no heredoc, pipes, complex constructs)
3. Schema structure

Usage:
    python3 scripts/validate-settings.py
    exit code: 0 = valid, 1 = invalid
"""

import json
import re
import sys
from pathlib import Path

# Invalid patterns in permissions
INVALID_PATTERNS = [
    '<<',      # Heredoc
    '|',       # Pipes
    '\n',      # Newlines
    '$(',      # Command substitution
    '`',       # Backticks
    '\\(',     # Escaped parens (except in Bash())
]

# Valid permission patterns
# - Bash(command) or Bash(command *)
# - WebFetch(domain:example.com)
# - WebSearch
# - mcp__server_name__tool_name (with hyphens, underscores)
# - Simple wildcards: command:*
VALID_PREFIXES = {
    'Bash(', 'WebFetch(', 'WebSearch',
    'mcp__',  # MCP server tools
}

# Check if permission looks valid
def is_valid_permission_pattern(perm: str) -> bool:
    """Check if permission pattern follows expected format."""
    # Allow wildcards
    if perm.endswith('*') and ':' in perm:
        return True

    # Check valid prefixes
    for prefix in VALID_PREFIXES:
        if perm.startswith(prefix):
            return True

    return False


def validate_json(filepath: Path) -> tuple[bool, str]:
    """Validate JSON syntax."""
    try:
        with open(filepath) as f:
            data = json.load(f)
        return True, "✅ JSON syntax valid"
    except json.JSONDecodeError as e:
        return False, f"❌ JSON syntax error: {e}"


def validate_structure(data: dict) -> tuple[bool, str]:
    """Validate settings structure."""
    required = ['permissions']
    for key in required:
        if key not in data:
            return False, f"❌ Missing required key: {key}"

    if 'allow' not in data.get('permissions', {}):
        return False, f"❌ Missing permissions.allow"

    return True, "✅ Structure valid"


def validate_permissions(data: dict) -> list[str]:
    """Validate individual permission patterns."""
    permissions = data.get('permissions', {}).get('allow', [])
    issues = []

    for i, perm in enumerate(permissions):
        # Check for invalid patterns
        for invalid in INVALID_PATTERNS:
            if invalid in perm:
                issues.append(
                    f"  Line {i+2}: Invalid pattern '{invalid}' in: {perm[:80]}..."
                )

        # Check format
        if not is_valid_permission_pattern(perm):
            issues.append(
                f"  Line {i+2}: Suspicious pattern: {perm}"
            )

    return issues


def main():
    settings_file = Path('.claude/settings.local.json')

    if not settings_file.exists():
        print("ℹ️  settings.local.json not found, skipping validation")
        return 0

    print(f"🔍 Validating {settings_file}...")

    # 1. JSON syntax
    valid, msg = validate_json(settings_file)
    print(msg)
    if not valid:
        return 1

    # 2. Load data
    with open(settings_file) as f:
        data = json.load(f)

    # 3. Structure
    valid, msg = validate_structure(data)
    print(msg)
    if not valid:
        return 1

    # 4. Permissions
    issues = validate_permissions(data)
    if issues:
        print(f"❌ Found {len(issues)} invalid permission pattern(s):")
        for issue in issues:
            print(issue)
        print("\n💡 Run: python3 scripts/sanitize-settings.py --fix")
        return 1
    else:
        perm_count = len(data.get('permissions', {}).get('allow', []))
        print(f"✅ All {perm_count} permission patterns valid")

    print("\n✅ Settings validation passed")
    return 0


if __name__ == '__main__':
    sys.exit(main())
