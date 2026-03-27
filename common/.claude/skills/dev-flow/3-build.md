# Phase 3: Build

## When to use

Implementation time. Entered automatically when Phase 1 routes here (trivial/small scope), or when `opsx:apply` is invoked on a tracked change, or after Phase 2 completes.

## BAI Auto-Detection

If repo path contains `black-atom-industries`, Linear context is loaded. Use semantic commits with BAI conventions.

## Before writing code

1. **Load the plan.** Read tasks.md (OpenSpec) or plan file fully.
2. **Review critically.** Raise concerns, contradictions, or missing details BEFORE writing any code.
3. **Confirm the branch.** Never implement on `main`/`master` without explicit consent.

## Execution: Tracked Changes (OpenSpec or plan file)

1. Work through tasks **sequentially** — one at a time, fully complete before moving on
2. After each task, run the **per-task review gate** (see below)
3. Mark each task complete (`- [ ]` to `- [x]`) immediately after it passes
4. Commit after each logical unit of work
5. When the last task is marked complete, surface: "All tasks in [change] are complete — ready for `/dev:flow close`?"

## Execution: Untracked Work

Implement directly, verify before committing, use conventional commit format.

## Per-Task Review Gate

Run in this order. Do not skip or reorder.

1. **Verification** — tests pass, build succeeds, lint clean. For UI changes: build, launch, screenshot, inspect visually. No completion claims without evidence.
2. **spec-compliance-reviewer** agent — does implementation match the task's requirements? Reads actual code, doesn't trust self-reports. Fix issues and re-run until clean.
3. **pr-reviewer** agent — code quality, architecture, testing. Critical: fix immediately. Important: fix before next task. Minor: note for later.

## Handling Review Feedback

When processing feedback from reviewers or Nik:

1. Read the full feedback without reacting
2. Restate the technical requirement in your own words
3. Verify the claim against codebase reality — is the reviewer correct?
4. Push back when feedback would break existing functionality, violates YAGNI, is technically incorrect, or conflicts with documented decisions. Use evidence, not defensiveness
5. Implement one fix at a time, test each before moving to next
6. Never say "Great point!" or express gratitude about feedback. Just: "Fixed. [description]"
7. If you understand items 1-3 but not 4-5: STOP. Clarify ALL unclear items before implementing ANY

## Subagents

If tasks are independent (no shared state, no ordering dependency), dispatch subagents in parallel. Every subagent prompt MUST include:

- Preload verification rules (no claims without evidence)
- Self-verify before returning (build, test, lint)
- For UI tasks: screenshot and inspect before returning
- Report evidence, not claims

Do NOT accept "done" without verification evidence. Re-dispatch if missing.

## When Blocked

Stop and ask. Present what you tried, what failed, and what you need. Don't force through with assumptions.

## Transition to Phase 4

All tasks complete, or untracked work done. Nik triggers `/dev:flow close`. Claude surfaces completion but never auto-transitions.
