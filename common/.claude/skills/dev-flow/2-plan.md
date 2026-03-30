# Phase 2: Plan

For work that benefits from planning before code. Used to write a plan from a PRD.

## Confirm the PRD is in context

The PRD should already be in the conversation. If it isn't, ask the user to paste it or point you to the file or URL.

If its an URL, fetch it including comments.

For GitHub issues, invoke the `about:gh-cli` skill use the CLI correctly.

## Finalizing the plan

If needed, use the `[interview](./interview.md)` and the `dev:util:visual-companion` skill to finalize the plan.

Also look out for `dev:style:*` skills that can and should be applied to the plan.

## Write a plan

When creating a plan from a PRD, we have two options:

- [PRD to Plan](./prd-to-plan.md)
- [PRD to Issues](./prd-to-issues.md)

Offer me a choice with a suggestion based on context.
After writing the plan, dispatch the **plan-reviewer** agent to review it.
Evaluate the feedback of the reviewer and iterate until the Plan is ready the next step.
If still unresolved after 3 iterations, escalate to me.

## Transition to Phase 3

When reviewer agent approves and the Plan is verified, offer to move to [Phase 3 - Implement](./3-implement.md).
