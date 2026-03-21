---
name: "dev:write-prd"
description: "Create a Product Requirements Document through structured interview and codebase exploration. Use when defining a new feature, project, or significant change before implementation."
---

# Write PRD

Create a PRD through interview, codebase exploration, and module design.

## Process

### Step 1: Get the Description

Ask for a short description of the feature or project. If already provided, proceed.

### Step 2: Explore the Repository

Explore the codebase to understand:

- Project structure, conventions, and patterns
- Existing code relevant to the feature
- Technical constraints and integration points

### Step 3: Interview

Grill the user on every aspect of the feature. For each question:

- Provide your recommended answer based on codebase exploration
- If a question can be answered by the codebase, answer it yourself
- Resolve dependencies between decisions before moving forward

### Step 4: Sketch Modules

Design the implementation using **deep modules** (small, simple interfaces hiding large, complex implementations):

- Define module boundaries and interfaces
- Keep interfaces minimal — push complexity into implementation
- Identify shared abstractions

Do NOT include file paths — they change. Describe modules by responsibility.

### Step 5: Write the PRD

## PRD Template

```markdown
# PRD: [Title]

## Problem Statement

[What problem does this solve? Why now?]

## Solution

[High-level approach. Reference the deep modules designed in Step 4.]

## User Stories

- As a [user], I want [goal] so that [reason]

## Implementation Decisions

[Key technical decisions made during the interview, with reasoning.]

## Testing Decisions

[Testing strategy — what to test, what not to test, and why.]

## Out of Scope

[Explicitly excluded items to prevent scope creep.]
```

## Output

By default, create as a **GitHub issue** using `gh issue create`.

If the user prefers local storage, save to `./plans/prd-[slug].md` instead.

For BAI projects, consider using **Linear** as an alternative to GitHub issues.

### Step 6: Review

Dispatch the **prd-reviewer** agent with the PRD content.

- If **Approved**: proceed (offer `dev:prd-to-plan` as next step)
- If **Issues Found**: address the issues, then re-dispatch the reviewer
- Max 3 review iterations — if still unresolved, escalate to the user for a decision
