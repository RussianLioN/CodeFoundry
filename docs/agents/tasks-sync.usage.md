# Tasks Sync Agent

Agent for synchronizing TASKS.md with GitHub Issues.

## Usage

Load this agent when:
- Syncing TASKS.md to GitHub Issues
- Updating task status from GitHub
- Managing bidirectional sync
- Handling sync conflicts

## Quick Start

```bash
# Sync tasks to issues
/tasks-sync --to-github

# Update from GitHub
/tasks-sync --from-github

# Check sync status
/tasks-sync --status
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `--to-github` | Create/update GitHub issues from TASKS.md |
| `--from-github` | Update TASKS.md from GitHub issues |
| `--status` | Check sync status |
| `--init` | Initialize sync for new project |

## Sync Mapping

TASKS.md ←→ GitHub Issues:
- `- [ ]` → Open issue
- `- [x]` → Closed issue
- Task IDs → Issue labels
