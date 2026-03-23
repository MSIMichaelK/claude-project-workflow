# Workflow Standards Bootstrap — Session Brief

> Hand this to a Claude Code session in the workflow project along with
> claude-workflow-standards-v3.md. This brief captures decisions made
> during the design conversation that are not obvious from the standard
> alone. Do not re-derive these — they were deliberately chosen.

---

## Status

**Standard version:** 1.2 (2026-03-23)
**All four projects retrofitted:** HA_Home ✓, Scores4Streams ✓, NRL ✓, RTheyOK ✓
**Pending:** Game studio project (new, multi-persona — may need standard extension)

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

## Project Inventory (Post-Retrofit 2026-03-23)

### HA_Home — Retrofitted ✓
- **Mode:** worktree | **Context weight:** Heavy | **Skills:** 7
- **Skills:** cameras-frigate, dashboard-kiosk, energy-system, network-infra, pir-lighting, pool-heating, release-workflow
- **Hooks:** SessionStart ✓, pre-commit-guard ✓, pre-pr-guard ✓, pre-release-guard ✓
- **Tested:** Full PR + merge + release cycle verified (PR #182, v0.4.34)

### Scores4Streams V2 — Retrofitted ✓
- **Mode:** main | **Context weight:** Medium | **Skills:** 8
- **Hooks:** SessionStart ✓, pre-commit-guard ✓, pre-pr-guard ✓, pre-release-guard ✓
- **Tested:** Guards verified in live session, backlog work proceeding under new workflow

### Edge Hunter (NRL) — Retrofitted ✓
- **Mode:** worktree | **Context weight:** Medium | **Skills:** 9
- **Skills:** betting-workflow, collaboration, dashboard-ui, deployment, help-guide, model-engine, multi-sport, multi-tenant, notifications
- **Hooks:** SessionStart ✓, pre-commit-guard ✓, pre-pr-guard ✓, pre-release-guard ✓
- **Pending:** feature/rebrand branch rebased onto main, ready to PR

### R They OK — Retrofitted ✓
- **Mode:** main | **Context weight:** Light | **Skills:** 4
- **Skills:** baseline-engine, ha-addon, sensor-pairing, deployment
- **Hooks:** SessionStart ✓, pre-commit-guard ✓, pre-pr-guard ✓, pre-release-guard ✓
- **Tested:** Backlog and roadmap session completed under new workflow

---

## Retrofit Learnings

1. **Skill count varies wildly** — RTheyOK needed 4, NRL needed 9. Don't force a number.
2. **Chore fragments used immediately** — `0-chore-roadmap-and-skills.md` validated the escape hatch.
3. **Roadmap as Tier 2** — RTheyOK added `docs/roadmap.md` to context-files. Recommend for milestone-driven projects.
4. **ADR renumbering not needed** — no project benefited. Keep existing numbering schemes.
5. **Existing sessions don't pick up new hooks** — must start a new session after retrofit.
6. **HA_Home token pressure** — context-recovery loads too much. Needs slim ARCHITECTURE summary for Tier 2.

---

## Known Issues and Future Work

1. **Game studio project** — multi-persona simulation (art director + dev) may need a standard extension
2. **Skill auto-triggering** — untested at scale across all projects
3. **Compaction resilience** — untested. Does re-loading skill pointers after compaction preserve enough context?
4. **HA_Home Tier 2 optimisation** — slim summary needed, full ARCHITECTURE.md to Tier 3

---

## Reference

Workflow standards doc: standards/claude-workflow-standards-v3.md (v1.2)
This brief: standards/bootstrap-session-brief.md
Retrofit plans: plans/retrofit-*.md
Prompts: prompts/new-project-starter.md, prompts/retrofit-existing-starter.md
Guide: guides/how-to-guide.md
