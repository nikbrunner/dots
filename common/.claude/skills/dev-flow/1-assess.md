# Phase 1: Assessment

## When to use

Automatic entry point for any development task. Runs whenever I describe work or invoke `/dev:flow assess`.

## Goal

The goal of this phase is to write a PRD _(Product Requirements Document)_.

## Assessment

Based on my prompt, explore the codebase, gather context, and try to make an early assessment of the scope of this task.

| Scope   | Signals                                     | Notes                                     |
| ------- | ------------------------------------------- | ----------------------------------------- |
| Trivial | One-liner, typo, config change, rename      | Needs no PRD                              |
| Small   | Small isolated feature or Bugfix            | Maybe needs a PRD                         |
| Medium  | Multi-file feature, new module, API changes | Needs PRD                                 |
| Large   | Multi-system, cross-cutting concerns        | Is usually an Epic with seperate subtasks |

- **Present the assessment** — Let me confirm or override.
- **Trivial/Small without PRD** — If I confirm a trivial or small scope that doesn't need a PRD, skip straight to [Phase 3 - Implement](./3-implement.md).
- **If scope is unclear**, ask clarifying questions.
- For **medium** and **large** tasks, please use the [interview](./guides/interview.md) to nail down the scope and requirements.
- If provided helpful during assessment, you can also suggest using the `dev:util:visual-companion` skill to help with visualization.

## Write a PRD

After the assessment, use the [write-a-prd](./guides/write-a-prd.md) guide to write a PRD.
Use the `prd-reviewer` agent to review the PRD.
Evaluate the feedback of the reviewer and iterate until the PRD is ready the next step.
If still unresolved after 3 iterations, escalate to me.

## Output

The PRD can either be written to a file or created as a GitHub issue.
Offer me a choice with a suggestion based on context.

## Transition

When reviewer agent approves and the PRD is verified, offer:

- **Continue** — move to [Phase 2 - Plan](./2-plan.md)
- **Park** — work is tracked (issue filed), not continuing now. Confirm issue properties are set (assignee, type, labels) and end cleanly.
