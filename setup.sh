#!/usr/bin/env bash
set -euo pipefail

# Claude Project Workflow — Setup Script
# Scaffolds the 4-file documentation system, SessionStart hook, and worktree template.
#
# Usage:
#   ./setup.sh --name "My Project" --dir ~/path/to/project
#   ./setup.sh --name "My Project" --dir ~/path/to/project --investigations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
PROJECT_NAME=""
PROJECT_DIR=""
INCLUDE_INVESTIGATIONS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --name) PROJECT_NAME="$2"; shift 2 ;;
    --dir) PROJECT_DIR="$2"; shift 2 ;;
    --investigations) INCLUDE_INVESTIGATIONS=true; shift ;;
    -h|--help)
      echo "Usage: ./setup.sh --name \"Project Name\" --dir /path/to/project [--investigations]"
      echo ""
      echo "Options:"
      echo "  --name              Project name (used in templates)"
      echo "  --dir               Path to the project root"
      echo "  --investigations    Include beliefs-and-tests.md investigation journal"
      echo ""
      echo "Creates:"
      echo "  CLAUDE.md                           Session rules and enforcement"
      echo "  ARCHITECTURE.md                     System map template"
      echo "  MEMORY.md                           Quick-reference lookup"
      echo "  CHANGELOG.md                        Release history"
      echo "  docs/as-built.md                    Design decisions journal"
      echo "  docs/beliefs-and-tests.md           Investigation journal (with --investigations)"
      echo "  .changelog/README.md                Changelog fragment format guide"
      echo "  .claude/settings.json               SessionStart hook config"
      echo "  .claude/hooks/context-recovery.sh   Context recovery script"
      echo "  .claude/worktree-prompt-template.md Worktree session template"
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

echo "Setting up Claude Project Workflow for: $PROJECT_NAME"
echo "Directory: $PROJECT_DIR"
echo ""

# Create directories
mkdir -p "$PROJECT_DIR/docs"
mkdir -p "$PROJECT_DIR/.claude/hooks"
mkdir -p "$PROJECT_DIR/.changelog"

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

# Copy templates
copy_template "$SCRIPT_DIR/templates/CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
copy_template "$SCRIPT_DIR/templates/ARCHITECTURE.md" "$PROJECT_DIR/ARCHITECTURE.md"
copy_template "$SCRIPT_DIR/templates/MEMORY.md" "$PROJECT_DIR/MEMORY.md"
copy_template "$SCRIPT_DIR/templates/CHANGELOG.md" "$PROJECT_DIR/CHANGELOG.md"
copy_template "$SCRIPT_DIR/templates/as-built.md" "$PROJECT_DIR/docs/as-built.md"
copy_template "$SCRIPT_DIR/templates/worktree-prompt-template.md" "$PROJECT_DIR/.claude/worktree-prompt-template.md"
copy_template "$SCRIPT_DIR/templates/changelog-readme.md" "$PROJECT_DIR/.changelog/README.md"

# Optional: investigation journal
if [[ "$INCLUDE_INVESTIGATIONS" == true ]]; then
  copy_template "$SCRIPT_DIR/templates/beliefs-and-tests.md" "$PROJECT_DIR/docs/beliefs-and-tests.md"
fi

# Copy hook files
if [[ -f "$PROJECT_DIR/.claude/settings.json" ]]; then
  echo "  SKIP  .claude/settings.json (already exists — merge hooks manually)"
else
  cp "$SCRIPT_DIR/hooks/settings.json" "$PROJECT_DIR/.claude/settings.json"
  echo "  CREATE .claude/settings.json"
fi

# Copy and customize the hook script
HOOK_DEST="$PROJECT_DIR/.claude/hooks/context-recovery.sh"
if [[ -f "$HOOK_DEST" ]]; then
  echo "  SKIP  $HOOK_DEST (already exists)"
else
  sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$SCRIPT_DIR/hooks/context-recovery.sh" > "$HOOK_DEST"
  chmod +x "$HOOK_DEST"
  echo "  CREATE $HOOK_DEST"
fi

# Update .gitignore if it exists
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
echo "Done! Next steps:"
echo ""
echo "  1. Fill in ARCHITECTURE.md with your system diagram and file structure"
echo "  2. Fill in MEMORY.md with your project config, schema, and key files"
echo "  3. Customize .claude/hooks/context-recovery.sh:"
echo "     - Update the PAST FAILURES section with real incidents"
echo "     - Update the DEV COMMANDS section"
echo "  4. Start adding as-built decisions to docs/as-built.md as you make them"
if [[ "$INCLUDE_INVESTIGATIONS" == true ]]; then
  echo "  5. Use docs/beliefs-and-tests.md when investigating complex issues"
fi
echo ""
echo "The SessionStart hook will fire on your next Claude session in this project."
