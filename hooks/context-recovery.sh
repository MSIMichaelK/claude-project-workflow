#!/usr/bin/env bash
# SessionStart hook — {{PROJECT_NAME}}
# Fires at every session start (including after compaction).
# Reads Tier 2 from .claude/context-files. Full detail via topic skills (Tier 3).
#
# CUSTOMIZATION:
#   - Replace {{PROJECT_NAME}} with your project name (setup.sh does this)
#   - Update the PAST FAILURES section with project-specific incidents
#   - Update STANDING RULES with project-specific operational rules

TRIGGER="${SESSION_TRIGGER:-startup}"
MODE=$(cat .claude/workflow-mode 2>/dev/null || echo "main")
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"

# -- Compact path: short recovery, skip the full output -----------------------
if [ "$TRIGGER" = "compact" ]; then
  echo "STOP. Context was compacted. Re-read these files NOW:"
  echo ""
  if [ -f "$PROJECT_DIR/.claude/context-files" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      [ -z "$line" ] && continue
      [ "${line:0:1}" = "#" ] && continue
      entry=$(echo "$line" | sed 's/#.*//' | xargs)
      [ -z "$entry" ] && continue
      if [ "$entry" = "gh-issues" ]; then
        echo "  - gh issue list --state open --limit 50"
      elif [[ "$entry" == *":tail:"* ]]; then
        file=$(echo "$entry" | cut -d: -f1)
        num=$(echo "$entry" | cut -d: -f3)
        echo "  - $file (last $num releases only)"
      else
        echo "  - $entry"
      fi
    done < "$PROJECT_DIR/.claude/context-files"
  fi
  echo ""
  echo "Re-load the topic skill for your current task."
  echo "DO NOT CONTINUE until you have re-read the files above."
  exit 0
fi

# -- Normal startup path -------------------------------------------------------
echo "STOP. Read the files below. Post proof checklist BEFORE any work."
echo ""
echo "Trigger: $TRIGGER | Mode: $MODE | Branch: $(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo detached)"
echo ""

# -- Tier 2: read context-files list -------------------------------------------
if [ -f "$PROJECT_DIR/.claude/context-files" ]; then
  echo "TIER 2 — Read ALL of the following before doing any work:"
  echo ""
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    [ "${line:0:1}" = "#" ] && continue
    entry=$(echo "$line" | sed 's/#.*//' | xargs)
    [ -z "$entry" ] && continue
    if [ "$entry" = "gh-issues" ]; then
      echo "  - gh issue list --state open --limit 50"
    elif [[ "$entry" == *":tail:"* ]]; then
      file=$(echo "$entry" | cut -d: -f1)
      num=$(echo "$entry" | cut -d: -f3)
      echo "  - $file (last $num releases only — use Read tool with offset)"
    else
      echo "  - $entry"
    fi
  done < "$PROJECT_DIR/.claude/context-files"
else
  echo "TIER 2 — Read ALL of the following before doing any work:"
  echo ""
  echo "  - ARCHITECTURE.md        — system diagram, design decisions"
  echo "  - MEMORY.md              — config values, key files"
  echo "  - gh issue list --state open --limit 50"
fi

echo ""

# -- Tier 3: topic skills ------------------------------------------------------
if [ -d "$PROJECT_DIR/.claude/skills" ]; then
  skill_count=$(find "$PROJECT_DIR/.claude/skills" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$skill_count" -gt 0 ]; then
    echo "TIER 3 — Load the topic skill for your task BEFORE starting:"
    echo ""
    for skill in "$PROJECT_DIR"/.claude/skills/*.md; do
      [ -f "$skill" ] || continue
      echo "  $(basename "$skill")"
    done
    echo ""
    echo "Read the skill file — it tells you which docs and sections to load."
    echo ""
  fi
fi

# -- Past failures (customize per project) -------------------------------------
cat <<'FAILURES'
PAST FAILURES (customize per project):
  - [Describe specific regressions that happened]
  - [Each should justify why context recovery matters]
FAILURES

# -- Standing rules (customize per project) ------------------------------------
cat <<'RULES'
STANDING RULES (customize per project):
  - [Your project's operational rules]
  - Commit at least once per significant change — uncommitted work is unprotected
  - Changelog fragments in .changelog/ — never edit CHANGELOG.md directly
RULES
echo ""

# -- Worktree mode: warn if on main -------------------------------------------
branch=$(cd "$PROJECT_DIR" 2>/dev/null && git branch --show-current 2>/dev/null || echo "")
if [ "$MODE" = "worktree" ] && [ "$branch" = "main" ]; then
  echo "WARNING: On main. Feature work must be in a worktree."
  echo "  -> claude -w issue-N-slug"
  echo ""
fi

# -- Tier 3 hint from branch name ---------------------------------------------
if [ -d "$PROJECT_DIR/.claude/skills" ] && [ -n "$branch" ] && [ "$branch" != "main" ]; then
  branch_words=$(echo "$branch" | tr '-' '\n' | tr '_' '\n')
  for skill in "$PROJECT_DIR"/.claude/skills/*.md; do
    [ -f "$skill" ] || continue
    for word in $branch_words; do
      [ ${#word} -lt 4 ] && continue
      if grep -qi "$word" "$skill" 2>/dev/null; then
        echo ">>> Suggested skill for this branch: $(basename "$skill")"
        echo ""
        break 2
      fi
    done
  done
fi

# -- Unassembled fragments check -----------------------------------------------
FRAGMENT_COUNT=$(find "$PROJECT_DIR/.changelog" -name "*.md" ! -name "README.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$FRAGMENT_COUNT" -gt 0 ]; then
  echo "WARNING: $FRAGMENT_COUNT unassembled changelog fragment(s) in .changelog/"
  echo ""
fi

# -- Active worktrees ----------------------------------------------------------
echo "Active worktrees:"
cd "$PROJECT_DIR" 2>/dev/null && git worktree list 2>/dev/null || echo "  (not in a git repo)"
echo ""

# -- Proof gate ----------------------------------------------------------------
echo "═══════════════════════════════════════════════════════════════"
echo "DO NOT PROCEED until you have posted the proof checklist above."
echo "═══════════════════════════════════════════════════════════════"

exit 0
