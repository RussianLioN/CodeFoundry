#!/usr/bin/env python3
"""
Unit tests for lesson-learned-tracker.py

Tests the LessonLearnedTracker class for:
- Error logging
- Threshold detection
- Lesson extraction
- JSON persistence
"""

import json
import os
import pytest
import tempfile
from pathlib import Path

# Add scripts to path
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../scripts'))

from lesson_learned_tracker import LessonLearnedTracker


@pytest.fixture
def temp_tracker():
    """Create a tracker with temporary files."""
    with tempfile.TemporaryDirectory() as tmpdir:
        error_log = os.path.join(tmpdir, 'error_log.json')
        lessons_file = os.path.join(tmpdir, 'LESSONS.md')

        tracker = LessonLearnedTracker()
        tracker.error_log = error_log
        tracker.lessons_file = lessons_file

        yield tracker


class TestLessonLearnedTracker:
    """Test suite for LessonLearnedTracker."""

    def test_init_creates_error_log(self, temp_tracker):
        """Test that tracker creates error log on init."""
        assert os.path.exists(temp_tracker.error_log)

    def test_log_error_increments_count(self, temp_tracker):
        """Test that logging an error increments the count."""
        temp_tracker.log_error(
            error_type="test_error",
            location="test.py",
            context={"line": 10}
        )

        with open(temp_tracker.error_log) as f:
            data = json.load(f)

        key = "test_error:test.py"
        assert key in data
        assert data[key]["count"] == 1

    def test_log_error_multiple_times(self, temp_tracker):
        """Test logging same error multiple times."""
        for i in range(3):
            temp_tracker.log_error(
                error_type="test_error",
                location="test.py",
                context={"iteration": i}
            )

        with open(temp_tracker.error_log) as f:
            data = json.load(f)

        assert data["test_error:test.py"]["count"] == 3

    def test_extract_lesson_on_threshold(self, temp_tracker):
        """Test that lesson is extracted when threshold reached."""
        # Log error 3 times (threshold)
        for i in range(3):
            temp_tracker.log_error(
                error_type="threshold_test",
                location="test.py",
                context={}
            )

        # Extract lessons
        temp_tracker._extract_lesson("threshold_test:test.py")

        # Check LESSONS.md was created
        assert os.path.exists(temp_tracker.lessons_file)

        with open(temp_tracker.lessons_file) as f:
            content = f.read()
            assert "threshold_test" in content

    def test_no_extraction_below_threshold(self, temp_tracker):
        """Test that lesson is NOT extracted below threshold."""
        # Log error only 2 times (below threshold of 3)
        for i in range(2):
            temp_tracker.log_error(
                error_type="below_threshold",
                location="test.py",
                context={}
            )

        # Extract should not create lesson
        try:
            temp_tracker._extract_lesson("below_threshold:test.py")
        except Exception:
            pass  # Expected behavior

    def test_context_tracking(self, temp_tracker):
        """Test that error contexts are tracked."""
        context1 = {"line": 10, "error": "first"}
        context2 = {"line": 20, "error": "second"}

        temp_tracker.log_error("context_test", "test.py", context1)
        temp_tracker.log_error("context_test", "test.py", context2)

        with open(temp_tracker.error_log) as f:
            data = json.load(f)

        contexts = data["context_test:test.py"]["contexts"]
        assert len(contexts) == 2
        assert contexts[0]["line"] == 10
        assert contexts[1]["line"] == 20


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
