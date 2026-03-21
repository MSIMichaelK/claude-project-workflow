# How to Use the Claude Workflow Standard

A plain-language guide for day-to-day use. The full standard is in `standards/claude-workflow-standards-v3.md` — this guide covers what you actually need to know.

---

## What This Standard Does

It prevents Claude from losing context between sessions and from making changes without proper checks. It does this with three mechanisms:

1. **Context loading** — a hook fires at session start and tells Claude which files to read
2. **Commit guards** — hooks block commits, PRs, and releases that don't meet quality checks
3. **Topic skills** — small pointer files that tell Claude where to find accumulated knowledge about a specific domain

---

## The Three Tiers (How Context Gets Loaded)

### Tier 1: CLAUDE.md
- Loaded automatically by Claude Code at every session
- Contains: session rules, common mistakes, critical facts
- You don't need to do anything — this just works

### Tier 2: Session Start Files
- Listed in `.claude/context-files`
- A hook prints the list at session start and tells Claude to read them
- Claude posts a proof checklist showing it read each file
- **To change the list:** edit `.claude/context-files`. Add files that have caused regressions when skipped.

### Tier 3: Topic Skills
- Loaded per-task via a starter prompt or auto-detected from branch name
- Each skill is a small file in `.claude/skills/` that points to relevant ADR entries, AB entries, findings, and issues
- **To use:** paste the worktree starter prompt when starting work, or let the SessionStart hook suggest one based on your branch name

---

## Daily Workflow

### Starting a Session

1. Open Claude Code in your project
2. The SessionStart hook fires automatically and prints a checklist
3. Claude reads the Tier 2 files and posts proof
4. If working on a specific issue, paste the worktree starter prompt to load Tier 3

### Making Changes

1. **Create a GitHub issue first** (unless it's a trivial chore)
2. **Create a worktree** (if worktree mode): `claude -w issue-N-slug`
3. **Write a changelog fragment** before your first commit: `.changelog/<issue>-<slug>.md`
4. **Commit normally** — the pre-commit-guard checks:
   - You're not on main (worktree mode only)
   - A changelog fragment exists
   - The GitHub issue exists and is open
5. **Create a PR** — the pre-pr-guard checks the fragment exists

### Trivial Changes (No Issue Needed)

For typo fixes, doc corrections, minor chores:
1. Use a branch named `chore/description`
2. Write a fragment named `.changelog/0-chore-<slug>.md`
3. The guards skip the issue requirement for chore branches

### Releasing

1. Merge PRs to main (or commit directly in main mode)
2. Run `bash scripts/release.sh` — it assembles fragments, bumps versions, tags, pushes
3. Or do it manually (see the standard for the full checklist)
4. The pre-release-guard blocks tags if fragments aren't assembled or versions don't match

---

## Key Files

| File | Where | What It Does |
|------|-------|-------------|
| `.claude/settings.json` | Project root | Configures all hooks |
| `.claude/workflow-mode` | Project root | `worktree` or `main` |
| `.claude/context-files` | Project root | Lists Tier 2 files for session start |
| `.claude/version-files` | Project root | Lists files containing version numbers |
| `.claude/release-artifacts` | Project root | Configures what gets checked at release |
| `.claude/hooks/context-recovery.sh` | Project root | SessionStart hook — Tier 2 loading |
| `.claude/hooks/pre-commit-guard.sh` | Project root | Blocks bad commits |
| `.claude/hooks/pre-pr-guard.sh` | Project root | Blocks bad PRs |
| `.claude/hooks/pre-release-guard.sh` | Project root | Blocks bad releases |
| `.claude/skills/<domain>.md` | Project root | Topic skill navigators |
| `.changelog/<issue>-<slug>.md` | Project root | Changelog fragments (assembled at release) |

---

## Document Types

### Documents you'll write most often

| Document | When | Format |
|----------|------|--------|
| Changelog fragment | Every commit | `.changelog/<issue>-<slug>.md` with Added/Fixed/Changed sections |
| AB entry | When you make an implementation decision | `AB-xxx` in `docs/as-built.md` |
| Finding | When you discover something that fails non-obviously | `F-xxx` in `docs/findings.md` |

### Documents you'll write occasionally

| Document | When | Format |
|----------|------|--------|
| ADR entry | When you make an architectural decision | `ADR-xxx` in `ARCHITECTURE.md` |
| Assumption | When something is unverified | `A-xxx` in `docs/assumptions.md` |
| Belief + Test | When investigating empirically | `B-xxx`, `T-xxx` in `docs/beliefs-and-tests.md` |

### How to decide: ADR or AB?

Ask: **"Would reversing this require rearchitecting, or just rewriting a function?"**

- Rearchitecting = ADR (goes in ARCHITECTURE.md)
- Rewriting = AB (goes in as-built.md)

---

## Topic Skills

### What they are

Small files (~300 tokens) that point Claude to the right knowledge for a specific domain. They contain:
- ADR numbers from ARCHITECTURE.md
- AB numbers from as-built.md
- Finding numbers from findings.md
- Relevant closed issue numbers
- Regression risks

### What they're NOT

They're not tutorials, not copies of the docs, not general reference material. They're pointers.

### How to create one

```markdown
---
name: domain-name
description: >
  Load when working on: [specific filenames], [feature names],
  [entity names], [keywords that would appear in a task description].
---

# Domain Name — Project Context Navigator

## Architecture Decisions (ARCHITECTURE.md)
- ADR-003: [title]

## Implementation Decisions (docs/as-built.md)
- AB-007: [title]

## Known Failure Modes (docs/findings.md)
- F-003: [title]

## Issue History
gh issue view 89    # [what happened]

## Regression Risks
- Do NOT [specific thing that would break]
```

### How to update one

When you add a new ADR, AB, or finding, add a reference to the relevant skill. If it's not in the skill, future sessions won't find it.

---

## Changelog Fragments

Instead of editing CHANGELOG.md directly, write a small fragment file:

**File:** `.changelog/86-pool-pump-solar.md`

```markdown
### Added
- **Pool pump solar automation** (#86) — runs pump when excess solar > 800W

### Discovered
- **KP115 energy sensors missing from HA** (#117) — power monitoring works but energy counters not appearing
```

At release time, all fragments get assembled into CHANGELOG.md and the fragment files get deleted.

**Why fragments?** In worktree mode, multiple sessions might be running in parallel. If they all edit CHANGELOG.md, you get merge conflicts. Fragments avoid this entirely.

---

## Hard Rules

These apply to every project. They're in CLAUDE.md but worth knowing:

### Never Cycle
If something fails twice with the same approach, stop. State what failed, propose a different approach.

### Never Guess
Don't guess file paths, API endpoints, or whether something worked. Check.

### Always Verify
After any deployment or production action, run a command to confirm it worked.

---

## Setting Up a New Project

Use the starter prompt: `prompts/new-project-starter.md`

It walks Claude through creating all the infrastructure files, hooks, and core documents.

## Retrofitting an Existing Project

Use the retrofit prompt: `prompts/retrofit-existing-starter.md`

Each project also has a specific plan in `plans/retrofit-<project>.md` that lists exactly what needs to change.

---

## Common Questions

**Q: Do I have to create a GitHub issue for every single commit?**
No. Use a `chore/` branch for trivial changes. But if it's real work — feature, fix, investigation — create an issue. The issue becomes queryable context for future sessions.

**Q: Can I add more files to the Tier 2 list?**
Yes. Edit `.claude/context-files`. Add files when you discover that skipping them causes regressions. Remove them when they stop being useful at session start (move them to a topic skill instead).

**Q: What if a hook blocks me and I think it's wrong?**
Read the error message — it tells you exactly what's missing. If you genuinely need to bypass (emergency), you can temporarily remove the hook from `settings.json`, but put it back immediately after.

**Q: Do topic skills auto-trigger?**
They should, if the description is precise enough. The SessionStart hook also hints at the relevant skill based on your branch name. If a skill isn't triggering, sharpen its description with more specific keywords.

**Q: What's the difference between .claude/hooks/ and .git/hooks/?**
`.claude/hooks/` contains Claude Code hooks (PreToolUse, SessionStart). They run inside Claude's tool execution pipeline. `.git/hooks/` contains standard git hooks (pre-commit, post-merge). They run when git executes. They're completely separate and can coexist.

**Q: Can I still work on main in worktree mode?**
Only for release assembly and infrastructure changes. Feature work must be in a worktree. The pre-commit-guard enforces this.
