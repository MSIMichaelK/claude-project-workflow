# Claude Project Workflow Standards
**Version:** 1.2 — 2026-03-23

> Deterministic enforcement of context loading, issue discipline, and release integrity across Claude Code projects. Derived from patterns across HA_Home, Scores4Streams V2, Edge Hunter (NRL), and R They OK.

---

## Standard Changelog

### 1.2 — 2026-03-23 (post-retrofit learnings)
- All four projects retrofitted and verified (Scores4S, HA_Home, NRL, RTheyOK)
- Skill count guidance changed: "start with 3-6, split if needed" (actual: 4-9 across projects)
- ADR/AB renumbering no longer required for existing projects — keep existing schemes
- Roadmap added as optional Tier 2 file (validated by RTheyOK)
- `0-chore-` fragment prefix documented as standard pattern (validated by RTheyOK bootstrap)
- Projects table updated with actual skill counts and context weights
- Existing sessions don't pick up new hooks — must start fresh after retrofit

### 1.1 — 2026-03-21
- Configurable Tier 2 via `.claude/context-files` — each project declares its own session-start file list
- Process for establishing and iterating context files (initial audit → incident-driven review)
- Smarter SessionStart hook — reads context-files, hints at Tier 3 from branch name
- Trivial-commit escape — `chore/` branches bypass issue requirement
- Relaxed ADR edit rule — typos and clarifications are fine; only decision/rationale changes require supersession
- Verification checklist against all four projects completed before implementation

### 1.0 — 2026-03-20
- Initial consolidated standard from four-project diff
- Three-tier context model
- Topic skills as Tier 3 navigators
- ADR-xxx / AB-xxx taxonomy formalised
- findings.md, assumptions.md, beliefs-and-tests.md as distinct documents
- Enriched issue closing in release script
- Version-files config for multi-file version projects
- User doco as configurable release artifact
- Never cycle / never guess / always verify rules
- Two-environment table pattern
- Worktree mode redefined — main mode permits worktrees

---

## Core Principle: Advisory vs Enforced

| Mechanism | Type | Claude can ignore? |
|-----------|------|-------------------|
| CLAUDE.md instructions | Advisory | Yes — especially after compaction |
| Proof checklists | Advisory | Yes — unless a hook blocks forward progress |
| `PreToolUse` hooks | **Enforced** | No — blocks tool execution |
| `SessionStart` hooks | **Enforced** | No — fires automatically |

**Anything the process cannot afford to skip belongs in a hook, not in a prompt.**

The second principle: **more context is not better context.** A context window loaded with everything Claude might need is slower, more expensive, and actively degrades attention quality. The goal is the right information at the right time — not maximum information at all times.

---

## Three-Tier Context Model

Context is loaded in three tiers at different points and for different reasons.

```
Tier 1 — Always (CLAUDE.md)
  Rules, common mistakes, pre-digested critical facts
  Loaded: automatically at every session
  Size: 1–2 pages maximum. Do not bloat it.

Tier 2 — Every session (orientation)
  The files this project needs loaded every session to avoid regressions.
  Loaded: by SessionStart hook reading .claude/context-files
  Default: ARCHITECTURE.md, MEMORY.md, gh issue list
  Each project configures its own list based on incident history.

Tier 3 — Per task (topic-specific)
  Accumulated decisions, findings, investigations relevant to this domain
  Loaded: by worktree starter prompt via topic skill, or auto-hinted by SessionStart
  Mechanism: skills as navigators into project knowledge
```

### Configurable Tier 2: `.claude/context-files`

Each project declares its own Tier 2 file list. The SessionStart hook reads this file and prints the checklist accordingly.

```
# .claude/context-files
# Files to read every session. One per line. Lines starting with # are ignored.
# The hook prints these as the mandatory checklist.
# gh-issues is a special token — runs gh issue list.

ARCHITECTURE.md
MEMORY.md
gh-issues
```

**Heavier projects add more files.** If a project's incident history shows that skipping a file causes regressions, that file belongs in context-files. This is not bloat — it's earned through real damage.

Example — HA_Home (heavy Tier 2, justified by 6+ incidents):
```
ARCHITECTURE.md
MEMORY.md
docs/as-built.md
docs/energy-beliefs-and-tests.md
CHANGELOG.md
docs/release_workflow.md
gh-issues
```

Example — NRL (standard Tier 2):
```
ARCHITECTURE.md
MEMORY.md
CHANGELOG.md
gh-issues
```

### Process for Establishing Context Files

**Initial setup (new project or retrofit):**
1. Start with the default three: `ARCHITECTURE.md`, `MEMORY.md`, `gh-issues`
2. Ask: "Which files, if skipped, have caused or would cause regressions?"
3. Add those files. Be honest — if the project is complex, the list will be longer.
4. Consider `docs/roadmap.md` if milestone awareness affects task prioritisation
5. Document *why* each non-default file is included (comment in the file)

**Iterating:**
- When an incident occurs because Claude didn't have context from a file → add it to context-files
- When a file hasn't been useful in Tier 2 for multiple sessions → consider moving it to Tier 3 (skill navigator)
- Review the list during each retrofit or major release

**The goal is not a short list. The goal is the right list.**

### Why Not Load Everything Upfront

The incidents that created context recovery requirements happened because Claude had **no** context — not the wrong amount. The fix is not to load all project knowledge every session. It is to load the *right* knowledge for the task.

Bulk upfront loading has three compounding costs:
- **Token budget** consumed before work begins
- **Latency** — more input tokens means slower responses
- **Attention quality** — Claude weights relevant content against noise poorly, increasing regression risk

A proof that ADR-007 and Finding F-003 were loaded for a specific deployment session is meaningful. A proof that the entire investigation journal was loaded is theatre.

But a project with a dense, interconnected domain (e.g. HA_Home energy system) may genuinely need more upfront context than a cleanly-bounded app. The standard accommodates this via configurable context-files — not by pretending all projects are the same weight.

### Tier 3 Auto-Hinting

The SessionStart hook can detect the branch name and suggest the relevant topic skill:

```bash
# If branch is issue-86-pool-pump, hint at the pool-solar skill
branch=$(git branch --show-current 2>/dev/null || echo "")
if [ -d ".claude/skills" ] && [ -n "$branch" ]; then
  for skill in .claude/skills/*.md; do
    skill_name=$(basename "$skill" .md)
    # Check if any keyword from skill description matches branch name
    if grep -qi "$(echo "$branch" | tr '-' ' ')" "$skill" 2>/dev/null; then
      echo "Suggested Tier 3 skill: $skill"
    fi
  done
fi
```

This is a hint, not enforcement. The starter prompt remains the primary Tier 3 mechanism. But the hint reduces the chance of forgetting to load a skill.

---

## Document Taxonomy

Every project has a core set plus optional documents selected by project type.

### Core Documents (all projects)

| Document | Role | Nature |
|----------|------|--------|
| `CLAUDE.md` | Session rules, enforcement, pre-digested critical facts | Concise, stable |
| `ARCHITECTURE.md` | Target state — h/w stack, tech stack, integrations, ADR-xxx decisions | Evolves with architecture |
| `CHANGELOG.md` | Per-release index — issues addressed, version, date | New entry each release |

### Strongly Recommended

| Document | Role | Nature |
|----------|------|--------|
| `MEMORY.md` | Fast lookup — entity names, config values, key files, versions | Lookup table, 1-3 pages |
| `docs/as-built.md` | Current deployed state + build history by phase, AB-xxx entries | Append-only history |
| `docs/release_workflow.md` | Project-specific release notes, environment diagram, deploy commands | Updated each release |

### Optional by Project Type

| Document | Role | When to use |
|----------|------|-------------|
| `docs/findings.md` | Permanent operational gotcha register — things that fail, don't repeat | Hardware, deployment, integration projects |
| `docs/assumptions.md` | Unverified assumption tracker — open -> confirmed/disproved -> resolved | All projects benefit, especially early stage |
| `docs/beliefs-and-tests.md` | Active investigation journal — hypotheses, evidence, test results | Empirical, sensor, model, data projects |
| `docs/[topic]-investigation.md` | Topic-specific deep investigation (e.g. `energy-investigation.md`) | When a domain has enough complexity to warrant its own journal |
| `docs/requirements.md` | Requirements spec and roadmap | Product projects with external users |
| `deploy/docs/runbook.md` | Deployment steps, verification, failure recovery | Multi-environment projects |
| User documentation | In-app help, user guide | Projects with non-technical users |

### Separation of Concerns

| | CLAUDE.md | ARCHITECTURE.md | MEMORY.md | as-built.md | findings.md | assumptions.md |
|---|---|---|---|---|---|---|
| Session rules | Y | | | | | |
| Target system design | | Y | | | | |
| ADR-xxx decisions | | Y | | | | |
| Fast lookup | | | Y | | | |
| Current deployed state | | | | Y | | |
| AB-xxx decisions | | | | Y | | |
| Operational gotchas | | | | | Y | |
| Unverified assumptions | | | | | | Y |
| Active investigations | | | | | | (beliefs-and-tests) |
| Version history | | | Y | | | |

---

## ADR vs AB — Which Notation to Use

The test: **"Would reversing this require rearchitecting, or just rewriting a function?"**

**ADR (Architecture Decision Record) — lives in ARCHITECTURE.md**

Decisions that define how the system is structured — choices you'd have to significantly redesign around if you reversed them:
- Database engine choice
- Auth approach
- Deployment model
- Tech stack selection
- Major integration patterns

**AB (As-Built record) — lives in as-built.md**

Decisions about how something was implemented *within* the architecture — things you could change without restructuring the system:
- Specific algorithm or logic choices
- Sensor or entity configuration decisions
- API handling patterns
- UI behaviour decisions

Both reference the GitHub issue where the full design discussion and rejected alternatives live.

**Existing project numbering:** Projects that predate this standard keep their existing numbering schemes (e.g. D1-D55 in RTheyOK, inline numbers in NRL). Use ADR-xxx/AB-xxx prefixes for new projects only.

### ADR Entry Format

```markdown
## ADR-003: SQLite not Postgres

**Date:** 2026-01-10 | **Status:** Active | **Affects:** All data persistence

**Decision:** Use SQLite as the sole database. No Postgres, no cloud DB.

**Rationale:** Pi 4 deployment, no network DB dependency, single-user app.
Full design discussion and alternatives considered in #34.

**Consequences:** No concurrent writes, no remote DB access. Acceptable for use case.

**Issue:** #34
```

### ADR Supersession

When an architectural decision is genuinely reversed or replaced, create a new ADR that supersedes it. Never change the Decision or Rationale of an accepted ADR.

**Typos, formatting fixes, and clarifying notes are fine to edit in place.** The supersession rule protects the decision record, not the prose. A solo developer fixing a spelling error doesn't need to create ADR-067 to supersede ADR-003.

When superseding:
- New ADR references old: `**Supersedes:** ADR-003`
- Old ADR gets status update: `**Status:** Superseded by ADR-067`
- Both remain in ARCHITECTURE.md for history

### AB Entry Format

```markdown
## AB-007: FC always records an out

**Date:** 2026-01-14 | **Phase:** 2 | **Affects:** engine.js scoring logic

**What was built:** FC handler records exactly one out regardless of defensive
outcome. No partial-out modelling.

**Why:** Edge cases (FC without out) are too rare to model; manual adjustment
handles them. Full design discussion including rejected alternatives in #67.

**Current state:** Deployed. Regression test in fc-handling.test.js.

**Issue:** #67 | **Release:** v2.1.0
```

---

## findings.md, assumptions.md, beliefs-and-tests — The Three Investigation Documents

These are distinct documents serving different stages of the knowledge lifecycle.

### The Pipeline

```
Something is unknown or uncertain
  -> Write an assumption (assumptions.md)

Start gathering evidence
  -> Open a belief entry (beliefs-and-tests.md or topic investigation doc)

Discover something that must never be forgotten
  -> Write a finding (findings.md)

Assumption confirmed or disproved
  -> Move to resolved section of assumptions.md
  -> Update belief status
```

### findings.md — Permanent Gotcha Register

Things that fail in non-obvious ways. Never deleted. Append-only.

```markdown
## F-003: Heredocs fail over SSH

**Discovered:** 2026-02-14 | **Project area:** HA OS deployment

**What happens:** Heredoc syntax in SSH commands fails silently or corrupts content.

**Rule:** Always SCP files instead of heredocs over SSH.

**Context:** Discovered during add-on deployment. Full incident in #89.
```

### assumptions.md — Unverified Tracker

```markdown
## A-012: Pi 5 will handle 8 concurrent sensors without latency

**Raised:** 2026-03-01 | **Status:** OPEN
**Raised by:** Architecture decision for Phase 3

**Assumption:** The baseline engine on Pi 5 will process 8 simultaneous
sensor events within the 2-second SLA.

**How to verify:** Load test with simulator at 8-sensor concurrency.
**Issue:** #103

---

## Resolved

### A-008: ZHA channel 20 would not conflict with home WiFi — CONFIRMED
**Resolved:** 2026-02-20 | Confirmed via spectrum scan — channel 15 (WiFi)
does not overlap channel 20 (Zigbee). Issue #78.
```

### beliefs-and-tests.md — Active Investigation Journal

For projects with ongoing empirical investigation (sensors, models, data pipelines).

```markdown
### B-012: Pool pump draws less solar than expected on east-facing panels

**Current Belief:** Panel orientation reduces effective yield by ~15% vs
north-facing at this latitude.

**Evidence FOR:**
- Three consecutive days measured 340W vs 400W expected

**Evidence AGAINST / UNCERTAIN:**
- Only measured in autumn — season effect unknown

**Status:** OPEN

**Test T-012a:** Measure same period next season
- **Status:** OPEN
- **Method:** Compare daily yield logs from HA energy dashboard
- **Result:** —
```

### Topic-Specific Investigation Docs

When a domain has enough complexity to warrant its own dedicated journal (e.g. `docs/energy-investigation.md` for HA_Home), create a topic-specific file. The beliefs-and-tests format applies. The topic skill navigator points to the specific file rather than the generic one.

---

## Topic Skills (Tier 3)

### What a Topic Skill Is

A topic skill is a **navigator** — not a knowledge document. It contains precise pointers to the accumulated decisions, findings, assumptions, and closed issues relevant to a specific domain. Claude reads the skill (~300 tokens) then loads only what matters for this session.

### What It Is Not

- Not a tutorial on the domain (Claude already knows how softball scoring works)
- Not a copy of AB entries or findings
- Not a general reference document

### Skill Location

```
.claude/skills/              Project-specific topic skills
~/.claude/skills/            Global skills shared across all projects
```

### Global Skills

```
~/.claude/skills/
└── release-management.md    Fragment format, hook behaviour, release assembly steps
```

### Project Skill Examples

**HA_Home:**
```
.claude/skills/
├── energy-monitoring.md     ADR-002, AB-001-AB-006, energy-investigation.md B-001-B-008
├── alarm-integration.md     ADR-005, relevant AB entries, issues #45 #52
├── pool-solar.md            AB-012-AB-015, energy-investigation.md B-009-B-012
└── dashboard.md             AB-008-AB-011, entity naming conventions
```

**Scores4Streams V2:**
```
.claude/skills/
├── batting-engine.md        AB-003 AB-004 AB-006, isPitch rules, regression tests
├── data-model.md            ADR-001, AB-001 AB-002 AB-011, dual-write, schema
├── scoring-modes.md         AB-008, simple vs advanced gate rules
└── undo-system.md           AB-011, soft-delete pattern
```

**Edge Hunter (NRL):**
```
.claude/skills/
├── betting-model.md         ADR-003-ADR-008, model constants, override vs market edge
├── odds-pipeline.md         ADR-012, pregame cutoff, round assignment, outcome_name
├── deployment.md            ADR-021, Pi deploy path, two-directory setup, cron gotchas
└── ui-voting.md             ADR-031, vote threshold, apply_suggestion timing
```

**R They OK:**
```
.claude/skills/
├── baseline-engine.md       ADR-004, AB-001-AB-006, Flask API patterns
├── ha-addon.md              F-001-F-006 (all addon gotchas), AB-007-AB-010
├── sensor-pairing.md        ADR-007, current paired/disabled state, ZHA channel
└── deployment.md            F-003 F-004, two-environment rules, SCP not heredoc
```

### Skill Body Format

```markdown
---
name: ha-addon
description: >
  Load when working on: HA OS add-on, addons/ directory, config.yaml schema,
  Supervisor, add-on deployment, SSH to HA Green, enabled_sensors, addon paths,
  or any file in addons/rtheyok-baseline-engine/. Contains all known add-on
  failure modes and current deployment state.
---

# HA Add-On — Project Context Navigator

## Architecture Decisions (ARCHITECTURE.md)
- ADR-009: File-based config not Supervisor options — schema caching issue
- ADR-010: Two add-on paths — /addons/local/ and /data/addons/local/ both required

## Implementation Decisions (docs/as-built.md)
- AB-007: enabled_sensors read from /config/enabled_sensors file not add-on options
- AB-008: JWT tokens inlined in scripts not passed via env vars

## Known Failure Modes — READ BEFORE TOUCHING ADD-ON (docs/findings.md)
- F-001: Supervisor caches config.yaml aggressively — do not add new options to schema
- F-002: Two add-on paths exist — SSH visible path differs from Supervisor read path
- F-003: Heredocs fail over SSH — always SCP files
- F-004: JWT tokens mangle in env vars — inline directly in scripts
- F-005: Entity renaming — WebSocket API only, REST returns 404

## Current Deployment State
- 4 sensors paired: kettle, tv, toilet, bedroom
- 3 disabled: front_door, fridge, medicine_cabinet
- ZHA channel 20

## Issue History
gh issue view 89    # Heredoc failure discovery
gh issue view 94    # Two-path confusion incident
gh issue view 101   # JWT env var corruption

## Regression Risks
- Do NOT add new options to add-on config.yaml schema
- Do NOT use heredocs over SSH
- Always update BOTH add-on paths when deploying
```

### Skill Description

Must be precise enough for auto-triggering. List specific filenames, feature names, and keywords.

---

## GitHub Issue Discipline

### All Work Starts With an Issue

No commit without a corresponding open GitHub issue. Enforced by `pre-commit-guard.sh`.

Issues serve three purposes:
1. **Before work** — scope, requirements, design options, decision discussion
2. **During work** — progress, blockers, approach changes
3. **After work** — permanent record, queryable as future context

### Trivial Commits

Not every commit needs a full issue lifecycle. For documentation fixes, typo corrections, and minor chores:

- Branch named `chore/description` bypasses the issue requirement in pre-commit-guard
- Fragment named `0-chore-<slug>.md` is accepted without an issue number match
- These commits still need a changelog fragment — just not an issue

Use sparingly. If a "chore" grows into real work, create an issue and switch to a proper branch.

### Issue as Detailed Design Record

The GitHub issue is where design options are discussed and decisions are made. The ADR or AB entry in the project docs is the summary and pointer. Future sessions read the entry, get the decision, and can fetch the issue for full rationale.

### Enriched Issue Closing

Never bare `gh issue close N`. Before closing, post a structured comment:

```markdown
## Resolved in vX.Y.Z

**PR:** #N
**Released:** YYYY-MM-DD

### What was done
[content from changelog fragment — verbatim]

### Architecture decisions recorded
- ADR-009: [title] — ARCHITECTURE.md

### Implementation decisions recorded
- AB-007: [title] — docs/as-built.md

### Findings added
- F-006: [title] — docs/findings.md

### Assumptions resolved
- A-008: [title] — CONFIRMED / DISPROVED

### Skill updated
- .claude/skills/[domain].md — references new ADR/AB entries

### Topic investigation updated
- docs/[topic]-investigation.md — B-012 status updated
```

This makes `gh issue view N` a complete lifecycle record. Closed issues become queryable context for future sessions without cross-referencing multiple docs.

The release script handles this automatically for each closed issue.

---

## Two Workflow Modes

Projects declare their mode in `.claude/workflow-mode`.

| Mode | What it enforces | Projects |
|------|-----------------|---------|
| `worktree` | Commits to main are blocked — all work must be in a worktree branch | HA_Home, NRL |
| `main` | No branch enforcement — work on main or worktree, your choice | Scores4S, RTheyOk |

**Note:** `main` mode does not prohibit worktrees — it simply does not enforce them. Project-specific warnings about worktree risks (e.g. Scores4S branch divergence history) belong in the `context-recovery.sh` incidents section, not in the mode definition.

---

## Workflow: `worktree` Mode

### Creating a Worktree

Always named with issue number for hook enforcement:

```bash
claude -w issue-N-slug       # e.g. claude -w issue-86-pool-pump
claude -w                     # auto-generated (relaxed enforcement)
```

### Worktree Starter Prompt (Tier 3 Loading)

Paste as the first message in every new worktree session:

```
Working on issue #[N]: [title]

Tier 2 was loaded by SessionStart hook. Now load Tier 3:

1. Load skill: .claude/skills/[domain].md
2. Read the ADR and AB entries listed in the skill
3. Read the findings listed in the skill (if any)
4. Fetch issue history:
   gh issue view [N]
   [any related issues from skill]
5. Check any open assumptions or beliefs listed in the skill

Post Tier 3 proof checklist:
  [x] Skill loaded: [domain].md
  [x] ADR/AB entries read: [list]
  [x] Findings checked: [F-xxx if any]
  [x] Issue #N fetched — [cite one specific detail]
  [x] Open assumptions/beliefs: [any relevant]

Related issues: [#N #M if any]
Scope: [one sentence — what this session will and won't do]
```

### What Worktrees NEVER Edit (shared release files)

- `CHANGELOG.md` — assembled at release time on main
- `CLAUDE.md` version number
- `ARCHITECTURE.md` version history table
- `MEMORY.md` version history table
- `docs/release_workflow.md` "Current:" line

### What Worktrees CAN Edit

- `docs/as-built.md` — new AB-xxx entries (appended at bottom)
- `ARCHITECTURE.md` — new ADR-xxx entries, system diagram updates
- `.claude/skills/[domain].md` — add new ADR/AB references to navigator
- `docs/findings.md` — new findings discovered during work
- `docs/assumptions.md` — new assumptions raised, or resolved during work
- `docs/[topic]-investigation.md` — belief and test updates
- All functional code, config, automations

**Important:** when writing a new ADR or AB entry, also update the relevant topic skill to reference it. If it's not in the skill, future sessions won't discover it.

---

## Workflow: `main` Mode

Work happens directly on main. All documentation and fragment discipline applies identically. Worktrees are permitted when the task warrants parallel isolation — neither enforced nor prohibited.

If a worktree exists from a previous session: check its status with `git branch -v`, merge or delete before starting new work.

Starter prompt is the same structure but omits worktree setup steps.

---

## Changelog Fragments

### Worktree Mode

Each worktree writes exactly one fragment before committing:

```
.changelog/<issue>-<slug>.md
```

Examples:
- `.changelog/86-pool-pump-solar.md`
- `.changelog/102-alarm-integration.md`

### Main Mode

Single fragment file per logical unit of work, same format.

### Trivial Commits

For chore branches without an issue:
- `.changelog/0-chore-<slug>.md`
- e.g. `.changelog/0-chore-fix-typos.md`

### Fragment Format

```markdown
### Added
- **Feature name** (#N) — description

### Fixed
- **Bug name** (#N) — description

### Changed
- **What changed** (#N) — description

### Discovered
- **Finding** (#N) — description
```

Recognised headings: `Added`, `Fixed`, `Changed`, `Discovered`, `Investigated`, `Notes`.

---

## Release Assembly

### Preferred: Release Script

```bash
bash scripts/release.sh           # patch bump
bash scripts/release.sh minor     # minor bump
bash scripts/release.sh major     # major bump
```

The script handles assembly, version bumping, enriched issue closing, tagging, and push.

### Manual Process

On main, after any PR merges:

1. `git pull` — sync main
2. Read all `.changelog/` fragments
3. Determine next version (`grep "Current:" docs/release_workflow.md`)
4. Assemble new `CHANGELOG.md` entry at top
5. Bump version in all files listed in `.claude/version-files`
6. Add row to version history tables
7. Delete assembled fragments (`rm .changelog/*.md`, keep `README.md`)
8. Update `docs/as-built.md` current state section if deployment state changed
9. `git commit` — descriptive message referencing issue numbers
10. `git tag vX.Y.Z`
11. `git push --tags`
12. `gh release create vX.Y.Z` with release notes matching changelog
13. For each resolved issue — post enriched comment then `gh issue close N`

The `pre-release-guard.sh` hook intercepts `git tag` and blocks if steps 1-8 are incomplete.

### User Documentation (Configurable)

Declared in `.claude/release-artifacts`:

```
changelog: true
architecture: true
memory: true
user-docs: false                        # not yet active
# user-docs: docs/user-guide.md        # file-based user docs
# user-docs: dashboard.py:help_tab     # in-app help tab (NRL pattern)
```

The pre-release guard reads this file and checks user-docs location was modified if any user-facing files changed. Only enforced when `user-docs` is not `false`.

---

## Hard Rules (All Projects)

These go into every project's CLAUDE.md. Derived from RTheyOk where they were first formalised.

### Never Cycle
If something fails twice with the same approach, **STOP**. Do not retry. Instead:
1. State what failed and why
2. Propose a genuinely different approach
3. Ask if unsure

### Never Guess
- Don't guess file paths — check docs or `ls` first
- Don't guess API endpoints — read the code or docs
- Don't guess if a change worked — verify with a concrete check

### Always Verify
After any deployment or production action, run a verification command before moving on. Don't assume it worked.

### Two-Environment Projects
Any project with dev + production environments must have a two-environment table in CLAUDE.md. Before every remote command: state which environment you're targeting and why.

Template:

```markdown
## Environments — NEVER CONFUSE THEM

| | Dev | Production |
|---|---|---|
| **Where** | [location] | [location] |
| **How** | [start command] | [deploy command] |
| **Port** | [port] | [port] |
| **Data** | [simulated/test] | [real] |
| **Tests** | Run here | Never run here |

Before every remote command: state which environment and why.
```

---

## Hook Architecture

### Overview

```
SessionStart
  └── context-recovery.sh         Tier 2 loading (from .claude/context-files) + branch status + Tier 3 hint

PreToolUse (Bash)
  ├── pre-commit-guard.sh          Intercepts: git commit
  ├── pre-pr-guard.sh              Intercepts: gh pr create
  └── pre-release-guard.sh        Intercepts: git tag
```

All hooks read `.claude/workflow-mode` and `.claude/version-files`.

Exit codes: `0` = allow, `2` = block with message.

---

### SessionStart: `context-recovery.sh`

**Purpose:** Force Tier 2 loading from `.claude/context-files`. The proof gate at the end creates a hard expectation that Claude's first response is the checklist, not task work.

**Design principle:** Keep output under 20 lines. Every extra line of banner reduces compliance. The proof gate is the critical line — everything else is supporting context.

**Customise per project:** context-files list, production warnings, skill hint logic.

```bash
#!/bin/bash
TRIGGER="${SESSION_TRIGGER:-startup}"
MODE=$(cat .claude/workflow-mode 2>/dev/null || echo "worktree")
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"

echo "CONTEXT RECOVERY | Trigger: $TRIGGER | Mode: $MODE | Branch: $(git branch --show-current 2>/dev/null || echo detached)"
echo ""
echo "STOP. Read these files NOW before doing anything else:"
echo ""

# -- Tier 2: read context-files list -------------------------------------------
if [ -f "$PROJECT_DIR/.claude/context-files" ]; then
  i=1
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    [ "${line:0:1}" = "#" ] && continue
    if [ "$line" = "gh-issues" ]; then
      echo "  $i. gh issue list --state open --limit 50"
    else
      echo "  $i. $line"
    fi
    i=$((i+1))
  done < "$PROJECT_DIR/.claude/context-files"
else
  echo "  1. ARCHITECTURE.md"
  echo "  2. MEMORY.md"
  echo "  3. gh issue list --state open --limit 50"
fi

echo ""

# -- Tier 3 hint from branch name ----------------------------------------------
branch=$(git branch --show-current 2>/dev/null || echo "")
if [ -d "$PROJECT_DIR/.claude/skills" ] && [ -n "$branch" ] && [ "$branch" != "main" ]; then
  branch_words=$(echo "$branch" | tr '-' '\n' | tr '_' '\n')
  for skill in "$PROJECT_DIR"/.claude/skills/*.md; do
    [ -f "$skill" ] || continue
    for word in $branch_words; do
      [ ${#word} -lt 4 ] && continue
      if grep -qi "$word" "$skill" 2>/dev/null; then
        echo "Then load skill: $(basename "$skill")"
        break 2
      fi
    done
  done
fi

# -- Compaction warning ---------------------------------------------------------
if [ "$TRIGGER" = "compact" ]; then
  echo ""
  echo "WARNING: Context was compacted. Re-read all files above. Re-load your task's skill."
fi

# -- Proof gate (CRITICAL — this is what forces compliance) ---------------------
echo ""
echo "YOUR FIRST RESPONSE must be the proof checklist. One fact per file. Do not work on any task until proof is posted."

exit 0
```

---

### PreToolUse: `pre-commit-guard.sh`

**Checks:**

| Check | `worktree` mode | `main` mode |
|-------|----------------|------------|
| Not committing to main | Block if on main | Skip |
| Not behind origin/main | Block if behind | Block if behind |
| Changelog fragment exists | Block if missing | Block if missing |
| Fragment matches branch issue | Block if mismatch | Skip |
| GitHub issue exists and is open | Block if not found/closed | Block if not found/closed |
| Chore branch exception | Skip issue checks | Skip issue checks |

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | python3 -c \
  "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null || echo "")

if [[ "$command" != *"git commit"* ]]; then
  exit 0
fi

MODE=$(cat .claude/workflow-mode 2>/dev/null || echo "worktree")
ERRORS=()
branch=$(git branch --show-current 2>/dev/null || echo "")

# -- Chore branch exception ----------------------------------------------------
is_chore=false
if [[ "$branch" == chore/* ]] || [[ "$branch" == chore-* ]]; then
  is_chore=true
fi

# -- Check 1: not committing to main (worktree mode only) ----------------------
if [ "$MODE" = "worktree" ] && [ "$branch" = "main" ]; then
  ERRORS+=("On main branch — feature work must be in a worktree")
  ERRORS+=("  -> Create one with: claude -w issue-N-slug")
fi

# -- Check 2: not behind origin/main -------------------------------------------
if [ "$branch" != "main" ]; then
  git fetch origin main --quiet 2>/dev/null || true
  behind=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo 0)
  if [ "$behind" -gt 0 ]; then
    ERRORS+=("Worktree is $behind commit(s) behind origin/main")
    ERRORS+=("  -> Run: git rebase origin/main")
  fi
fi

# -- Check 3: changelog fragment exists -----------------------------------------
fragments_any=$(find .changelog -name "*.md" -not -name "README.md" \
  2>/dev/null | wc -l | tr -d ' ')
if [ "$fragments_any" -eq 0 ]; then
  ERRORS+=("No changelog fragment found in .changelog/")
  if [ "$is_chore" = true ]; then
    ERRORS+=("  -> Write .changelog/0-chore-<slug>.md before committing")
  else
    ERRORS+=("  -> Write .changelog/<issue>-<slug>.md before committing")
  fi
fi

# -- Check 4 + 5: fragment matches issue, issue exists and is open ---------------
if [ "$is_chore" = false ]; then
  issue_num=$(echo "$branch" | grep -oE '[0-9]+' | head -1 || echo "")

  if [ -n "$issue_num" ]; then
    if [ "$fragments_any" -gt 0 ] && [ "$MODE" = "worktree" ]; then
      matching=$(find .changelog -name "${issue_num}-*.md" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$matching" -eq 0 ]; then
        existing=$(find .changelog -name "*.md" -not -name "README.md" \
          2>/dev/null | xargs -I{} basename {} | tr '\n' ' ')
        ERRORS+=("No fragment matching issue #${issue_num} for branch '$branch'")
        ERRORS+=("  -> Expected: .changelog/${issue_num}-<slug>.md")
        ERRORS+=("  -> Found: ${existing:-none}")
      fi
    fi

    issue_state=$(gh issue view "$issue_num" --json state \
      --jq '.state' 2>/dev/null || echo "NOT_FOUND")
    if [ "$issue_state" = "NOT_FOUND" ]; then
      ERRORS+=("GitHub issue #${issue_num} not found")
      ERRORS+=("  -> Create it first: gh issue create")
    elif [ "$issue_state" = "CLOSED" ]; then
      ERRORS+=("GitHub issue #${issue_num} is already closed")
      ERRORS+=("  -> Reopen it or create a new issue for this work")
    fi
  fi
fi

# -- Result ---------------------------------------------------------------------
if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""; echo "COMMIT BLOCKED"; echo "=============="
  for err in "${ERRORS[@]}"; do echo "  x $err"; done
  echo ""; exit 2
fi

exit 0
```

---

### PreToolUse: `pre-pr-guard.sh`

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | python3 -c \
  "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null || echo "")

if [[ "$command" != *"gh pr create"* ]]; then exit 0; fi

MODE=$(cat .claude/workflow-mode 2>/dev/null || echo "worktree")
ERRORS=()
branch=$(git branch --show-current 2>/dev/null || echo "")

if [ "$MODE" = "worktree" ] && [ "$branch" = "main" ]; then
  ERRORS+=("Cannot create PR from main — PRs must come from a worktree branch")
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
  # Chore branches still need a fragment, just not issue-matched
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
```

---

### PreToolUse: `pre-release-guard.sh`

Reads `.claude/version-files` for multi-file version projects.

```bash
#!/bin/bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | python3 -c \
  "import sys,json; print(json.load(sys.stdin).get('command',''))" 2>/dev/null || echo "")

if [[ "$command" != *"git tag"* ]]; then exit 0; fi

ERRORS=()
branch=$(git branch --show-current 2>/dev/null || echo "")

# -- Must be on main --------------------------------------------------------------
if [ "$branch" != "main" ]; then
  ERRORS+=("Releases must be tagged from main (currently on '$branch')")
fi

# -- No unassembled fragments -----------------------------------------------------
fragments=$(find .changelog -name "*.md" -not -name "README.md" \
  2>/dev/null | wc -l | tr -d ' ')
if [ "$fragments" -gt 0 ]; then
  fragment_list=$(find .changelog -name "*.md" -not -name "README.md" \
    2>/dev/null | xargs -I{} basename {} | tr '\n' ' ')
  ERRORS+=("Unassembled fragments remain: $fragment_list")
  ERRORS+=("  -> Run: bash scripts/release.sh")
fi

# -- Extract tag version ----------------------------------------------------------
tag_version=$(echo "$command" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "")

if [ -n "$tag_version" ]; then
  # CHANGELOG must contain this version
  if ! grep -q "\[$tag_version\]" CHANGELOG.md 2>/dev/null; then
    ERRORS+=("CHANGELOG.md has no entry for $tag_version")
  fi

  # Check all version files listed in .claude/version-files
  if [ -f ".claude/version-files" ]; then
    while IFS= read -r vfile || [ -n "$vfile" ]; do
      [ -z "$vfile" ] && continue
      [ "${vfile:0:1}" = "#" ] && continue
      if [ -f "$vfile" ]; then
        file_ver=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "$vfile" 2>/dev/null | head -1 || echo "")
        if [ -n "$file_ver" ] && [ "$file_ver" != "${tag_version#v}" ] && \
           [ "v$file_ver" != "$tag_version" ]; then
          ERRORS+=("$vfile version ($file_ver) does not match tag ($tag_version)")
        fi
      else
        ERRORS+=("Version file not found: $vfile")
      fi
    done < ".claude/version-files"
  else
    # Fallback: check CLAUDE.md and MEMORY.md
    for vfile in CLAUDE.md MEMORY.md; do
      if [ -f "$vfile" ]; then
        file_ver=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$vfile" 2>/dev/null | head -1 || echo "")
        if [ -n "$file_ver" ] && [ "$file_ver" != "$tag_version" ]; then
          ERRORS+=("$vfile version ($file_ver) does not match tag ($tag_version)")
        fi
      fi
    done
  fi

  # Check user-docs if active
  if [ -f ".claude/release-artifacts" ]; then
    user_docs=$(grep "^user-docs:" .claude/release-artifacts | \
      grep -v "false" | cut -d: -f2- | tr -d ' ' || echo "")
    if [ -n "$user_docs" ]; then
      doc_file=$(echo "$user_docs" | cut -d: -f1)
      if [ -f "$doc_file" ]; then
        changed=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -c "$doc_file" || echo 0)
        if [ "$changed" -eq 0 ]; then
          ERRORS+=("User docs ($doc_file) not updated — required release artifact")
          ERRORS+=("  -> Update before tagging, or set user-docs: false if not applicable")
        fi
      fi
    fi
  fi
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""; echo "RELEASE BLOCKED"; echo "==============="
  for err in "${ERRORS[@]}"; do echo "  x $err"; done
  echo ""; exit 2
fi

exit 0
```

---

## Full `.claude/settings.json`

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/context-recovery.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-commit-guard.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-pr-guard.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-release-guard.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Configuration Files

### `.claude/workflow-mode`
```
worktree
```
or
```
main
```

### `.claude/context-files`
```
# Files to read every session. One per line.
# gh-issues is a special token — runs gh issue list.
# Add files here when skipping them has caused regressions.
ARCHITECTURE.md
MEMORY.md
gh-issues
```

### `.claude/version-files`
```
# Files containing version numbers that must match git tag at release
# One file per line. Lines starting with # are ignored.
baseline_engine/app.py
addons/rtheyok-baseline-engine/config.yaml
```

### `.claude/release-artifacts`
```
# Release artifact enforcement
changelog: true
architecture: true
memory: true
user-docs: false
# user-docs: docs/user-guide.md
# user-docs: dashboard.py
```

---

## File Layout

```
.claude/
├── settings.json                    Hook configuration
├── workflow-mode                    "worktree" or "main"
├── context-files                   Tier 2 file list (configurable per project)
├── version-files                   Files containing version numbers
├── release-artifacts                Configurable release artifact enforcement
├── hooks/
│   ├── context-recovery.sh          SessionStart — Tier 2 + branch status + Tier 3 hint
│   ├── pre-commit-guard.sh          PreToolUse — git commit gate
│   ├── pre-pr-guard.sh              PreToolUse — gh pr create gate
│   └── pre-release-guard.sh         PreToolUse — git tag gate
└── skills/
    ├── [domain-a].md                Topic skill navigator
    └── [domain-b].md                Topic skill navigator

~/.claude/skills/
└── release-management.md            Global — shared across all projects

.changelog/
├── README.md                        Fragment format reference (never deleted)
└── [issue]-[slug].md               Pending fragments

docs/
├── as-built.md                      AB-xxx entries + current + build history
├── findings.md                      Permanent operational gotcha register (F-xxx)
├── assumptions.md                   Unverified tracker (A-xxx) + resolved section
├── beliefs-and-tests.md             Investigation journal (B-xxx, T-xxx)
├── [topic]-investigation.md         Topic-specific deep investigation (optional)
├── requirements.md                  Requirements spec (optional)
├── release_workflow.md              Project-specific release notes
└── runbook.md                       Deployment guide (optional)
```

---

## Commit Format

### In worktree or main (before release)
```
fix: short description (#N)

Longer explanation if needed.

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

### Chore commits (no issue)
```
chore: short description

What was done.

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

### Release commit
```
v0.4.25: Short description (#N, #M)

- What was added
- What was fixed
- What was discovered

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

---

## Setup: New Project

```bash
# 1. Set workflow mode
mkdir -p .claude/hooks .claude/skills .changelog docs
echo "worktree" > .claude/workflow-mode    # or "main"

# 2. Configure context files (start with defaults, iterate based on incidents)
cat > .claude/context-files << EOF
# Files to read every session. One per line.
# gh-issues is a special token — runs gh issue list.
# Add files here when skipping them has caused regressions.
ARCHITECTURE.md
MEMORY.md
gh-issues
EOF

# 3. Copy and customise hooks
cp /path/to/standards/hooks/* .claude/hooks/
chmod +x .claude/hooks/*.sh
# Edit context-recovery.sh: add project-specific incidents and standing rules

# 4. Configure settings and artifacts
cp /path/to/standards/settings.json .claude/settings.json
cp /path/to/standards/release-artifacts .claude/release-artifacts

# 5. Declare version files
cat > .claude/version-files << EOF
# Add files containing version numbers
EOF

# 6. Create changelog placeholder
cp /path/to/standards/changelog-README.md .changelog/README.md

# 7. Scaffold core docs
touch CLAUDE.md ARCHITECTURE.md MEMORY.md CHANGELOG.md
touch docs/as-built.md docs/release_workflow.md

# 8. Add optional docs as needed
touch docs/findings.md         # if hardware/deployment complexity
touch docs/assumptions.md      # recommended for all projects
touch docs/beliefs-and-tests.md  # if empirical investigation

# 9. Create topic skills per domain
# .claude/skills/[domain].md — see navigator template above

# 10. Add two-environment table to CLAUDE.md if dev + production
```

---

## Setup: Retrofit Existing Project

### Good existing docs (HA_Home, Scores4S, NRL, RTheyOk pattern)

One session of work per project:

1. **Clarify ARCHITECTURE.md** — ensure it represents target state. Move any pure "current build state" content to as-built.md. Number or rename design decisions as ADR-xxx.
2. **Clarify as-built.md** — ensure it has a "current state" section plus build history. AB-xxx entries stay here.
3. **Create findings.md** — extract operational gotchas from CLAUDE.md, as-built, and session memory. Number as F-xxx.
4. **Create assumptions.md** — identify anything currently unverified. Surface from CLAUDE.md, requirements, open issues.
5. **Install hooks** — copy scripts, customise context-recovery.sh incidents section with real project incidents.
6. **Set workflow-mode** — based on actual working pattern.
7. **Configure context-files** — audit current mandatory reading list. Files that have caused regressions when skipped go in Tier 2. Others become Tier 3 skill references.
8. **Configure version-files** — list all files containing version numbers.
9. **Create topic skills** — one per domain, navigator format, referencing existing AB/ADR entries.
10. **Update CLAUDE.md** — add two-environment table if applicable. Add hard rules (never cycle, never guess, always verify). Trim to 1-2 pages — move detail into skills.

### NRL-specific addition

Renumber ARCHITECTURE.md design decisions as ADR-xxx. Sed-based batch rename then manual verification. One session, low risk if done carefully.

---

## Adopting Workflow Upgrades

When a pattern improves in this central standard:

1. Update version number and CHANGELOG at top of this doc
2. Each active project checks standard version in `.claude/workflow-mode` comments
3. Adoption is **pull not push** — each project adopts improvements when relevant
4. Hook logic improvements: copy the logic block, leave project-specific incidents untouched
5. New optional documents: add only when the project type warrants it

---

## Agent Teams

Not recommended for solo developer workflows. Designed for agents that need to communicate mid-task. The coordination and token overhead exceeds the benefit for single-developer sequential issue work.

Revisit if you have genuinely interdependent parallel workstreams where two agents need to negotiate shared interfaces before either can complete.

---

## Projects Using This Workflow

| Project | Mode | Version | Skills | Context weight | Status |
|---------|------|---------|--------|---------------|--------|
| HA_Home | `worktree` | 1.2 | 7 (cameras-frigate, dashboard-kiosk, energy-system, network-infra, pir-lighting, pool-heating, release-workflow) | Heavy | Retrofitted ✓ — PR #182, v0.4.34 |
| Scores4Streams V2 | `main` | 1.2 | 8 | Medium | Retrofitted ✓ — guards verified in live session |
| Edge Hunter (NRL) | `worktree` | 1.2 | 9 (betting-workflow, collaboration, dashboard-ui, deployment, help-guide, model-engine, multi-sport, multi-tenant, notifications) | Medium | Retrofitted ✓ — rebrand branch rebased |
| R They OK | `main` | 1.2 | 4 (baseline-engine, ha-addon, sensor-pairing, deployment) | Light | Retrofitted ✓ — backlog + roadmap done |
