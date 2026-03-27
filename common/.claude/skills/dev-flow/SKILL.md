---
name: "dev:flow"
description: "Development workflow — orient, propose, build, close. Invoke with an argument to jump to a phase, or without to see the overview."
user-invocable: true
---

# dev:flow

The development lifecycle in 4 phases.

## Arguments

| Invocation          | Description                                                                               |
| ------------------- | ----------------------------------------------------------------------------------------- |
| `/dev:flow`         | Show overview of all phases and current state.                                            |
| `/dev:flow start`   | Orient on a task — gather context, identify scope, check for active OpenSpec changes.     |
| `/dev:flow propose` | Draft a plan — outline approach, trade-offs, and acceptance criteria before writing code. |
| `/dev:flow build`   | Execute the plan — implement, test, iterate.                                              |
| `/dev:flow close`   | Wrap up — commit, verify, archive OpenSpec if applicable, surface completion to Nik.      |

## OpenSpec Integration

If `openspec/` exists, check for active changes on start. Archive happens automatically during close.

## Phases

1. [Start](1-start.md)
2. [Propose](2-propose.md)
3. [Build](3-build.md)
4. [Close](4-close.md)

## Responsibility

Nik triggers `/dev:flow close`. Claude checks active work, routes, and surfaces completion.
