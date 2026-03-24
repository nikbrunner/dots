---
name: "dev:plan-tasks"
description: "Convert an approved proposal into implementation tasks using tracer-bullet vertical slices. Reads OpenSpec artifacts when available, or falls back to PRD/plan format. Use when a proposal is approved and ready for implementation planning."
---

# Plan Tasks

Convert an approved proposal into phased implementation tasks.

## Step 1: Detect OpenSpec

Check if an active OpenSpec change exists for this work.

- **If active change**: Read proposal.md, design.md, and specs/ from `openspec/changes/<name>/`
- **If no change**: Fall back to reading a PRD (GitHub issue, Linear issue, or local file)

## Step 2: Confirm the Proposal

Locate and read the proposal artifacts. Confirm with the user that this is the correct change.

## Step 3: Explore the Codebase

Understand the current architecture relevant to the proposal:

- Existing patterns and conventions
- Integration points and dependencies
- Test infrastructure

## Step 4: Identify Durable Architectural Decisions

Extract decisions that will survive implementation:

- Module boundaries and interfaces
- Data flow patterns
- State management approach
- API contracts

## Step 5: Draft Vertical Slices

Design **tracer-bullet phases** — each phase is a vertical slice through ALL layers (UI, logic, data, tests), not a horizontal layer.

Each phase should:

- Deliver a working, testable increment
- Build on the previous phase
- Be small enough to complete in one session

## Step 6: Quiz the User

Walk through the tasks. Challenge assumptions. Adjust based on feedback.

## Step 7: Write Tasks

**OpenSpec path**: Use `openspec instructions tasks --change "<name>"` for the template. Write to `openspec/changes/<name>/tasks.md` with numbered checkbox items.

**Fallback path**: Save to `./plans/plan-<slug>.md` using the plan template below.

## Step 8: Review

Dispatch the **plan-reviewer** agent with the tasks file and proposal reference.

- If **Approved**: proceed (offer `dev:worktrees` → `dev:executing-plans` as next steps)
- If **Issues Found**: address the issues, then re-dispatch the reviewer
- Max 3 review iterations — if still unresolved, escalate to the user

## Fallback Plan Template

```markdown
# Plan: [Title]

**PRD**: [link or reference]

## Architectural Decisions

- [Decision]: [Reasoning]

## Phases

### Phase 1: [Name — the tracer bullet]

**What to build**:

- [ ] [Concrete deliverable spanning all layers]

**Acceptance criteria**:

- [ ] [Observable, testable outcome]

### Phase 2: [Name]

...
```
