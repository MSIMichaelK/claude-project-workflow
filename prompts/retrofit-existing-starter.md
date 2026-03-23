# Retrofit Existing Project Starter Prompt

> Copy-paste this into a Claude Code session in the project to be retrofitted.
> Adapt the project-specific sections before pasting.

---

## Prompt

```
Retrofit this project to the Claude workflow standard v1.2.

Read these in order:
1. ~/Documents/GitHub/claude-project-workflow/standards/claude-workflow-standards-v3.md
2. ~/Documents/GitHub/claude-project-workflow/plans/retrofit-<project>.md

The retrofit plan has the specific steps, proposed context-files, and proposed
topic skills for this project. Follow it.

### Before changing anything

1. Read all existing docs in this project:
   - CLAUDE.md
   - ARCHITECTURE.md
   - MEMORY.md (if exists)
   - docs/as-built.md (or as_built.md)
   - docs/findings.md (if exists)
   - docs/assumptions.md (if exists)
   - CHANGELOG.md
   - Any other docs listed in the project's documentation map

2. Read the existing hooks:
   - .claude/settings.json (if exists)
   - .claude/hooks/context-recovery.sh (if exists)
   - .git/hooks/pre-commit (if exists — must be preserved)

3. Post a pre-retrofit checklist showing:
   - What exists vs what needs to be created
   - Any conflicts between existing setup and the standard
   - What will change vs what stays the same

Wait for my approval before making any changes.

### Infrastructure phase

Follow the steps in the retrofit plan. For each step:
- Create or update the file
- Show me what was created/changed
- Mark the step complete

Key rules:
- Do NOT replace existing context-recovery.sh — update it to read from
  .claude/context-files while preserving all project-specific content
  (incidents, standing rules, dev commands)
- Do NOT touch .git/hooks/ — those are git hooks, separate from Claude hooks
- Do NOT modify existing doc content — only add new files and new config files
- Do NOT create topic skills in this session — that's a separate session

### New documents

When creating findings.md, assumptions.md, or other new docs:
- Extract content from CLAUDE.md, as-built.md, and session memory
- Use the entry formats from the standard (F-xxx, A-xxx, etc.)
- Post the proposed content for review before writing

### Verification

After all infrastructure is in place:
- Run context-recovery.sh and confirm it reads from .claude/context-files
- Attempt a git commit without a changelog fragment — confirm it's blocked
- If worktree mode: attempt a commit on main — confirm it's blocked
- Show me the final .claude/ directory tree

### What NOT to do in this session

- Do NOT bootstrap topic skills — use the separate bootstrap prompt for that
- Do NOT renumber ADR/AB entries — that's a separate session (especially for NRL)
- Do NOT modify functional code, config, or automations
- Do NOT trim CLAUDE.md yet — that happens after skills exist to absorb the detail
```

---

## After Retrofit: Topic Skills Bootstrap

In a separate session after the infrastructure is verified, use the topic skills
bootstrap prompt from the standard:

```
Bootstrap topic skills for this project.

Read in order:
1. ARCHITECTURE.md
2. docs/as-built.md (or equivalent)
3. CLAUDE.md
4. docs/findings.md (if exists)
5. docs/assumptions.md (if exists)
6. CHANGELOG.md
7. gh issue list --state closed --limit 100

Then:
- Identify 3-6 natural domain clusters in the accumulated decisions
- Post proposed domain list first — wait for approval before writing files
- For each approved domain, draft .claude/skills/<domain>.md navigator:
  - YAML frontmatter with name and precise auto-trigger description
  - ADR references from ARCHITECTURE.md
  - AB references from as-built.md
  - Findings references (F-xxx) if any
  - Open assumptions relevant to this domain
  - 3-5 most relevant closed issue numbers
  - Regression risks specific to this domain
- Test description quality: would it auto-trigger from a task description
  mentioning only natural language terms for this domain?
```
