# Phase 2: Propose

## When to use

Medium+ scope work that benefits from planning before code. Triggered by me invoking `/dev:flow propose` or `/opsx:propose`.

## BAI Auto-Detection

If repo path contains `black-atom-industries`, load Linear context. Create Linear issues instead of GitHub issues when breaking down work.

## Core Principle

Design before code. The level of ceremony matches the scope — don't over-plan a small feature, don't under-plan a system redesign.

## Steps

### 1. Detect OpenSpec

Check if `openspec/` exists in project root.

- **Present**: Use OpenSpec workflow (steps 2-6)
- **Absent**: Offer `dev:setup:openspec`. If declined, use PRD fallback (step 7)

### 2. Explore the codebase

Understand before proposing: project structure, conventions, existing code relevant to the change, integration points, existing specs in `openspec/specs/` that may be affected.

### 3. Interview

Grill me on every aspect of the change:

- Provide your recommended answer for each question based on codebase exploration
- If a question can be answered by the codebase, answer it yourself
- Resolve dependencies between decisions before moving forward
- For refactors: consider alternatives first, ruthlessly cut scope, define what's explicitly out of scope, check test coverage before planning changes

### 4. Write artifacts (OpenSpec path)

1. Run `openspec new change "<slug>"` to scaffold
2. Run `openspec instructions proposal --change "<slug>"` for template
3. Write `proposal.md` — what and why
4. Write `design.md` — how (architecture decisions, trade-offs, risks)
5. Write `specs/<capability>/spec.md` for each capability using ADDED/MODIFIED/REMOVED delta headers. Each requirement needs at least one `#### Scenario:` with WHEN/THEN
6. Run `openspec validate <change-name>` — fix any errors before review

### 5. Plan tasks

Break the approved proposal into vertical slices (not horizontal layers):

- Each task delivers a working, testable increment through ALL layers
- Each builds on the previous task
- Each is small enough for one session
- Write to `openspec/changes/<name>/tasks.md` with numbered checkboxes
- For fallback: save to `./plans/plan-<slug>.md`
- For large scope: use `dev:prd-to-issues` to create GitHub/Linear issues with HITL/AFK classification and dependency ordering

### 6. Review gates

Dispatch review agents (max 3 iterations each):

1. **prd-reviewer** — validates proposal.md + design.md
2. **plan-reviewer** — validates tasks against proposal

If still unresolved after 3 iterations, escalate to me.

### 7. PRD fallback (no OpenSpec)

Same interview process, then write a PRD with: Problem Statement, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope. Output as GitHub issue, Linear issue, or local `./plans/prd-<slug>.md`.

## Transition to Phase 3

Proposal approved and tasks written. I move to `/dev:flow build` or `opsx:apply`. Claude never auto-transitions.
