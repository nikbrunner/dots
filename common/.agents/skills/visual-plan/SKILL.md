---
name: visual-plan
description: Create a self-contained visual HTML implementation plan and deliver it through Plannotator for approval. Use this whenever the user asks for a visual plan, HTML plan, implementation plan with diagrams or UI mockups, architecture proposal, or a reviewable plan artifact. Prefer this over a plain Markdown plan when the requested change has meaningful relationships, state, layout, or sequencing to show.
argument-hint: "[feature or change to plan]"
user-invocable: true
metadata:
  argument-hint: "[feature or change to plan]"
  user-invocable: true
---

# Visual Plan

Create a readable HTML plan that shows the intended solution. Do not implement the planned change before approval. Approval is the handoff into the implementation workflow below.

## Scope

Use this skill for implementation plans that benefit from visual structure: UI changes, stateful workflows, APIs, data flow, migrations, architecture changes, CLI behavior, and refactors with meaningful relationships to explain.

Prefer an ordinary Markdown plan for small, linear changes with no meaningful UI, state, data flow, or component relationships. Do not use it for a request that explicitly needs only a short Markdown checklist, a commit message, or implementation without a planning step.

## Interview

1. Treat the invocation arguments as the initial brief. If there is no brief, ask for one.
2. Inspect the repository before asking questions. Find entry points, existing patterns, affected modules, public interfaces, tests, configuration, and related features.
3. Ask one focused question at a time for decisions that materially affect the plan. Resolve facts from the repository instead of asking the user to supply them.
4. Stop interviewing when the scope, non-goals, acceptance criteria, and remaining owner decisions are clear. Do not invent answers for missing facts.

## Contract audit

Apply every audit that matches the change. A combined API, state, and UI change uses all three relevant audits. Record irrelevant sections as `not applicable` instead of forcing every plan through the same checklist.

- **Persisted fields, API results, IPC, or frontend state:** trace the value from input and persistence through backend operations, bindings, frontend state, rendering, tests, fixtures, detection/setup code, and relevant docs.
- **UI or user-visible behavior:** cover loading, empty, success, partial-success, error, permission, responsive, and retry states when they apply.
- **CLI or refactor:** trace public callers, streams, exit codes, configuration, compatibility constraints, and failure behavior.

Record representation changes such as stored versus expanded paths, serialized versus hydrated defaults, legacy versus current schema, and generated versus hand-authored files. Include a behavior matrix for the relevant legacy, current, mixed, empty, missing, success, partial-success, and failure cases. Give every changed user-visible row an observable acceptance criterion.

Check indirect registries, capability metadata, auto-detection, setup flows, generated bindings, development fixtures, and durable documentation when the change can affect them. State unknowns plainly and assign each unresolved choice to its owner.

## Workflow

### 1. Gather evidence

Read the relevant repository files and use file paths or symbols as evidence in the plan. Keep the scope bounded to the requested change. If the current repository does not contain the target application or subsystem, say so in the plan and keep proposed code illustrative rather than presenting it as a repository fact.

For an implementation plan, read:

- `plannotator-visual-explainer/SKILL.md`
- `plannotator-visual-explainer/references/design-system.md`
- `plannotator-visual-explainer/references/svg-patterns.md`

Load `plannotator-annotate` for the delivery workflow.

### 2. Choose the artifact path

Keep the plan in the current repository so it can be reviewed and tracked with the implementation:

```bash
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
plan_dir="$repo_root/plans"
mkdir -p "$plan_dir"
```

Derive a lowercase kebab-case slug from the brief, keeping it short and filesystem-safe. Set `plan_file` to `$plan_dir/<slug>.html`. If that path exists, append `-2`, `-3`, and so on rather than overwriting an existing plan. Keep the HTML plan tracked; do not move it to an external diagrams directory or add it to `.gitignore`.

Keep CSS, SVG, and scripts inline. Do not use external assets or dependencies unless the user asks for them. Use Plannotator semantic theme tokens and include standalone defaults from the design-system reference.

### 3. Build the plan

Use only sections that serve the change. The first viewport must answer what is changing and why. Include:

- goal, scope, and explicit non-goals
- current state and proposed design
- implementation sequence and dependencies, without time estimates
- affected files and important interfaces or contracts
- risks, mitigations, and owner decisions
- proposed commit sequence, when the change has natural commit boundaries
- test strategy and observable acceptance criteria

When useful, pre-plan commits as an ordered list. Give each proposed commit a small scope, an imperative intent, its affected area, and the validation that should pass before it lands. Keep the plan at one commit when splitting would make review harder. Record the actual commit IDs in the implementation record later.

Show the solution rather than describing it abstractly:

- Use an inline SVG diagram for three or more interacting components, data flow, or state transitions.
- Use a real HTML/CSS mockup whenever the change affects layout or UI. Show the relevant loading, empty, error, permission, data, and responsive states that apply.
- Use short representative code for meaningful interfaces, schemas, configuration, or tricky behavior. Label each snippet with its proposed file path and mark illustrative code when the repository does not contain the target subsystem.
- Use timelines for sequence and dependency only. Never include time estimates.

Include a collapsed implementation record with a planning row and the columns `Phase`, `What changed`, `Why`, `Fix`, and `Landed in`. Record current facts only, for example `Planning | Plan drafted | ... | plans/<slug>.html`. After approval, update it at each implementation phase, checkpoint, commit, or plan deviation. Record findings, not debugging, and never invent entries.

### 4. Deliver for approval

Run the gate with structured output so approval, denial, annotations, and tool errors are distinguishable:

```bash
result_file="$(mktemp "${TMPDIR:-/tmp}/visual-plan-result.XXXXXX.json")"
trap 'rm -f "$result_file"' EXIT
plannotator annotate "$plan_file" --gate --json --result-file "$result_file"
```

Read and validate the result JSON before reporting an outcome. Use the decision and annotations fields emitted by Plannotator as the authority; do not infer approval from the process exit code alone. If annotations are returned, address them in the HTML and run the gate again. If the result is approved, report the approved artifact path and continue with **After approval**. If it is denied, report the denial and stop unless the user asks for a revision. Do not start implementation without an approval result.

If the browser or Plannotator is unavailable, the command times out, exits without a result file, or produces malformed JSON, preserve the HTML, report the exact command failure, and classify the review as incomplete and unapproved. Removing the result file before each attempt prevents stale approval data from being mistaken for the current review. Never treat a timeout or missing result as approval or denial. Never claim approval from a successful HTML write or a command that only opened the page.

## Quality rules

- Ground factual claims in repository evidence and label proposals as proposals.
- Keep one idea per viewport with generous whitespace.
- Use accessible headings, semantic HTML, sufficient contrast, and responsive layout.
- Make open decisions explicit, with an owner and the consequence of each option.
- Keep snippets small and focused. The plan is a communication artifact, not a second implementation.
- Do not dump every touched file. Include the files that establish the contract and put supporting detail in collapsible sections.
- Do not use `open`, `xdg-open`, or plan mode. Plannotator is the delivery surface.

## After approval

Treat the approved HTML plan as the implementation contract. Re-read it and raise blocking questions before editing.

1. Ask the user to choose an implementation mode:
   - **Human-in-the-loop** — announce and load `superpowers:executing-plans`. Review the plan, create todos, execute tasks with checkpoints, and stop for questions or blockers. Let that workflow own its commit decision; do not add a second commit-gate question here.
   - **Subagent-driven** — announce and load `superpowers:subagent-driven-development`. Use fresh implementer and reviewer subagents per task, then a broad final review, without pausing for human check-ins between tasks. Use this when the plan has mostly independent tasks that fit the current session. Before starting, ask whether to enable the **commit gate** for this run.
2. If the selected mode conflicts with the plan's task shape, explain the conflict and ask before editing. Otherwise follow the supporting Superpowers workflow. First use `superpowers:using-git-worktrees` to detect whether the current directory is already an isolated worktree. If it is, continue there. Only create a new worktree when needed and after that skill's consent gate. Then use relevant domain and TDD skills during implementation, `superpowers:verification-before-completion` before claiming success, and `superpowers:finishing-a-development-branch` after all tasks and checks pass.
3. When using subagent-driven mode, keep the commit-gate choice for the whole run and do not ask it again at the end:
   - **Commit gate enabled** — finish implementation and verification, update the plan, prepare the proposed commit sequence, then stop before `git add`, `git commit`, or `git push` and ask for approval.
   - **Commit gate disabled** — continue through the normal commit workflow after verification.
4. Execute the approved tasks without reopening the planning phase or widening scope. For UI changes, render the result and compare it with the approved mockup. Follow the proposed commit sequence when it still fits; record deviations and actual commit IDs in the implementation record.
5. Stop and ask if the plan has a blocking gap, implementation is blocked, or verification fails.

## Subagent commit gate

When the subagent-driven commit gate is enabled:

1. Complete the implementation, reviews, and agreed verification without committing or pushing.
2. Update the implementation record, including the final verification result and proposed commit message or sequence.
3. If implementation is complete, rename the tracked plan to its `-completed.html` filename before requesting approval so the final plan is part of the reviewed change.
4. Show the changed files, verification evidence, plan path, and proposed commit sequence. Ask for approval to stage and commit.
5. If approved, continue the normal commit workflow and record the actual commit IDs. If declined, leave all changes uncommitted and keep the final plan available for review.

When the subagent-driven commit gate is disabled, follow the normal commit workflow.

## After implementation

When implementation is complete:

1. Run the agreed verification and record the result in the implementation record.
2. If subagent-driven mode uses the commit gate, follow the **Subagent commit gate** section before staging or committing.
3. Otherwise, let the selected implementation workflow handle its commit decision and record each landed commit or state that the changes remain uncommitted by choice.
4. If the plan has not already been renamed during the commit-gate handoff, rename it from `plans/<slug>.html` to `plans/<slug>-completed.html`. If that destination exists, append `-2`, `-3`, and so on rather than overwriting it.
5. Update the final implementation-record row with the completed filename and report that path to the user.

If implementation stops because of a blocker, failed verification, a declined commit gate, or an explicit pause, record the current status and residual work and report the available plan path.

## Related skills

- `plannotator-visual-explainer` — plan-page structure, theme tokens, and diagram patterns
- `plannotator-annotate` — browser review and approval workflow
- `superpowers:executing-plans` — human-in-the-loop implementation after approval
- `superpowers:subagent-driven-development` — reviewed subagent implementation for independent tasks
