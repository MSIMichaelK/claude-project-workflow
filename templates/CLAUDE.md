# {{PROJECT_NAME}} — Session Rules

> This file is auto-loaded at session start. A SessionStart hook enforces context recovery.

## Mandatory Context Recovery

**Before doing ANY work**, read these files and commands in order. No exceptions — not even for "quick fixes."

1. **`ARCHITECTURE.md`** — system diagram, file structure, data flows
2. **`MEMORY.md`** — config, schema, key files, known bugs
3. **`docs/as-built.md`** — design decisions (AB-001+). Read ALL of them.
4. **`CHANGELOG.md`** — what has been released, current version
5. **`gh issue list --state open --limit 50`** — current priorities and open work

### Proof Checklist

After reading, post a checklist citing ONE specific fact from each file to prove you read it:

```
[x] ARCHITECTURE.md — <cite one fact>
[x] MEMORY.md — <cite one fact>
[x] as-built.md — <cite one fact with AB-xxx reference>
[x] CHANGELOG.md — <cite current version>
[x] gh issues — <cite count or top issue>
```

### Why This Is Non-Negotiable

Context gets lost across sessions and compactions. Real incidents from this project:
- [List specific regressions and failures as they happen]
- [Each entry should be a concrete example of what went wrong]

## Critical Facts (Pre-Digested)

[List the facts most likely to cause regressions if forgotten. These should be the condensed essence of your as-built decisions — the things a new session MUST know before touching any code.]

## Development Commands

```bash
# [Project-specific dev commands]
```

## Common Mistakes to Avoid

1. **Don't skip context recovery** — even for "one quick change."
2. [Add project-specific anti-patterns as they're discovered]

## Worktree Workflow

All feature work happens in worktrees, never directly on `main`.

- **Create:** `claude -w issue-N-slug` (named) or click "+ New session" in Desktop
- **Active worktrees** live at `.claude/worktrees/` (gitignored)
- **Changelog fragments:** Write to `.changelog/<issue>-<slug>.md` — NEVER edit CHANGELOG.md or version numbers directly
- **Release assembly** (version bump, CHANGELOG, tag) happens on main after PR merges
- **Merge** via `gh pr create` to `main`
- **See** `.claude/worktree-prompt-template.md` for how to start a new session

## Documentation Map

| Document | Purpose | When to Read |
|----------|---------|-------------|
| `CLAUDE.md` | Session rules, enforcement, common mistakes | Every session start (this file) |
| `ARCHITECTURE.md` | System map, data flow, file structure | Understanding what exists |
| `MEMORY.md` | Quick lookup: schema, files, bugs, versions | Need a specific name or value |
| `docs/as-built.md` | Design decisions, what was tried/rejected | Before changing core logic |
| `CHANGELOG.md` | Release history | Before version bumping |
