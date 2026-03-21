---
name: "dev:refactor-plan"
description: "Plan a refactor as a sequence of tiny, safe commits with a structured issue template. Use when a refactor spans multiple files or needs team alignment before starting."
---

# Refactor Planning

Structured refactoring plans following Martin Fowler's principle: _"Make each refactoring step as small as possible, so that you can always see the program working."_

## Process

### 1. Get Description

Ask the user what they want to refactor and why. Understand the pain point.

### 2. Explore the Repo

Read the relevant code. Understand the current structure, dependencies, and call sites. Use LSP (`findReferences`, `incomingCalls`) to map the blast radius.

### 3. Consider Alternatives

Before committing to the refactor, ask: is there a simpler approach? Could a different abstraction avoid the refactor entirely?

### 4. Interview

Ask clarifying questions:

- What's the desired end state?
- Are there parts of the codebase that should NOT be touched?
- What's the testing situation?
- Timeline / urgency?

### 5. Hammer Scope

Ruthlessly cut scope. A refactor plan that tries to do everything will do nothing. Define what's explicitly **out of scope**.

### 6. Check Test Coverage

Assess existing test coverage for the affected code. Note gaps that need filling BEFORE refactoring begins.

### 7. Break into Tiny Commits

Each commit must:

- Leave the codebase in a working state (tests pass, app runs)
- Be independently reviewable
- Have a clear, semantic commit message

### 8. Create Issue

Write the issue using the template below. Create on **GitHub** or **Linear** (Linear for BAI projects).

## Issue Template

```markdown
## Problem Statement

Why this refactor is needed. What pain it causes today.

## Solution

High-level approach. No file paths or code snippets — they go stale.

## Commits

Ordered list of tiny steps. Each leaves the codebase working.

1. Rename X concept to Y for clarity
2. Extract shared logic into a dedicated module
3. Update all call sites to use new module
4. Remove old code path
5. Update tests to reflect new structure

## Decision Document

Key decisions and their rationale. Link to ADRs if they exist.

## Testing Decisions

- What needs new tests before refactoring starts
- What tests need updating after
- Manual verification steps if applicable

## Out of Scope

Explicitly list what this refactor does NOT touch.
```

## Rules

- **No file paths or code snippets in the issue** — they go stale fast. Describe intent, not location.
- **Every commit must pass CI** — if a step can't be atomic, break it down further.
- **Don't implement** — this skill produces a plan, not code.
