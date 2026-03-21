---
name: "dev:prd-to-issues"
description: "Convert a PRD into GitHub or Linear issues with dependency ordering and HITL/AFK classification. Use when a PRD is approved and ready to be broken into trackable work items."
---

# PRD to Issues

Convert an approved PRD into ordered, classified issues.

## Process

### Step 1: Locate the PRD

Find the PRD (GitHub issue, Linear issue, or local file). Confirm with the user.

### Step 2: Explore the Codebase

Understand existing code relevant to the PRD:

- Current patterns and conventions
- Integration points
- Test infrastructure

### Step 3: Draft Vertical Slices

Break the PRD into **vertical slices** (not horizontal layers). Each issue should cut through all relevant layers and deliver a testable increment.

### Step 4: Classify and Quiz

For each issue, classify as:

- **HITL** (Human-in-the-loop): Requires human decisions, design review, or subjective judgment during implementation
- **AFK** (Fully automatable): Can be completed by an AI agent without human intervention — clear inputs, clear outputs, mechanical work

Present the full issue list with classifications to the user. Adjust based on feedback.

### Step 5: Create Issues

Create issues **in dependency order** (blockers first) so that real issue numbers can be referenced by dependent issues.

For **GitHub** projects, use `gh issue create`.
For **BAI projects**, consider using **Linear** instead.

## Issue Template

```markdown
## Parent PRD

[Link to PRD issue]

## Classification

[HITL | AFK] — [brief reason]

## What to Build

[Concrete deliverables for this slice]

## Acceptance Criteria

- [ ] [Observable, testable outcome]

## Blocked By

- [#issue-number or "None"]

## User Stories Addressed

- [User stories from the PRD that this issue covers]
```

## Guidelines

- Keep issues small — one session of focused work
- Every issue must be independently testable
- Reference real issue numbers for blockers (this is why order matters)
- AFK issues should have zero ambiguity in acceptance criteria
