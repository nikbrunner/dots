---
name: dev:verification
description: "Behavioral constraint -- no completion claims without fresh verification evidence. Load before any commit, PR, or done statement."
user-invocable: true
---

# Verification

**Iron law: no completion claim without fresh verification evidence.**

## The Gate

Every claim passes through this sequence. No shortcuts.

1. **Identify** the verification command (test suite, build, lint, manual check).
2. **Run it.** Right now. Not "I'll run it later."
3. **Read the full output.** Not just the exit code.
4. **Check exit code.** Zero means nothing if the output contains failures.
5. **Verify the claim matches the output.** Word for word.
6. **Only then** make the claim.

## What Counts

| Claim            | Requires                               | Not sufficient                |
| ---------------- | -------------------------------------- | ----------------------------- |
| Tests pass       | Test command output showing 0 failures | Previous run, "should pass"   |
| Build succeeds   | Build command exit 0 + clean output    | Linter passing                |
| Bug fixed        | Original symptom verified absent       | "Code changed, assumed fixed" |
| Requirements met | Line-by-line checklist verified        | "Tests passing"               |

## Red Flags in Your Own Output

If you catch yourself writing any of these, stop and run the verification:

- "should work now"
- "probably fixed"
- "seems to be working"
- "I'm confident that..."
- Any expression of satisfaction before running a command

## Rationalization Prevention

- **"Should work now"** -- run it.
- **"I'm confident"** -- confidence is not evidence.
- **"Just this once"** -- no exceptions.
- **"The change is trivial"** -- trivial changes break builds.
- **"I already verified something similar"** -- similar is not same.

## Applies Before

- Any completion claim
- Any commit
- Any PR creation
- Any task marked done
- Any positive statement about work state
