# Workflow Standards Bootstrap — Session Brief

> Hand this to a Claude Code session in the workflow project along with
> claude-workflow-standards-v3.md. This brief captures decisions made
> during the design conversation that are not obvious from the standard
> alone. Do not re-derive these — they were deliberately chosen.

---

## What This Session Must Do

1. **Verify** the standard against all four projects (read all, check for conflicts) — DONE (v1.1)
2. **Implement** the standard in this workflow project (files, templates, scripts)
3. **Plan** the retrofit sequence for each existing project
4. **Do NOT** retrofit existing projects in this session — plan only

---

## What Has Already Been Decided (Do Not Re-Derive)

### Document Taxonomy
- `ARCHITECTURE.md` = target state + ADR-xxx entries (architectural decisions)
- `as-built.md` = current deployed state + build history + AB-xxx entries (implementation decisions)
- ADR test: "would reversing this require rearchitecting, or just rewriting a function?"
- ADRs live in ARCHITECTURE.md. ABs live in as-built.md. Both reference GitHub issues for full rationale.
- ADR supersession: never change Decision or Rationale — create new ADR. Typos and clarifications are fine to edit in place (v1.1 relaxation).
- AB entries are append-only

### Three Investigation Documents (distinct, not interchangeable)
- `findings.md` — permanent operational gotcha register (F-xxx). Things that fail, append-only, never deleted
- `assumptions.md` — unverified tracker (A-xxx) with lifecycle: open -> confirmed/disproved -> resolved
- `beliefs-and-tests.md` — active investigation journal (B-xxx, T-xxx) for empirical/sensor/model projects
- These form a pipeline: assumption -> investigation -> finding
- Topic-specific investigation docs (e.g. `energy-investigation.md`) are valid for complex domains

### Two Workflow Modes
- `worktree` — commits to main are BLOCKED. All work in worktrees. (HA_Home, NRL)
- `main` — no branch enforcement. Work on main or worktree, your choice. (Scores4S, RTheyOk)
- `main` mode does NOT prohibit worktrees — it just doesn't enforce them
- Scores4S worktree aversion is a project-specific incident note, not a mode-level rule

### Three-Tier Context Model (v1.1 — configurable)
- Tier 1: CLAUDE.md (always loaded, auto)
- Tier 2: Configurable via `.claude/context-files` (every session, via SessionStart hook)
- Tier 3: topic skill navigator (per task, via worktree starter prompt OR auto-hint from branch name)
- Each project declares its own Tier 2 file list based on incident history
- Default Tier 2: ARCHITECTURE.md + MEMORY.md + gh issue list
- Projects with heavier context needs (HA_Home) add more files — this is earned, not bloat
- Process: start with defaults, add files when incidents prove they're needed, review during retrofits

### Topic Skills as Navigators
- Skills are NOT knowledge documents — they are POINTERS to existing knowledge
- Content: ADR/AB entry numbers, findings numbers, issue numbers to fetch, regression risks
- Skills load the pointers (~300 tokens), then Claude loads only what's relevant
- Descriptions must be precise enough for auto-triggering (specific filenames, entity names, urgency phrase)
- Global skill `~/.claude/skills/release-management.md` shared across all projects

### GitHub Issue Discipline
- All work starts with an open GitHub issue
- pre-commit-guard blocks commits if issue doesn't exist or is closed
- Chore exception: branches named `chore/` bypass issue requirement (v1.1)
- Issues are enriched before closing — structured comment with what was done, ADR/AB refs, skill updated
- Closed issues become queryable context — `gh issue view N` gives full lifecycle record

### Stop Hook for Auto-Capture (newly adopted)
- Session close checklist fires on every Stop event
- Prompts Claude to surface unrecorded decisions before session ends
- Lightweight — prints checklist only, no auto-write

### Auto-Triggering Skills (newly adopted)
- Skills should auto-trigger from descriptions, not require manual loading
- SessionStart hook now hints at Tier 3 skill based on branch name (v1.1)
- After bootstrap, test each skill by starting a fresh session and giving a domain task without mentioning the skill
- If it doesn't trigger, sharpen the description

### Version Files Config
- `.claude/version-files` lists all files containing version numbers per project
- pre-release-guard reads this file instead of hardcoded locations
- NRL: `dashboard.py`. RTheyOk: `baseline_engine/app.py` + `addons/rtheyok-baseline-engine/config.yaml`

### User Documentation
- Declared in `.claude/release-artifacts` as `user-docs: false` or `user-docs: <path>`
- NRL: enforce now (Help tab in dashboard.py)
- RTheyOk: enforce from first release (users arriving soon)
- Scores4S: deferred — UI still iterating
- HA_Home: minimal, not yet

### NRL-Specific
- 66 design decisions in ARCHITECTURE.md currently without ADR notation
- Bootstrap session will renumber as ADR-xxx
- This is a one-session task — batch rename, verify nothing breaks

### Never Cycle / Never Guess / Always Verify Rules
- Derived from RTheyOk. Now standard for all projects.
- Never cycle: if something fails twice with same approach, STOP. State what failed, propose different approach.
- Never guess: check docs or ls first. Read code before assuming endpoints.
- Always verify: run verification command after every deployment action.

### Two-Environment Table
- Required in CLAUDE.md for any project with dev + production environments
- "Before every remote command: state which environment and why"
- RTheyOk and HA_Home have this. Scores4S and NRL may not need it (single environment each).

---

## Project Inventory (Verified 2026-03-21)

### HA_Home
- **Mode:** worktree
- **Docs:** CLAUDE.md, ARCHITECTURE.md, MEMORY.md, as-built.md,
  energy-beliefs-and-tests.md, CHANGELOG.md, release_workflow.md
- **Missing:** findings.md, assumptions.md
- **AB entries:** AB-001 through AB-007+ (energy phase sensors, formula decisions)
- **Key incidents:** M1 sensor regression (AB-001), battery phase misdiagnosis, wrong SSH password after compaction
- **Proposed skills:** energy-monitoring, alarm-integration, pool-solar, dashboard
- **Hook state:** SessionStart installed (context-recovery.sh with 8-file checklist). No PreToolUse hooks.
- **Proposed context-files:** ARCHITECTURE.md, MEMORY.md, docs/as-built.md, docs/energy-beliefs-and-tests.md, CHANGELOG.md, docs/release_workflow.md, gh-issues (7 items — heavy, justified by 6+ incidents)
- **Needs:** .claude/context-files, .claude/workflow-mode, pre-commit-guard, pre-pr-guard, pre-release-guard, .changelog/ directory, topic skills, findings.md, assumptions.md
- **.changelog/ directory:** Does not exist — create fresh

### Scores4Streams V2
- **Mode:** main (worktrees explicitly discouraged — past divergence incidents #41, #46)
- **Docs:** CLAUDE.md, ARCHITECTURE.md, MEMORY.md, as-built.md,
  requirements.md, CHANGELOG.md
- **Missing:** findings.md, assumptions.md, release_workflow.md (separate)
- **AB entries:** AB-001 through AB-011 (dual-write, isPitch, force-advance, scoring modes, undo)
- **Key incidents:** isPitch regression (AB-003), HBP force-advance bug (AB-004), duplicate work
- **Proposed skills:** batting-engine, data-model, scoring-modes, undo-system
- **Hook state:** SessionStart installed (context-recovery.sh with 5-file checklist). No PreToolUse hooks.
- **Proposed context-files:** ARCHITECTURE.md, MEMORY.md, docs/as-built.md, CHANGELOG.md, gh-issues (5 items — matches current)
- **Needs:** .claude/context-files, .claude/workflow-mode, pre-commit-guard, pre-pr-guard, pre-release-guard, .changelog/ directory, .claude/version-files, topic skills
- **User docs:** deferred

### Edge Hunter (NRL)
- **Mode:** worktree
- **Docs:** CLAUDE.md, ARCHITECTURE.md (66 decisions, needs ADR renumbering),
  MEMORY.md, CHANGELOG.md, release_workflow.md
- **Missing:** as-built.md, findings.md, assumptions.md
- **Key decisions:** 66 in ARCHITECTURE.md — renumber as ADR-xxx during bootstrap
- **Auto-version hook:** .git/hooks/pre-commit auto-bumps patch. This is a git hook, NOT a Claude hook — no conflict with PreToolUse guards. NEVER use --no-verify.
- **Key incidents:** stake=0 crash (v1.20.1), vote threshold recheck bug (v1.20.4), cron wrap (v1.19.1)
- **Proposed skills:** betting-model, odds-pipeline, deployment, ui-voting
- **Hook state:** SessionStart installed (context-recovery.sh with 4-file checklist). No PreToolUse hooks.
- **Proposed context-files:** ARCHITECTURE.md, MEMORY.md, CHANGELOG.md, gh-issues (4 items — standard weight)
- **Needs:** .claude/context-files, .claude/workflow-mode, pre-commit-guard (coexists with git auto-version), pre-pr-guard, pre-release-guard, .changelog/ directory, .claude/version-files (dashboard.py), as-built.md, topic skills
- **User docs:** Help tab in dashboard.py — enforce now
- **Special:** deploy to Pi via `bash infra/deploy.sh` — must be in deployment skill

### R They OK
- **Mode:** main
- **Docs:** CLAUDE.md, ARCHITECTURE.md, as-built.md (as `as_built.md`), findings.md,
  assumptions.md, requirements.md, CHANGELOG.md, release_workflow.md,
  deploy/docs/ha_addon_build_notes.md, deploy/docs/ha_green_runbook.md
- **Missing:** MEMORY.md, beliefs-and-tests.md (optional)
- **Key incidents:** Supervisor config caching, two add-on paths, heredocs over SSH,
  JWT env var corruption, entity renaming via WebSocket only
- **Proposed skills:** baseline-engine, ha-addon, sensor-pairing, deployment
- **Hook state:** No settings.json, no hooks directory. Only settings.local.json with empty hooks. Fully missing.
- **Proposed context-files:** ARCHITECTURE.md, docs/as_built.md, docs/findings.md, docs/assumptions.md, CHANGELOG.md, gh-issues (6 items — justified by findings/assumptions maturity)
- **Needs:** .claude/settings.json, .claude/hooks/ directory, context-recovery.sh, .claude/context-files, .claude/workflow-mode, pre-commit-guard, pre-pr-guard, pre-release-guard, .changelog/ directory, .claude/version-files (2 files), MEMORY.md, topic skills
- **User docs:** enforce from next release (users arriving soon)
- **Note:** `as_built.md` uses underscore not hyphen — standardise during retrofit or leave as-is

---

## Verification Results (2026-03-21)

### Specific Verification Items

| # | Item | Result |
|---|------|--------|
| 1 | NRL auto-version hook vs pre-commit-guard | NO CONFLICT — git hook (.git/hooks/pre-commit) and Claude PreToolUse hook operate at different layers. Guard intercepts git commit command before git executes; git's hook fires after. |
| 2 | HA_Home fragment naming | N/A — no .changelog/ directory exists. Created fresh. |
| 3 | Scores4S no-worktree rule vs main mode | OK — pre-commit-guard only blocks main commits in worktree mode. Scores4S will be main mode. |
| 4 | RTheyOK version file grep patterns | OK — `baseline_engine/app.py` has `__version__ = "0.19.0"`, `config.yaml` has `version: "0.19.0"`. Guard's `grep -oE '[0-9]+\.[0-9]+\.[0-9]+'` matches both. |
| 5 | HA_Home production access exposure | OK — hooks only read workflow config files. SSH password referenced in CLAUDE.md prose only. docker/.env is gitignored. |

### Key Conflicts Resolved in v1.1

1. **HA_Home 8-file recovery vs standard 3-file Tier 2** — RESOLVED: configurable `.claude/context-files` lets each project declare its own Tier 2 list. HA_Home keeps its heavy loading, justified by 6+ real incidents.
2. **RTheyOK 7-file recovery vs standard** — RESOLVED: same mechanism. RTheyOK declares 6 files including findings.md and assumptions.md.
3. **Trivial commits blocked by issue requirement** — RESOLVED: `chore/` branch prefix bypasses issue checks.
4. **ADR supersession too rigid for solo dev** — RESOLVED: typos and clarifications can be edited in place; only decision/rationale changes require new ADR.

---

## Bootstrap Sequence

### Recommended order (easiest -> most complex)

1. **Scores4Streams** — cleanest domain boundaries, well-numbered ABs, good test case
2. **RTheyOk** — richest findings/assumptions, ha-addon skill highest value, needs most infrastructure (no hooks at all)
3. **HA_Home** — investigation journal adds complexity, energy domain large and high-stakes
4. **NRL** — ADR renumbering adds complexity, benefits from lessons on first three

### Bootstrap prompt (use in each project)

```
Bootstrap topic skills for this project.

Read in order:
1. ARCHITECTURE.md
2. docs/as-built.md (or equivalent per project inventory)
3. CLAUDE.md
4. docs/findings.md (if exists)
5. docs/assumptions.md (if exists)
6. CHANGELOG.md
7. gh issue list --state closed --limit 100

Then:
- Identify 3-6 natural domain clusters in the accumulated decisions
- Post proposed domain list first — wait for approval before writing files
- For each approved domain, draft .claude/skills/<domain>.md navigator:
  - YAML frontmatter with name and precise auto-trigger description
  - ADR references from ARCHITECTURE.md
  - AB references from as-built.md
  - Findings references (F-xxx) if any
  - Open assumptions relevant to this domain
  - 3-5 most relevant closed issue numbers
  - Regression risks specific to this domain
- Test description quality: would it auto-trigger from a task description
  mentioning only natural language terms for this domain?
```

---

## This Workflow Project Structure (Target)

```
/
├── README.md                         Overview and quick-start
├── CLAUDE.md                         This project's own session rules
├── standards/
│   ├── claude-workflow-standards-v3.md  The canonical standard (v1.1)
│   └── bootstrap-session-brief.md      This file
├── plans/
│   ├── retrofit-ha-home.md
│   ├── retrofit-scores4streams.md
│   ├── retrofit-nrl.md
│   └── retrofit-rtheyok.md
├── prompts/
│   ├── new-project-starter.md        Copy-paste prompt for new projects
│   └── retrofit-existing-starter.md  Copy-paste prompt for retrofits
├── guides/
│   └── how-to-guide.md              Plain language guide
├── templates/
│   ├── CLAUDE.md.template            Base template per mode
│   ├── context-recovery.sh.template  Hook template with placeholders
│   ├── settings.json.template        Full settings template
│   ├── release-artifacts.template    Release artifact config
│   ├── version-files.template        Version files config
│   ├── context-files.template        Tier 2 file list template
│   ├── skill-navigator.md.template   Topic skill template
│   ├── as-built-entry.md.template    AB-xxx entry template
│   ├── adr-entry.md.template         ADR-xxx entry template
│   ├── finding-entry.md.template     F-xxx entry template
│   ├── assumption-entry.md.template  A-xxx entry template
│   ├── belief-entry.md.template      B-xxx entry template
│   ├── changelog-fragment.md.template Fragment format reference
│   └── worktree-starter-prompt.md    Tier 3 loading prompt template
├── hooks/
│   ├── context-recovery.sh           Master hook (customise per project)
│   ├── pre-commit-guard.sh
│   ├── pre-pr-guard.sh
│   ├── pre-release-guard.sh
│   └── session-capture.sh            Stop hook for auto-capture
├── scripts/
│   └── setup.sh                      Scaffold new project
└── global-skills/
    └── release-management.md         ~/.claude/skills/ candidate
```

---

## Retrofit Task Per Project (Plan Only In This Session)

For each project, produce a retrofit plan as a markdown file in plans/:

```
Title: Retrofit [Project] to workflow standard v1.1

## Value Case
[Why this project benefits from the standard — specific incidents it would prevent]

## Steps
1. [ ] Verify existing hooks against new standard
2. [ ] Create/update missing documents
3. [ ] Install updated hook scripts
4. [ ] Configure .claude/workflow-mode
5. [ ] Configure .claude/context-files
6. [ ] Configure .claude/version-files
7. [ ] Configure .claude/release-artifacts
8. [ ] Create .changelog/ directory
9. [ ] Bootstrap topic skills (separate session)
10. [ ] Test auto-triggering of each skill
11. [ ] Verify pre-commit-guard with test commit
12. [ ] Verify pre-release-guard with dry-run tag

## Project-specific notes
[From project inventory above]

## Proposed context-files
[The Tier 2 file list for this project with justification]

## Proposed topic skills
[Domain list with key references]

## Risks and mitigations
[What could go wrong during retrofit]
```

---

## Reference

Workflow standards doc: standards/claude-workflow-standards-v3.md (v1.1)
This brief: standards/bootstrap-session-brief.md
