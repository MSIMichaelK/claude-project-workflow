# Standard v2 — Design Decisions Log

**Created:** 2026-05-12 | **Status:** Framework decisions captured; full standard not yet written

## Purpose

Captures the foundational framework decisions made during the 2026-05-12 design conversation, before they decay from working memory. This is not the standard itself — that's a separate writing task. This is the rationale a future writing session needs so it doesn't re-derive every decision from scratch.

Pattern is the F-034 lesson (KFO `docs/findings.md`) applied to design work: pin decision-useful content to disk before it evaporates.

## Origin and motivation

The 2026-05-12 KFO workflow degradation triage (KFO #130, #131, #132) surfaced that `claude-project-workflow` v1.5 is under-prescribed for heavier projects.

The NRL audit (Edge Hunter, ran 2026-05-12) found six independently-invented mechanisms across NRL and KFO that the standard doesn't document: structured F-xxx findings format, four-way docs split (investigations/spikes/audits/retros), 2-job CI with browser-cache + memory snapshot, PR-type → e2e-coverage table, Healthchecks cron-ping monitoring, AST-based widget-key detector with three-layer defence pattern.

The S4S V2 audit (ran 2026-05-12) validated the framework against a smaller-shape project and confirmed convergent signals — same latent skill-format bug as NRL, GH Projects created-then-abandoned on both NRL and S4S, permission-allowlist sprawl across the fleet.

These signals were not idiosyncratic. The standard needs structural change, not just documentation refresh.

## Decisions

### 1. Structural fix, not doc-quality fix

**Call:** the standard's shape changes to absorb what NRL + KFO + HA_Home have learned. This is not a doc refresh of v1.5; it's a v2 with new sections.

**Reasoning:** the audits surfaced six independently-invented mechanisms the standard doesn't document. Documentation cleanup can't paper over the absence of (e.g.) a CI template — that's a missing section, not a stale paragraph.

**Rejected alternative:** "doc-quality only" — just refresh README v1.3→v1.5, fix examples, prune flat-format references. Rejected because the under-prescription is genuinely structural; doc work alone leaves NRL and KFO continuing to invent their own mechanisms locally.

### 2. Pattern + recipe discipline

**Call:** every profile section names a **pattern** first (universal: "pipeline projects need monitoring on cron entry points"), then a **recipe** as a worked example (MK-specific: "Healthchecks.io with these URLs"). Anyone using the standard substitutes their own recipe for the pattern.

**Reasoning:** addresses the "becomes MK-shaped, hard to share with others" risk. Lets the standard grow structurally to absorb MK's projects' learnings while staying shareable.

**Rejected alternative:** ship MK's recipes as the standard directly. Would tie adoption to specific tools (Healthchecks, Tailscale, M1 worker), making it personal infrastructure rather than a reusable framework.

### 3. Axis: project nature, not weight

**Call:** profiles split along project **nature** (what the project DOES — pipeline / UI / docs-rich / remote-ops) not **weight** (Light / Medium / Heavy).

**Reasoning:** weight is downstream of nature. A pipeline project IS heavy because pipelines need monitoring + scheduling + remote dispatch. Naming the cause tells you *which* patterns apply, not just *how many*.

**Rejected alternative:** weight (Light/Medium/Heavy), which maps to the existing retrofit table at `claude-workflow-standards-v3.md:1683`. Easier to classify but says nothing about *what* to install.

### 4. Composition, not flat presets

**Call:** a small `core` standard + opt-in profiles that compose freely. KFO = core + pipeline + docs-rich + remote-ops. NRL = core + pipeline + ui + docs-rich. Etc.

**Reasoning:**
- Convergent invention across NRL+KFO (both built cron-ping, both built structured findings) is exactly what composition handles. Pattern lives once, both projects opt in.
- The 6 existing projects already map to 4+ distinct compositions — flat presets would have to fork into many bundles or pick which projects get approximated.
- Future-proof if new profile dimensions emerge (e.g. Codex compat from cluster B).

**Rejected alternative:** flat presets (named bundles like `kfo-shape`, `nrl-shape`, `light-app`). Simpler retrofit but produces drift as the standard grows — adding +Codex would mean updating every preset.

**Cost accepted:** retrofit asks "which profiles" instead of "which preset" — ~30 extra seconds per project. Mitigation: smart defaults (picking +pipeline suggests +remote-ops too).

### 5. Core = mechanics + process skills

**Call:** `core` includes both:
- **Mechanics:** worktree-vs-main, hook proof gate, pre-commit/pre-pr/pre-release guards, changelog fragments, CLAUDE.md skeleton, ARCHITECTURE.md skeleton, basic findings.md
- **Process skills:** BA Analyst, PM, Scrum Master, UX Designer, QA Tester

**Reasoning:** process skills are cheap to ship and discoverable. Even unused they document the personas the workflow expects. The cost of including them universally is low; the cost of operators not knowing they exist is high.

**Rejected alternative:** strip core to mechanics only, move process skills into a `+planning-personas` profile. Logical (NRL never invokes them; spikes don't need a BA Analyst) but loses the discoverability benefit.

### 6. Profile set: four opt-in profiles

**Call:** four profiles, separately composable:

| Profile | When |
|---|---|
| `+pipeline` | Data extraction / transform / scheduled jobs |
| `+ui` | Interactive UI, e2e tests |
| `+docs-rich` | investigations/spikes/audits/retros split, structured F-xxx findings |
| `+remote-ops` | Healthchecks cron-ping, M1-worker pattern, secrets handling |

**Composition matrix (validated across the fleet):**

| Project | Composition |
|---|---|
| KFO | core + pipeline + docs-rich + remote-ops |
| NRL (Edge Hunter) | core + pipeline + ui + docs-rich |
| HA_Home | core + ui + remote-ops |
| S4S V2 | core + ui |
| R They OK | core only |
| Thunkit Factory | core only |

**Rejected alternative 1:** merge +remote-ops into +pipeline. Correlated but not identical — HA_Home has +remote-ops without +pipeline. Keeping separate respects HA_Home's actual shape; the cost of an unused profile is low.

**Rejected alternative 2:** add a `+strategy-light` profile for S4S's roadmap/monetization/positioning docs. Those are project-specific content, not workflow patterns. The standard shouldn't systematise per-project strategy artefacts.

## Evidence base

### NRL_Bet_Model (Edge Hunter) audit — 2026-05-12

Six independently-invented mechanisms the standard doesn't document:

1. Structured F-xxx findings (Date / Affects / Finding / Impact template)
2. Four-way docs split (investigations / spikes / audits / retros)
3. 2-job CI template (pytest + Playwright e2e, browser-cache keyed on requirements-dev, before/after memory snapshots, diagnostic-bundle upload on failure)
4. #491 Layer 1 e2e coverage policy — PR-type → required-test-addition table in PR/issue templates
5. Healthchecks.io cron-ping monitoring + per-script credit-budget table in MEMORY.md
6. AST-based widget-key detector + AB-047 three-layer defence pattern

"Not quite right" surface on NRL itself: AB-047 cascade (3 releases to fully grep one bug class), xfail open since 2026-05-06, 5 open `priority:now`/`priority:next` infra items on e2e/smoke, two parallel test-discipline mechanisms doing similar work, 495-line `.claude/settings.local.json`.

Latent bug: NRL still uses flat `<name>.md` skills AND the hook still globs `*.md` — both bugs cancel out, but the moment skills migrate, KFO's F-040 symptom appears.

Key files: `~/Documents/GitHub/NRL_Bet_Model/.claude/`, `.github/workflows/ci.yml`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/`, `CLAUDE.md:138-153`, `tests/e2e/conftest.py`, `tests/test_dashboard_widget_keys.py`, `docs/findings.md`, `docs/as-built.md` AB-040..AB-048.

### Scores4Streams V2 audit — 2026-05-12

Validated the framework — S4S maps cleanly to `core + ui` with no new profile needed.

S4S-specific patterns flagged for later consideration: "Critical Facts" CLAUDE.md block (`CLAUDE.md:35-58`), `release-artifacts` config-file convention, F-002-backed work-on-main rationale.

Convergent signals: same latent skill-format bug as NRL; GH Projects created-then-abandoned on both projects; permission-allowlist sprawl (`.claude/settings.local.json` has 9 near-identical `node -e "const lock = require..."` entries); `.claude/worktrees/` directory exists despite `workflow-mode = main` (contradiction).

S4S is three standard versions behind ("v1.2 retrofitted — v1.3+v1.4+v1.5 update pending").

## What's NOT yet decided

### Design questions for the v2 writeup session

- **AB-047 audit-completeness rule** — when an audit fixes a bug class, the standard could prescribe a completeness check (the AB-047 cascade across v1.48.17 / .18 / .19 suggests narrow-audit risk is real). Standard-level discipline or NRL-specific? Convergent signals from S4S strengthen the lift case.
- **Where shared bits live** — three profiles all want the structured findings format. Does each profile carry its own copy, or do they reference a shared section? Affects whether `standards/` becomes a directory of fragments vs one file.
- **GH Projects discipline** — both NRL and S4S have GH Projects created-then-abandoned. MK confirmed NRL uses GH Projects actively. The standard should take a position: prescribe usage with a maintenance discipline, or explicitly not recommend it. Not just "use it or don't".
- **Profile content details** — the section-by-section authoring of each profile (what specifically goes in +pipeline, +ui, etc.) is the bulk of the writing work.
- **Codex support (Q5 from cluster B)** — affects whether SKILL.md format is locked to Claude Code's convention or abstracted. Stacks orthogonally on the profile axis.

### Operator-facing health checks (candidate discipline lifts)

Surfaced from convergent "not quite right" signals across NRL + KFO + S4S:

- Pruning `.claude/settings.local.json` on a schedule (sprawl is convergent across projects)
- Auditing convergent-mechanism duplication (NRL has 2 test-discipline mechanisms; pattern likely to repeat)
- Half-built-infra detection (open `priority:now` items >2 weeks signal blocked workflow)
- Stale-branch + zombie-issue cleanup (NRL + S4S both carry old branches; S4S has 108 open issues with none on the active GH Project)
- `workflow-mode` vs filesystem-state consistency check (S4S has `.claude/worktrees/` despite `mode = main`)

### Latent migrations identified

- **NRL_Bet_Model** — flat-format skills + matching broken hook glob. Same as KFO #133 but on NRL.
- **Scores4Streams V2** — same as NRL, plus 3 standard versions behind.

## Next steps

The intended next session is the v2 writeup — author the standard itself in the chosen shape.

**Suggested order for the writeup session:**

1. Resolve the AB-047 audit-completeness question
2. Decide where shared bits live (single file vs fragments directory)
3. Resolve GH Projects discipline question (needs MK input — what's working on NRL, what's failing)
4. Write the `core` section
5. Write each profile section in turn, each starting with pattern then recipe
6. Migration guide for existing projects (covers KFO #133 + NRL latent fix + S4S full retrofit)
7. Update README.md version reference (currently v1.3, actual v1.5, target v2.0)
8. Tag v2.0-draft for review before commitment

**Pending input from MK** (deferred but tracked):

- GH Projects pattern from NRL — what's the maintenance discipline that's working there vs the abandoned-board syndrome
- S4S-invented patterns ("Critical Facts" block, `release-artifacts` config) — lift into core or leave as project-specific?
- Codex support scope (cluster B Q5)

**Independent of this work — cluster B (tooling/ops):**

- Q5: Codex + Claude Code support
- Q6: Disk permission patterns (S4S audit found 9 near-identical permission entries — pattern recurs across fleet)
- Q7: Remote control and dispatch
- Q8: M1 cupboard / tmux sessions

Cluster B runs in parallel; cluster A's v2 writeup doesn't need to wait for it.

## Related artefacts

- KFO F-040 (`~/Documents/GitHub/kronk_family_office/docs/findings.md:917`) — symptom-1 finding that surfaced the standard's under-prescription
- KFO #132 — symptom-1 investigation tracker with diagnosis summary in first comment
- KFO #133 — KFO-side hook patch (F-040 option b), pending fresh KFO session
- `claude-project-workflow` commit `d6cd23e` — symptom-1 primary fix (hook + standards code blocks), unpushed at time of decisions-log creation
- `claude-project-workflow` #3 — residual standards sweep (post-#88 flat-format references)
