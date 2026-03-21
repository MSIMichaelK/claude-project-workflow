# New Project Starter Prompt

> Copy-paste this into a Claude Code session in your new project directory.
> It bootstraps the workflow standard from scratch.

---

## Prompt

```
Set up this project with the Claude workflow standard v1.1.

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

### 2. Create infrastructure

After I answer, create these files:

```
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
    └── pre-release-guard.sh   # From standard

.changelog/
└── README.md                  # Fragment format reference
```

Use the hook scripts from the standard document. Customise context-recovery.sh:
- Replace placeholder standing rules with project-specific rules
- Replace placeholder past failures with "None yet — this section grows from real incidents"

### 3. Create core docs

```
CLAUDE.md                      # Session rules — include hard rules (never cycle, never guess, always verify)
ARCHITECTURE.md                # System diagram, tech stack, file structure
MEMORY.md                      # Entity names, config values, key files
CHANGELOG.md                   # Start with ## [0.1.0] - YYYY-MM-DD
docs/as-built.md               # Empty — "No AB entries yet"
docs/release_workflow.md        # Release process for this project
```

If the project has dev + production environments, add the two-environment table to CLAUDE.md.

### 4. Create optional docs (ask me which apply)

- docs/findings.md              # If hardware, deployment, or integration complexity
- docs/assumptions.md           # Recommended for all projects
- docs/beliefs-and-tests.md     # If empirical investigation (sensors, models, data)
- docs/requirements.md          # If product with external users

### 5. Scaffold topic skills

For each domain area I listed, create a skeleton skill navigator:

```
.claude/skills/<domain>.md
```

With YAML frontmatter (name + description for auto-triggering) and empty sections for:
- Architecture Decisions
- Implementation Decisions
- Known Failure Modes
- Issue History
- Regression Risks

These will be populated as the project accumulates decisions.

### 6. Verify

- Run context-recovery.sh manually and confirm it prints the checklist
- Attempt a git commit without a changelog fragment — confirm it's blocked
- Show me the final file tree

Post the complete file list when done so I can review before committing.
```
