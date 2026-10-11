---
name: nbr-repo-conventions
description:
  "Nik's conventions for personal projects, as topics: TypeScript, React, CSS, state, TanStack, agent tooling (AGENTS.md,
  skills), Git hooks, the commit-to-release workflow (Conventional Commits, release-please, CHANGELOG.md), and dependency
  upgrades. Use whenever a task writes or reviews code in those areas or changes a repo's tooling. Read only the topics
  that match."
user-invocable: false
---

# Conventions

These are Nik's defaults for personal projects. A project's stated, working choice wins: use a topic to fill a gap or to make
a deliberate deviation visible, not to reshape code that works.

## Choose a topic

| Topic                                    | Read when                                                                   |
| ---------------------------------------- | --------------------------------------------------------------------------- |
| [typescript](topics/typescript.md)       | Writing TypeScript: type safety, derivation, function design, naming.       |
| [react](topics/react.md)                 | Designing components, roles, folder structure, hooks, or reviewing effects. |
| [css](topics/css.md)                     | Writing CSS: CSS Modules, CVA, co-located styles.                           |
| [state](topics/state.md)                 | Deciding where state lives: server, URL, or client.                         |
| [tanstack](topics/tanstack.md)           | Any `@tanstack/*` package: Query, Form, Router, the TanStack CLI for docs.  |
| [agent-tooling](topics/agent-tooling.md) | Writing `AGENTS.md`, adding a project skill, or adding agent enforcement.   |
| [hooks](topics/hooks.md)                 | Choosing a hook manager or deciding what runs on pre-commit and pre-push.   |
| [workflow](topics/workflow.md)           | Commits, changelog, and releases in a repo with the workflow kit.          |
| [dependencies](topics/dependencies.md)   | Upgrading dependencies or reviewing Dependabot and Renovate PRs.            |

Each topic links its deeper files (`react/`, `css/`, `state/`, `tanstack/`, `agent-tooling/`). Read those only when the topic points the task
there.

## Setup and audit

`nbr-repo-setup` builds the tooling topics (agent-tooling, hooks, workflow, dependencies) in a repo.
[`templates/AUDIT_CHECKLIST.md`](templates/AUDIT_CHECKLIST.md) holds the checkable rules per topic, and
[`templates/REPORT.md`](templates/REPORT.md) the finding format. `nbr-repo-audit` runs a project against both without
changing it. A topic edit updates its checklist block in the same change.
