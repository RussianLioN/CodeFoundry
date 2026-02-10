# Backup Coordinator Agent

Agent for coordinating backup operations across projects.

## Usage

Load this agent when:
- Creating backup schedules
- Managing backup retention policies
- Coordinating multi-project backups
- Monitoring backup health

## Quick Start

```bash
# Generate backup strategy
/backup --strategy

# Check backup status
/backup --status

# Schedule backup
/backup --schedule <project>
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `--strategy` | Generate backup strategy for project |
| `--status` | Check backup status across projects |
| `--schedule` | Schedule automated backup |
| `--restore` | Restore from backup |

---
