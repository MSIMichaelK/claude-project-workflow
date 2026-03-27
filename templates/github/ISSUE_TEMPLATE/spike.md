---
name: Spike
about: Time-boxed exploration to answer a specific question or validate an approach.
labels: spike
---

## Question to Answer <!-- required -->
<!-- The specific, answerable question this spike exists to resolve.
     Even "no" or "not yet" is a valid answer.

     Bad:  "explore the undo system"
     Good: "can we implement undo without breaking the Firestore transaction model (AB-001)?" -->

## Time Box <!-- required -->
<!-- Maximum effort before stopping and documenting what was learned, regardless of outcome.
     e.g. 2 hours, 1 session, half a day -->

## Context
<!-- What triggered this spike — link to epic, issue, concept.md, or discussion -->

## Approach
<!-- How we'll explore this: prototype, read docs, benchmark, test assumption, proof of concept -->

## Output <!-- required -->
<!-- What this spike will produce and where it lives:
     - Quick finding → findings.md as F-xxx entry
     - Substantial approach → docs/spikes/<issue-number>-<slug>.md
     - Architecture decision → input to ADR in ARCHITECTURE.md
     - Project-start approach → docs/concept.md -->
Output location:

## Definition of Done <!-- required -->
- [ ] Question answered (or documented as unanswerable within time box)
- [ ] Output at location above
- [ ] Triggering epic or issue updated with findings
- [ ] Follow-on stories or spikes created if applicable
