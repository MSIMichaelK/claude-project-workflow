# Claude Project Workflow Standards

> Patterns for managing context, design decisions, and investigations across Claude Code projects.

## Why This Exists

Claude Code sessions lose context through compaction, session restarts, and worktree switches. Without explicit context recovery, Claude will:
- Re-derive decisions that were already made
- Contradict established design choices
- Duplicate work that was done in a parallel worktree
- Introduce regressions by not knowing what was already tested

This repo contains the templates and tooling to prevent that.

## The 4-File System

Every project should have these four documents, each with a distinct responsibility:

| File | Role | Analogy | Typical Size |
|------|------|---------|-------------|
| **`CLAUDE.md`** | Session rules, enforcement, common mistakes | Operating manual for Claude | 1-2 pages |
| **`ARCHITECTURE.md`** | System map — what exists, how it connects | Floor plan | 2-5 pages |
| **`MEMORY.md`** | Fast lookup — entity names, config values, key files | Cheat sheet | 1-3 pages |
| **`docs/as-built.md`** | The "why" — decisions made, what was tried, what was rejected | Construction journal | Grows over time |

### Separation of Concerns

| | CLAUDE.md | ARCHITECTURE.md | MEMORY.md | as-built.md |
|---|---|---|---|---|
| Session rules | Yes | No | No | No |
| System diagram | No | Yes | No | No |
| Entity/key lookup | No | No | Yes | No |
| Design decisions | Referenced | No | No | Full detail |
| Common mistakes | Yes | No | No | No |
| Version history | No | No | Yes | No |
| File structure | No | Yes | No | No |

### Rules

- **CLAUDE.md** should be concise. It's read every session — don't bloat it.
- **ARCHITECTURE.md** describes current state, not history. Update it on every release.
- **MEMORY.md** is a lookup table. If you can't find something in 10 seconds, it's too long.
- **as-built.md** entries are append-only. Don't delete old decisions — add new ones that supersede.

## Optional: Investigation Journal

For projects with complex debugging or empirical investigation (e.g., hardware, data pipelines, sensor calibration), add:

| File | Role |
|------|------|
| **`docs/beliefs-and-tests.md`** | Assumptions, evidence, tests, and what's confirmed vs still open |

This document prevents "cycling on incorrect assumptions" — a common failure mode where Claude (or a human) re-investigates something that was already proven true or false.

See `templates/beliefs-and-tests.md` for the template.

## SessionStart Hook

The hook is the enforcement mechanism. It fires at every session start (including after compaction) and prints a mandatory checklist to Claude's context window.

### How It Works

1. `.claude/settings.json` registers the hook
2. `.claude/hooks/context-recovery.sh` runs on SessionStart
3. Claude sees the banner and mandatory file list
4. Claude reads each file and posts a proof checklist with cited facts
5. Only then does work begin

### Proof Checklist

The key innovation from HA_Home: Claude must cite a **specific fact** from each file, not just claim it was read. This prevents skimming or hallucinating file contents.

```
[x] ARCHITECTURE.md — <cite one specific fact>
[x] MEMORY.md — <cite one specific fact>
[x] as-built.md — <cite one specific fact, referencing an AB-xxx number>
[x] CHANGELOG.md — <cite current version>
[x] gh issues — <cite count or top issue>
```

## Worktree Workflow

All feature work happens in worktrees, never directly on `main`. This prevents merge conflicts when multiple Claude sessions run in parallel.

### Creating Worktrees

- **CLI:** `claude -w issue-N-slug` (named) or `claude -w` (auto-named)
- **Desktop:** Click "+ New session"

### Starting a New Session

Use `.claude/worktree-prompt-template.md` — fill in issue number, scope, related issues, and key context. Paste as the first message in the new session.

### Merging

Via `gh pr create` to `main`. Each worktree gets its own branch and version bump.

## CHANGELOG Format

Use [Keep a Changelog](https://keepachangelog.com/):

```markdown
## [X.Y.Z] — YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing features

### Fixed
- Bug fixes

### Known Issues
- Documented limitations
```

## As-Built Entry Format

Each decision is numbered `AB-xxx` and follows this structure:

```markdown
## AB-001: Title

**Date:** YYYY-MM-DD | **Affects:** [files or components]

**Finding:** What was discovered or what problem was encountered.

**Decision:** What was decided and how it was implemented.

**Why it matters:** What breaks if this decision is ignored or reversed.
```

## Beliefs-and-Tests Entry Format

Each belief is numbered `B-xxx` with associated tests `T-xxxN`:

```markdown
### B-001: Title of Assumption

**Current Belief:** What we think is true.

**Evidence FOR:**
- Supporting observation 1
- Supporting observation 2

**Evidence AGAINST / UNCERTAIN:**
- Counter-evidence or unknown

**Status:** One of: ✅ CONFIRMED | 🔴 WRONG | ⚠️ PARTIAL | 🟡 OPEN

**Test T-001a:** Description of test
- **Status:** ✅ DONE | 🟡 OPEN
- **Method:** How to test
- **Result:** What was found (if done)
```

## Setup

Run `setup.sh` to scaffold a new project:

```bash
./setup.sh --name "My Project" --dir ~/path/to/project
```

Or manually copy templates and customize.

## Adopting Workflow Upgrades

When you improve a pattern in the central repo:

1. Update the template in this repo
2. For each active project, decide if it's relevant
3. Manually adopt the change (copy the relevant sections)
4. Don't force-sync — each project customizes its files

## Projects Using This Workflow

| Project | Status | Notes |
|---------|--------|-------|
| HA_Home | Full adoption | Pioneered the pattern — SessionStart hook, proof checklist, worktree isolation |
| NRL_Bet_Model | Partial | ARCHITECTURE.md with 66 design decisions, no hook yet |
| Scores4Streams V2 | Full adoption | 4-file system, hook, worktree template, 11 as-built decisions |
