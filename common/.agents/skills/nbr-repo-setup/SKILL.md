---
name: nbr-repo-setup
description:
  "Plan and, after explicit approval, set up a personal project's repo tooling from `nbr-repo-conventions`: agent setup,
  Git hooks and config, npm scripts, the docs shape, the workflow kit (repo-commit, repo-changelog, repo-release
  on release-please), and a dependency upgrade skill. Use when setting up a repo for agent work, Git hooks (pre-commit, pre-push, Lefthook, migrating from Husky or
  native hooks), releases, a changelog, or dependency upgrades. Inspect first,
  propose concrete files, and write only what is approved. Use nbr-repo-audit for read-only checks."
argument-hint: "[full | agent-tooling | git | npm-project | docs-structure | workflow | dependencies | free text]"
---

# Set up a repo

Fill the missing pieces of a repo's tooling. The existing project wins: setup adds what is absent and changes a working
piece only through an approved audit finding or an explicit request to change it, such as a hook migration.

## Workflow

1. Resolve the scope.
   - The argument is free-form. Topic names (one or several) scope to those topics; `full` runs every topic; free text
     ("curated releases", "hooks and the docs") maps to the topics it names, stated back in one line before the survey.
   - Text that maps to no topic, or only ambiguously, falls through to the interview.
   - No argument starts an interview: survey the repo read-only, show each topic as present, partial, or missing with
     one line of evidence, and ask which to set up, with a recommendation. That one multi-select answer is the scope.
2. Read the topic in `nbr-repo-conventions` and the procedure the table below names.
3. Inspect the repo. Read files freely; run only read-only `git` and `gh` queries and the version and help output
   of tools the procedure names (`lefthook --version`). Never run installers, builds, or anything that writes.
4. Propose a plan: every file to create or change with its intended content, one table of inferred values with their
   source, the commands that will run, and the steps left for the maintainer. Use the host's plan mode when it has one.
5. Wait for explicit approval. Then write only the listed files and run only the listed commands.
6. Run `nbr-repo-audit <topic>` over what was written, and report each finding with its fix.

`full` runs the topics in table order: agent setup first, since the project skills live in `.agents/skills/`; the npm
scripts before the hooks that call them; hooks before the workflow kit, so the commit skill can describe what they run.

| Topic           | Builds                                                           | Procedure                                                |
| --------------- | ---------------------------------------------------------------- | -------------------------------------------------------- |
| `agent-tooling` | `AGENTS.md`, `.agents/skills/`, the `.claude/skills` link        | The topic itself                                         |
| `npm-project`   | `package.json` fields, `verify:*` scripts, `.npmrc`              | The topic itself                                         |
| `git`           | Lefthook or native hooks, `verify:staged`/`verify:full`, Git config | [`references/hooks.md`](references/hooks.md)          |
| `docs-structure`| README and `docs/` shape                                         | The topic itself                                         |
| `workflow`      | `repo-commit`, `repo-changelog`, `repo-release`, release-please  | [`references/workflow.md`](references/workflow.md)       |
| `dependencies`  | `repo-dep-upgrades`                                              | [`references/dependencies.md`](references/dependencies.md) |

The code topics of `nbr-repo-conventions` have no setup; `nbr-repo-audit` checks them.

## Safety

- Leave every file unstaged. Committing goes through the repo's commit skill, only when the maintainer asks.
- A repository setting on GitHub (Actions permissions) changes only after an explicit yes for that command.
- Test hooks in a disposable repository, never by committing or pushing in the real one.
- A missing tool or a failed install is reported, never worked around by silently switching method.
