# Workflow Standards Bootstrap — Session Brief

> Hand this to a Claude Code session in the workflow project along with
> claude-workflow-standards-v3.md. This brief captures decisions made
> during the design conversation that are not obvious from the standard
> alone. Do not re-derive these — they were deliberately chosen.

---

## Status

**Standard version:** 1.3 (2026-03-27)
**All five projects retrofitted to v1.3:** HA_Home ✓, Scores4Streams ✓, NRL ✓, RTheyOK ✓, Game Studio ✓
**v1.3 propagation to projects:** pending (use Prompt B in retrofit-existing-starter.md)

---

## What Has Already Been Decided (Do Not Re-Derive)

### Document Taxonomy
- `ARCHITECTURE.md` = target state + ADR-xxx entries (architectural decisions)
- `as-built.md` = current deployed state + build history + AB-xxx entries (implementation decisions)
- ADR test: "would reversing this require rearchitecting, or just rewriting a function?"
- ADRs live in ARCHITECTURE.md. ABs live in as-built.md. Both reference GitHub issues for full rationale.
- ADR supersession: never change Decision or Rationale — create new ADR. Typos and clarifications are fine to edit in place.
- AB entries are append-only
- `docs/concept.md` = initial project concept, written once, never updated — deviations become ADRs

### Three Investigation Documents (distinct, not interchangeable)
- `findings.md` — permanent operational gotcha register (F-xxx). Things that fail, append-only, never deleted
- `assumptions.md` — unverified tracker (A-xxx) with lifecycle: open → confirmed/disproved → resolved
- `beliefs-and-tests.md` — active investigation journal (B-xxx, T-xxx) for empirical/sensor/model projects
- These form a pipeline: assumption → investigation → finding
- Topic-specific investigation docs (e.g. `energy-investigation.md`) are valid for complex domains

### Two Workflow Modes
- `worktree` — commits to main are BLOCKED. All work in worktrees. (HA_Home, NRL)
- `main` — no branch enforcement. Work on main or worktree, your choice. (Scores4S, RTheyOk, Game Studio)
- `main` mode does NOT prohibit worktrees — it just doesn't enforce them

### Three-Tier Context Model
- Tier 1: CLAUDE.md (always loaded, auto)
- Tier 2: Configurable via `.claude/context-files` (every session, via SessionStart hook)
- Tier 3: skill navigator — topic skill OR process skill (per task, via worktree starter prompt OR auto-hint from branch name)
- Each project declares its own Tier 2 file list based on incident history
- Default Tier 2: ARCHITECTURE.md + MEMORY.md + gh issue list
- Process for Tier 2: start with defaults, add files when incidents prove they're needed

### Topic Skills as Navigators
- Skills are NOT knowledge documents — they are POINTERS to existing knowledge
- Content: ADR/AB entry numbers, findings numbers, issue numbers to fetch, regression risks
- Descriptions must be precise enough for auto-triggering (specific filenames, entity names, urgency phrase)
- Global skill `~/.claude/skills/release-management.md` shared across all projects

### Process Skills (v1.3)
- Three process skills copied to every project by setup.sh: process-ba-analyst, process-product-manager, process-scrum-master
- Process skills tell Claude HOW to approach a type of work — distinct from topic skills which tell Claude WHAT to know
- Naming convention: `process-<role>.md` to distinguish from domain skills
- Templates in `templates/skills/`

### Issue Hierarchy (v1.3)
- Six types: epic, story, spike, investigation, bug, chore
- Epic = strategic container, never a release trigger, spans multiple sprints
- Story = primary release unit, one PR, independently testable, has retirement checklist
- Spike = time-boxed question, has time box + definition of done
- Investigation = open-ended, anchors to findings.md, no time box
- Release = explicit curation of closed stories/bugs — not automatic at any hierarchy level
- Epic task list uses `- [ ] #number` format — GitHub auto-checks when referenced issue closes
- Templates in `templates/github/ISSUE_TEMPLATE/`

### Greenfield Planning Flow (v1.3)
- Sequence: concept doc → spike(s) → prototype (optional) → PRD → epics/stories → setup.sh
- PRD written after spikes, not before — requirements written in a vacuum are fiction
- docs/concept.md written once at project start, not updated
- Spike outputs: quick → findings.md (F-xxx), substantial → docs/spikes/<issue>-<slug>.md

### GitHub Issue Discipline
- All work starts with an open GitHub issue using the correct template
- pre-commit-guard blocks commits if issue doesn't exist or is closed
- Chore exception: branches named `chore/` bypass issue requirement
- Issues enriched before closing — structured comment with what was done, ADR/AB refs, skill updated
- Closed issues become queryable context — `gh issue view N` gives full lifecycle record
- Story/bug retirement checklist must be completed before closing

### Pre-Release Guard (v1.3 update)
- Now accepts a list of story/bug issue numbers: `bash pre-release-guard.sh 88 89 90`
- Checks each issue is closed and retirement checklist is complete
- Warns if issue type is epic/spike/investigation (wrong release unit)
- Old behaviour (fragment assembly, version file checks) preserved alongside new checks

### GitHub Issue Discipline
- All work starts with an open GitHub issue
- pre-commit-guard blocks commits if issue doesn't exist or is closed
- Chore exception: branches named `chore/` bypass issue requirement
- Issues are enriched before closing — structured comment with what was done, ADR/AB refs, skill updated
- Closed issues become queryable context — `gh issue view N` gives full lifecycle record

### Version Files Config
- `.claude/version-files` lists all files containing version numbers per project
- pre-release-guard reads this file instead of hardcoded locations

### User Documentation
- Declared in `.claude/release-artifacts` as `user-docs: false` or `user-docs: <path>`
- Enforced when set — pre-release-guard checks the file was modified

### Never Cycle / Never Guess / Always Verify Rules
- Derived from RTheyOk. Standard for all projects.
- Never cycle: if something fails twice with same approach, STOP. State what failed, propose different approach.
- Never guess: check docs or ls first. Read code before assuming endpoints.
- Always verify: run verification command after every deployment action.

### Two-Environment Table
- Required in CLAUDE.md for any project with dev + production environments
- "Before every remote command: state which environment and why"

### BMAD Attribution
- Process skills (BA Analyst, PM, Scrum Master) and greenfield planning flow inspired by BMAD Method (Brian Goff)
- Hook enforcement, tier system, document taxonomy, and issue hierarchy are original to this workflow
- Attribution in README.md Acknowledgements section

---

## Project Inventory (Post-Retrofit v1.3 — v1.3 propagation pending)

### HA_Home — v1.3 ✓
- **Mode:** worktree | **Context weight:** Heavy | **Skills:** 7 domain
- **Skills:** cameras-frigate, dashboard-kiosk, energy-system, network-infra, pir-lighting, pool-heating, release-workflow
- **v1.3 pending:** issue templates, 3 process skills, updated pre-release-guard

### Scores4Streams V2 — v1.3 ✓
- **Mode:** main | **Context weight:** Medium | **Skills:** 8 domain
- **v1.3 pending:** issue templates, 3 process skills, updated pre-release-guard

### Edge Hunter (NRL) — v1.3 ✓
- **Mode:** worktree | **Context weight:** Medium | **Skills:** 9 domain
- **Skills:** betting-workflow, collaboration, dashboard-ui, deployment, help-guide, model-engine, multi-sport, multi-tenant, notifications
- **v1.3 pending:** issue templates, 3 process skills, updated pre-release-guard

### R They OK — v1.3 ✓
- **Mode:** main | **Context weight:** Light | **Skills:** 4 domain
- **Skills:** baseline-engine, ha-addon, sensor-pairing, deployment
- **v1.3 pending:** issue templates, 3 process skills, updated pre-release-guard

### Thunkit Factory (Game Studio) — v1.3 ✓
- **Mode:** main | **Context weight:** Medium | **Multi-persona:** Susi (Art Director) + Alex (Lead Dev)
- **Skills:** art-direction, codecks-ops, engineering, game-design
- **Note:** [producer] is Game Designer — Claude fills Susi + Alex only. Codecks MCP integration.
- **v1.3 pending:** issue templates, 3 process skills, updated pre-release-guard

---

## Retrofit Learnings (accumulated v1.0 → v1.3)

1. **Skill count varies wildly** — RTheyOK needed 4, NRL needed 9. Don't force a number.
2. **Chore fragments used immediately** — `0-chore-roadmap-and-skills.md` validated the escape hatch.
3. **Roadmap as Tier 2** — RTheyOK added `docs/roadmap.md` to context-files. Useful for milestone-driven projects.
4. **ADR renumbering not needed** — no project benefited. Keep existing numbering schemes.
5. **Existing sessions don't pick up new hooks** — must start a new session after retrofit.
6. **GitHub issues are already story files** — structured issue templates replace the need for separate story doc files.
7. **PRD should follow spikes, not precede them** — requirements written before technical validation are often wrong.
8. **Process skills need to be in-project** — SM skill needs domain skill context to write accurate story constraints.

---

## Known Open Items

1. **v1.3 propagation** — all five projects need Prompt B (issue templates + process skills + updated guard)
2. **Skill auto-triggering at scale** — process skills haven't been tested across all projects yet
3. **Epic/story workflow validation** — issue hierarchy designed but not yet used in a live project cycle

---

## Reference

Full standard: `standards/claude-workflow-standards-v3.md` (v1.3)
This brief: `standards/bootstrap-session-brief.md`
Retrofit plans: `plans/retrofit-*.md`
Prompts: `prompts/new-project-starter.md`, `prompts/retrofit-existing-starter.md`
Guide: `guides/how-to-guide.md`
