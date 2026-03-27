# Starter Prompt — Existing Project Adoption

> **This template has been superseded by `prompts/retrofit-existing-starter.md`**
>
> Use that file for the full guided retrofit — it has two prompts:
> - **Prompt A** — first-time retrofit (never had the workflow standard)
> - **Prompt B** — v1.2 → v1.3 update (add issue templates, process skills, updated release guard)

---

## Quick Version

If you just want a minimal first-message prompt, use this.
For the full guided retrofit, use `prompts/retrofit-existing-starter.md` instead.

---

## Project: [PROJECT NAME]

### What this project does
[1-3 sentences: what it does, who it's for, why it exists]

### Current state
[What works, what's broken, what's in progress]

### Why we're adopting the workflow
[What context problems have you hit?]
- Sessions losing track of design decisions
- Regressions after compaction
- Duplicate work across worktrees

### Existing documentation
[List any docs that already exist]
- [e.g., `README.md` — basic overview]
- [e.g., `docs/architecture.md` — existing architecture notes]

### Key design decisions to capture
[Important decisions that keep getting lost — these become your first as-built entries]
1.
2.
3.

### Project workflow
Adopting the Claude Project Workflow Standard v1.3.

**First task:** Read the retrofit prompt at `prompts/retrofit-existing-starter.md`,
then explore the codebase, read existing docs, and post a pre-retrofit checklist
showing what exists vs what needs to be created. Wait for approval before making changes.
