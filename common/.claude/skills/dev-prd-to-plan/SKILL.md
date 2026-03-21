---
name: "dev:prd-to-plan"
description: "Convert a PRD into a phased implementation plan using tracer-bullet vertical slices. Use when a PRD is approved and ready for implementation planning."
---

# PRD to Plan

Convert an approved PRD into a phased implementation plan with vertical slices.

## Process

### Step 1: Confirm the PRD

Locate and read the PRD (GitHub issue, Linear issue, or local file). Confirm with the user that this is the correct PRD.

### Step 2: Explore the Codebase

Understand the current architecture relevant to the PRD:

- Existing patterns and conventions
- Integration points and dependencies
- Test infrastructure

### Step 3: Identify Durable Architectural Decisions

Extract decisions that will survive implementation:

- Module boundaries and interfaces
- Data flow patterns
- State management approach
- API contracts

These go at the top of the plan — they guide all phases.

### Step 4: Draft Vertical Slices

Design **tracer-bullet phases** — each phase is a vertical slice through ALL layers (UI, logic, data, tests), not a horizontal layer.

Each phase should:

- Deliver a working, testable increment
- Build on the previous phase
- Be small enough to complete in one session

Bad: "Phase 1: Set up database. Phase 2: Build API. Phase 3: Build UI."
Good: "Phase 1: Single entity end-to-end (DB + API + UI). Phase 2: Add list view. Phase 3: Add filtering."

### Step 5: Quiz the User

Walk through the plan. Challenge assumptions. Adjust based on feedback.

### Step 6: Write the Plan

Save to `./plans/plan-[slug].md`.

## Plan Template

```markdown
# Plan: [Title]

**PRD**: [link or reference]

## Architectural Decisions

- [Decision]: [Reasoning]

## Phases

### Phase 1: [Name — the tracer bullet]

**User stories addressed**: [list from PRD]

**What to build**:
- [ ] [Concrete deliverable spanning all layers]

**Acceptance criteria**:
- [ ] [Observable, testable outcome]

### Phase 2: [Name]

...
```
