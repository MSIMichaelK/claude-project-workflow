#!/bin/bash
set -euo pipefail

# pre-pr-guard.sh — PreToolUse hook, intercepts: gh pr create
#
# Checks:
#   1. Not creating PR from main
#   2. Changelog fragment exists matching branch issue number
#   3. Chore branches need any fragment (not issue-matched)
#
# EXIT CODES:
#   0 = allow
#   2 = block with message

input=$(cat)
command=$(echo "$input" | python3 -c \
  "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null || echo "")

if [[ "$command" != *"gh pr create"* ]]; then exit 0; fi

ERRORS=()
branch=$(git branch --show-current 2>/dev/null || echo "")

if [ "$branch" = "main" ]; then
  ERRORS+=("Cannot create PR from main — PRs must come from a feature branch")
fi

# Chore branches skip issue-matching checks
is_chore=false
if [[ "$branch" == chore/* ]] || [[ "$branch" == chore-* ]]; then
  is_chore=true
fi

if [ "$is_chore" = false ]; then
  issue_num=$(echo "$branch" | grep -oE '[0-9]+' | head -1 || echo "")
  if [ -n "$issue_num" ]; then
    fragment=$(find .changelog -name "${issue_num}-*.md" 2>/dev/null | head -1)
    if [ -z "$fragment" ]; then
      ERRORS+=("No changelog fragment for issue #${issue_num}")
      ERRORS+=("  -> Write .changelog/${issue_num}-<slug>.md before creating PR")
    elif [ ! -s "$fragment" ]; then
      ERRORS+=("Changelog fragment '$fragment' is empty")
    fi
  fi
else
  fragments_any=$(find .changelog -name "*.md" -not -name "README.md" \
    2>/dev/null | wc -l | tr -d ' ')
  if [ "$fragments_any" -eq 0 ]; then
    ERRORS+=("No changelog fragment found — write .changelog/0-chore-<slug>.md")
  fi
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""; echo "PR CREATION BLOCKED"; echo "==================="
  for err in "${ERRORS[@]}"; do echo "  x $err"; done
  echo ""; exit 2
fi

exit 0
