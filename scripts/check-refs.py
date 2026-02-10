#!/usr/bin/env python3
"""Check @ref link integrity in instruction files."""

import re
import os
import glob
import sys

broken = []
# Only check core instruction files
scan_files = ['CLAUDE.md', 'SESSION.md']
for g in ['instructions/**/*.md', '.claude/agents/*.md', '.claude/commands/*.md']:
    scan_files.extend(glob.glob(g, recursive=True))

# Patterns to skip (examples, templates, placeholders)
skip_patterns = [
    r'^path/to/',
    r'^\[',           # [files, [affected, etc.
    r'^\*',           # ** glob patterns
    r'^`',            # backtick-wrapped
    r'^\w+\.md#',     # same-file anchors without path
    r'^file\.md',     # example placeholder
    r'^doc-templates/',  # may not exist in all setups
]
skip_re = re.compile('|'.join(skip_patterns))

for md_file in scan_files:
    if not os.path.isfile(md_file):
        continue
    try:
        with open(md_file) as f:
            content = f.read()
        for m in re.findall(r'@ref:\s*([^\])\s]+)', content):
            target = m.strip().rstrip('`')
            if not target or skip_re.match(target):
                continue
            # Handle #anchor — check file part only
            file_part = target.split('#')[0]
            if not file_part:
                continue
            # Try absolute path first, then relative to file's directory
            if os.path.isfile(file_part) or os.path.isdir(file_part):
                continue
            rel_dir = os.path.dirname(md_file)
            rel_path = os.path.join(rel_dir, file_part)
            if os.path.isfile(rel_path) or os.path.isdir(rel_path):
                continue
            # Skip glob/template patterns
            if '*' in file_part or '[' in file_part:
                continue
            broken.append(f'{md_file}: {target}')
    except Exception:
        pass

print(len(broken))
for b in broken:
    print(b)

sys.exit(0)
