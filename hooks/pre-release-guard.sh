#!/usr/bin/env bash
# pre-release-guard.sh — PreToolUse hook, intercepts: git tag
#
# Validates a release against a list of story/bug issue numbers.
# Each issue must be closed and have its retirement checklist completed.
#
# USAGE (called from release script or manually):
#   bash pre-release-guard.sh <issue-number> [issue-number ...]
#   e.g. bash pre-release-guard.sh 88 89 90 91
#
# HOOK INVOCATION (settings.json):
#   PreToolUse matcher: "Bash" | command contains "git tag"
#   The hook reads RELEASE_ISSUES env var if no args provided.
#
# EXIT CODES:
#   0 = all checks passed, allow release
#   2 = blocked — prints reason

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
ERRORS=0
WARNINGS=0

# ── Colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

pass()  { echo -e "  ${GREEN}✓${NC} $1"; }
fail()  { echo -e "  ${RED}✗${NC} $1"; ((ERRORS++)); }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           PRE-RELEASE GUARD                              ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ── Collect issue numbers ─────────────────────────────────────────────────────
ISSUES=("$@")

if [[ ${#ISSUES[@]} -eq 0 ]]; then
  # Fallback: read from RELEASE_ISSUES env var (space-separated)
  if [[ -n "${RELEASE_ISSUES:-}" ]]; then
    read -ra ISSUES <<< "$RELEASE_ISSUES"
  fi
fi

if [[ ${#ISSUES[@]} -eq 0 ]]; then
  echo "Usage: bash pre-release-guard.sh <issue-number> [issue-number ...]"
  echo "       RELEASE_ISSUES=\"88 89 90\" bash pre-release-guard.sh"
  echo ""
  echo "Pass the issue numbers for all stories/bugs included in this release."
  exit 2
fi

echo "Issues in this release: ${ISSUES[*]}"
echo ""

# ── Check each issue ──────────────────────────────────────────────────────────
for issue in "${ISSUES[@]}"; do
  echo "── Issue #${issue} ──────────────────────────────────────────────────"

  # Fetch issue state and labels
  issue_json=$(gh issue view "$issue" --json state,labels,title,body 2>/dev/null) || {
    fail "#${issue} — could not fetch from GitHub (check gh auth)"
    continue
  }

  title=$(echo "$issue_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['title'])" 2>/dev/null || echo "(unknown)")
  state=$(echo "$issue_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['state'])" 2>/dev/null || echo "unknown")
  labels=$(echo "$issue_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(' '.join(l['name'] for l in d['labels']))" 2>/dev/null || echo "")
  body=$(echo "$issue_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['body'] or '')" 2>/dev/null || echo "")

  echo "  Title: $title"
  echo "  Labels: ${labels:-none}"

  # Check issue type — epics, spikes, and investigations are wrong release units
  if echo "$labels" | grep -qw "epic"; then
    warn "#${issue} is labelled 'epic' — epics are not release units. Did you mean to list its child stories?"
  fi
  if echo "$labels" | grep -qw "spike"; then
    warn "#${issue} is labelled 'spike' — spikes don't ship. Did you mean a follow-on story?"
  fi
  if echo "$labels" | grep -qw "investigation"; then
    warn "#${issue} is labelled 'investigation' — investigations don't ship. Did you mean a follow-on story or bug?"
  fi

  # Check issue is closed
  if [[ "$state" == "CLOSED" ]]; then
    pass "#${issue} is closed"
  else
    fail "#${issue} is still OPEN — close the issue before releasing"
    continue
  fi

  # Check retirement checklist — look for unchecked items in the Retirement Checklist section
  # Matches "- [ ]" (unchecked) items after the "Retirement Checklist" heading
  checklist_section=$(echo "$body" | awk '/## Retirement Checklist/,0' 2>/dev/null || echo "")

  if [[ -z "$checklist_section" ]]; then
    warn "#${issue} has no Retirement Checklist section — was the correct issue template used?"
  else
    unchecked=$(echo "$checklist_section" | grep -c "^- \[ \]" 2>/dev/null || echo "0")
    checked=$(echo "$checklist_section" | grep -c "^- \[x\]" 2>/dev/null || echo "0")

    if [[ "$unchecked" -gt 0 ]]; then
      fail "#${issue} has ${unchecked} unchecked retirement checklist item(s) — complete before releasing"
    elif [[ "$checked" -eq 0 ]]; then
      warn "#${issue} retirement checklist appears empty — verify manually"
    else
      pass "#${issue} retirement checklist complete (${checked} items)"
    fi
  fi

  echo ""
done

# ── Changelog fragments check ─────────────────────────────────────────────────
echo "── Changelog fragments ──────────────────────────────────────────────────"
FRAGMENT_COUNT=$(find "$PROJECT_DIR/.changelog" -name "*.md" ! -name "README.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$FRAGMENT_COUNT" -gt 0 ]]; then
  pass "${FRAGMENT_COUNT} changelog fragment(s) ready to assemble"
else
  fail "No changelog fragments found in .changelog/ — write a fragment before releasing"
fi
echo ""

# ── Version files check ───────────────────────────────────────────────────────
VERSION_FILES="$PROJECT_DIR/.claude/version-files"
if [[ -f "$VERSION_FILES" ]]; then
  echo "── Version files ─────────────────────────────────────────────────────────"
  while IFS= read -r vfile || [[ -n "$vfile" ]]; do
    [[ -z "$vfile" || "${vfile:0:1}" == "#" ]] && continue
    if [[ -f "$PROJECT_DIR/$vfile" ]]; then
      pass "$vfile — exists"
    else
      fail "$vfile — not found (listed in .claude/version-files)"
    fi
  done < "$VERSION_FILES"
  echo ""
fi

# ── User docs check ───────────────────────────────────────────────────────────
RELEASE_ARTIFACTS="$PROJECT_DIR/.claude/release-artifacts"
if [[ -f "$RELEASE_ARTIFACTS" ]]; then
  user_docs=$(grep "^user-docs:" "$RELEASE_ARTIFACTS" 2>/dev/null | sed 's/^user-docs: *//' || echo "false")
  if [[ "$user_docs" != "false" && -n "$user_docs" ]]; then
    echo "── User documentation ────────────────────────────────────────────────────"
    # Check if the user docs file was modified in recent commits
    if git diff HEAD~1..HEAD --name-only 2>/dev/null | grep -qF "$user_docs"; then
      pass "User docs updated: $user_docs"
    else
      warn "User docs ($user_docs) not modified in latest commit — verify if update needed"
    fi
    echo ""
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════════════════"
if [[ $ERRORS -gt 0 ]]; then
  echo -e "${RED}BLOCKED${NC} — ${ERRORS} error(s) must be resolved before releasing"
  [[ $WARNINGS -gt 0 ]] && echo -e "${YELLOW}         ${WARNINGS} warning(s) also noted${NC}"
  echo ""
  exit 2
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "${YELLOW}PROCEED WITH CAUTION${NC} — ${WARNINGS} warning(s) noted above"
  echo "Review warnings before continuing. If all are intentional, proceed."
  echo ""
  exit 0
else
  echo -e "${GREEN}CLEAR TO RELEASE${NC} — all checks passed"
  echo ""
  exit 0
fi
