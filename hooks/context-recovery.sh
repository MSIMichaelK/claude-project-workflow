#!/usr/bin/env bash
# SessionStart hook — fires at every session start (including after compaction).
# Prints mandatory context recovery checklist to Claude's context window.
#
# CUSTOMIZATION:
#   - Replace {{PROJECT_NAME}} with your project name
#   - Update the "PAST FAILURES" section with project-specific incidents
#   - Update "DEV COMMANDS" with your project's commands
#   - Add/remove mandatory files in the checklist if needed

cat <<'BANNER'
╔══════════════════════════════════════════════════════════════╗
║        {{PROJECT_NAME}} — CONTEXT RECOVERY                   ║
║                                                              ║
║  You MUST read all 5 sources below before doing any work.    ║
║  Post a proof checklist with one specific fact from each.    ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  1. Read ARCHITECTURE.md        — system map, data flows     ║
║  2. Read MEMORY.md              — schema, files, bugs        ║
║  3. Read docs/as-built.md       — design decisions (AB-xxx)  ║
║  4. Read CHANGELOG.md           — releases, current version  ║
║  5. Run: gh issue list --state open --limit 50               ║
║                                                              ║
║  PROOF FORMAT (post this before starting work):              ║
║  [x] ARCHITECTURE.md — <cite one fact>                       ║
║  [x] MEMORY.md — <cite one fact>                             ║
║  [x] as-built.md — <cite one fact>                           ║
║  [x] CHANGELOG.md — <cite one fact>                          ║
║  [x] gh issues — <cite count or top issue>                   ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  PAST FAILURES (customize per project):                      ║
║  - [Describe specific regressions that happened]             ║
║  - [Each should justify why context recovery matters]        ║
╠══════════════════════════════════════════════════════════════╣
║  DEV COMMANDS (customize per project):                       ║
║  [Your project's build/test/run commands]                    ║
╚══════════════════════════════════════════════════════════════╝
BANNER

# List active worktrees so Claude knows about parallel sessions
echo ""
echo "Active worktrees:"
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && git worktree list 2>/dev/null || echo "  (not in a git repo or git not available)"
echo ""
