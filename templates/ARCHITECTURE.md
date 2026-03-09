# ARCHITECTURE.md — System Map

> Version: 0.1.0 | Last updated: YYYY-MM-DD

## Overview

[1-2 sentences: what this project does and why it exists.]

## System Diagram

```
[ASCII diagram showing major components, data flows, and external services.
Keep it readable — this is the first thing a new session sees.]
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | |
| Backend | |
| Database | |
| Testing | |
| Deployment | |

## Project Structure

```
project-root/
├── CLAUDE.md                    # Session rules and enforcement
├── ARCHITECTURE.md              # This file — system map
├── MEMORY.md                    # Quick-reference lookup
├── CHANGELOG.md                 # Release history
├── docs/
│   ├── as-built.md              # Design decisions journal
│   └── beliefs-and-tests.md     # Investigation journal (if applicable)
├── .claude/
│   ├── settings.json            # SessionStart hook config
│   ├── hooks/
│   │   └── context-recovery.sh  # Mandatory context recovery script
│   └── worktree-prompt-template.md
└── src/                         # [Expand with your project structure]
```

## Data Flows

[Describe the key data flows through the system. Use ASCII diagrams or numbered steps.]

```
1. User does X
   │
2. Component A processes it:
   ├── Writes to Database B
   └── Notifies Service C
   │
3. Service C updates D
```

## Configuration

[Key config files, environment variables, secrets (names only, not values).]

## Documentation Map

| Document | Purpose | When to Read |
|----------|---------|-------------|
| `CLAUDE.md` | Session rules, enforcement | Every session start |
| `ARCHITECTURE.md` | System map, data flow | Understanding what exists |
| `MEMORY.md` | Quick lookup | Need a specific name or value |
| `docs/as-built.md` | Design decisions | Before changing core logic |
| `CHANGELOG.md` | Release history | Before version bumping |
