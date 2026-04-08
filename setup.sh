#!/usr/bin/env bash
set -euo pipefail

# Claude Project Workflow — Setup Script v1.3
# Scaffolds the full workflow standard: docs, hooks, guards, config, skills.
#
# Usage:
#   ./setup.sh --name "My Project" --dir ~/path/to/project
#   ./setup.sh --name "My Project" --dir ~/path/to/project --mode worktree
#   ./setup.sh --name "My Project" --dir ~/path/to/project --investigations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
PROJECT_NAME=""
PROJECT_DIR=""
WORKFLOW_MODE="main"
INCLUDE_INVESTIGATIONS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --name) PROJECT_NAME="$2"; shift 2 ;;
    --dir) PROJECT_DIR="$2"; shift 2 ;;
    --mode) WORKFLOW_MODE="$2"; shift 2 ;;
    --investigations) INCLUDE_INVESTIGATIONS=true; shift ;;
    -h|--help)
      echo "Usage: ./setup.sh --name \"Project Name\" --dir /path/to/project [--mode main|worktree] [--investigations]"
      echo ""
      echo "Options:"
      echo "  --name              Project name (used in templates)"
      echo "  --dir               Path to the project root"
      echo "  --mode              Workflow mode: main (default) or worktree"
      echo "  --investigations    Include beliefs-and-tests.md investigation journal"
      echo ""
      echo "Creates:"
      echo "  Core docs:          CLAUDE.md, ARCHITECTURE.md, MEMORY.md, CHANGELOG.md"
      echo "  Decision docs:      docs/as-built.md, docs/findings.md, docs/assumptions.md"
      echo "  Changelog:          .changelog/README.md"
      echo "  Hooks:              context-recovery.sh, pre-commit-guard.sh, pre-pr-guard.sh, pre-release-guard.sh"
      echo "  Config:             settings.json, workflow-mode, context-files, version-files, release-artifacts"
      echo "  Skills:             Process skills (BA, PM, Scrum Master, UX, QA)"
      echo "  Issue templates:    .github/ISSUE_TEMPLATE/ (epic, story, spike, investigation, bug, chore)"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$PROJECT_NAME" || -z "$PROJECT_DIR" ]]; then
  echo "Error: --name and --dir are required."
  echo "Run ./setup.sh --help for usage."
  exit 1
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Error: Directory does not exist: $PROJECT_DIR"
  exit 1
fi

if [[ "$WORKFLOW_MODE" != "main" && "$WORKFLOW_MODE" != "worktree" ]]; then
  echo "Error: --mode must be 'main' or 'worktree'"
  exit 1
fi

echo "Setting up Claude Project Workflow v1.3 for: $PROJECT_NAME"
echo "Directory: $PROJECT_DIR"
echo "Mode: $WORKFLOW_MODE"
echo ""

# Create directories
mkdir -p "$PROJECT_DIR/docs"
mkdir -p "$PROJECT_DIR/docs/spikes"
mkdir -p "$PROJECT_DIR/.claude/hooks"
mkdir -p "$PROJECT_DIR/.claude/skills"
mkdir -p "$PROJECT_DIR/.changelog"
mkdir -p "$PROJECT_DIR/.github/ISSUE_TEMPLATE"

# Helper: copy template with project name substitution
copy_template() {
  local src="$1"
  local dest="$2"

  if [[ -f "$dest" ]]; then
    echo "  SKIP  $dest (already exists)"
    return
  fi

  sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$src" > "$dest"
  echo "  CREATE $dest"
}

# -- Core documents ------------------------------------------------------------
echo "Core documents:"
copy_template "$SCRIPT_DIR/templates/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
copy_template "$SCRIPT_DIR/templates/ARCHITECTURE.md" "$PROJECT_DIR/ARCHITECTURE.md"
copy_template "$SCRIPT_DIR/templates/MEMORY.md" "$PROJECT_DIR/MEMORY.md"
copy_template "$SCRIPT_DIR/templates/CHANGELOG.md" "$PROJECT_DIR/CHANGELOG.md"
copy_template "$SCRIPT_DIR/templates/as-built.md" "$PROJECT_DIR/docs/as-built.md"
echo ""

# -- Decision documents --------------------------------------------------------
echo "Decision documents:"
if [[ ! -f "$PROJECT_DIR/docs/findings.md" ]]; then
  cat > "$PROJECT_DIR/docs/findings.md" << 'EOF'
# Findings Register

> Permanent operational gotcha register. Things that fail in non-obvious ways.
> Never deleted. Append-only. Format: F-xxx.

---

<!-- Add findings as you discover them:

## F-001: [Short title]

**Discovered:** YYYY-MM-DD | **Project area:** [area]

**What happens:** [Description of the failure mode]

**Rule:** [What to do instead]

**Context:** [How it was discovered, issue reference]

-->
EOF
  echo "  CREATE docs/findings.md"
else
  echo "  SKIP  docs/findings.md (already exists)"
fi

if [[ ! -f "$PROJECT_DIR/docs/assumptions.md" ]]; then
  cat > "$PROJECT_DIR/docs/assumptions.md" << 'EOF'
# Assumptions Register

> Unverified assumption tracker. Lifecycle: open → confirmed/disproved → resolved.
> Format: A-xxx.

---

## Open

<!-- Add assumptions as you identify them:

### A-001: [Short title]

**Raised:** YYYY-MM-DD | **Status:** OPEN
**Raised by:** [Context — which decision or task raised this]

**Assumption:** [What is being assumed]

**How to verify:** [Concrete test or check]
**Issue:** #N

-->

---

## Resolved

<!-- Move confirmed/disproved assumptions here with resolution date and outcome -->
EOF
  echo "  CREATE docs/assumptions.md"
else
  echo "  SKIP  docs/assumptions.md (already exists)"
fi

# Optional: investigation journal
if [[ "$INCLUDE_INVESTIGATIONS" == true ]]; then
  copy_template "$SCRIPT_DIR/templates/beliefs-and-tests.md" "$PROJECT_DIR/docs/beliefs-and-tests.md"
fi
echo ""

# -- Changelog -----------------------------------------------------------------
echo "Changelog:"
copy_template "$SCRIPT_DIR/templates/changelog-readme.md" "$PROJECT_DIR/.changelog/README.md"
echo ""

# -- Worktree template ---------------------------------------------------------
echo "Templates:"
copy_template "$SCRIPT_DIR/templates/worktree-prompt-template.md" "$PROJECT_DIR/.claude/worktree-prompt-template.md"
echo ""

# -- Hook scripts --------------------------------------------------------------
echo "Hooks:"
# settings.json
if [[ -f "$PROJECT_DIR/.claude/settings.json" ]]; then
  echo "  SKIP  .claude/settings.json (already exists — merge hooks manually)"
else
  cp "$SCRIPT_DIR/hooks/settings.json" "$PROJECT_DIR/.claude/settings.json"
  echo "  CREATE .claude/settings.json (SessionStart + 3 PreToolUse guards)"
fi

# context-recovery.sh
HOOK_DEST="$PROJECT_DIR/.claude/hooks/context-recovery.sh"
if [[ -f "$HOOK_DEST" ]]; then
  echo "  SKIP  $HOOK_DEST (already exists)"
else
  sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$SCRIPT_DIR/hooks/context-recovery.sh" > "$HOOK_DEST"
  chmod +x "$HOOK_DEST"
  echo "  CREATE context-recovery.sh"
fi

# pre-commit-guard.sh
GUARD_DEST="$PROJECT_DIR/.claude/hooks/pre-commit-guard.sh"
if [[ -f "$GUARD_DEST" ]]; then
  echo "  SKIP  $GUARD_DEST (already exists)"
else
  cp "$SCRIPT_DIR/hooks/pre-commit-guard.sh" "$GUARD_DEST"
  chmod +x "$GUARD_DEST"
  echo "  CREATE pre-commit-guard.sh"
fi

# pre-pr-guard.sh
GUARD_DEST="$PROJECT_DIR/.claude/hooks/pre-pr-guard.sh"
if [[ -f "$GUARD_DEST" ]]; then
  echo "  SKIP  $GUARD_DEST (already exists)"
else
  cp "$SCRIPT_DIR/hooks/pre-pr-guard.sh" "$GUARD_DEST"
  chmod +x "$GUARD_DEST"
  echo "  CREATE pre-pr-guard.sh"
fi

# pre-release-guard.sh
GUARD_DEST="$PROJECT_DIR/.claude/hooks/pre-release-guard.sh"
if [[ -f "$GUARD_DEST" ]]; then
  echo "  SKIP  $GUARD_DEST (already exists)"
else
  cp "$SCRIPT_DIR/hooks/pre-release-guard.sh" "$GUARD_DEST"
  chmod +x "$GUARD_DEST"
  echo "  CREATE pre-release-guard.sh"
fi
echo ""

# -- Config files --------------------------------------------------------------
echo "Config:"

# workflow-mode
if [[ ! -f "$PROJECT_DIR/.claude/workflow-mode" ]]; then
  echo "$WORKFLOW_MODE" > "$PROJECT_DIR/.claude/workflow-mode"
  echo "  CREATE .claude/workflow-mode ($WORKFLOW_MODE)"
else
  echo "  SKIP  .claude/workflow-mode (already exists)"
fi

# context-files
if [[ ! -f "$PROJECT_DIR/.claude/context-files" ]]; then
  cat > "$PROJECT_DIR/.claude/context-files" << EOF
# Tier 2 sources — loaded by SessionStart hook every session.
# One source per line. Lines starting with # are ignored.
# Add files here when skipping them has caused regressions.
ARCHITECTURE.md
MEMORY.md
gh-issues
EOF
  echo "  CREATE .claude/context-files (3 default sources)"
else
  echo "  SKIP  .claude/context-files (already exists)"
fi

# version-files
if [[ ! -f "$PROJECT_DIR/.claude/version-files" ]]; then
  cat > "$PROJECT_DIR/.claude/version-files" << 'EOF'
# Files containing version numbers that must match git tag at release.
# One file per line. Lines starting with # are ignored.
# Example: dashboard.py
# Example: package.json
EOF
  echo "  CREATE .claude/version-files (empty — add your version-bearing files)"
else
  echo "  SKIP  .claude/version-files (already exists)"
fi

# release-artifacts
if [[ ! -f "$PROJECT_DIR/.claude/release-artifacts" ]]; then
  cat > "$PROJECT_DIR/.claude/release-artifacts" << 'EOF'
# Release artifact enforcement
changelog: true
architecture: true
memory: true
user-docs: false
# user-docs: docs/user-guide.md
EOF
  echo "  CREATE .claude/release-artifacts"
else
  echo "  SKIP  .claude/release-artifacts (already exists)"
fi
echo ""

# -- Issue templates -----------------------------------------------------------
echo "Issue templates:"
for template in "$SCRIPT_DIR/templates/github/ISSUE_TEMPLATE/"*.md; do
  [ -f "$template" ] || continue
  dest="$PROJECT_DIR/.github/ISSUE_TEMPLATE/$(basename "$template")"
  if [[ -f "$dest" ]]; then
    echo "  SKIP  $(basename "$template") (already exists)"
  else
    cp "$template" "$dest"
    echo "  CREATE $(basename "$template")"
  fi
done
echo ""

# -- Process skills ------------------------------------------------------------
echo "Process skills:"
for skill in "$SCRIPT_DIR/templates/skills/process-"*.md; do
  [ -f "$skill" ] || continue
  dest="$PROJECT_DIR/.claude/skills/$(basename "$skill")"
  if [[ -f "$dest" ]]; then
    echo "  SKIP  $(basename "$skill") (already exists)"
  else
    cp "$skill" "$dest"
    echo "  CREATE $(basename "$skill")"
  fi
done
echo ""

# -- .gitignore update ---------------------------------------------------------
GITIGNORE="$PROJECT_DIR/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
  if ! grep -q ".claude/worktrees/" "$GITIGNORE" 2>/dev/null; then
    echo "" >> "$GITIGNORE"
    echo "# Claude Code worktrees (local session state)" >> "$GITIGNORE"
    echo ".claude/worktrees/" >> "$GITIGNORE"
    echo ".claude/settings.local.json" >> "$GITIGNORE"
    echo "  UPDATE .gitignore (added .claude/worktrees/ and settings.local.json)"
  else
    echo "  SKIP  .gitignore (already has worktrees entry)"
  fi
else
  echo "  SKIP  .gitignore (file not found — add .claude/worktrees/ manually)"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "Done! Workflow Standard v1.3 scaffolded for: $PROJECT_NAME"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "  1. Fill in ARCHITECTURE.md with your system diagram"
echo "  2. Fill in MEMORY.md with config values, key files, versions"
echo "  3. Add version-bearing files to .claude/version-files"
echo "  4. Customize .claude/hooks/context-recovery.sh:"
echo "     - Update PAST FAILURES with real incidents"
echo "     - Update STANDING RULES with operational rules"
echo "  5. Add .claude/context-files entries as you discover which files matter"
echo ""
echo "  Issue templates: .github/ISSUE_TEMPLATE/ (epic, story, spike, investigation, bug, chore)"
echo "  Process skills:  .claude/skills/ (BA, PM, Scrum Master, UX, QA)"
echo ""
echo "  Greenfield? Run planning phases:"
echo "    1. docs/concept.md  — use process-ba-analyst skill"
echo "    2. Spike(s)         — use spike issue template"
echo "    3. docs/requirements.md — use process-product-manager skill"
echo "    4. Epic issues      — use process-scrum-master skill"
echo ""
echo "  Commit at least once per significant change."
echo "  Uncommitted work is unprotected work."
echo ""
echo "The SessionStart hook fires on your next Claude session in this project."
