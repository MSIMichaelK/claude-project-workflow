# Retrofit: Scores4Streams V2 to Workflow Standard v1.1

## Value Case

Scores4Streams has the cleanest domain boundaries and the most mature AB entries (AB-001 to AB-011), making it the ideal first retrofit:

- **isPitch regression risk** — AB-003 was nearly re-broken in a later session. A topic skill pointing to `isPitch: true` rules and the regression test file would have prevented this.
- **Duplicate work** — scoring mode split was partially re-planned by a session that didn't know it was done. Issue discipline + enriched closing makes closed issues queryable context.
- **HBP/walk force-advance** — AB-004 has been fixed in both handlers. A skill pointing to the regression test (`walkForceAdvance.test.js`) makes this discoverable.
- **No release workflow friction** — main-mode project, no worktree enforcement, straightforward fragment flow.

### What the standard prevents (specific to this project)
- Re-planning work that's already done (enriched issue closing)
- Modifying scoring logic without knowing the AB entry (topic skills)
- Releasing without version consistency across files
- Worktree-related divergence (mode=main, worktree warning stays in context-recovery incidents)

## Current State (Verified 2026-03-21)

| Component | Status |
|-----------|--------|
| CLAUDE.md | Exists, comprehensive (101 lines) |
| ARCHITECTURE.md | Exists, detailed (223 lines) |
| MEMORY.md | Exists |
| as-built.md | Exists (AB-001 to AB-011) |
| CHANGELOG.md | Exists |
| requirements.md | Exists at `src/Doco/Requirements.md` |
| findings.md | **Missing** |
| assumptions.md | **Missing** |
| release_workflow.md | **Missing** (release info is in CLAUDE.md) |
| SessionStart hook | Installed (context-recovery.sh, 5-file checklist) |
| PreToolUse hooks | **None** |
| .claude/workflow-mode | **Missing** |
| .claude/context-files | **Missing** |
| .claude/version-files | **Missing** |
| .claude/release-artifacts | **Missing** |
| .changelog/ | **Missing** |
| .claude/skills/ | **Missing** |

## Steps

1. [ ] Create `.claude/workflow-mode` with `main`
2. [ ] Create `.claude/context-files` (see proposed list below)
3. [ ] Create `.claude/version-files` — identify all version-bearing files (MEMORY.md, CHANGELOG.md, package.json?)
4. [ ] Create `.claude/release-artifacts` with `user-docs: false`
5. [ ] Create `.changelog/` directory with `README.md`
6. [ ] Install `pre-commit-guard.sh` in `.claude/hooks/`
7. [ ] Install `pre-pr-guard.sh` in `.claude/hooks/`
8. [ ] Install `pre-release-guard.sh` in `.claude/hooks/`
9. [ ] Update `settings.json` to add PreToolUse hooks
10. [ ] Update `context-recovery.sh` to read from `.claude/context-files`
11. [ ] Create `docs/findings.md` — extract any operational gotchas (isPitch regression, worktree divergence incidents)
12. [ ] Create `docs/assumptions.md` — surface from requirements.md and open issues
13. [ ] Create `docs/release_workflow.md` — extract from CLAUDE.md into standalone file
14. [ ] Add hard rules to CLAUDE.md (never cycle, never guess, always verify)
15. [ ] Bootstrap topic skills (separate session — use bootstrap prompt)
16. [ ] Test auto-triggering of each skill
17. [ ] Verify pre-commit-guard with test commit (should require fragment + issue)
18. [ ] Verify pre-release-guard with dry-run tag

## Proposed `.claude/context-files`

```
# Scores4Streams Tier 2 — matches current 5-file recovery
ARCHITECTURE.md
MEMORY.md
docs/as-built.md       # AB-003 isPitch regression when skipped
CHANGELOG.md
gh-issues
```

This matches the current context-recovery.sh checklist exactly. No change in weight — just formalised in a config file.

## Proposed Topic Skills

| Skill | Key References | Auto-trigger Keywords |
|-------|---------------|----------------------|
| `batting-engine.md` | AB-003, AB-004, AB-005, AB-006, AB-007, AB-009 | isPitch, strikeout, out, hit, walk, HBP, force-advance, DP, FC, sac fly, scoringEngine.js |
| `data-model.md` | AB-001, AB-002, AB-011 | Firestore, games, events, dual-write, aggregate, subcollection, pending, commit, undo |
| `scoring-modes.md` | AB-008 | simple, advanced, scoringMode, gate, GameCreationForm |
| `undo-system.md` | AB-011 | undo, redo, soft-delete, undone, useGameEvents |

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Worktree warning must stay in context-recovery despite mode=main | Keep it in the PAST FAILURES section of context-recovery.sh — it's an incident note, not enforcement |
| Version files unclear — where does the version live? | Audit: CLAUDE.md line 78 says "bump version in MEMORY.md and CHANGELOG.md". Check package.json too. |
| No release_workflow.md exists as separate file | Create one during retrofit, extracting from CLAUDE.md |
| Firebase credentials in settings | Not affected by hooks — hooks don't touch .env or firebase config |

## Estimated Effort

One session for infrastructure (steps 1-14). Separate session for topic skills (steps 15-16). Testing (steps 17-18) inline. This is the smallest retrofit of the four.
