# Starter Prompt — New Project

> **This template has been superseded by `prompts/new-project-starter.md`**
>
> Use that file for the full guided setup — it covers greenfield planning flow,
> infrastructure, issue templates, process skills, and verification.

---

## Quick Version

If you just want a minimal first-message prompt after running setup.sh, use this.
For the full guided setup, use `prompts/new-project-starter.md` instead.

---

## Project: [PROJECT NAME]

### What this project does
[1-3 sentences: what it does, who it's for, why it exists]

### Tech stack
- **Frontend:** [e.g., React + Vite]
- **Backend:** [e.g., Firebase, Express]
- **Database:** [e.g., Firestore, SQLite]
- **Deployment:** [e.g., Firebase Hosting, Raspberry Pi]

### What exists so far
[Greenfield? Scaffold? Existing code from another tool?]

### Greenfield planning — done?
- [ ] `docs/concept.md` written (use process-ba-analyst skill)
- [ ] Spike(s) completed
- [ ] `docs/requirements.md` written (use process-product-manager skill)
- [ ] Epic and story issues created (use process-scrum-master skill)

If not done yet — do the planning phases first before setting up the project.
See `prompts/new-project-starter.md` for the full guided flow.

### Project workflow
This project uses the Claude Project Workflow Standard v1.3.

**First task:** Read CLAUDE.md, then help me fill in ARCHITECTURE.md and MEMORY.md
based on what we're building. After that, we'll start on the first story issue.
