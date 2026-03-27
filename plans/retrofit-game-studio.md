# Retrofit: Thunkit Factory (Game Studio) to Workflow Standard v1.2

**Status: COMPLETED** — 2026-03-23

## Project Overview

Thunkit Factory is a simulated game development studio giving [artist] (junior artist) real-world production experience. Unlike the other four projects, this one has:

- **Two AI personas** (Susi/Art Director, Alex/Lead Dev) posting to Codecks as separate users
- **An external human team member** ([artist]) who interacts only through Codecks and GitHub Desktop
- **A browser fallback requirement** — Codecks API can write comments but can't read them
- **Three tokens** that expire independently and require manual browser refresh per-profile

The standard needs a **multi-persona extension** for this project.

## Role Clarification

| Role | Who | Codecks Account | How |
|------|-----|----------------|-----|
| Producer + Game Designer | [producer] | [producer-username] | Direct — decides scope, priorities, design |
| Art Director | Claude AI | Susi | `role: "susi"` — briefs, reviews, feedback |
| Lead Dev | Claude AI | Alex | `role: "alex"` — engineering cards, integration |
| Artist | [artist] | [artist-username] | Codecks + art tools only, never Claude Code |

**Note:** CLAUDE.md currently lists Game Designer as a Claude role. This should be corrected — [producer] is the Game Designer. Claude executes design decisions, doesn't make them.

## Value Case

### What the standard prevents
- **Token amnesia** — after compaction, Claude forgets which browser profile maps to which token. A skill fixes this.
- **Role confusion** — posting as the wrong persona (Susi posting engineering cards, Alex giving art feedback). A skill with explicit role-action mapping prevents this.
- **Cold starts** — every session currently starts from scratch. SessionStart hook prints board state, `_TO_UNREAL/` status, and token health.
- **[artist] getting inconsistent feedback** — if Claude forgets the feedback principles (lead with what works, be objective, push for rough-ins), [artist] gets confusing direction. A skill ensures the art-direction context is loaded for every review.
- **Lost design decisions** — DD-001 to DD-009 exist but nothing enforces reading them. They're already in ADR-like format.

### What the standard adds
- **Predictable session starts** — Codecks board state + `_TO_UNREAL/` check + token reminder
- **Domain-specific context** — art review sessions load art-direction skill, engineering sessions load UE5 skill
- **Guard rails** — commit discipline, changelog fragments, release workflow
- **MEMORY.md** — single lookup for all IDs, tokens, API quirks, file paths

## Current State (Verified 2026-03-23)

| Component | Status |
|-----------|--------|
| CLAUDE.md | Exists, comprehensive (217 lines) — needs role correction |
| ARCHITECTURE.md | Exists at `Docs/Technical/ARCHITECTURE.md` (195 lines) |
| DESIGN_DECISIONS.md | Exists (DD-001 to DD-009) — already ADR-like format |
| MEMORY.md | **Missing** |
| CHANGELOG.md | **Missing** |
| as-built.md | **Missing** |
| findings.md | **Missing** |
| assumptions.md | **Missing** |
| release_workflow.md | **Missing** |
| MILLIE_BRIEF.md | Exists (49 lines) |
| GAME_CONCEPT.md | Exists |
| SessionStart hook | **Missing** |
| PreToolUse hooks | **Missing** |
| .claude/settings.json | **Missing** (only settings.local.json with permission sprawl) |
| .claude/workflow-mode | **Missing** |
| .claude/context-files | **Missing** |
| .claude/version-files | **Missing** |
| .claude/release-artifacts | **Missing** |
| .changelog/ | **Missing** |
| .claude/skills/ | **Missing** |
| .claude/hooks/ | **Missing** |

## Steps

### Phase 1: Foundation (this session or next)

1. [x] Correct CLAUDE.md — [producer] is Game Designer, not Claude. Claude fills Susi + Alex only.
2. [x] Create `MEMORY.md` — user IDs, token locations, browser profile mapping, API quirks, key file paths
3. [x] Create `CHANGELOG.md` — retroactive entries from 5 existing commits
4. [x] Create `.claude/workflow-mode` with `main` (no worktree enforcement needed yet)
5. [x] Create `.claude/context-files` (see proposed list below)
6. [x] Create `.claude/settings.json` with SessionStart + PreToolUse hooks
7. [x] Create `.claude/hooks/context-recovery.sh` — reads context-files, checks Codecks connectivity, checks `_TO_UNREAL/`
8. [x] Create `.claude/hooks/pre-commit-guard.sh`
9. [x] Create `.claude/hooks/pre-pr-guard.sh`
10. [x] Create `.claude/hooks/pre-release-guard.sh`
11. [x] Create `.changelog/README.md`
12. [x] Clean up `settings.local.json` — remove stale curl permissions from debugging

### Phase 2: Knowledge Structure

13. [x] Rename `DESIGN_DECISIONS.md` to follow standard — DD-xxx is fine (keep existing numbering)
14. [x] Create `docs/findings.md` — extract from ARCHITECTURE.md (DD-009 comment API limitation is a finding, not a decision)
15. [x] Create `docs/assumptions.md` — e.g., "Git LFS not yet configured — assuming binary assets stay small for now"
16. [x] Move ARCHITECTURE.md to root or create root-level pointer (standard expects root ARCHITECTURE.md)

### Phase 3: Topic Skills (separate session)

17. [x] Bootstrap topic skills using standard prompt (see proposed skills below)
18. [x] Test auto-triggering — give an art review task without mentioning the skill
19. [x] Test auto-triggering — give an engineering task without mentioning the skill
20. [x] Verify role switching works correctly with skill-loaded context

### Phase 4: Multi-Persona Extension

21. [x] Add `studio-mode` section to CLAUDE.md or as a skill — documents role-action mapping
22. [x] Create a `codecks-ops.md` skill that includes token refresh procedure, browser profile mapping, and API limitations
23. [x] Test: start fresh session, ask to review [artist]'s art — should load art-direction skill, post as Susi

## Proposed `.claude/context-files`

```
# Thunkit Factory Tier 2 — Medium weight
# Loads studio identity, system map, and current board state
CLAUDE.md
MEMORY.md
Docs/Technical/ARCHITECTURE.md
gh issue list --state open --limit 20
```

**Why these 4:**
- CLAUDE.md — roles, [artist]'s profile, card format, communication style (essential every session)
- MEMORY.md — IDs, tokens, paths (lookup table, prevents guessing)
- ARCHITECTURE.md — system components, API capabilities, data flow
- gh issues — what's in flight

**Not in Tier 2:**
- DESIGN_DECISIONS.md — loaded via skill when making new decisions
- MILLIE_BRIEF.md — loaded via art-direction skill when reviewing art
- GAME_CONCEPT.md — loaded via skill when doing design work
- ArtBriefs/*.md — loaded per-task

## Proposed Topic Skills

| Skill | Key Context | Auto-trigger Keywords |
|-------|------------|----------------------|
| `art-direction.md` | MILLIE_BRIEF.md, DD-003, DD-006, DD-008, feedback principles, pipeline gates, style guide status, current art cards | review, art, [artist], brief, feedback, Susi, blockout, concept, texture, asset, Island, style guide, portfolio |
| `codecks-ops.md` | Token management, browser profiles, API capabilities/limits, role switching, DD-002, DD-004, DD-009 | Codecks, card, token, 401, 403, Susi post, Alex post, role, API, comment, conversation, board |
| `engineering.md` | UE5 setup status, asset integration path, _TO_UNREAL mailbox, file naming conventions, DD-001, DD-007 | Unreal, UE5, Blueprint, C++, import, integrate, FBX, collision, LOD, _TO_UNREAL |
| `game-design.md` | GAME_CONCEPT.md, DD-003 (style from [artist]), DD-005 (tool decisions are hers), DD-006 (smaller tasks), island breakdown | Sky Lands, island, feature, gameplay, design, scope, concept, level |

## Multi-Persona Extension (Standard Addition)

This is new territory for the workflow standard. The pattern:

### Role-Action Mapping (goes in codecks-ops skill or CLAUDE.md)

```
| Action | Post as | Why |
|--------|---------|-----|
| Art brief | Susi | Art Director sets the brief |
| Art review / feedback | Susi | Art Director reviews deliverables |
| Engineering card | Alex | Lead Dev owns technical tasks |
| Integration update | Alex | Lead Dev does the integration |
| Design decision | [producer] | Producer/Designer decides scope |
| Card assignment to [artist] | Susi | Art Director assigns art work |
| Board management | [producer] | Producer manages the board |
```

### Token Health Check (goes in context-recovery.sh)

The SessionStart hook should attempt a lightweight Codecks API call (e.g., list projects) and report:
- [producer] token: OK / EXPIRED
- Susi token: OK / EXPIRED
- Alex token: OK / EXPIRED

If any token is expired, print the refresh procedure before allowing work to proceed.

### Browser Fallback Protocol

When Claude needs to read [artist]'s comments:
1. Use Chrome MCP to navigate to the card URL
2. Read the conversation thread
3. Summarise what [artist] said
4. Respond as appropriate persona via API

This should be documented in the codecks-ops skill.

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Token check at session start fails (all expired) | Hook prints refresh procedure clearly. Dad refreshes before continuing. |
| settings.local.json curl permissions conflict with new settings.json | Clean up stale permissions in Phase 1 step 12 |
| ARCHITECTURE.md not at root level | Create root-level pointer or move it. Standard expects root ARCHITECTURE.md for Tier 2 loading. |
| Codecks MCP server not running | SessionStart hook should detect and warn, not block |
| [artist] sees AI-generated content in repo | CLAUDE.md, skills, hooks are in `.claude/` (gitignored by default). Review `.gitignore` to confirm. |
| Chrome MCP not available in all sessions | codecks-ops skill documents fallback: ask Dad to copy-paste comment text |

## What This Does NOT Change

- [artist]'s workflow — she still uses only Codecks, GitHub Desktop, and her art tools
- The art pipeline — 10 steps with blockout hard gate stays as-is
- Codecks board structure — decks, journeys, spaces stay as configured
- The studio simulation — Susi and Alex remain the two AI personas

## Estimated Effort

- Phase 1 (Foundation): One session — install hooks, create MEMORY.md, CHANGELOG.md, clean up permissions
- Phase 2 (Knowledge): Same session or next — findings.md, assumptions.md, ARCHITECTURE.md location
- Phase 3 (Skills): Separate session — bootstrap 4 skills, test auto-triggering
- Phase 4 (Multi-persona): Fold into Phase 3 or separate — token health check, role-action mapping

Total: 2 sessions. Lighter than HA_Home, heavier than RTheyOK.
