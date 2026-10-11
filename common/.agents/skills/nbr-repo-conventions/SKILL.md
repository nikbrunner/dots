---
name: nbr-repo-conventions
description:
  "Nik's conventions for personal projects, as topics: TypeScript, React, CSS, state, TanStack and the data boundary,
  validation, authentication, testing, assets, tooling, npm projects, Git hooks, docs, agent tooling, the
  commit-to-release workflow, and dependency upgrades. Use whenever a task writes or reviews code, docs, or repo tooling in
  a personal project. Read only the topics that match."
user-invocable: false
---

# Conventions

These are Nik's defaults for personal projects. A project's stated, working choice wins: use a topic to fill a gap or to make
a deliberate deviation visible, not to reshape code that works.

## Choose a topic

| Topic                                            | Read when                                                                   |
| ------------------------------------------------ | --------------------------------------------------------------------------- |
| [typescript](topics/typescript.md)               | Writing TypeScript: type safety, derivation, function design, naming.       |
| [react](topics/react.md)                         | Designing components, roles, folder structure, imports, hooks, or effects.  |
| [css](topics/css.md)                             | Writing CSS: CSS Modules, CVA and class names, spacing, overrides.          |
| [state](topics/state.md)                         | Deciding where state lives: URL, server, local, Context, or a store.        |
| [tanstack](topics/tanstack.md)                   | Any `@tanstack/*` package: Query and the data boundary, Form, Router.       |
| [validation](topics/validation.md)               | Accepting data from outside the frontend, or locking a form field.          |
| [authentication](topics/authentication.md)       | Protecting routes, the current-user query, login and logout.                |
| [testing](topics/testing.md)                     | Deciding what to test and where tests live.                                 |
| [assets](topics/assets.md)                       | Adding images, icons, or other static files.                                |
| [tooling](topics/tooling.md)                     | Choosing a library or tool, or configuring TypeScript and ESLint.           |
| [npm-project](topics/npm-project.md)             | Changing `package.json`, scripts, `.npmrc`, pins, or the Node floor.        |
| [git](topics/git.md)                             | Hooks, Git config, or what runs on pre-commit and pre-push.                 |
| [docs-structure](topics/docs-structure.md)       | Writing or reorganizing README, `docs/`, or recording a decision.           |
| [agent-tooling](topics/agent-tooling.md)         | Writing `AGENTS.md`, adding a project skill, or adding an agent hook.       |
| [workflow](topics/workflow.md)                   | Commits, changelog, and releases in a repo with the workflow kit.           |
| [dependencies](topics/dependencies.md)           | Upgrading dependencies or reviewing Dependabot and Renovate PRs.            |

Each topic links its deeper files (`react/`, `css/`, `state/`, `tanstack/`, `agent-tooling/`). Read those only when the topic points the task
there.

## Setup and audit

`nbr-repo-setup` builds the tooling topics (agent-tooling, git, npm-project, docs-structure, workflow, dependencies) in a
repo.
[`templates/AUDIT_CHECKLIST.md`](templates/AUDIT_CHECKLIST.md) holds the checkable rules per topic, and
[`templates/REPORT.md`](templates/REPORT.md) the finding format. `nbr-repo-audit` runs a project against both without
changing it. A topic edit updates its checklist block in the same change.
