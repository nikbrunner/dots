---
name: "dev:propose"
description: "Propose a change through structured interview and codebase exploration. Produces OpenSpec artifacts (proposal.md, design.md, specs/) when available, or falls back to PRD format. Use when defining a new feature, project, or significant change before implementation."
---

# Propose

Propose a change through interview, codebase exploration, and module design.

## Step 1: Detect OpenSpec

Check if `openspec/` directory exists in the project root.

- **If present**: Use OpenSpec workflow (Steps 2-7)
- **If absent**: Offer `dev:openspec-init` to bootstrap. If declined, fall back to PRD workflow (see [Fallback](#fallback-prd-workflow))

## Step 2: Get the Description

Ask for a short description of the change. If already provided, proceed.

## Step 3: Explore the Repository

Explore the codebase to understand:

- Project structure, conventions, and patterns
- Existing code relevant to the change
- Technical constraints and integration points
- Existing specs in `openspec/specs/` that may be affected

## Step 4: Interview

Grill the user on every aspect of the change. For each question:

- Provide your recommended answer based on codebase exploration
- If a question can be answered by the codebase, answer it yourself
- Resolve dependencies between decisions before moving forward

## Step 5: Scaffold and Write Artifacts

1. Run `openspec new change "<slug>"` to create the change directory
2. Use `openspec instructions proposal --change "<slug>"` for the template
3. Write `proposal.md` — what and why (problem, changes, capabilities, impact)
4. Write `design.md` — how (context, goals, decisions, risks, migration)
5. Write `specs/<capability>/spec.md` for each new or modified capability
   - Use ADDED/MODIFIED/REMOVED delta headers
   - Each requirement MUST have at least one `#### Scenario:` with WHEN/THEN

## Step 6: Validate

Run `openspec validate <change-name>` for structural compliance.

- If errors: fix them before proceeding
- If clean: proceed to content review

## Step 7: Review

Dispatch the **prd-reviewer** agent with proposal.md + design.md.

- If **Approved**: proceed (offer `dev:plan-tasks` as next step)
- If **Issues Found**: address the issues, then re-dispatch the reviewer
- Max 3 review iterations — if still unresolved, escalate to the user

## Fallback: PRD Workflow

When OpenSpec is not available and user declined initialization:

1. Follow the same interview process (Steps 2-4)
2. Design deep modules (small interfaces, large implementations)
3. Write a PRD using the template below
4. Output as GitHub issue (`gh issue create`), Linear issue, or local `./plans/prd-<slug>.md`
5. Dispatch prd-reviewer, then offer `dev:plan-tasks`

### PRD Template

```markdown
# PRD: [Title]

## Problem Statement
[What problem does this solve? Why now?]

## Solution
[High-level approach.]

## User Stories
- As a [user], I want [goal] so that [reason]

## Implementation Decisions
[Key technical decisions with reasoning.]

## Testing Decisions
[Testing strategy.]

## Out of Scope
[Explicitly excluded items.]
```
