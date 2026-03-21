---
name: dev:start
description: "Entry point for any development task — assess scope from context, route to the right pipeline depth. Use when starting work on a feature, bugfix, idea, or issue."
user-invocable: true
---

# Start

Entry point for development work. Assess scope, then route.

## Step 1: Gather Context

Read the user's prompt carefully. Look for:

- Is there an existing issue/ticket reference?
- Is the scope described or implied?
- Is this greenfield or modification of existing code?
- How many files/modules are likely involved?

If the scope is unclear, ask ONE clarifying question via `AskUserQuestion` before routing. Don't over-ask — infer what you can.

## Step 2: Assess Scope

Based on what you know, classify:

| Scope       | Signals                                                 |
| ----------- | ------------------------------------------------------- |
| **Trivial** | One-liner, typo fix, config change, rename              |
| **Small**   | Single-file bugfix, small feature, isolated change      |
| **Medium**  | Multi-file feature, new module, API changes             |
| **Large**   | Multi-issue project, new system, cross-cutting concerns |

Present your assessment: "This looks like a [scope] task — I'll [route]. Sound right?"
Let the user confirm or override.

## Step 3: Route

| Scope   | Pipeline                                                                                                                                              |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Trivial | Just do it. No ceremony.                                                                                                                              |
| Small   | `dev:worktrees` → implement → `dev:close`                                                                                                             |
| Medium  | `dev:write-prd` → `dev:prd-to-plan` → `dev:worktrees` → `dev:executing-plans` → `dev:close`                                                           |
| Large   | `dev:grill-me` → `dev:write-prd` → `dev:prd-to-plan` → `dev:prd-to-issues` → pick first issue → `dev:worktrees` → `dev:executing-plans` → `dev:close` |

## Notes

- For BAI projects, use `bai:start` instead (wraps this with Linear context)
- `dev:verification` applies at every scope level — even trivial changes get verified before claiming done
- The user can always say "skip to coding" to bypass planning steps
- `dev:tdd` is loaded contextually during implementation regardless of scope
