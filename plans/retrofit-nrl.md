# Retrofit: Edge Hunter (NRL) to Workflow Standard v1.1

## Value Case

NRL has the most mature codebase (~8,600 lines) and the most design decisions (66), but they're unnumbered — making them invisible to topic skills:

- **Context loss after compaction** — AFL planning (#96) required full codebase re-exploration because session compaction lost all prior exploration. Topic skills would have pointed directly to relevant decisions.
- **stake=0 crash (v1.20.1)** — Market Edge vs Override Edge distinction was forgotten between sessions. A betting-model skill pointing to the relevant decision would surface this every time the model is touched.
- **Vote threshold bug (v1.20.4)** — voting system context lost between sessions. A ui-voting skill with the `_apply_suggestion` timing note prevents this.
- **Cron wrap (v1.19.1)** — Pi cron limitation re-discovered. This is a textbook finding (F-xxx) — once recorded, never repeated.
- **Pre-commit auto-version** — the existing `.git/hooks/pre-commit` is valuable and must be preserved. The standard's PreToolUse guard operates at a different layer (Claude hook, not git hook) so there's no conflict.

### What the standard prevents (specific to this project)
- Losing context about the 66 design decisions after compaction (skills as navigators)
- Re-discovering operational gotchas that should be in findings.md
- Committing without an issue (the project already has good issue discipline — guard enforces it)
- Releasing without updating the Help tab (user-docs enforcement)

## Current State (Verified 2026-03-21)

| Component | Status |
|-----------|--------|
| CLAUDE.md | Exists, comprehensive (146 lines) |
| ARCHITECTURE.md | Exists, large (66 decisions in generic table, not ADR-xxx) |
| MEMORY.md | Exists |
| CHANGELOG.md | Exists |
| release_workflow.md | In CLAUDE.md (Release Checklist section) |
| as-built.md | **Missing** |
| findings.md | **Missing** |
| assumptions.md | **Missing** |
| SessionStart hook | Installed (context-recovery.sh, 4-file checklist + standing rules) |
| PreToolUse hooks | **None** |
| Git pre-commit hook | Exists — auto-increments patch version in dashboard.py |
| .claude/workflow-mode | **Missing** |
| .claude/context-files | **Missing** |
| .claude/version-files | **Missing** (version in dashboard.py line 7: `__version__ = "1.20.6"`) |
| .claude/release-artifacts | **Missing** |
| .changelog/ | **Missing** |
| .claude/skills/ | **Missing** |

## Steps

### Phase 1: Infrastructure (one session)

1. [ ] Create `.claude/workflow-mode` with `worktree`
2. [ ] Create `.claude/context-files` (see proposed list below)
3. [ ] Create `.claude/version-files` with `dashboard.py`
4. [ ] Create `.claude/release-artifacts` with `user-docs: dashboard.py`
5. [ ] Create `.changelog/` directory with `README.md`
6. [ ] Install `pre-commit-guard.sh` in `.claude/hooks/`
7. [ ] Install `pre-pr-guard.sh` in `.claude/hooks/`
8. [ ] Install `pre-release-guard.sh` in `.claude/hooks/`
9. [ ] Update `settings.json` to add PreToolUse hooks
10. [ ] Update `context-recovery.sh` to read from `.claude/context-files`
11. [ ] Create `docs/as-built.md` — extract implementation decisions from ARCHITECTURE.md that are AB-level, not ADR-level
12. [ ] Create `docs/findings.md` — cron wrap, stake=0 crash, vote threshold timing
13. [ ] Create `docs/assumptions.md` — surface from open issues
14. [ ] Add hard rules to CLAUDE.md (never cycle, never guess, always verify)
15. [ ] Verify pre-commit-guard coexists with git auto-version hook (test commit)
16. [ ] Verify pre-release-guard with dry-run tag

### Phase 2: ADR Renumbering (one session)

17. [ ] Read all 66 decisions in ARCHITECTURE.md
18. [ ] Apply ADR test to each: "would reversing this require rearchitecting?"
19. [ ] ADR-level decisions: renumber as ADR-001 through ADR-xxx
20. [ ] AB-level decisions: move to docs/as-built.md as AB-001 through AB-xxx
21. [ ] Verify no other files reference old decision numbers
22. [ ] Update ARCHITECTURE.md version and date

### Phase 3: Topic Skills (one session)

23. [ ] Bootstrap topic skills using standard prompt
24. [ ] Test auto-triggering of each skill
25. [ ] Verify skills reference correct ADR/AB numbers from Phase 2

## Proposed `.claude/context-files`

```
# NRL Tier 2 — standard weight
ARCHITECTURE.md       # 66 design decisions (ADR-xxx after renumbering)
MEMORY.md             # Config values, dev commands, Pi paths
CHANGELOG.md          # Recent releases, current version
gh-issues
```

Standard weight — 4 items. The current context-recovery.sh has exactly these 4. Once topic skills exist, domain-specific decisions are loaded via Tier 3 rather than requiring the full ARCHITECTURE.md scan.

## Proposed Topic Skills

| Skill | Key References | Auto-trigger Keywords |
|-------|---------------|----------------------|
| `betting-model.md` | ADR decisions on model, override edge, market edge, rest adjustment | model, edge, override, probability, bankroll, margin, stake, odds |
| `odds-pipeline.md` | ADR on pre-game cutoff, round assignment, outcome_name | fetch, odds, API, round, pregame, bookmaker, the-odds-api |
| `deployment.md` | Pi deploy, two-directory setup, cron, Cloudflare, infra/ | deploy, Pi, Raspberry, cron, tunnel, Cloudflare, infra, setup |
| `ui-voting.md` | Vote threshold, apply_suggestion, collab, suggestions | vote, voting, suggest, collab, threshold, feedback |

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Git pre-commit hook vs Claude pre-commit-guard confusion | Document clearly: git hook is `.git/hooks/pre-commit` (auto-version). Claude guard is `.claude/hooks/pre-commit-guard.sh` (PreToolUse). Different layers, no conflict. |
| ADR renumbering (Phase 2) could break references | Grep entire repo for old decision numbers before renumbering. Do in one session. |
| 66 decisions — some ambiguous ADR vs AB classification | Apply the test honestly. When ambiguous, lean ADR (the consequences of missing an ADR in a skill are worse than miscategorising an AB). |
| `feature/rebrand` branch exists with v1.21.0 | Retrofit on main. Rebrand branch merges after Round 2 per CLAUDE.md. Skills will need updating after merge. |

## Estimated Effort

Three sessions: infrastructure (Phase 1), ADR renumbering (Phase 2), topic skills (Phase 3). Phase 2 is the most time-consuming due to 66 decisions to classify.
