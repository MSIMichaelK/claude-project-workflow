# Starter Prompt — Existing Project Adoption

> Paste this as your first message when adopting the workflow into an existing project that already has code, history, and design decisions. Fill in the blanks.

---

## Project: [PROJECT NAME]

### What this project does
[1-3 sentences: what it does, who it's for, why it exists]

### Current state
[What works, what's broken, what's in progress. Be honest about technical debt.]

### Why we're adopting the workflow
[What context problems have you hit? Examples:]
- Sessions losing track of design decisions
- Regressions after compaction
- Duplicate work across worktrees
- New sessions re-deriving things that were already decided

### Existing documentation
[List any docs that already exist — README, architecture docs, API specs, etc. These will feed into the new files.]
- [e.g., `README.md` — basic project overview]
- [e.g., `docs/api.md` — API reference]
- [e.g., inline comments in key files]

### Key design decisions to capture
[List the important decisions that keep getting lost. These become your first as-built entries.]
1. [e.g., "We use X pattern because Y — this was debated and settled"]
2. [e.g., "Component A talks to B this way, not that way — there's a reason"]
3. [e.g., "This known bug exists and we intentionally haven't fixed it because..."]

### Known bugs and limitations
[Things that future sessions need to know about to avoid re-discovering or accidentally breaking]

### Project workflow
This project is adopting the standard Claude Project Workflow. The template files have been scaffolded via setup.sh.

**First task:** Please do the following in order:
1. Explore the codebase — understand the project structure, key files, and existing patterns
2. Read any existing documentation listed above
3. Fill in `ARCHITECTURE.md` with the system diagram, file structure, and data flows
4. Fill in `MEMORY.md` with config values, schema, key files, known bugs
5. Create the first batch of `docs/as-built.md` entries from the design decisions listed above
6. Customize `.claude/hooks/context-recovery.sh` with project-specific past failures and dev commands
7. Update `CLAUDE.md` with the critical facts and common mistakes sections

After that, the workflow is live and future sessions will get context recovery automatically.
