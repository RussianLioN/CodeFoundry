# Expert Consilium v2.0 Analysis: settings.local.json Incident

**Date:** 2026-02-11
**Problem:** Claude Code автоматически загрязняет settings.local.json невалидными паттернами
**Approach:** Multi-round expert debate → Lessons extraction → Automation design

---

## 🔴 Problem Statement

**Initial Incident:**
```
Ошибка при запуске Claude Code:
  settings.local.json содержит невалидный паттерн:
  "Bash(file << 'EOF' ...)" — heredoc ломает JSON
```

**First Attempt (REJECTED):**
- Решение: Добавить запрет "NEVER edit settings.local.json" в инструкции
- Результат: Экспертный консилиум раскритиковал подход

---

## 🎭 Expert Consilium v2.0 Debates

### Domain Positions

| Domain | Initial Position | Final Position | Confidence Change |
|--------|-----------------|----------------|-------------------|
| **Infrastructure** | Manual control | Automated validation | +0.3 |
| **Delivery** | Pre-commit hooks | Full pipeline automation | +0.2 |
| **Quality** | Instructions change | System design fix | +0.4 |
| **AI** | Better prompts | Automated remediation | +0.3 |

---

## 📊 Round 1: Domain Cross-Examination

### Infrastructure → Delivery
**Challenge:** "Запреты в инструкциях не работают для автоматизированных систем"

**Delivery Response:** "Согласен. Pre-commit hooks — это better, но недостаточно. Нужен full pipeline."

**Result:** Delivery пересмотрел позицию с hooks на full automation.

---

### Quality → AI
**Challenge:** "Промпты не предотвращают ошибки, они только документируют их"

**AI Response:** "Верно, но хорошие промпты помогают agent teams принимать правильные решения"

**Result:** AI признал ограниченность промптов, подчеркнув need for automation.

---

## 📊 Round 2: Adversarial Debates

### Docker Engineer vs CI/CD Architect

**Docker:** "Запрет на редактирование — это как запрет на docker commit. Не работает."

**CI/CD:** "Нужен automated validation в pipeline, не инструкции."

**Consensus:** Instructions → Automated validation + pre-commit hooks.

---

### Unix Script Expert vs Prompt Engineer

**Unix:** "Heredoc — это не проблема. Проблема в auto-grant логике."

**Prompt:** "Промпты могут предотвратить использование heredoc для file creation."

**Consensus:** Prevention (промпты) + Remediation (auto-fix).

---

## 📊 Round 3: Red Teaming

### Team "Instructions" vs Team "Automation"

**Team Instructions:** "Изменить CLAUDE.md с явными запретами"

**Team Automation:** "Создать validate-settings.py + pre-commit hook"

**Red Team Analysis:**
- ❌ Instructions: Не предотвращают, только документируют
- ✅ Automation: Предотвращает + исправляет автоматически

**Winner:** Team Automation (confidential: 0.95)

---

## 🎯 Final Consensus

**RECOMMENDATION: AUTOMATED REMEDIATION** (confidence: 0.92)

**Rationale:**
1. **Prevention** → Промпты объясняют, но не предотвращают
2. **Detection** → Pre-commit hooks ловят ошибки перед коммитом
3. **Remediation** → Auto-fix скрипты исправляют автоматически
4. **Recovery** → Backup机制 позволяет откатиться

---

## 📚 Extracted Lessons

### Lesson 1: The "Prohibition Anti-Pattern" ⚠️

**Pattern:**
```
❌ WRONG: "NEVER edit X" in instructions
✅ RIGHT: Automated validation + auto-fix
```

**Why it fails:**
- Instructions are read after errors occur
- Automated systems don't read instructions
- Humans ignore prohibitions under pressure

**Correct approach:**
```yaml
# Вместо запрета → automated system
Prevention:  Промпты для agents (soft guidance)
Detection:   Pre-commit hooks (hard gate)
Remediation: Auto-fix scripts (self-healing)
Recovery:    Backup system (safety net)
```

---

### Lesson 2: Layered Defense > Single Point of Control 🛡️

**Single layer (FAILED):**
```
Instruction: "NEVER edit settings.local.json"
```

**Layered defense (SUCCESS):**
```
Layer 1: Prompts           → Educate agents
Layer 2: Pre-commit hook   → Block invalid commits
Layer 3: Validation script → Detect issues
Layer 4: Auto-fix script   → Auto-remediate
Layer 5: Backup system     → Recovery mechanism
```

**Principle:** Каждый layer создаёт safety net для предыдущего.

---

### Lesson 3: Automate the Workflow, Not Just the Fix 🔧

**Wrong approach:**
```python
# Manual workflow
if settings_invalid:
    ask_user_to_fix()
```

**Right approach:**
```python
# Automated workflow
if settings_invalid:
    backup_settings()
    sanitize_settings()
    notify_user()
    # Continue working
```

**Principle:** Make the system self-healing, not just self-diagnosing.

---

### Lesson 4: Expert Consilium Value for Meta-Problems 💡

**Why 10 experts better than 1:**
- Docker Engineer увидел container-specific issues
- Unix Script Expert понял heredoc не root cause
- CI/CD Architect предложил pipeline integration
- GitOps Specialist подчеркнул state management
- SRE потребовал automated remediation

**Cross-pollination:** Each expert challenged others' assumptions.

---

### Lesson 5: Error Pattern Recognition & Automation 🤖

**Pattern detected:**
```
settings.local.json polluted → Error → Manual fix → Repeat
```

**Automation opportunity:**
```python
# Error frequency tracker
error_count = get_error_count("settings.invalid_json")

if error_count >= 3:
    # Automatically trigger remediation
    run_auto_fix()
    update_documentation()
    # Consider architectural fix
```

**Principle:** Third occurrence → systemic issue, not user error.

---

## 🔄 Automation Design: Lesson-Learned System

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Error Occurrence                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Error Classification │
         │  - Type               │
         │  - Location           │
         │  - Context            │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Frequency Counter    │
         │  error_type: 2/3      │
         └───────────┬───────────┘
                     │
                     ▼
              ┌──────────────┐
              │  Count >= 3? │
              └──────┬───────┘
                     │
         ┌───────────┴───────────┐
         │ NO                   │ YES
         ▼                       ▼
    ┌─────────┐         ┌──────────────────┐
    │ Log it  │         │ LESSON LEARNED   │
    └─────────┘         │ 1. Auto-fix      │
                        │ 2. Update docs   │
                        │ 3. Add validator │
                        │ 4. Notify user   │
                        └──────────────────┘
```

### Implementation

```python
# scripts/lesson-learned-tracker.py
"""
Automated lesson extraction from repeated errors.

When error occurs 3+ times:
1. Extract lesson automatically
2. Add to LESSONS.md
3. Create/update validation script
4. Update documentation
"""

import json
from datetime import datetime
from pathlib import Path
from collections import defaultdict

ERROR_LOG = ".tracking/error_log.json"
LESSONS_FILE = "LESSONS.md"
LESSON_THRESHOLD = 3


class LessonLearnedTracker:
    """Track errors and extract lessons from patterns."""

    def __init__(self):
        self.error_log = self._load_error_log()
        self.lessons = self._load_lessons()

    def log_error(self, error_type: str, location: str, context: dict):
        """Log an error occurrence."""
        key = f"{error_type}:{location}"

        if key not in self.error_log:
            self.error_log[key] = {
                "type": error_type,
                "location": location,
                "count": 0,
                "first_seen": datetime.now().isoformat(),
                "contexts": []
            }

        self.error_log[key]["count"] += 1
        self.error_log[key]["last_seen"] = datetime.now().isoformat()
        self.error_log[key]["contexts"].append(context)

        self._save_error_log()

        # Check if threshold reached
        if self.error_log[key]["count"] >= LESSON_THRESHOLD:
            self._extract_lesson(key)

    def _extract_lesson(self, error_key: str):
        """Extract and document lesson from repeated error."""
        error_info = self.error_log[error_key]

        lesson = {
            "error_type": error_info["type"],
            "location": error_info["location"],
            "occurrences": error_info["count"],
            "pattern": self._analyze_pattern(error_info["contexts"]),
            "lesson": self._generate_lesson(error_info),
            "prevention": self._generate_prevention(error_info),
            "created": datetime.now().isoformat()
        }

        self._add_to_lessons(lesson)
        self._create_validator(error_info)
        self._notify_user(lesson)

    def _analyze_pattern(self, contexts: list) -> str:
        """Analyze common pattern across occurrences."""
        # Extract commonalities
        return "Auto-detected pattern"

    def _generate_lesson(self, error_info: dict) -> str:
        """Generate lesson from error info."""
        return f"""### Lesson: {error_info['type']} in {error_info['location']}

**Pattern:** This error occurred {error_info['count']} times.

**Root Cause:** Auto-detected from contexts.

**Prevention:** See prevention section below."""

    def _generate_prevention(self, error_info: dict) -> list[str]:
        """Generate prevention strategies."""
        return [
            "Add validation script",
            "Update CLAUDE.md instructions",
            "Create pre-commit hook"
        ]

    def _add_to_lessons(self, lesson: dict):
        """Add lesson to LESSONS.md."""
        lessons_path = Path(LESSONS_FILE)

        if not lessons_path.exists():
            lessons_path.write_text("# Lessons Learned\n\n")

        content = lessons_path.read_text()
        content += f"\n## {lesson['error_type']}\n\n"
        content += f"**Occurrences:** {lesson['occurrences']}\n\n"
        content += f"**Pattern:** {lesson['pattern']}\n\n"
        content += f"**Lesson:** {lesson['lesson']}\n\n"
        content += f"**Prevention:**\n"
        for strategy in lesson['prevention']:
            content += f"- {strategy}\n"
        content += "\n---\n"

        lessons_path.write_text(content)

    def _create_validator(self, error_info: dict):
        """Create validation script for this error type."""
        # Auto-generate validator based on error pattern
        pass

    def _notify_user(self, lesson: dict):
        """Notify user about new lesson."""
        print(f"\n🎓 LESSON LEARNED (occurrence #{lesson['occurrences']}):")
        print(f"   Type: {lesson['error_type']}")
        print(f"   Location: {lesson['location']}")
        print(f"   See: {LESSONS_FILE}\n")

    def _load_error_log(self) -> dict:
        """Load error log from file."""
        path = Path(ERROR_LOG)
        if path.exists():
            return json.loads(path.read_text())
        return {}

    def _save_error_log(self):
        """Save error log to file."""
        Path(ERROR_LOG).write_text(
            json.dumps(self.error_log, indent=2)
        )

    def _load_lessons(self) -> list:
        """Load existing lessons."""
        path = Path(LESSONS_FILE)
        if path.exists():
            return path.read_text()
        return ""


# Usage in quality gates or hooks
if __name__ == "__main__":
    tracker = LessonLearnedTracker()

    # Example: Log settings.json error
    tracker.log_error(
        error_type="invalid_json",
        location=".claude/settings.local.json",
        context={
            "file": "settings.local.json",
            "line": 66,
            "pattern": "heredoc in permissions"
        }
    )

    # On 3rd occurrence, lesson is auto-extracted
```

---

## 📋 Action Items

### Immediate (P0)
- [x] Create validate-settings.py
- [x] Create sanitize-settings.py
- [x] Add pre-commit hook
- [x] Update .gitignore
- [x] Create settings.example.json

### Short-term (P1)
- [ ] Implement lesson-learned-tracker.py
- [ ] Create LESSONS.md template
- [ ] Add error tracking to quality gates
- [ ] Update CLAUDE.md with new approach

### Long-term (P2)
- [ ] Integrate with agent error reporting
- [ ] Auto-generate validators from patterns
- [ ] Create lesson recommendation engine
- [ ] Build lesson-search for agents

---

## 📖 References

- **Incident:** settings.local.json pollution (2026-02-11)
- **Solution:** Automated validation + remediation
- **Experts:** 10-domain consilium (3-round debate)
- **Outcome:** System design fix vs instruction fix

---

**Status:** ✅ LESSONS EXTRACTED
**Next:** Implement lesson-learned-tracker.py
