# Retrofit: R They OK to Workflow Standard v1.1

## Value Case

RTheyOK is where the hard rules (never cycle, never guess, always verify) were born — but ironically has the least infrastructure of the four projects:

- **No hooks at all** — no settings.json (only settings.local.json with empty hooks), no hooks directory. Every session relies entirely on CLAUDE.md text and developer discipline.
- **Richest investigation docs** — findings.md (operational gotchas) and assumptions.md (unverified tracker) are the most mature of any project. These become high-value Tier 2 context.
- **HA add-on gotchas** — F-001 through F-005 are hard-won lessons (Supervisor caching, two add-on paths, heredocs over SSH, JWT corruption, WebSocket-only entity renaming). An ha-addon skill pointing to all five would prevent re-discovery.
- **Two environments** — dev Docker and HA Green production. The two-environment table already exists and is well-structured.
- **Users arriving soon** — user documentation enforcement matters here more than other projects.
- **Two version files** — `baseline_engine/app.py` and `addons/rtheyok-baseline-engine/config.yaml` must stay in sync. Pre-release-guard catches mismatches.

### What the standard prevents (specific to this project)
- Repeating any of the 5 known add-on failure modes (skill navigator)
- Version mismatch between app.py and config.yaml at release (pre-release-guard)
- Shipping without user docs once enforcement begins (release-artifacts)
- Confusing dev and production environments (already handled — standard formalises it)

## Current State (Verified 2026-03-21)

| Component | Status |
|-----------|--------|
| CLAUDE.md | Exists, comprehensive (127 lines) |
| ARCHITECTURE.md | Exists, detailed (55 design decisions, 304 lines) |
| as_built.md | Exists (note: underscore, not hyphen) |
| findings.md | Exists |
| assumptions.md | Exists |
| requirements.md | Exists |
| CHANGELOG.md | Exists |
| release_workflow.md | Exists |
| workflow.md | Exists (session workflow — mandatory reading) |
| MEMORY.md | **Missing** |
| beliefs-and-tests.md | **Missing** (optional for this project) |
| SessionStart hook | **Missing entirely** — no settings.json, no hooks directory |
| PreToolUse hooks | **Missing** |
| .claude/workflow-mode | **Missing** |
| .claude/context-files | **Missing** |
| .claude/version-files | **Missing** (versions confirmed: app.py `0.19.0`, config.yaml `0.19.0`) |
| .claude/release-artifacts | **Missing** |
| .changelog/ | **Missing** |
| .claude/skills/ | **Missing** |

## Steps

### Phase 1: Infrastructure (one session)

1. [ ] Create `.claude/settings.json` with SessionStart + PreToolUse hooks
2. [ ] Create `.claude/hooks/` directory
3. [ ] Create `.claude/hooks/context-recovery.sh` customised for RTheyOK
4. [ ] Install `pre-commit-guard.sh` in `.claude/hooks/`
5. [ ] Install `pre-pr-guard.sh` in `.claude/hooks/`
6. [ ] Install `pre-release-guard.sh` in `.claude/hooks/`
7. [ ] Create `.claude/workflow-mode` with `main`
8. [ ] Create `.claude/context-files` (see proposed list below)
9. [ ] Create `.claude/version-files` with both version file paths
10. [ ] Create `.claude/release-artifacts` with `user-docs: false` (change to path at first user-facing release)
11. [ ] Create `.changelog/` directory with `README.md`
12. [ ] Create `MEMORY.md` — extract entity names, config values, key files from CLAUDE.md and ARCHITECTURE.md
13. [ ] Add hard rules to CLAUDE.md — already present (originated here), verify completeness
14. [ ] Verify pre-commit-guard with test commit
15. [ ] Verify pre-release-guard with dry-run tag

### Phase 2: Topic Skills (one session)

16. [ ] Bootstrap topic skills using standard prompt
17. [ ] Test auto-triggering of each skill
18. [ ] Verify ha-addon skill surfaces all 5 findings

### Decision: `as_built.md` naming

The file is currently `docs/as_built.md` (underscore). The standard uses `docs/as-built.md` (hyphen). Options:
- **Rename to hyphen** — consistent with standard, but breaks any existing references
- **Leave as underscore** — inconsistent but zero-risk

Recommendation: leave as underscore. Add a comment in context-files noting the naming. Consistency isn't worth the grep-and-fix risk.

## Proposed `.claude/context-files`

```
# RTheyOK Tier 2 — moderately heavy, justified by rich investigation docs
ARCHITECTURE.md                   # 55 design decisions, system diagram
docs/as_built.md                  # Current deployment state (note: underscore)
docs/findings.md                  # F-001 to F-005+ — hard-won operational gotchas
docs/assumptions.md               # Active unverified assumptions
CHANGELOG.md                      # Recent releases
gh-issues
```

6 items. Heavier than default but justified — findings.md and assumptions.md are the most mature investigation docs of any project. Skipping findings.md would risk repeating the Supervisor caching or heredoc-over-SSH mistakes.

MEMORY.md is not in Tier 2 initially because it doesn't exist yet. Add after creation if it proves useful.

## Proposed Topic Skills

| Skill | Key References | Auto-trigger Keywords |
|-------|---------------|----------------------|
| `baseline-engine.md` | Decisions 3, 11, 12, 14-18, 26-28 + AB entries | baseline, engine, compare, sleep, trends, summary, Flask, app.py, db.py |
| `ha-addon.md` | Decisions 45-49, F-001 to F-005 | addon, add-on, Supervisor, addons/, config.yaml schema, enabled_sensors, run.sh |
| `sensor-pairing.md` | Decisions 44, 48 + current deployment state | sensor, pair, Zigbee, ZHA, channel, kettle, tv, toilet, bedroom, TS011F, Lumi |
| `deployment.md` | Decisions 39-42, 52-55, F-003, F-004 | deploy, SCP, SSH, HA Green, provision, health check, backup, restore, generate_config |

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| No existing hooks infrastructure at all | Building from scratch — use standard templates directly. Less customisation risk than updating existing hooks. |
| settings.local.json exists with permissions | Don't touch it — settings.json (project-level) and settings.local.json (personal) are separate. Only create settings.json. |
| Design decisions numbered 1-55, not ADR-xxx | Unlike NRL, these are already well-structured with date and rationale. Renumber to ADR-xxx during retrofit or defer to a later session. |
| Two add-on paths confusion during hook installation | Hooks go in `.claude/hooks/`, not in the add-on paths. Document clearly. |
| User docs enforcement timing | Start with `user-docs: false`. Change to actual path when first user-facing release is cut. |

## Estimated Effort

Two sessions: infrastructure + MEMORY.md creation (Phase 1), topic skills (Phase 2). This project needs the most infrastructure work (building from scratch) but has the cleanest existing docs to reference.
