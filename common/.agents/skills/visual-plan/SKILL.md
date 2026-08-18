---
name: visual-plan
description: Create a self-contained visual HTML implementation plan and send it through Plannotator for approval. Use when the user asks for a visual plan, HTML plan, implementation plan with diagrams, or a reviewable plan artifact.
argument-hint: "[feature or change to plan]"
user-invocable: true
metadata:
  argument-hint: "[feature or change to plan]"
  user-invocable: true
---

# Visual Plan

Create the plan as a readable HTML artifact, not a Markdown plan and not a plan-mode session. Show the intended solution, not just a list of work. Use visual structure, representative code, and UI sketches to make relationships, sequence, behavior, and decisions easy to scan. Do not implement the planned change.

## Interview

### Initial brief

- Treat the invocation arguments as the brief.
- If none are provided, ask for the brief first.

### Grilling

> Interview me relentlessly about every aspect of this plan until we reach a shared understanding.

- Focus on decisions that affect the plan or implementation.
- Find facts in the codebase instead of asking the user for them.
- Carry resolved decisions into the plan and implementation.

### Commit gate

Ask whether implementation should:

- **Review before commit** — stop after verification with all changes uncommitted.
- **Continue through commit** — follow the selected implementation mode's normal commit workflow.

Do not ask the same decision again after approval.

## Workflow

1. Treat the invocation arguments as the brief. If no brief is provided, ask what should be planned.
2. Read the relevant repository files before planning: entry points, existing patterns, affected modules, public APIs, tests, configuration, data models, related features, and project constraints. Ground factual claims in file or symbol evidence, and state unknowns plainly.
3. Load `plannotator-visual-explainer` and follow its implementation-plan path. Read its `references/design-system.md` and `references/svg-patterns.md` before generating the page.
4. Write a self-contained HTML file to `~/.agent/diagrams/<slug>.html`, unless the user gives another output path. Keep CSS, SVG, and any scripts inline. Use Plannotator semantic theme tokens so the file works standalone and inside Plannotator.
5. Treat code and UI as first-class plan material:
   - For meaningful interfaces, schemas, state transitions, configuration, APIs, or tricky behavior, show a short representative code snippet with its file path and explain what it establishes. Prefer proposed code that makes the contract concrete over prose about it.
   - Whenever the change affects layout or UI, always include an HTML/CSS mockup of the affected screen, component, or state. Show the proposed visual change directly, including relevant empty, loading, error, permission, data, and responsive states.
   - For other concerns, choose diagrams, timelines, mockups, cards, tables, and compact code blocks that carry information better than paragraphs. Keep one idea per viewport and leave generous whitespace.
6. Cover the plan essentials that apply:
   - goal, scope, and explicit non-goals
   - current state and proposed design
   - implementation sequence and dependencies, without time estimates
   - affected file map and important interfaces or contracts
   - risks, open decisions, and mitigations
   - test strategy and observable acceptance criteria
7. Deliver the artifact through Plannotator using the annotation workflow from `plannotator-annotate`:

   ```bash
   plannotator annotate <html-file> --gate
   ```

   Wait for the review. Address returned annotations directly, revise the HTML when needed, and re-open it for approval. If the session closes without feedback, report that briefly.

## After approval

Approval is the handoff to implementation, not the end of the workflow.

1. Treat the approved HTML plan as the implementation contract. Re-read it and raise blocking questions before editing.
2. Ask the user to choose an implementation mode:
   - **Human-in-the-loop** — announce and load `superpowers:executing-plans`. Review the plan, create todos, execute tasks with checkpoints, and stop for questions or blockers.
   - **Subagent-driven** — announce and load `superpowers:subagent-driven-development`. Use fresh implementer and reviewer subagents per task, then a broad final review, without pausing for human check-ins between tasks. This fits plans with mostly independent tasks that stay in the current session.
3. If the selected mode conflicts with the plan's task shape, explain the conflict and ask before editing. Otherwise follow the supporting Superpowers workflow. First use `superpowers:using-git-worktrees` to detect whether the current directory is already an isolated worktree. If it is, continue there. Only create a new worktree when needed and after that skill's consent gate. Then use relevant domain and TDD skills during implementation, `superpowers:verification-before-completion` before claiming success, and `superpowers:finishing-a-development-branch` after all tasks and checks pass.
4. Execute the approved tasks without reopening the planning phase or widening scope. For UI changes, render the result and compare it with the approved mockup.
5. Apply the interview's commit-gate choice:
   - **Review before commit:** keep all implementation changes uncommitted. In subagent-driven mode, preserve the task and review loops but instruct implementers not to commit. After verification, show changed files, checks, visual validation, and residual risks. Stop for review, iterate on feedback if needed, and continue to the selected Superpowers finishing/commit workflow only after explicit approval.
   - **Continue through commit:** follow the selected Superpowers mode's normal commit and finishing workflow.
6. Stop and ask if the plan has a blocking gap, the implementation is blocked, or verification fails.

## Quality rules

- Make the first viewport answer what is changing and why.
- Show, do not merely describe: use representative code for important contracts and behavior, and use an HTML/CSS mockup for every layout or UI change.
- Keep snippets small and focused. They illustrate the proposed shape, not a second implementation to maintain.
- Keep detailed file and test references compact or collapsible. Do not produce an exhaustive file dump.
- State uncertainty and unresolved decisions plainly. Never invent codebase facts.
- Use accessible headings, sufficient contrast, responsive layout, and semantic HTML.
- Avoid external assets and dependencies unless the user explicitly asks for them.
- Do not use `open`, `xdg-open`, or plan mode. Plannotator is the delivery surface.

## Implementation record

Create a collapsed section in the HTML during planning and update it live at every implementation phase, checkpoint, commit, or plan deviation. Use one row per phase:

| Phase      | What changed or broke | Why | Fix | Landed in |
| ---------- | --------------------- | --- | --- | --------- |
| Phase name |                       |     |     |           |

Record findings, not debugging. Use `nothing surprising` when applicable; never invent lessons.

## Related skills

- `plannotator-visual-explainer` — plan-page structure, theme tokens, and diagram patterns
- `plannotator-annotate` — browser review and approval workflow
- `superpowers:executing-plans` — human-in-the-loop implementation after approval
- `superpowers:subagent-driven-development` — reviewed subagent implementation for independent tasks
