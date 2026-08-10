---
name: dev-how-to-test
description: "My black-box acceptance testing checklist — tailored end-user journeys, edge cases, and UX behavior in HOW_TO_TEST.md. Load when changes need human acceptance testing, manual QA instructions, or an end-user validation checklist."
argument-hint: "[optional: scope or user journey to emphasize]"
metadata:
  argument-hint: "[optional: scope or user journey to emphasize]"
  user-invocable: true
---

# How to Test

Create `HOW_TO_TEST.md` in the project root. It is a handoff for a human tester, not a developer test plan.

## Before writing

1. Inspect the current diff and recent commits to understand what changed.
2. Read the project README and relevant user-facing docs.
3. Identify the app's real entry point, test account or fixture needs, supported platforms, and the changed user journeys.
4. Use the optional argument to focus the checklist when provided.
5. Determine and run the relevant existing checks before creating the document: targeted tests, typecheck/lint/build where relevant, and browser automation with `agent-browser` when a runnable UI is available. Do not change code to make these checks pass.
6. Do not invent behavior. Mark unknown setup values as `[fill in]` rather than guessing.

## What to write

Generate a detailed, project-specific checklist with unchecked Markdown boxes. Keep the main effort on the 80/20 paths that represent the normal user's highest-value work. Add only edge cases that could cause data loss, blocked progress, confusing state, access problems, or a poor first impression. Under every checkbox, add exactly one indented `Agent check:` bullet with a one-line result from the checks you ran. Use `PASS`, `FAIL`, `BLOCKED`, or `NOT RUN`, name the check or browser flow, and keep the human checkbox unchecked because the human still needs to verify it.

Use this structure:

1. **Test context** — build/branch, URL or launch command, account/role, seed data, device/browser, and a short change summary.
2. **Entry criteria** — what must be true before testing starts.
3. **Critical user journeys** — exact black-box steps with concrete inputs and observable expected results. Include happy path, refresh/reopen, and persistence where relevant.
4. **Important edge cases** — empty, one, many, long, invalid, duplicate, boundary, interrupted, slow/offline, permission, and repeated-action cases where the feature supports them.
5. **UX and accessibility pass** — loading, success, empty, error, destructive confirmation, undo/cancel, keyboard/focus, labels, contrast, responsive layout, and plain-language feedback.
6. **Regression smoke test** — adjacent flows most likely to be affected.
7. **Exploratory prompts** — short “try this” charters that let the tester follow the data and violate reasonable assumptions without inspecting code.
8. **Defect log** — a small table or checklist capturing severity, exact steps, expected vs. actual result, environment, and evidence.
9. **Sign-off** — pass/fail decision, known issues, retest items, and tester/date.

## Rules for each checklist item

- Start with an action and state the expected visible or user-observable result.
- Put the agent's one-line evidence immediately below it, for example: `- Agent check: PASS — Playwright smoke test completed; saved record was visible after reload.`
- Name the persona or permission level when it changes the outcome.
- Separate setup, action, and expected result so the tester can execute without source-code knowledge.
- Include checkpoints after meaningful actions, not just at the end.
- Prefer realistic values plus a boundary value; use `[replace with project value]` for missing data.
- Call out irreversible actions and verify that cancel, confirmation, and recovery behave safely.
- Keep automated/unit/integration commands out of the checklist except as entry criteria.
- Include browser/device coverage only when relevant to the changed surface.

## Quality bar

Before finishing, verify that the document is executable by someone who did not make the change, covers the changed journey end to end, tests failure recovery and persistence, and does not claim an unverified requirement. Every checkbox must have one truthful agent result beneath it. Report failed, blocked, and skipped checks plainly, including the reason and any evidence path. Agent checks support the human review; they do not mark the human checkbox complete. Keep the checklist extensive enough to be useful, but prune duplicate or low-risk checks.

## Cross-References

- `dev:audit` — deeper UX and accessibility review when the checklist finds a concern.
