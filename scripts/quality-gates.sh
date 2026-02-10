#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# quality-gates.sh — Quality Gates Framework for CodeFoundry
# Unified validation system: blocking + non-blocking gates
# ═══════════════════════════════════════════════════════════════════════════════
#
# Usage:
#   ./scripts/quality-gates.sh [--blocking|--info|--all|--pre-commit|--pre-deploy|--generated-profile <dir>]
#
# Exit codes:
#   0 = All gates passed
#   1 = Non-blocking warnings only
#   2 = Blocking gate failed (cannot proceed)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

MODE="${1:---all}"
PROFILE_DIR="${2:-.claude}"
EXIT_CODE=0
BLOCKING_FAILED=0
BLOCKING_PASSED=0
INFO_WARNED=0
INFO_PASSED=0

# Colors
if [ -t 1 ] && [ "${CI:-}" != "true" ]; then
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m'
else
    RED='' YELLOW='' GREEN='' BLUE='' BOLD='' DIM='' NC=''
fi

# ─── Utility Functions ───────────────────────────────────────────────────────

gate_pass() {
    local gate_type="$1" gate_name="$2"
    if [ "$gate_type" = "BLOCKING" ]; then
        BLOCKING_PASSED=$((BLOCKING_PASSED + 1))
    else
        INFO_PASSED=$((INFO_PASSED + 1))
    fi
    printf "  ${GREEN}PASS${NC}  [%s] %s\n" "$gate_type" "$gate_name"
}

gate_fail() {
    local gate_type="$1" gate_name="$2" detail="${3:-}"
    if [ "$gate_type" = "BLOCKING" ]; then
        BLOCKING_FAILED=$((BLOCKING_FAILED + 1))
        if [ "$EXIT_CODE" -lt 2 ]; then EXIT_CODE=2; fi
    else
        INFO_WARNED=$((INFO_WARNED + 1))
        if [ "$EXIT_CODE" -lt 1 ]; then EXIT_CODE=1; fi
    fi
    printf "  ${RED}FAIL${NC}  [%s] %s\n" "$gate_type" "$gate_name"
    if [ -n "$detail" ]; then
        printf "        ${DIM}→ %s${NC}\n" "$detail"
    fi
}

gate_warn() {
    local gate_type="$1" gate_name="$2" detail="${3:-}"
    INFO_WARNED=$((INFO_WARNED + 1))
    if [ "$EXIT_CODE" -lt 1 ]; then EXIT_CODE=1; fi
    printf "  ${YELLOW}WARN${NC}  [%s] %s\n" "$gate_type" "$gate_name"
    if [ -n "$detail" ]; then
        printf "        ${DIM}→ %s${NC}\n" "$detail"
    fi
}

header() {
    echo ""
    printf "${BOLD}%s${NC}\n" "$1"
    echo "───────────────────────────────────────────────────"
}

# ═══════════════════════════════════════════════════════════════════════════════
# BLOCKING GATES — Must pass for deployment/commit
# ═══════════════════════════════════════════════════════════════════════════════

run_blocking_gates() {
    header "BLOCKING GATES"

    # ─── Gate B1: JSON Schema Validation ──────────────────────────────────
    local json_errors=0
    for json_file in .claude/auto-routing-rules.json; do
        if [ -f "$json_file" ]; then
            if python3 -c "import json; json.load(open('$json_file'))" 2>/dev/null; then
                : # valid
            else
                json_errors=$((json_errors + 1))
            fi
        fi
    done

    # Check all .json files in .claude/
    while IFS= read -r -d '' jf; do
        if ! python3 -c "import json; json.load(open('$jf'))" 2>/dev/null; then
            json_errors=$((json_errors + 1))
        fi
    done < <(find .claude -name "*.json" -type f -print0 2>/dev/null)

    if [ "$json_errors" -eq 0 ]; then
        gate_pass "BLOCKING" "JSON syntax validation"
    else
        gate_fail "BLOCKING" "JSON syntax validation" "$json_errors file(s) with invalid JSON"
    fi

    # ─── Gate B2: @ref Link Integrity ─────────────────────────────────────
    local ref_result
    ref_result=$(python3 "$SCRIPT_DIR/check-refs.py" 2>/dev/null)

    local broken_refs
    broken_refs=$(echo "$ref_result" | head -1)
    broken_refs=${broken_refs:-0}

    if [ "$broken_refs" -eq 0 ] 2>/dev/null; then
        gate_pass "BLOCKING" "@ref link integrity"
    else
        gate_fail "BLOCKING" "@ref link integrity" "$broken_refs broken reference(s)"
        echo "$ref_result" | tail -n +2 | while IFS= read -r line; do
            [ -z "$line" ] && continue
            printf "        ${DIM}→ %s${NC}\n" "$line"
        done
    fi

    # ─── Gate B3: Token Budget Compliance ─────────────────────────────────
    if [ -f "$SCRIPT_DIR/validate-token-budget.sh" ]; then
        if "$SCRIPT_DIR/validate-token-budget.sh" --quick >/dev/null 2>&1; then
            gate_pass "BLOCKING" "Token budget compliance"
        else
            local tb_exit=$?
            if [ "$tb_exit" -eq 2 ]; then
                gate_fail "BLOCKING" "Token budget compliance" "One or more files exceed budget"
            else
                gate_warn "INFO" "Token budget approaching limits"
            fi
        fi
    else
        gate_warn "INFO" "Token budget script not found (skipped)"
    fi

    # ─── Gate B4: Python Syntax Check ─────────────────────────────────────
    local py_errors=0
    while IFS= read -r -d '' py_file; do
        if ! python3 -c "import py_compile; py_compile.compile('$py_file', doraise=True)" 2>/dev/null; then
            py_errors=$((py_errors + 1))
        fi
    done < <(find . -name "*.py" -not -path "./.git/*" -not -path "./node_modules/*" -type f -print0)

    if [ "$py_errors" -eq 0 ]; then
        gate_pass "BLOCKING" "Python syntax check"
    else
        gate_fail "BLOCKING" "Python syntax check" "$py_errors file(s) with syntax errors"
    fi

    # ─── Gate B5: Shell Script Syntax Check ───────────────────────────────
    local sh_errors=0
    while IFS= read -r -d '' sh_file; do
        if ! bash -n "$sh_file" 2>/dev/null; then
            sh_errors=$((sh_errors + 1))
        fi
    done < <(find . -name "*.sh" -not -path "./.git/*" -not -path "./node_modules/*" -type f -print0)

    if [ "$sh_errors" -eq 0 ]; then
        gate_pass "BLOCKING" "Shell script syntax check"
    else
        gate_fail "BLOCKING" "Shell script syntax check" "$sh_errors file(s) with syntax errors"
    fi

    # ─── Gate B6: Agent Routing Integrity ─────────────────────────────────
    local phantom_agents=0
    if [ -f ".claude/auto-routing-rules.json" ]; then
        # Extract unique agent names from routing rules
        local agents_in_rules
        agents_in_rules=$(python3 -c "
import json
with open('.claude/auto-routing-rules.json') as f:
    data = json.load(f)
agents = set()
for rule in data.get('rules', []):
    agent = rule.get('agent', '')
    if agent and agent != 'system':
        agents.add(agent)
print('\n'.join(sorted(agents)))
" 2>/dev/null || echo "")

        # Virtual agents (no .md file needed — handled by Claude natively)
        local virtual_agents="code_assistant reviewer"

        # Check each agent has a corresponding file or is virtual
        while IFS= read -r agent_name; do
            [ -z "$agent_name" ] && continue
            # Skip virtual agents
            if echo "$virtual_agents" | grep -qw "$agent_name"; then
                continue
            fi
            if [ ! -f ".claude/agents/${agent_name}.md" ]; then
                phantom_agents=$((phantom_agents + 1))
            fi
        done <<< "$agents_in_rules"
    fi

    if [ "$phantom_agents" -eq 0 ]; then
        gate_pass "BLOCKING" "Agent routing integrity (no phantom agents)"
    else
        gate_fail "BLOCKING" "Agent routing integrity" "$phantom_agents phantom agent(s) in routing rules"
    fi

    # ─── Gate B7: Required Files Exist ────────────────────────────────────
    local missing_files=0
    for req_file in CLAUDE.md SESSION.md PROJECT.md TASKS.md Makefile; do
        if [ ! -f "$req_file" ]; then
            missing_files=$((missing_files + 1))
        fi
    done

    if [ "$missing_files" -eq 0 ]; then
        gate_pass "BLOCKING" "Required project files exist"
    else
        gate_fail "BLOCKING" "Required project files exist" "$missing_files required file(s) missing"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# NON-BLOCKING (INFO) GATES — Warnings, do not block
# ═══════════════════════════════════════════════════════════════════════════════

run_info_gates() {
    header "INFO GATES (non-blocking)"

    # ─── Gate I1: Shell Scripts Executable ────────────────────────────────
    local non_exec=0
    while IFS= read -r -d '' sh_file; do
        if [ ! -x "$sh_file" ]; then
            non_exec=$((non_exec + 1))
        fi
    done < <(find ./scripts -name "*.sh" -type f -print0 2>/dev/null)

    if [ "$non_exec" -eq 0 ]; then
        gate_pass "INFO" "All shell scripts are executable"
    else
        gate_warn "INFO" "Non-executable shell scripts" "$non_exec script(s) missing +x permission"
    fi

    # ─── Gate I2: Documentation Coverage ──────────────────────────────────
    local agents_without_docs=0
    while IFS= read -r -d '' agent_file; do
        local agent_name
        agent_name=$(basename "$agent_file" .md)
        if [ ! -d "docs/agents" ] || ! ls docs/agents/${agent_name}.* >/dev/null 2>&1; then
            agents_without_docs=$((agents_without_docs + 1))
        fi
    done < <(find .claude/agents -name "*.md" -type f -print0 2>/dev/null)

    if [ "$agents_without_docs" -eq 0 ]; then
        gate_pass "INFO" "Agent documentation coverage"
    else
        gate_warn "INFO" "Agent documentation coverage" "$agents_without_docs agent(s) without docs"
    fi

    # ─── Gate I3: Makefile test target surfacing ──────────────────────────
    if grep -q '"No tests defined"' Makefile 2>/dev/null; then
        gate_warn "INFO" "Makefile test target" "'make test' says 'No tests defined' but test targets exist (test-agents, ci-test)"
    else
        gate_pass "INFO" "Makefile test target surfaces real tests"
    fi

    # ─── Gate I4: Git staging safety ──────────────────────────────────────
    if grep -q 'git add -A' Makefile 2>/dev/null; then
        gate_warn "INFO" "Git staging safety" "'git add -A' in Makefile can stage unintended files"
    else
        gate_pass "INFO" "Git staging uses explicit file patterns"
    fi

    # ─── Gate I5: Archetype completeness ──────────────────────────────────
    local incomplete_archetypes=0
    if [ -d "templates/archetypes" ]; then
        for archetype_dir in templates/archetypes/*/; do
            [ -d "$archetype_dir" ] || continue
            if [ ! -f "${archetype_dir}README.md" ]; then
                incomplete_archetypes=$((incomplete_archetypes + 1))
            fi
        done
    fi

    if [ "$incomplete_archetypes" -eq 0 ]; then
        gate_pass "INFO" "Archetype completeness"
    else
        gate_warn "INFO" "Archetype completeness" "$incomplete_archetypes archetype(s) missing README.md"
    fi

    # ─── Gate I6: Profile template completeness ─────────────────────────
    local profile_issues=0
    if [ -d "templates/claude-profile/base" ]; then
        # Check base has required files
        for req in CLAUDE.md.j2 settings.json.j2 auto-routing-rules.json.j2; do
            if [ ! -f "templates/claude-profile/base/$req" ]; then
                profile_issues=$((profile_issues + 1))
            fi
        done
        # Check each overlay has manifest.json
        if [ -d "templates/claude-profile/overlays" ]; then
            for overlay_dir in templates/claude-profile/overlays/*/; do
                [ -d "$overlay_dir" ] || continue
                if [ ! -f "${overlay_dir}manifest.json" ]; then
                    profile_issues=$((profile_issues + 1))
                fi
            done
        fi
        if [ "$profile_issues" -eq 0 ]; then
            gate_pass "INFO" "Profile template completeness"
        else
            gate_warn "INFO" "Profile template completeness" "$profile_issues issue(s) in templates/claude-profile/"
        fi
    else
        gate_warn "INFO" "Profile template completeness" "templates/claude-profile/base/ not found"
    fi

    # ─── Gate I7: Document integration (breadcrumbs + INDEX.md) ──────────
    local orphan_docs=0
    local no_breadcrumbs=0
    if [ -f "docs/INDEX.md" ]; then
        local index_content
        index_content=$(cat docs/INDEX.md)

        while IFS= read -r -d '' doc_file; do
            local doc_basename
            doc_basename=$(basename "$doc_file")

            # Skip INDEX.md itself and hidden files
            [ "$doc_basename" = "INDEX.md" ] && continue
            [ "$doc_basename" = "NAVIGATION.md" ] && continue

            # Check breadcrumbs (line starting with > containing 🏠)
            if ! head -5 "$doc_file" | grep -q '🏠' 2>/dev/null; then
                no_breadcrumbs=$((no_breadcrumbs + 1))
            fi

            # Check if listed in INDEX.md
            if ! echo "$index_content" | grep -q "$doc_basename" 2>/dev/null; then
                orphan_docs=$((orphan_docs + 1))
            fi
        done < <(find docs -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null)
    fi

    local i7_issues=$((orphan_docs + no_breadcrumbs))
    if [ "$i7_issues" -eq 0 ]; then
        gate_pass "INFO" "Document integration (breadcrumbs + INDEX.md)"
    else
        local detail=""
        [ "$no_breadcrumbs" -gt 0 ] && detail="${no_breadcrumbs} doc(s) missing breadcrumbs"
        [ "$orphan_docs" -gt 0 ] && {
            [ -n "$detail" ] && detail="$detail, "
            detail="${detail}${orphan_docs} doc(s) not in INDEX.md"
        }
        gate_warn "INFO" "Document integration" "$detail"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# GENERATED PROFILE VALIDATION — Validates a generated .claude/ directory
# ═══════════════════════════════════════════════════════════════════════════════

run_profile_gates() {
    local profile_dir="${PROFILE_DIR:-.claude}"
    header "PROFILE GATES (generated .claude/ validation)"

    if [ ! -d "$profile_dir" ]; then
        gate_fail "BLOCKING" "Profile directory exists" "$profile_dir not found"
        return
    fi

    # ─── Gate P1: Routing rules reference existing agents ───────────────
    local routing_file="$profile_dir/auto-routing-rules.json"
    if [ -f "$routing_file" ]; then
        local bad_refs=0
        # Extract agent names from routing rules
        local agents_in_rules
        agents_in_rules=$(python3 -c "
import json, sys
with open('$routing_file') as f:
    data = json.load(f)
agents = set()
for rule in data.get('rules', []):
    agents.add(rule.get('agent', ''))
for a in sorted(agents):
    print(a)
" 2>/dev/null || echo "")

        for agent_name in $agents_in_rules; do
            if [ ! -f "$profile_dir/agents/${agent_name}.md" ]; then
                bad_refs=$((bad_refs + 1))
            fi
        done

        if [ "$bad_refs" -eq 0 ]; then
            gate_pass "BLOCKING" "Routing rules reference existing agents"
        else
            gate_fail "BLOCKING" "Routing rules reference existing agents" "$bad_refs agent(s) referenced but missing"
        fi
    else
        gate_warn "INFO" "Routing rules" "auto-routing-rules.json not found"
    fi

    # ─── Gate P2: AGENTS.md lists only existing files ───────────────────
    local agents_md="$profile_dir/AGENTS.md"
    if [ -f "$agents_md" ]; then
        local missing_agent_files=0
        while IFS= read -r agent_file; do
            if [ ! -f "$profile_dir/$agent_file" ]; then
                missing_agent_files=$((missing_agent_files + 1))
            fi
        done < <(python3 -c "
import re, sys
with open('$agents_md') as f:
    for line in f:
        m = re.search(r'\x60(agents/[^\x60]+\.md)\x60', line)
        if m:
            print(m.group(1))
" 2>/dev/null)

        if [ "$missing_agent_files" -eq 0 ]; then
            gate_pass "BLOCKING" "AGENTS.md references existing files"
        else
            gate_fail "BLOCKING" "AGENTS.md references existing files" "$missing_agent_files file(s) listed but missing"
        fi
    fi

    # ─── Gate P3: Settings JSON valid ───────────────────────────────────
    local settings_file="$profile_dir/settings.json"
    if [ -f "$settings_file" ]; then
        if python3 -c "import json; json.load(open('$settings_file'))" 2>/dev/null; then
            gate_pass "BLOCKING" "Profile settings.json valid JSON"
        else
            gate_fail "BLOCKING" "Profile settings.json valid JSON" "Syntax error"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# Summary & Execution
# ═══════════════════════════════════════════════════════════════════════════════

print_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    printf "${BOLD}QUALITY GATES SUMMARY${NC}\n"
    echo "═══════════════════════════════════════════════════════════"
    printf "  Blocking:     ${GREEN}%d passed${NC}" "$BLOCKING_PASSED"
    if [ "$BLOCKING_FAILED" -gt 0 ]; then
        printf ", ${RED}%d failed${NC}" "$BLOCKING_FAILED"
    fi
    echo ""
    printf "  Info:         ${GREEN}%d passed${NC}" "$INFO_PASSED"
    if [ "$INFO_WARNED" -gt 0 ]; then
        printf ", ${YELLOW}%d warnings${NC}" "$INFO_WARNED"
    fi
    echo ""
    echo "───────────────────────────────────────────────────────────"

    case $EXIT_CODE in
        0) printf "  ${GREEN}RESULT: ALL GATES PASSED${NC}\n" ;;
        1) printf "  ${YELLOW}RESULT: PASSED with warnings${NC}\n" ;;
        2) printf "  ${RED}RESULT: BLOCKED — fix blocking gates before proceeding${NC}\n" ;;
    esac

    echo "═══════════════════════════════════════════════════════════"
    echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────

echo ""
printf "${BOLD}QUALITY GATES${NC} — CodeFoundry Validation Framework\n"
printf "${DIM}Mode: %s${NC}\n" "$MODE"

case "$MODE" in
    --blocking|--pre-commit|--pre-deploy)
        run_blocking_gates
        ;;
    --info)
        run_info_gates
        ;;
    --generated-profile)
        run_profile_gates
        ;;
    --all|*)
        run_blocking_gates
        run_info_gates
        ;;
esac

print_summary

exit $EXIT_CODE
