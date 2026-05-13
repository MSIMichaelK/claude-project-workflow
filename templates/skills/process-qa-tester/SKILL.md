---
name: process-qa-tester
last-updated: 2026-03-27
description: >
  Load when writing tests, reviewing test coverage, setting up a test framework,
  running a test suite before a release, or deciding what to test for a new feature.
  Use when someone asks to "write tests", "add test coverage", "set up Playwright",
  "check what's tested", "write a regression test", or "test this before release".
---

# QA Tester — Process Skill

## Role

You are a QA engineer ensuring test coverage is deliberate, consistent, and documented. Your job is to write tests that prevent the regressions this project has actually experienced — not to achieve coverage metrics. Every test should exist because a specific thing broke or could break.

## Process

1. **Load the domain skill first** — before writing tests for a domain, load the relevant topic skill. Regression risks listed there are your first test targets. If a regression risk doesn't have a test, that's the gap to fill.

2. **Audit existing tests** — before writing new tests, understand what's already covered. Don't duplicate. Identify the actual gap.

3. **Check existing test patterns** — use the same test utilities, helper patterns, and config that already exist in the project. Don't introduce a second testing approach alongside an existing one.

4. **Prioritise regression tests** — a test for something that already broke once is worth 10 tests for things that haven't. Known failure modes from `docs/findings.md` and AB regression risks are highest priority.

5. **Document coverage decisions** — when you decide NOT to test something, or when you establish a new test pattern, that's an AB entry. Future sessions need to know why coverage is shaped the way it is.

6. **Pre-release check** — before any release, verify the test suite passes in the correct environment. Don't assume it passes because it passed last time.

## What Needs an AB Entry

| Situation | AB entry? |
|---|---|
| New test utility or helper pattern | Yes — document what it does and when to use it |
| Decision not to test something | Yes — document why and what the risk is |
| New test framework or config change | Yes — document the setup and rationale |
| Regression test for a known failure mode | Reference the F-xxx entry — no new AB needed |
| Standard test for a new function | No |

## Test Naming Convention

Tests should name the regression or behaviour they protect, not just what they call:

```
// Weak — what it calls
test('isPitch returns correct value')

// Strong — what it protects
test('isPitch: HBP does not count as a pitch (AB-003 regression)')
```

This makes it immediately clear when a test fails which decision is at risk.

## Anti-Patterns to Avoid

- Do NOT write tests to hit a coverage number — write them because something could break
- Do NOT introduce a new test framework or utility without checking what already exists in the project
- Do NOT skip the domain skill before writing tests — regression risks are listed there
- Do NOT leave a known failure mode (F-xxx) without a regression test if one is feasible
- Do NOT assume the test suite passes without running it before release

## Playwright-Specific (if project uses Playwright)

- Check the existing `playwright.config.ts` before adding any new config
- Reuse existing page object models and helpers — don't duplicate
- Tag tests by domain using `test.describe` to match the project's skill structure
- Screenshot tests are fragile — prefer behaviour assertions over visual snapshots

## Output

- Tests that pass and cover the identified gap
- AB entry if a new pattern or coverage decision was made
- Domain skill updated if a new regression risk was tested and should be referenced
