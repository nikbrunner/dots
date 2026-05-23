# Phase 2: Plan

For work that benefits from planning before code. Used to write a plan from a PRD.

## Confirm the PRD is in context

The PRD should already be in the conversation. If it isn't, ask the user to paste it or point you to the file or URL.

If its an URL, fetch it including comments.

For GitHub issues, invoke the `about:gh-cli` skill use the CLI correctly.

## Finalizing the plan

If needed, use the `[interview](./guides/interview.md)` and the `dev:util:visual-companion` skill to finalize the plan.

Also look out for `dev:style:*` skills that can and should be applied to the plan.

## Write a plan

Every plan file MUST include a `## Commits` section in each phase that breaks the work into commit-sized slices, each with a one-line conventional-commit message and the files it touches, ordered so each commit leaves the repo in a passing state.

When creating a plan from a PRD, we have two options:

- [PRD to Plan](./guides/prd-to-plan.md) — use this when you want a plan file
- [PRD to Issues](./guides/prd-to-issues.md) — use this when you want GitHub issues

Offer me a choice with a suggestion based on context.

Required plan file sections (when using PRD to Plan):

- **Context** — what problem we're solving
- **Critical files** — what will be touched
- **Phases** — vertical slices, each with its own `## Commits` section
- **Verification** — how we'll know it's done

After writing the plan, dispatch the **plan-reviewer** agent to review it.
Evaluate the feedback of the reviewer and iterate until the Plan is ready the next step.
If still unresolved after 3 iterations, escalate to me.

## Transition

When reviewer agent approves and the Plan is verified, offer:

- **Continue** — move to [Phase 3 - Implement](./3-implement.md)
- **Park** — plan is written and reviewed, not implementing now. Confirm artifacts are saved (plan file or issues created) and end cleanly.
