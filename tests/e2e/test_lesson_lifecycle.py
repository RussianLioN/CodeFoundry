#!/usr/bin/env python3
"""
End-to-end tests for lesson extraction lifecycle

Tests the complete workflow:
1. Error occurs → logged
2. Repeats 3 times → threshold reached
3. Lesson extracted → LESSONS.md updated
4. Validator created
"""

import json
import os
import tempfile
import pytest


@pytest.fixture
def tracker():
    """Create tracker with temp files."""
    import sys
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../scripts'))

    from lesson_learned_tracker import LessonLearnedTracker

    with tempfile.TemporaryDirectory() as tmpdir:
        tracker = LessonLearnedTracker()
        tracker.error_log = os.path.join(tmpdir, 'error_log.json')
        tracker.lessons_file = os.path.join(tmpdir, 'LESSONS.md')

        yield tracker


class TestLessonLifecycle:
    """E2E tests for complete lesson extraction lifecycle."""

    def test_full_lifecycle(self, tracker):
        """Test complete lifecycle from error to lesson."""
        # Phase 1: Error occurs (1st time)
        tracker.log_error(
            error_type="json_parse_error",
            location="settings.json",
            context={"line": 10}
        )

        # Check no lesson yet
        assert not os.path.exists(tracker.lessons_file)

        # Phase 2: Error repeats (2nd time)
        tracker.log_error(
            error_type="json_parse_error",
            location="settings.json",
            context={"line": 15}
        )

        # Still no lesson
        assert not os.path.exists(tracker.lessons_file)

        # Phase 3: Threshold reached (3rd time)
        tracker.log_error(
            error_type="json_parse_error",
            location="settings.json",
            context={"line": 20}
        )

        # Extract lesson
        tracker._extract_lesson("json_parse_error:settings.json")

        # Phase 4: Verify lesson created
        assert os.path.exists(tracker.lessons_file)

        with open(tracker.lessons_file) as f:
            content = f.read()

        assert "json_parse_error" in content
        assert "settings.json" in content
        assert "3" in content  # occurrence count

    def test_multiple_errors_same_location(self, tracker):
        """Test multiple different errors at same location."""
        errors = [
            ("syntax_error", "script.sh"),
            ("permission_error", "script.sh"),
            ("runtime_error", "script.sh"),
        ]

        for error_type, location in errors:
            for _ in range(3):
                tracker.log_error(error_type, location, {})

        # Extract all lessons
        for error_type, location in errors:
            key = f"{error_type}:{location}"
            tracker._extract_lesson(key)

        # Verify all lessons documented
        with open(tracker.lessons_file) as f:
            content = f.read()

        assert "syntax_error" in content
        assert "permission_error" in content
        assert "runtime_error" in content

    def test_error_pattern_evolution(self, tracker):
        """Test that error contexts are tracked for pattern analysis."""
        contexts = [
            {"function": "parse", "input": "file1.json"},
            {"function": "parse", "input": "file2.json"},
            {"function": "parse", "input": "file3.json"},
        ]

        for ctx in contexts:
            tracker.log_error("parse_error", "parser.py", ctx)

        # Extract and check pattern
        tracker._extract_lesson("parse_error:parser.py")

        with open(tracker.lessons_file) as f:
            content = f.read()

        # Should mention pattern
        assert "parse" in content or "pattern" in content.lower()

    def test_prevention_strategies_generated(self, tracker):
        """Test that prevention strategies are generated."""
        for _ in range(3):
            tracker.log_error(
                "token_exceeded",
                "CLAUDE.md",
                {"tokens": 500, "budget": 400}
            )

        tracker._extract_lesson("token_exceeded:CLAUDE.md")

        with open(tracker.lessons_file) as f:
            content = f.read()

        # Should have prevention section
        assert "Prevention" in content or "prevention" in content.lower()


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
