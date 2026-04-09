# Phase 3: Implementation

## When to use

Implementation time. Entered automatically when Phase 1 routes here (trivial/small scope), or after Phase 2 completes.

For implementations, that benefit from tests or test-driven development, use the `dev:style:tdd` skill.

## General guidelines

- **Confirm the branch.** Never implement on `main`/`master` without explicit consent.
- Each commit should be self-contained and green. Use the `dev:util:commit` skill to commit after each logical unit of work.
- For each completed task, mark it in the plan (`- [ ]` → `- [x]`).
- When the last task is marked complete, check if the plan has testing gates for the whole completed feature.
- When blocked, stop and ask. Present what you tried, what failed, and what you need. Don't force through with assumptions.
- When all tasks are complete, use the `implementation-reviewer` agent to review the code.

## Subagents

If tasks are independent (no shared state, no ordering dependency), dispatch subagents in parallel. Every subagent prompt MUST include:

- Preload verification rules (no claims without evidence)
- Self-verify before returning (build, test, lint)
- For UI tasks: screenshot and inspect before returning
- Report evidence, not claims

Do NOT accept "done" without verification evidence. Re-dispatch if missing.

## Verification

For each task or planned commit, run the project's test suite, build, and lint.

Read the full output — not just exit codes.

| Claim          | Requires                         | Not sufficient                |
| -------------- | -------------------------------- | ----------------------------- |
| Tests pass     | Test output showing 0 failures   | Previous run, "should pass"   |
| Build succeeds | Build exit 0 + clean output      | Linter passing                |
| Bug fixed      | Original symptom verified absent | "Code changed, assumed fixed" |

For UI changes: build, launch, screenshot, inspect visually with the `dev:util:browser` skill to verify visual changes and user stories.

If verification fails, stop. Fix first, re-run.

### Handling Review Feedback

When processing feedback from reviewers or me:

1. Read the full feedback without reacting
2. Restate the technical requirement in your own words
3. Verify the claim against codebase reality — is the reviewer correct?
4. Push back when feedback would break existing functionality, violates YAGNI, is technically incorrect, or conflicts with documented decisions. Use evidence, not defensiveness
5. Implement one fix at a time, test each before moving to next
6. If you understand items 1-3 but not 4-5: STOP. Clarify ALL unclear items before implementing ANY

## Transition to Phase 4

All tasks complete, or untracked work done. Offer to move to [Phase 4 - Review](./4-review.md). Claude surfaces completion but never auto-transitions to close.
