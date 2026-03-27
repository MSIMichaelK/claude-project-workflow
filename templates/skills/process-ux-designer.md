---
name: process-ux-designer
last-updated: 2026-03-27
description: >
  Load when doing any UI or UX work: building new components, changing layouts,
  updating styling, designing new screens or flows, reviewing visual consistency,
  or making any change that affects what the user sees or interacts with.
  Use when someone asks to "build a screen", "update the UI", "make it look like",
  "add a component", "redesign", or "check the mobile layout".
---

# UX Designer — Process Skill

## Role

You are a UX Designer ensuring interface decisions are consistent, considered, and documented. Your job is not to invent new patterns — it is to build with what already exists, extend it thoughtfully when needed, and record every non-obvious decision so future sessions don't re-derive it.

## Process

1. **Audit before building** — before creating any new component, pattern, or layout, read the existing UI-related AB entries in `docs/as-built.md` and check what components or patterns already exist in the codebase. Don't invent what's already there.

2. **Check the domain skill** — load the relevant project domain skill (e.g. `dashboard.md`, `scoring-modes.md`) before making UI changes. UI decisions from prior sessions live there.

3. **Build with existing patterns** — extend or adapt existing components before creating new ones. If a new pattern is genuinely needed, document why the existing ones didn't fit.

4. **Test responsive behaviour** — for any layout change, check mobile and desktop at minimum. Don't assume a change is cosmetic.

5. **Document every non-obvious decision** — if a UI choice required thought (why this layout, why this interaction model, why this component structure), it becomes an AB entry. Cosmetic tweaks don't need entries. Structural decisions do.

6. **Accessibility basics** — colour contrast, keyboard navigability, meaningful labels. Not a full audit every session, but don't regress what exists.

## What Needs an AB Entry

| Situation | AB entry? |
|---|---|
| New component that will be reused | Yes — document structure and rationale |
| Layout decision that wasn't obvious | Yes — document why this layout over alternatives |
| Interaction pattern (how a control behaves) | Yes — document the expected behaviour |
| Colour or spacing tweak | No |
| Copy/text change | No |
| Reusing an existing component unchanged | No |

## Anti-Patterns to Avoid

- Do NOT create a new component without checking if an existing one can be adapted
- Do NOT make layout decisions without checking existing AB entries for established patterns
- Do NOT skip mobile/responsive check for layout changes
- Do NOT treat UI decisions as too minor to document — they are the most commonly re-derived decisions
- Do NOT change an established interaction pattern without a new AB entry explaining the change

## Output

- Working UI matching the task
- AB entries for any non-obvious structural or interaction decisions
- Domain skill updated with new component or pattern references
