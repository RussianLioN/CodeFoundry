#!/usr/bin/env python3
"""
Generate .claude/ profile for a new project.

Merges base profile templates with archetype-specific overlays,
renders Jinja2 templates, and writes to the target project directory.

Usage:
    python3 generate-claude-profile.py --archetype web-service \
        --project-name my-api --project-dir /path/to/my-api \
        --template-dir /path/to/templates/claude-profile
"""

import argparse
import json
import os
import shutil
import stat
import sys
from pathlib import Path

try:
    from jinja2 import Environment, FileSystemLoader, TemplateNotFound
except ImportError:
    print("ERROR: jinja2 not installed. Run: pip3 install jinja2", file=sys.stderr)
    sys.exit(1)


def load_manifest(overlay_dir: Path) -> dict:
    """Load and parse manifest.json from an overlay directory."""
    manifest_path = overlay_dir / "manifest.json"
    if not manifest_path.exists():
        print(f"WARNING: No manifest.json in {overlay_dir}", file=sys.stderr)
        return {}
    with open(manifest_path) as f:
        return json.load(f)


def merge_agents(base_agents: list[str], manifest: dict) -> list[str]:
    """Merge base agent list with overlay additions/removals (deduplicated)."""
    agents_config = manifest.get("agents", {})
    add = agents_config.get("add", [])
    remove = set(agents_config.get("remove", []))

    result = [a for a in base_agents if a not in remove]
    # Add only agents not already in result
    for agent in add:
        if agent not in result:
            result.append(agent)
    return result


def merge_lists(base: list[str], manifest: dict, key: str) -> list[str]:
    """Merge base list with overlay additions for skills/commands (deduplicated)."""
    config = manifest.get(key, {})
    add = config.get("add", [])
    result = list(base)
    for item in add:
        if item not in result:
            result.append(item)
    return result


def build_routing_overrides(manifest: dict) -> list[dict]:
    """Convert manifest routing overrides to template-friendly format."""
    routing = manifest.get("routing", {})
    overrides = routing.get("overrides", {})
    return [
        {"pattern": pattern, "agent": agent, "priority": 8}
        for pattern, agent in overrides.items()
    ]


def build_template_vars(args, manifest: dict, agents: list[str],
                        skills: list[str], commands: list[str]) -> dict:
    """Build the full set of Jinja2 template variables."""
    variables = manifest.get("variables", {})
    return {
        "project_name": args.project_name,
        "project_description": args.project_description or f"{args.archetype} project",
        "archetype": args.archetype,
        "language": args.language or variables.get("default_language", "python"),
        "framework": variables.get("default_framework", ""),
        "test_framework": variables.get("test_framework", "pytest"),
        "docker_enabled": variables.get("docker_enabled", True),
        "k8s_enabled": variables.get("k8s_enabled", False),
        "agents": agents,
        "skills": skills,
        "commands": commands,
        "routing_overrides": build_routing_overrides(manifest),
        "language_ext": _lang_ext(args.language or variables.get("default_language", "python")),
        "year": "2026",
    }


def _lang_ext(lang: str) -> str:
    """Map language name to file extension."""
    return {
        "python": "py", "typescript": "ts", "javascript": "js",
        "go": "go", "rust": "rs", "markdown": "md",
    }.get(lang, "py")


def render_templates(template_dir: Path, output_dir: Path,
                     template_vars: dict, subdirs: list[str]):
    """Render all .j2 templates from template_dir into output_dir."""
    env = Environment(
        loader=FileSystemLoader(str(template_dir)),
        keep_trailing_newline=True,
        undefined=__import__('jinja2').Undefined,
    )

    for subdir in subdirs:
        src = template_dir / subdir
        if not src.exists():
            continue

        for template_file in src.rglob("*.j2"):
            rel_path = template_file.relative_to(template_dir)
            # Remove .j2 extension for output
            out_path = output_dir / str(rel_path).removesuffix(".j2")

            out_path.parent.mkdir(parents=True, exist_ok=True)

            try:
                tmpl = env.get_template(str(rel_path))
                rendered = tmpl.render(**template_vars)
                out_path.write_text(rendered)

                # Make hooks executable
                if "hooks" in str(out_path) and out_path.suffix == ".sh":
                    out_path.chmod(out_path.stat().st_mode | stat.S_IEXEC | stat.S_IXGRP)

            except Exception as e:
                print(f"WARNING: Failed to render {rel_path}: {e}", file=sys.stderr)


def render_root_templates(template_dir: Path, output_dir: Path, template_vars: dict):
    """Render root-level .j2 files (CLAUDE.md, settings.json, routing rules)."""
    env = Environment(
        loader=FileSystemLoader(str(template_dir)),
        keep_trailing_newline=True,
        undefined=__import__('jinja2').Undefined,
    )

    for template_file in template_dir.glob("*.j2"):
        rel_path = template_file.relative_to(template_dir)
        out_name = template_file.name.removesuffix(".j2")

        # CLAUDE.md goes to project root, others go to .claude/
        if out_name == "CLAUDE.md":
            out_path = output_dir.parent / out_name  # project root
        else:
            out_path = output_dir / out_name  # .claude/

        out_path.parent.mkdir(parents=True, exist_ok=True)

        try:
            tmpl = env.get_template(str(rel_path))
            rendered = tmpl.render(**template_vars)
            out_path.write_text(rendered)
        except Exception as e:
            print(f"WARNING: Failed to render {rel_path}: {e}", file=sys.stderr)


def copy_overlay_templates(overlay_dir: Path, output_dir: Path,
                           template_vars: dict, subdirs: list[str]):
    """Render overlay-specific templates into the output directory."""
    if not overlay_dir.exists():
        return

    env = Environment(
        loader=FileSystemLoader(str(overlay_dir)),
        keep_trailing_newline=True,
        undefined=__import__('jinja2').Undefined,
    )

    for subdir in subdirs:
        src = overlay_dir / subdir
        if not src.exists():
            continue

        for template_file in src.rglob("*.j2"):
            rel_path = template_file.relative_to(overlay_dir)
            out_path = output_dir / str(rel_path).removesuffix(".j2")

            out_path.parent.mkdir(parents=True, exist_ok=True)

            try:
                tmpl = env.get_template(str(rel_path))
                rendered = tmpl.render(**template_vars)
                out_path.write_text(rendered)

                if "hooks" in str(out_path) and out_path.suffix == ".sh":
                    out_path.chmod(out_path.stat().st_mode | stat.S_IEXEC | stat.S_IXGRP)

            except Exception as e:
                print(f"WARNING: Failed to render overlay {rel_path}: {e}", file=sys.stderr)


def generate_agents_md(output_dir: Path, agents: list[str], project_name: str):
    """Generate AGENTS.md registry file listing all agents."""
    lines = [
        f"# Agents Registry — {project_name}\n",
        "",
        "| Agent | File | Description |",
        "|-------|------|-------------|",
    ]
    for agent in agents:
        agent_file = output_dir / "agents" / f"{agent}.md"
        desc = ""
        if agent_file.exists():
            # Extract first heading after "## Role"
            for line in agent_file.read_text().splitlines():
                if line.startswith("## Role"):
                    continue
                if line.strip() and not line.startswith("#"):
                    desc = line.strip()
                    break
        lines.append(f"| {agent} | `agents/{agent}.md` | {desc} |")

    lines.append("")
    (output_dir / "AGENTS.md").write_text("\n".join(lines))


def _cleanup_extra_files(directory: Path, allowed_names: list[str], ext: str):
    """Remove files from directory that aren't in the allowed list."""
    if not directory.exists():
        return
    allowed = {f"{name}{ext}" for name in allowed_names}
    for f in directory.glob(f"*{ext}"):
        if f.name not in allowed:
            f.unlink()


def main():
    parser = argparse.ArgumentParser(description="Generate .claude/ profile for a project")
    parser.add_argument("--archetype", required=True, help="Archetype name")
    parser.add_argument("--project-name", required=True, help="Project name")
    parser.add_argument("--project-dir", required=True, help="Project directory path")
    parser.add_argument("--template-dir", required=True, help="Claude profile templates directory")
    parser.add_argument("--language", default=None, help="Primary language override")
    parser.add_argument("--project-description", default=None, help="Project description")
    args = parser.parse_args()

    template_dir = Path(args.template_dir)
    project_dir = Path(args.project_dir)
    base_dir = template_dir / "base"
    overlay_dir = template_dir / "overlays" / args.archetype
    shared_dir = template_dir / "shared"
    output_dir = project_dir / ".claude"

    # Validate
    if not base_dir.exists():
        print(f"ERROR: Base template not found: {base_dir}", file=sys.stderr)
        sys.exit(1)

    if not overlay_dir.exists():
        print(f"WARNING: No overlay for archetype '{args.archetype}', using base only",
              file=sys.stderr)

    # Load manifest
    manifest = load_manifest(overlay_dir) if overlay_dir.exists() else {}

    # Merge components
    base_agents = ["coordinator", "code-assistant", "reviewer", "tester"]
    base_skills = ["validate"]
    base_commands = ["health"]

    agents = merge_agents(base_agents, manifest)
    skills = merge_lists(base_skills, manifest, "skills")
    commands = merge_lists(base_commands, manifest, "commands")

    # Determine removed agents for cleanup
    removed_agents = set(manifest.get("agents", {}).get("remove", []))

    # Build template variables
    template_vars = build_template_vars(args, manifest, agents, skills, commands)

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)

    # Render base templates
    subdirs = ["agents", "skills", "commands", "hooks"]
    render_root_templates(base_dir, output_dir, template_vars)
    render_templates(base_dir, output_dir, template_vars, subdirs)

    # Render shared templates (fallback for agents/skills/commands not in overlay)
    if shared_dir.exists():
        copy_overlay_templates(shared_dir, output_dir, template_vars, subdirs)

    # Render overlay templates (overwrite base/shared where applicable)
    if overlay_dir.exists():
        copy_overlay_templates(overlay_dir, output_dir, template_vars, subdirs)

    # Cleanup: remove agents that were excluded by manifest
    for agent_name in removed_agents:
        agent_file = output_dir / "agents" / f"{agent_name}.md"
        if agent_file.exists():
            agent_file.unlink()

    # Remove shared/overlay files not in final merged lists
    _cleanup_extra_files(output_dir / "agents", agents, ".md")
    _cleanup_extra_files(output_dir / "skills", skills, ".md")
    _cleanup_extra_files(output_dir / "commands", commands, ".md")

    # Generate AGENTS.md registry
    generate_agents_md(output_dir, agents, args.project_name)

    # Summary
    agent_count = len(list((output_dir / "agents").glob("*.md"))) if (output_dir / "agents").exists() else 0
    skill_count = len(list((output_dir / "skills").glob("*.md"))) if (output_dir / "skills").exists() else 0
    cmd_count = len(list((output_dir / "commands").glob("*.md"))) if (output_dir / "commands").exists() else 0

    print(f"Generated .claude/ profile: {agent_count} agents, {skill_count} skills, {cmd_count} commands")


if __name__ == "__main__":
    main()
