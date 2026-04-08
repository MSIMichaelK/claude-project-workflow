# How to Use the Claude Workflow Standard

A plain-language guide for day-to-day use. The full standard is in `standards/claude-workflow-standards-v3.md` — this guide covers what you actually need to know to work with it day to day.

---

## What This Standard Does

It prevents Claude from losing context between sessions and from making changes without proper checks. It does this with four mechanisms:

1. **Context loading** — a hook fires at session start and tells Claude which files to read
2. **Commit guards** — hooks block commits, PRs, and releases that don't meet quality checks
3. **Topic skills** — small pointer files that tell Claude where to find accumulated knowledge about a specific domain
4. **Process skills** — planning personas (BA Analyst, PM, Scrum Master) for structured work

---

## The Three Tiers (How Context Gets Loaded)

### Tier 1: CLAUDE.md
- Loaded automatically by Claude Code at every session
- Contains: session rules, common mistakes, critical facts
- Keep to 1–2 pages. Do not bloat it.

### Tier 2: Session Start Files
- Listed in `.claude/context-files`
- A hook prints the list at session start and tells Claude to read them
- Claude posts a proof checklist showing it read each file with a cited fact from each
- **To change the list:** edit `.claude/context-files`. Add files that have caused regressions when skipped.

### Tier 3: Topic and Process Skills
- Loaded per-task via a starter prompt or auto-detected from branch name
- **Topic skills** — domain navigators in `.claude/skills/` pointing to ADR entries, AB entries, findings, and issues
- **Process skills** — planning personas in `.claude/skills/process-*.md` for concept docs, PRDs, and story planning
- **To use:** paste the worktree starter prompt when starting work, or let the SessionStart hook suggest one based on your branch name

---

## Issue Types

Every piece of work starts with a GitHub issue. Use the correct template — they're in `.github/ISSUE_TEMPLATE/`.

| Type | Use when | Release unit? |
|---|---|---|
| **Epic** | A capability too large for one session — spans multiple sprints | No |
| **Story** | A single unit of work, one PR, independently shippable | Yes |
| **Spike** | You don't know how to build something yet — answer a specific question | No |
| **Investigation** | Something is broken and the cause isn't clear | No |
| **Bug** | Something is broken and the expected behaviour is clear | Yes |
| **Chore** | Dependency update, refactor, no user-facing change | Patch only |

**Epic → Story:** Add stories to the epic using `- [ ] #number` format. GitHub auto-checks them as stories close.

**Story retirement checklist:** Before closing a story or bug issue, complete the retirement checklist in the template — decisions to as-built.md, regression risks to skills, CHANGELOG fragment written. This is how knowledge migrates from transient issues into permanent docs.

---

## Planning a New Project (Greenfield Flow)

Run this sequence before writing production code:

```
1. Concept doc (docs/concept.md)
   Load: process-ba-analyst skill
   Output: concept.md — idea, users, scope, out-of-scope, constraints

2. Spike(s)
   Open a spike issue, answer the question, document the output
   Quick → findings.md (F-xxx) | Substantial → docs/spikes/<number>-<slug>.md

3. Prototype (optional)
   Validate spike findings hold at scale

4. PRD (docs/requirements.md)
   Load: process-product-manager skill
   Input: concept.md + spike output
   Output: user stories, measurable NFRs, epics

5. Epics and stories
   Load: process-scrum-master skill
   Input: requirements.md
   Output: GitHub epic and story issues

6. setup.sh → normal workflow
```

For existing projects, skip to step 5 or 6.

---

## Daily Workflow

### Starting a Session

1. Open Claude Code in your project
2. The SessionStart hook fires automatically and prints a checklist
3. Claude reads the Tier 2 files and posts proof (one cited fact per file)
4. If working on a specific issue, paste the worktree starter prompt to load Tier 3

### Starting Work on a Feature or Bug

1. **Create a GitHub issue** using the appropriate template (story, bug, spike, etc.)
2. If it belongs to an epic, add it to the epic's Stories checklist: `- [ ] #number Title`
3. **Create a worktree** (worktree mode): `claude -w issue-N-slug`
4. Load the relevant topic skill at the start of the session

### Making Changes

1. **Write a changelog fragment** before your first commit: `.changelog/<issue>-<slug>.md`
2. **Commit normally** — the pre-commit-guard checks:
   - You're not on main (worktree mode only)
   - A changelog fragment exists
   - The GitHub issue exists and is open
3. **Create a PR** — the pre-pr-guard checks the fragment exists

### Trivial Changes (No Issue Needed)

For typo fixes, doc corrections, minor chores:
1. Use a branch named `chore/description`
2. Write a fragment named `.changelog/0-chore-<slug>.md`
3. The guards skip the issue requirement for chore branches

### Closing an Issue

Before closing a story or bug, complete the retirement checklist in the issue:
- [ ] Non-obvious decisions added to as-built.md
- [ ] New regression risks added to relevant skill
- [ ] CHANGELOG fragment written

Skip this and the knowledge is buried in closed issue history.

### Releasing

1. Merge PRs to main
2. Run `bash scripts/release.sh` — assembles fragments, bumps versions, tags, pushes
3. Or do it manually (see the standard for the full checklist)
4. The pre-release-guard now accepts a list of issue numbers and checks each is closed with retirement checklist complete:
   ```
   bash .claude/hooks/pre-release-guard.sh 88 89 90 91
   ```

---

## Key Files

| File | What It Does |
|------|-------------|
| `.claude/settings.json` | Configures all hooks |
| `.claude/workflow-mode` | `worktree` or `main` |
| `.claude/context-files` | Lists Tier 2 files for session start |
| `.claude/version-files` | Lists files containing version numbers |
| `.claude/release-artifacts` | Configures what gets checked at release |
| `.claude/hooks/context-recovery.sh` | SessionStart hook — Tier 2 loading |
| `.claude/hooks/pre-commit-guard.sh` | Blocks bad commits |
| `.claude/hooks/pre-pr-guard.sh` | Blocks bad PRs |
| `.claude/hooks/pre-release-guard.sh` | Blocks bad releases — v1.3: accepts issue list |
| `.claude/skills/<domain>.md` | Topic skill navigators |
| `.claude/skills/process-*.md` | Process skills (BA Analyst, PM, Scrum Master) |
| `.github/ISSUE_TEMPLATE/` | Issue templates (epic, story, spike, investigation, bug, chore) |
| `.changelog/<issue>-<slug>.md` | Changelog fragments (assembled at release) |
| `docs/concept.md` | Initial project concept — written once, not updated |
| `docs/spikes/<issue>-<slug>.md` | Spike output docs |

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
| Concept doc | At the start of a new project | `docs/concept.md` |
| PRD | After spikes validate an approach | `docs/requirements.md` |

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

## Process Skills

Three planning personas are installed in every project under `.claude/skills/`:

| Skill | Use when |
|---|---|
| `process-ba-analyst.md` | Starting a new project — produce docs/concept.md |
| `process-product-manager.md` | After spikes — produce docs/requirements.md |
| `process-scrum-master.md` | Breaking an epic into stories — throughout project lifecycle |
| `process-ux-designer.md` | Any UI/UX work — audit existing patterns, document decisions as AB entries |
| `process-qa-tester.md` | Writing tests, reviewing coverage, pre-release test check |

**Spotting stale skills:** every skill has a `last-updated` date in its frontmatter. If it's significantly older than your most recent release, review it for missing AB entries or regression risks.

Load them like any topic skill: reference in the worktree starter prompt or load explicitly.

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

```bash
./setup.sh --name "My Project" --dir ~/path/to/project
```

Then use the starter prompt: `prompts/new-project-starter.md`

For greenfield projects, run the planning flow first (concept → spike → PRD) before setup.sh. See the greenfield section above.

## Retrofitting an Existing Project

Use the retrofit prompt: `prompts/retrofit-existing-starter.md`

- **First-time retrofit** → use Prompt A
- **Updating v1.3 → v1.3** → use Prompt B (adds issue templates, process skills, updated release guard only)

Each project also has a specific plan in `plans/retrofit-<project>.md`.

---

## Common Questions

**Q: Do I have to create a GitHub issue for every single commit?**
No. Use a `chore/` branch for trivial changes. But if it's real work — feature, fix, investigation — create an issue. Use the right template. The issue becomes queryable context for future sessions.

**Q: What's the difference between a spike and an investigation?**
A spike has a time box and a specific question to answer. An investigation is open-ended — you don't know the shape of the problem yet. If the time box expires on a spike, that's still a valid output: document what you learned.

**Q: When do I need an epic vs just a story?**
If the feature will take more than a day or produce more than one PR, make it an epic. If it's one session and one PR, it's a story.

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
