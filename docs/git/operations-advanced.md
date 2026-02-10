# Git Operations - Advanced Reference

**Purpose:** Extended documentation for git operations beyond P1 basics.

---

## GitHub CLI (gh)

### Authentication
```bash
gh auth login
```

### Enhanced Operations

**Get repo info:**
```bash
gh repo view
```

**Create commit with issue link:**
```bash
git commit -m "feat: implement feature (#123)"
```

**Push and create PR:**
```bash
git push -u origin feature-branch
gh pr create --title "Feature" --body "Description"
```

---

## Special Cases

### Case 1: Uncommitted Changes from Previous Session

If local changes exist from before:
```bash
git status  # review changes
git stash   # save for later
# OR
git add -u && git commit -m "wip: session save"
```

### Case 2: Working on Different Branch

```bash
git checkout -b feature-branch
# Work...
git push -u origin feature-branch
```

### Case 3: Large Files or Binary Changes

Use Git LFS for large files:
```bash
git lfs track "*.psd"
git add .gitattributes
```

### Case 4: Merge Conflicts During Sync

```bash
git status  # list conflicts
# Edit files, remove <<<<<<< markers
git add <resolved>
git commit
```

---

## Commit Message Templates

### Regular Session
```
type(scope): description

Optional details
```

### Milestone Reached
```
feat(major): Complete Phase X

- Achievement 1
- Achievement 2
```

### Architecture Change
```
refactor(core): Restructure X for Y benefit

BREAKING CHANGE: Z changed
```

### Bug Fix
```
fix(module): Resolve issue (#123)

Root cause: X
Solution: Y
```

---

## Safety Checklist

- [ ] Reviewed `git status` before add
- [ ] Verified staged files
- [ ] Checked commit message format
- [ ] No sensitive files in `.env`, credentials
- [ ] Tests passing (if applicable)

---

## Error Messages (Russian)

**Connection:** "⚠️ Нет связи с сервером. Проверьте интернет."
**Auth:** "⚠️ Ошибка авторизации. Выполните `gh auth login`."
**Conflict:** "⚠️ Конфликт слияния. Разрешите конфликты вручную."

---
