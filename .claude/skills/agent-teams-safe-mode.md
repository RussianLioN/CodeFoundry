# Skill: Agent Teams Safe Mode

## Contract
- **Input:** Agent Teams operation, backup_mode (auto|git|fs)
- **Output:** Results + backup_status + validation_report
- **Stateless:** No
- **Side effects:** Creates backup, may rollback

## Algorithm

1. **PRE-WORK BACKUP** (ALWAYS):
   ```bash
   make backup-create  # Abort if fails
   ```

2. **EXECUTE** operation:
   - Use parallel or sequential skill
   - Monitor progress

3. **POST-WORK VALIDATION**:
   ```bash
   make backup-validate  # 5 checks
   ```

4. **DECISION**:
   ```
   IF 5/5 passed: SUCCESS → Clean backup optional
   ELSE: ROLLBACK → make backup-rollback
   ```

## Safety Guarantees
| Guarantee | Implementation |
|-----------|----------------|
| Pre-backup | Always created, abort if fails |
| Validation | 5 automatic checks |
| Auto-rollback | On validation failure |
| No silent failures | All errors reported |

## Token Budget
- **Total:** ~1050-2500 tokens (includes backup overhead)

## Example
```
→ Backup: stash@{0} created
→ Agent Teams: 4 agents, 52 sec
→ Validation: 5/5 PASSED
✓ Safe to commit
```

## Error Handling
| Error | Action |
|-------|--------|
| Backup fails | Abort operation |
| Validation fails | Auto-rollback |
| Rollback fails | Alert + manual steps |

## Integration
- Requires: [backup-coordinator](.claude/agents/backup-coordinator.md)
- Related: [agent-teams-parallel.md](agent-teams-parallel.md)
- Related: [agent-teams-sequential.md](agent-teams-sequential.md)
- Reference: [agent-teams-integration-plan.md](docs/reference/agent-teams-integration-plan.md) AT-002

---

⚠️ **WARNING:** Never skip safe mode for multi-file Agent Teams.
