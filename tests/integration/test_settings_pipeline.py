#!/usr/bin/env python3
"""
Integration tests for settings validation pipeline

Tests the full workflow:
1. Invalid settings detected
2. Validation script runs
3. Sanitization fixes issues
4. Settings are valid
"""

import json
import os
import pytest
import tempfile
import subprocess


@pytest.fixture
def invalid_settings():
    """Create invalid settings for testing."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump({
            "permissions": {
                "allow": [
                    # Invalid pattern with heredoc
                    "Bash(file.md << 'EOF'\ncontent\nEOF)"
                ]
            }
        }, f)
        return f.name


@pytest.fixture
def valid_settings():
    """Create valid settings for testing."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump({
            "permissions": {
                "allow": [
                    "Bash(*)",
                    "mcp__context7__query-docs"
                ]
            }
        }, f)
        return f.name


class TestSettingsValidationPipeline:
    """Integration tests for settings validation."""

    def test_validate_detects_invalid_json(self, invalid_settings):
        """Test that validate-settings.py detects invalid patterns."""
        result = subprocess.run(
            ['python3', 'scripts/validate-settings.py'],
            capture_output=True,
            text=True
        )

        # Should fail
        assert result.returncode != 0
        assert "invalid" in result.stdout.lower()

    def test_sanitize_fixes_invalid_patterns(self, tmp_path):
        """Test that sanitize-settings.py fixes invalid patterns."""
        # Create invalid settings
        settings_file = tmp_path / "settings.json"
        with open(settings_file, 'w') as f:
            json.dump({
                "permissions": {
                    "allow": [
                        "Bash(file.md << 'EOF'\ncontent\nEOF)"
                    ]
                }
            }, f)

        # Run sanitization
        result = subprocess.run(
            ['python3', 'scripts/sanitize-settings.py', '--fix'],
            capture_output=True,
            text=True
        )

        # Check file is now valid
        with open(settings_file) as f:
            data = json.load(f)

        # Invalid pattern should be removed
        assert len(data['permissions']['allow']) == 0
        assert "Removed" in result.stdout

    def test_validate_passes_on_valid_settings(self, valid_settings):
        """Test that validate-settings.py passes on valid settings."""
        # Copy to temp location
        import shutil
        temp_settings = f"/tmp/test_settings_{os.getpid()}.json"
        shutil.copy(valid_settings, temp_settings)

        result = subprocess.run(
            ['python3', 'scripts/validate-settings.py'],
            capture_output=True,
            text=True
        )

        # Should pass
        assert result.returncode == 0
        assert "All.*permission patterns valid" in result.stdout

        # Cleanup
        os.unlink(temp_settings)

    def test_full_pipeline_workflow(self, tmp_path):
        """Test complete workflow: detect → fix → validate."""
        # Step 1: Create invalid settings
        settings_file = tmp_path / "settings.json"
        with open(settings_file, 'w') as f:
            json.dump({
                "permissions": {
                    "allow": [
                        "Bash(bad << 'EOF')",
                        "Bash(*)"
                    ]
                }
            }, f)

        # Step 2: Detect invalid
        detect = subprocess.run(
            ['python3', 'scripts/validate-settings.py'],
            capture_output=True,
            text=True
        )
        assert detect.returncode != 0

        # Step 3: Fix
        fix = subprocess.run(
            ['python3', 'scripts/sanitize-settings.py', '--fix'],
            capture_output=True,
            text=True
        )

        # Step 4: Validate again (should pass)
        validate = subprocess.run(
            ['python3', 'scripts/validate-settings.py'],
            capture_output=True,
            text=True
        )
        assert validate.returncode == 0


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
