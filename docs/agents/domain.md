# Domain docs

## Before exploring

This repo uses a single-context layout:

- `CONTEXT.md` at the repo root contains domain terms and their meanings.
- `docs/adr/` contains architecture decisions.

Read `CONTEXT.md` and ADRs relevant to the area you are exploring.

If either is absent, proceed silently. The `domain-modeling` skill creates these documents when terms or decisions are resolved.

## Vocabulary

Use the terms defined in `CONTEXT.md` in issue titles, proposals, hypotheses, and tests.

When a needed concept is missing, reconsider whether it belongs to the project's vocabulary. If it does, note the gap for `domain-modeling`.

## ADR conflicts

If a proposal contradicts an existing ADR, name the ADR and explain why the decision should be reconsidered.
