# Retrofit: HA_Home to Workflow Standard v1.1

## Value Case

HA_Home has the strongest case for the standard's guard rails:

- **6+ real incidents** from skipped context (M1 sensor regression, battery misdiagnosis, duplicate issues, conflicting configs from parallel sessions)
- **Worktree-heavy workflow** — multiple concurrent sessions touching production config and energy sensors. Fragment-based changelog prevents the merge conflicts that would inevitably hit CHANGELOG.md
- **Dense investigation domain** — energy system has 15+ beliefs, 7+ AB entries, and active tests. Topic skills turn this from "read everything" into "read what matters for this task"
- **Production risk** — SSH to HA Yellow, real energy data, real automations. Pre-commit-guard + issue discipline adds a checkpoint before changes reach production

### What the standard prevents (specific to this project)
- Committing to main without a worktree (already in CLAUDE.md as advisory — now enforced)
- Releasing without updating all version files
- Creating duplicate issues (issue search discipline)
- Forgetting to update skills after adding new AB/ADR entries

## Current State (Verified 2026-03-21)

| Component | Status |
|-----------|--------|
| CLAUDE.md | Exists, comprehensive (165 lines) |
| ARCHITECTURE.md | Exists, large (500+ lines) |
| MEMORY.md | Exists |
| as-built.md | Exists (AB-001 to AB-007) |
| energy-beliefs-and-tests.md | Exists (B-001 to B-015+) |
| CHANGELOG.md | Exists |
| release_workflow.md | Exists |
| findings.md | **Missing** |
| assumptions.md | **Missing** |
| SessionStart hook | Installed (context-recovery.sh, 8-file checklist) |
| PreToolUse hooks | **None** |
| .claude/workflow-mode | **Missing** |
| .claude/context-files | **Missing** |
| .claude/version-files | **Missing** |
| .claude/release-artifacts | **Missing** |
| .changelog/ | **Missing** |
| .claude/skills/ | **Missing** |

## Steps

1. [ ] Create `.claude/workflow-mode` with `worktree`
2. [ ] Create `.claude/context-files` (see proposed list below)
3. [ ] Create `.claude/version-files` — identify all files containing version numbers
4. [ ] Create `.claude/release-artifacts`
5. [ ] Create `.changelog/` directory with `README.md`
6. [ ] Install `pre-commit-guard.sh` in `.claude/hooks/`
7. [ ] Install `pre-pr-guard.sh` in `.claude/hooks/`
8. [ ] Install `pre-release-guard.sh` in `.claude/hooks/`
9. [ ] Update `settings.json` to add PreToolUse hooks
10. [ ] Update `context-recovery.sh` to read from `.claude/context-files` instead of hardcoded list
11. [ ] Create `docs/findings.md` — extract operational gotchas from CLAUDE.md and as-built.md
12. [ ] Create `docs/assumptions.md` — surface unverified items from CLAUDE.md, open issues
13. [ ] Add hard rules to CLAUDE.md (never cycle, never guess, always verify)
14. [ ] Bootstrap topic skills (separate session — use bootstrap prompt)
15. [ ] Test auto-triggering of each skill
16. [ ] Verify pre-commit-guard with test commit on main (should block)
17. [ ] Verify pre-commit-guard with test commit in worktree (should pass with fragment + issue)
18. [ ] Verify pre-release-guard with dry-run tag

## Proposed `.claude/context-files`

```
# HA_Home Tier 2 — heavy loading justified by 6+ incidents
# See CLAUDE.md "Why This Is Non-Negotiable" for incident list
ARCHITECTURE.md
MEMORY.md
docs/as-built.md                  # AB-001 regression when skipped
docs/energy-beliefs-and-tests.md  # B-011 presented as fact when battery was cycling
CHANGELOG.md                      # Conflicting config pushed without knowing what changed
docs/release_workflow.md           # Production access methods
gh-issues                          # Duplicate issue #106 created when #3 existed
```

This preserves the current 8-item recovery (minus the SSH config read, which is operational not context). The standard's configurable Tier 2 was specifically designed to accommodate this.

## Proposed Topic Skills

| Skill | Key References | Auto-trigger Keywords |
|-------|---------------|----------------------|
| `energy-monitoring.md` | AB-001-AB-006, B-001-B-015, energy-beliefs-and-tests.md | M1, SolarEdge, 3EM, grid, battery, phase, CT, Modbus, energy |
| `alarm-integration.md` | ARCHITECTURE.md InnerRange section, relevant issues | InnerRange, Inception, alarm, zone, panel, security |
| `pool-solar.md` | AB-008, TP-Link, pool pump, solar automation | pool, pump, solar, PoolPump, PoolSolar, KP115 |
| `dashboard.md` | Tablet config, kiosk, Lovelace, entity naming | dashboard, tablet, kiosk, Lovelace, front hall, study |

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Existing context-recovery.sh is heavily customised (150+ lines) | Update to read from context-files but keep all project-specific content (incidents, standing rules) |
| Multiple active worktrees may conflict during retrofit | Do retrofit on main, not in a worktree. Check `.claude/worktrees/` for active sessions first |
| Version files unknown — need to identify all locations | Audit: CLAUDE.md line 164 says v0.4.27, check MEMORY.md, ARCHITECTURE.md, release_workflow.md |
| Energy-beliefs-and-tests.md in Tier 2 may be too heavy | Monitor — if most sessions don't touch energy, consider moving to Tier 3 skill. Current evidence says most sessions do touch energy. |

## Estimated Effort

One session for infrastructure (steps 1-13). Separate session for topic skills (steps 14-15). Testing (steps 16-18) can be done inline.
