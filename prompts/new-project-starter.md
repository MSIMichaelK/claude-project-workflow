# New Project Starter Prompt

> Copy-paste this into a Claude Code session in your new project directory.
> It bootstraps the workflow standard from scratch.
>
> Before using this prompt: have you completed the greenfield planning flow?
>   docs/concept.md  →  spike(s)  →  prototype (optional)  →  docs/requirements.md
> If not, consider running that first — see the BA Analyst and PM process skills.

---

## Prompt

```
Set up this project with the Claude workflow standard v1.3.

Read the standard first:
  ~/Documents/GitHub/claude-project-workflow/standards/claude-workflow-standards-v3.md

Then do the following:

### 1. Gather project info

Before creating any files, ask me:
- Project name and one-line description
- Workflow mode: worktree (all work in branches) or main (work directly on main)?
- Does this project have separate dev and production environments? If yes, what are they?
- Are there files containing version numbers that must stay in sync? List them.
- Are there user-facing docs that should be updated each release? Where?
- What are the 2-4 main domain areas of this project?
- Does a docs/concept.md or docs/requirements.md already exist? (I will read them if so)

### 2. Create infrastructure

After I answer, create these files:

.claude/
├── settings.json              # SessionStart + PreToolUse hooks
├── workflow-mode              # "worktree" or "main"
├── context-files              # Start with defaults: ARCHITECTURE.md, MEMORY.md, gh-issues
├── version-files              # Files containing version numbers
├── release-artifacts          # changelog: true, architecture: true, memory: true, user-docs: <path or false>
└── hooks/
    ├── context-recovery.sh    # From standard template — customise standing rules section
    ├── pre-commit-guard.sh    # From standard
    ├── pre-pr-guard.sh        # From standard
    └── pre-release-guard.sh   # From standard — accepts issue number list

.changelog/
└── README.md                  # Fragment format reference

.github/
└── ISSUE_TEMPLATE/            # Copy from ~/Documents/GitHub/claude-project-workflow/templates/github/ISSUE_TEMPLATE/

Use the hook scripts from the standard document. Customise context-recovery.sh:
- Replace placeholder standing rules with project-specific rules
- Replace placeholder past failures with "None yet — this section grows from real incidents"

### 3. Create core docs

CLAUDE.md                      # Session rules — include hard rules (never cycle, never guess, always verify)
ARCHITECTURE.md                # System diagram, tech stack, file structure
MEMORY.md                      # Entity names, config values, key files
CHANGELOG.md                   # Start with ## [0.1.0] - YYYY-MM-DD
docs/as-built.md               # Empty — "No AB entries yet"
docs/release_workflow.md       # Release process for this project

If docs/concept.md exists: read it and use scope/constraints to populate CLAUDE.md rules.
If docs/requirements.md exists: read it and use epics to suggest initial GitHub epic issues.

If the project has dev + production environments, add the two-environment table to CLAUDE.md.

### 4. Create optional docs (ask me which apply)

- docs/concept.md              # If not already written — use BA Analyst process skill to guide
- docs/requirements.md         # If product with external users — use PM process skill to guide
- docs/findings.md             # If hardware, deployment, or integration complexity
- docs/assumptions.md          # Recommended for all projects
- docs/beliefs-and-tests.md    # If empirical investigation (sensors, models, data)

### 5. Scaffold topic skills

For each domain area I listed, create a skeleton skill navigator:

.claude/skills/<domain>.md

With YAML frontmatter (name + description for auto-triggering) and empty sections for:
- Architecture Decisions
- Implementation Decisions
- Known Failure Modes
- Issue History
- Regression Risks

Also copy the three process skills to .claude/skills/:
  ~/Documents/GitHub/claude-project-workflow/templates/skills/process-ba-analyst.md
  ~/Documents/GitHub/claude-project-workflow/templates/skills/process-product-manager.md
  ~/Documents/GitHub/claude-project-workflow/templates/skills/process-scrum-master.md

These will be populated as the project accumulates decisions.

### 6. Verify

- Run context-recovery.sh manually and confirm it prints the checklist
- Attempt a git commit without a changelog fragment — confirm it's blocked
- Show me the final file tree

Post the complete file list when done so I can review before committing.
```

---

## Greenfield Planning Flow (run before this prompt if starting fresh)

For brand new projects, run the planning phases first — before setup.sh and before writing code:

```
Step 1 — Concept doc
  Use the BA Analyst process skill: load .claude/skills/process-ba-analyst.md
  Output: docs/concept.md

Step 2 — Spike(s)
  Create a spike issue using the spike issue template
  Output: findings.md entry (F-xxx) or docs/spikes/<number>-<slug>.md

Step 3 — Prototype (optional)
  Rough build to prove the spike findings hold

Step 4 — PRD
  Use the PM process skill: load .claude/skills/process-product-manager.md
  Input: concept.md + spike output
  Output: docs/requirements.md

Step 5 — Epics and stories
  Use the Scrum Master process skill: load .claude/skills/process-scrum-master.md
  Input: requirements.md
  Output: GitHub epic and story issues

Step 6 — Run this prompt (new project setup)
```

For brownfield projects (existing codebase), use the retrofit starter prompt instead.
