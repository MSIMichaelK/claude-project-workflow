# Claude Project Workflow

> Deterministic context recovery, decision durability, and release integrity for AI-assisted development.

---

## The Problem

AI coding assistants lose context. A session that started with full knowledge of your architecture compacts, restarts, or switches worktrees — and suddenly Claude re-derives decisions that were already made, contradicts established design choices, or introduces regressions it would have avoided if it had read the right files.

This isn't a Claude-specific problem. Every AI coding assistant has it. The question is whether you have a system to fight it.

This repo is that system.

---

## What It Does

Five things, in order of importance:

**1. Forces context recovery at every session start**
A `SessionStart` hook fires automatically — even after compaction — and prints a mandatory checklist. Claude must cite a specific fact from each required file before doing any work. Claiming to have read something isn't enough.

**2. Prevents commits, PRs, and releases from bypassing quality gates**
`PreToolUse` hooks intercept `git commit`, `gh pr create`, and `git tag`. No commit without an open issue. No PR without a changelog fragment. No release without checklist completion.

**3. Organises project knowledge into the right documents**
A clear taxonomy: `CLAUDE.md` for session rules, `ARCHITECTURE.md` for system decisions, `MEMORY.md` for fast lookup, `as-built.md` for implementation history. Each document has one job. Nothing bleeds between them.

**4. Scales context to what each task actually needs**
Three tiers: always-loaded (CLAUDE.md), every-session (configurable per project), and per-task (topic skills). More context is not better context — the goal is the right information at the right time.

**5. Structures planning before building**
A greenfield flow and process skills (BA Analyst, Product Manager, Scrum Master) borrow the best of structured planning methodology without the overhead of a full framework.

**Full technical reference:** [`standards/claude-workflow-standards-v3.md`](standards/claude-workflow-standards-v3.md) — the complete standard including all hook implementations, configuration reference, and setup instructions.

---

## What's in the Box

```
standards/
  claude-workflow-standards-v3.md   Complete workflow standard (current: v1.3)

templates/
  CLAUDE.md                         Session rules template
  ARCHITECTURE.md                   System map template
  MEMORY.md                         Fast-lookup template
  CHANGELOG.md                      Release history template
  as-built.md                       Implementation decisions template
  concept.md                        Initial concept doc (new project kickoff)
  beliefs-and-tests.md              Investigation journal template
  github/ISSUE_TEMPLATE/            Issue templates (epic, story, spike, investigation, bug, chore)
  skills/
    process-ba-analyst.md           Business Analyst persona skill
    process-product-manager.md      Product Manager persona skill
    process-scrum-master.md         Scrum Master persona skill

hooks/
  context-recovery.sh               SessionStart hook template
  pre-release-guard.sh              Release gate hook template
  settings.json                     Hook configuration template

prompts/
  new-project-starter.md            First-session prompt for new projects
  retrofit-existing-starter.md      First-session prompt for retrofitting existing projects

guides/
  how-to-guide.md                   Plain-language usage guide

plans/
  retrofit-*.md                     Completed retrofit plans (HA_Home, NRL, Scores4Streams, RTheyOK, Game Studio)

setup.sh                            Scaffolding script for new projects
```

---

## How It Works

### The Three-Tier Context Model

```
Tier 1 — Always loaded
  CLAUDE.md: session rules, hard constraints, common mistakes
  Read automatically at every session start
  Keep to 1–2 pages. Do not bloat it.

Tier 2 — Every session
  Files declared in .claude/context-files
  Loaded by SessionStart hook via proof checklist
  Default: ARCHITECTURE.md + MEMORY.md + open issues
  Add files when incidents prove they're needed

Tier 3 — Per task
  Topic skills: domain navigators pointing to relevant ADRs, AB entries, findings
  Process skills: planning personas (BA, PM, Scrum Master)
  Loaded explicitly at task start
  ~300–800 tokens each — load only what the task requires
```

### The Hook Architecture

```
SessionStart
  └── context-recovery.sh     Tier 2 loading + proof gate + Tier 3 hint from branch name

PreToolUse (Bash)
  ├── pre-commit-guard.sh     Intercepts: git commit — requires open issue + changelog fragment
  ├── pre-pr-guard.sh         Intercepts: gh pr create — requires fragment + checklist
  └── pre-release-guard.sh    Intercepts: git tag — accepts issue list, checks each is closed
```

Exit codes: `0` = allow, `2` = block with message.

### The Document Taxonomy

| Document | Role | Updated when |
|---|---|---|
| `CLAUDE.md` | Session rules, enforcement, common mistakes | Rarely — only when the rules change |
| `ARCHITECTURE.md` | ADR-xxx decisions, system structure, tech stack | Each release |
| `MEMORY.md` | Entity names, config values, key files, versions | Each release |
| `docs/as-built.md` | AB-xxx entries — implementation decisions and why | Each feature |
| `docs/findings.md` | F-xxx entries — permanent operational gotchas | When something fails in a non-obvious way |
| `docs/assumptions.md` | A-xxx entries — unverified assumptions with test plans | When assumptions are raised or resolved |
| `docs/beliefs-and-tests.md` | B-xxx entries — active investigation journal | For empirical/sensor/model projects |
| `docs/requirements.md` | PRD — functional requirements, NFRs, epics | At project inception, when scope shifts |
| `docs/concept.md` | Initial idea, rough scope, constraints, open questions | Once, at project start |

### The Issue Hierarchy

Work is structured in six issue types, each with its own template:

| Type | Purpose | Release unit? |
|---|---|---|
| **Epic** | Strategic container for a capability — spans multiple sprints | No — stays open until capability is delivered |
| **Story** | Single unit of independently releasable work | Yes — the primary release unit |
| **Spike** | Time-boxed exploration to answer a specific question | No — produces an output, not a release |
| **Investigation** | Open-ended problem exploration — anchors to findings.md | No |
| **Bug** | Something is broken | Yes |
| **Chore** | Maintenance with no user-facing value | Patch only |

**Epic → Story relationship:** Use `- [ ] #number` format in the epic's Stories section. GitHub auto-checks the item when the referenced issue closes — no manual maintenance required.

**Release model:** A release is an explicit curation of closed stories and bugs. It is not triggered by epic completion. Minor/major releases reference the epic(s) they advance; patch releases can stand alone.

---

## The Greenfield Flow

For new projects, run this sequence before writing any code:

```
1. Concept doc (docs/concept.md)
   Capture the idea, target users, rough scope, out-of-scope, constraints.
   Use the process-ba-analyst skill to guide this.

2. Spike(s)
   Time-boxed technical validation. Does the approach work?
   Output: findings.md entry or docs/spikes/<issue>-<slug>.md

3. Prototype (optional)
   Rough build to prove the spike findings hold at scale.

4. PRD (docs/requirements.md)
   First scope attempt — informed by the spike, not written blind.
   Use the process-product-manager skill to guide this.

5. Epics and stories
   Translate PRD features into GitHub epics and stories.
   Use the process-scrum-master skill to break epics into well-formed stories.

6. Normal workflow
   setup.sh → skills → development cycle
```

For brownfield projects, skip to step 5 or 6 depending on how much planning has already been done informally.

---

## Getting Started

### New project

```bash
# Scaffold the project
./setup.sh --name "My Project" --dir ~/path/to/project

# Optional: include investigation journal
./setup.sh --name "My Project" --dir ~/path/to/project --investigations

# Then in Claude Code, use the new project starter prompt:
# prompts/new-project-starter.md
```

### Existing project (retrofit)

Use `prompts/retrofit-existing-starter.md` as your first message in a Claude Code session inside the project. It guides Claude through reading existing docs, identifying gaps, and installing the standard without overwriting anything.

### What setup.sh creates

```
CLAUDE.md                           Session rules
ARCHITECTURE.md                     System map
MEMORY.md                           Fast-lookup table
CHANGELOG.md                        Release history
docs/as-built.md                    Implementation decisions
.claude/
  settings.json                     SessionStart hook config
  workflow-mode                     "worktree" or "main"
  context-files                     Tier 2 file list
  hooks/
    context-recovery.sh             SessionStart hook (customise per project)
    pre-commit-guard.sh             Commit gate
    pre-pr-guard.sh                 PR gate
    pre-release-guard.sh            Release gate
.changelog/README.md                Fragment format guide
.github/ISSUE_TEMPLATE/             Issue templates (copied from this repo)
```

---

## Claude-Specific vs. Tool-Agnostic

**Claude Code-specific:**
- `CLAUDE.md` filename (Claude Code's project instruction convention)
- `.claude/` directory structure (skills, context-files, hooks)
- SessionStart and PreToolUse hook system
- Skill auto-triggering via description matching

**Tool-agnostic (works with Cursor, Windsurf, Copilot, or no AI tool):**
- Document taxonomy (ARCHITECTURE.md, MEMORY.md, as-built.md, findings.md)
- Issue hierarchy and GitHub templates
- Three-tier context loading concept
- Greenfield planning flow
- Changelog fragment pattern
- ADR/AB decision taxonomy

The underlying problem — AI losing context, making contradictory decisions, re-introducing regressions — is not Claude-specific. The enforcement hooks are Claude Code-specific; the methodology is not.

> **Using a different tool?** The document taxonomy, issue hierarchy, and planning flow work with any AI assistant. Implement equivalent enforcement via your tool's project instruction mechanism and standard git hooks.

---

## Projects Using This Workflow

All five projects below were retrofitted to v1.2 in March 2026. Each produced patterns that shaped the standard.

| Project | Domain | Key patterns contributed |
|---|---|---|
| HA_Home | Home automation (HA Yellow, Zigbee, Modbus) | Proof-gate checklist, worktree mode, beliefs-and-tests |
| NRL_Bet_Model | Sports betting model (Python, Firestore, Pi) | 66-decision ARCHITECTURE.md, pre-release version guard |
| Scores4Streams | Baseball scoring app (React, Firestore) | Clean skill boundaries, AB regression prevention |
| RTheyOK | Home monitoring add-on (Python, HA OS) | findings.md, assumptions.md, two-environment table |
| Thunkit Factory | Game studio sim (UE5, Codecks) | Multi-persona extension (Art Director + Lead Dev AI personas) |

---

## Acknowledgements

The **process skills** (BA Analyst, Product Manager, Scrum Master) and the **greenfield planning flow** (concept doc → spike → PRD before architecture) are inspired by the [BMAD Method](https://github.com/bmad-method/bmad-method) by Brian Goff. BMAD structures AI-assisted development around named personas producing formal artifacts in sequence. We borrow the structured planning persona concept and the principle of formalising requirements before committing to architecture.

The enforcement model, three-tier context system, hook architecture, document taxonomy, and issue hierarchy are original to this workflow, derived from real incidents across the five projects above.

---

## Licence

MIT
