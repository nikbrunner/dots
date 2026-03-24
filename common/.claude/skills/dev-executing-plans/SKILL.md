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
2. Work through tasks **sequentially** — one at a time, fully complete before moving on.
3. Mark progress as you go (mental checklist, or update the plan file if asked).
4. After completing each task, run the **review gate** (see below) before moving to the next.

### Per-Task Review Gate

After each task is implemented, run this sequence. Order matters — do not skip or reorder.

1. **`dev:verification`** — tests pass, build succeeds, lint clean.
2. **Stage 1: spec-compliance-reviewer** agent — verify the implementation matches the task's requirements. Does not trust your own report; reads actual code.
   - If issues found: fix, then re-run stage 1.
3. **Stage 2: pr-reviewer** agent — verify code quality, architecture, testing.
   - If Critical issues: fix immediately, re-run stage 2.
   - If Important issues: fix before proceeding.
   - If Minor issues: note for later.
4. Only after both stages pass, mark the task complete and move on.

Apply `dev:receiving-review` when processing feedback from either reviewer.

## When Blocked

- Stop and ask. Don't guess. Don't force through with assumptions.
- Present what you tried, what failed, and what you need.

## Subagents

If subagents are available and tasks are independent (no shared state, no ordering dependency), dispatch them in parallel. Otherwise, sequential.

### Subagent Self-Verification

Every subagent prompt MUST include these instructions:

1. **Preload `dev:verification`** — the subagent must follow the same verification rules (no completion claims without evidence).
2. **Self-verify before returning** — the subagent must run the verification loop itself (build, test, lint). If it fails, fix and retry. Do NOT return to the main context with broken code.
3. **For UI/visual tasks** — the subagent must build, launch, capture a screenshot, and inspect it for visual correctness before returning. Build/lint passing is not sufficient for visual work.
4. **Report evidence, not claims** — the subagent's response must include what it verified and the results, not just "I implemented X."

Do NOT accept a subagent result that says "done" without verification evidence. If a subagent returns without evidence, re-dispatch with explicit verification instructions.

## Completion

After all tasks pass verification, invoke `dev:finishing-branch`.
