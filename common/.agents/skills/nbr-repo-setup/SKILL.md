---
name: nbr-repo-setup
description:
  "Plan and, after explicit approval, set up a personal project's repo tooling from `nbr-repo-conventions`: agent setup,
  Git hooks, the workflow kit (repo-commit, repo-changelog, repo-release on release-please), and a dependency upgrade
  skill. Use when setting up a repo for agent work, Git hooks (pre-commit, pre-push, Lefthook, migrating from Husky or
  native hooks), releases, a changelog, or dependency upgrades. Inspect first,
  propose concrete files, and write only what is approved. Use nbr-repo-audit for read-only checks."
argument-hint: "[full | agent-tooling | hooks | workflow | dependencies]"
---

# Set up a repo

Fill the missing pieces of a repo's tooling. The existing project wins: setup adds what is absent and changes a working
piece only through an approved audit finding or an explicit request to change it, such as a hook migration.

## Workflow

1. Resolve the scope. A named topic limits the work to that topic. A bare invocation means `full`, unless the request is
   about one topic: answer that and offer the wider sweep. An unknown topic lists the supported ones.
2. Read the topic in `nbr-repo-conventions` and the procedure the table below names.
3. Inspect the repo. Read files freely; run only read-only `git` and `gh` queries and the version and help output
   of tools the procedure names (`lefthook --version`). Never run installers, builds, or anything that writes.
4. Propose a plan: every file to create or change with its intended content, one table of inferred values with their
   source, the commands that will run, and the steps left for the maintainer. Use the host's plan mode when it has one.
5. Wait for explicit approval. Then write only the listed files and run only the listed commands.
6. Run `nbr-repo-audit <topic>` over what was written, and report each finding with its fix.

`full` runs the topics in table order: agent setup first, since the project skills live in `.agents/skills/`; hooks
next, so the commit skill can describe what they run; then the workflow kit and dependencies.

| Topic           | Builds                                                           | Procedure                                                |
| --------------- | ---------------------------------------------------------------- | -------------------------------------------------------- |
| `agent-tooling` | `AGENTS.md`, `.agents/skills/`, the `.claude/skills` link        | The topic itself                                         |
| `hooks`         | Lefthook or native hooks, pre-commit and pre-push checks         | [`references/hooks.md`](references/hooks.md)             |
| `workflow`      | `repo-commit`, `repo-changelog`, `repo-release`, release-please  | [`references/workflow.md`](references/workflow.md)       |
| `dependencies`  | `repo-dep-upgrades`                                              | [`references/dependencies.md`](references/dependencies.md) |

The code topics of `nbr-repo-conventions` (TypeScript, React, CSS, state, TanStack) have no setup; `nbr-repo-audit`
checks them.

## Safety

- Leave every file unstaged. Committing goes through the repo's commit skill, only when the maintainer asks.
- A repository setting on GitHub (Actions permissions) changes only after an explicit yes for that command.
- Test hooks in a disposable repository, never by committing or pushing in the real one.
- A missing tool or a failed install is reported, never worked around by silently switching method.
