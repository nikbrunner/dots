# Phase 4: Review

## When to use

All implementation tasks are complete. Enter automatically after Phase 3, or invoke directly with `/dev:flow review`.

## Steps

### 1. Automated verification

Run the project's test suite, build, and lint. Read the full output — not just exit codes.

| Claim          | Requires                         | Not sufficient                |
| -------------- | -------------------------------- | ----------------------------- |
| Tests pass     | Test output showing 0 failures   | Previous run, "should pass"   |
| Build succeeds | Build exit 0 + clean output      | Linter passing                |
| Bug fixed      | Original symptom verified absent | "Code changed, assumed fixed" |

For UI changes: build, launch, screenshot, inspect visually with `dev:util:browser`.

If verification fails, stop. Fix first, re-run.

### 2. Implementation review

Dispatch **implementation-reviewer** agent across the full branch diff (diff against base branch). This catches what per-task reviews miss at the integration level:

- Dead code, incomplete removals, orphaned imports
- Dev artifacts left behind
- Dependency hygiene issues

If issues found: fix, re-verify, re-dispatch reviewer. Only proceed once clean.

### 3. Human test plan

Write a manual QA checklist — the steps I should take to verify the feature works as a user. Post it as:

- A comment on the PR (if shipping via PR)
- A comment on the linked issue (if one exists)
- Inline in the conversation (if neither applies)

Format:

```markdown
## Test Plan

- [ ] Step 1: description of what to do and what to expect
- [ ] Step 2: ...
```

Focus on user-facing behavior, edge cases, and anything automation can't catch.

## Transition to Phase 5

After I confirm the test plan passes (or waive it for trivial changes), proceed to [Phase 5 - Close](./5-close.md).
