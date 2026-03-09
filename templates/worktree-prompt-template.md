# Worktree Session Prompt Template

> Copy this template when starting a new worktree session. Fill in the blanks and paste as your first message.

---

## Issue: #[NUMBER] — [TITLE]

### Scope
[1-2 sentences describing what this worktree will accomplish]

### Related Issues
- #[N] — [brief description of how it relates]

### Key Context
[What does Claude need to know that isn't in the standard docs? Examples:]
- Which files are most relevant
- Any prior attempts or rejected approaches
- Relevant as-built decisions (e.g., "AB-004 is directly relevant")
- Relevant beliefs (e.g., "B-003 was confirmed — don't re-investigate")

### Tasks
1. [ ] [First task]
2. [ ] [Second task]
3. [ ] [Final verification: build, test, etc.]

### Rules Reminder
- Context recovery is mandatory (the hook will remind you)
- Create a PR to merge back to main: `gh pr create`
- Bump version in MEMORY.md and CHANGELOG.md
- Keep responses short (32K output token limit)
