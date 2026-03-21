---
name: dev:executing-plans
description: "Execute an implementation plan file -- load, review, work through tasks sequentially, verify each one."
user-invocable: true
---

# Executing Plans

## Before Starting

1. Load the plan file. Read it fully.
2. Review critically -- raise concerns, contradictions, or missing details **before writing any code**.
3. Confirm the current branch. Never start implementation on `main`/`master` without explicit consent.

## Execution Loop

1. Create a task list from the plan's steps.
2. Work through tasks **sequentially** -- one at a time, fully complete before moving on.
3. Mark progress as you go (mental checklist, or update the plan file if asked).
4. After completing each task, invoke `dev:verification` before claiming it done.

## When Blocked

- Stop and ask. Don't guess. Don't force through with assumptions.
- Present what you tried, what failed, and what you need.

## Subagents

If subagents are available and tasks are independent (no shared state, no ordering dependency), dispatch them in parallel. Otherwise, sequential.

## Completion

After all tasks pass verification, invoke `dev:finishing-branch`.
