---
name: self-improvement
description: Use when the user explicitly asks to learn from something that went wrong in the current conversation or wants a correction turned into a durable improvement.
argument-hint: "[what went wrong or what to inspect]"
disable-model-invocation: true
compatibility: Requires access to the current conversation and shell access for public skill discovery with npx skills find.
---

# Self-Improvement

Turn friction in the current conversation into the smallest reusable improvement. A valid retrospective may conclude that nothing should change.

## Input

Treat text after `/skill:self-improvement` as the focus. Without an argument, inspect the latest correction or friction point. Read the conversation before asking the user to restate anything.

Use concrete evidence from:

- user corrections and repeated requests;
- assistant responses and assumptions;
- tool calls and results;
- skills that were loaded, skipped, or followed incorrectly.

## Diagnose

State:

1. What the user expected.
2. What happened instead.
3. Which conversation evidence proves the mismatch.
4. Why it happened.

Classify the cause as one or more of:

- **Triggering:** a relevant skill did not load, or an irrelevant one did.
- **Missing guidance:** the skill did not cover the situation.
- **Wrong guidance:** following the skill caused the failure.
- **Compliance:** existing guidance was correct but was not followed.
- **Missing capability:** no current skill or instruction covers a reusable pattern.
- **Tooling:** a mechanical check or better tool could prevent the failure.

Do not assume a skill needs editing merely because one was involved. If its guidance already covers the case, distinguish an isolated compliance miss from wording that repeatedly fails under pressure.

## Choose the Durable Home

Select one:

| Destination | Use when |
|---|---|
| Existing skill | Its trigger or guidance is incomplete or misleading |
| New skill | A reusable workflow requires steps or contextual judgment |
| `AGENTS.md` | A short instruction should apply to nearly every task |
| Automation | The failure is mechanically detectable |
| No change | The incident is isolated, already covered, or too specific to generalize |

Prefer the smallest destination that prevents recurrence. Do not turn one incident into a broad rule without evidence that it generalizes.

## Check for Existing Skills

Before proposing a new skill:

1. Inspect the available local skill names and descriptions, then read plausible matches.
2. Search the public archive with `npx skills find` using 2-3 terms taken from the incident.
3. Inspect close public matches with `npx skills use <owner/repo@skill>` before recommending adoption or adaptation.
4. Prefer updating, adapting, or installing a close match over creating a duplicate.

Skip public discovery when the destination is clearly not a new skill.

## Report

Use this structure:

```markdown
## Diagnosis
- Expected:
- Actual:
- Evidence:
- Root cause:

## Recommendation
- Destination:
- Reason:
- Existing options: <!-- include only when skill discovery was needed -->
- Proposal: <!-- exact replacement/addition, or a small new-skill outline -->
```

Omit `Proposal` when no durable change is justified. Keep the diagnosis concise and the proposal exact enough to review as a diff.

End with one approval question. Do not edit skills, instructions, or automation until the user approves the proposal.
