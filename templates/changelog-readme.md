# Changelog Fragments

Each worktree writes its release notes here as a separate file. This prevents merge conflicts — each worktree writes to its own file, never touching CHANGELOG.md directly.

## How it works

1. **Worktree creates a fragment** when it's ready to release:
   ```
   .changelog/<issue>-<slug>.md
   ```
   Example: `.changelog/86-pool-pump-solar.md`

2. **Fragment format:**
   ```markdown
   ### Added
   - **Feature name** (#issue) — description

   ### Fixed
   - **Bug name** (#issue) — description

   ### Changed
   - Description of change

   ### Discovered
   - **Finding** (#issue) — description
   ```
   Use only the sections you need. Follow [Keep a Changelog](https://keepachangelog.com/) format.

3. **Assembly** happens at release time on main (after PR merges):
   - Read all fragments in `.changelog/`
   - Create a new CHANGELOG.md entry with the next version number
   - Update version in all docs (CLAUDE.md, ARCHITECTURE.md, MEMORY.md, etc.)
   - Delete assembled fragments
   - Tag, push, create GitHub release

## Rules

- **Worktrees NEVER edit:** CHANGELOG.md, version numbers, version history tables
- **Worktrees CAN edit:** as-built.md (append new AB-xxx), ARCHITECTURE.md system diagram (if adding hardware), MEMORY.md entity lists (if adding entities)
- **Fragment filenames** must be unique — use issue number as prefix
- **One fragment per worktree** — combine all changes into a single file
