---
name: dev:flow
description: "Development workflow — orient, propose, build, close. Invoke with an argument to jump to a phase, or without to see the overview."
argument-hint: "[start|propose|build|close]"
user-invocable: true
---

# dev:flow

The development lifecycle in 4 phases. Read the phase doc matching `$ARGUMENTS` and follow its steps.

## Routing

| Argument  | Phase doc                    | What happens                                                 |
| --------- | ---------------------------- | ------------------------------------------------------------ |
| `start`   | [1-start.md](1-start.md)     | Orient, gather context, check OpenSpec, assess scope         |
| `propose` | [2-propose.md](2-propose.md) | Draft plan, create PRD or OpenSpec change, review gates      |
| `build`   | [3-build.md](3-build.md)     | Implement tasks, per-task verification, track progress       |
| `close`   | [4-close.md](4-close.md)     | Verify, ship (merge/PR/keep), archive OpenSpec, close issues |
| _(none)_  | Show this overview           | Ask which phase, or auto-detect from context                 |

If no argument given and an active OpenSpec change exists with pending tasks, route to `build`.

## OpenSpec

If `openspec/` exists: check for active changes on `start`, use `opsx:propose` during `propose`, use `opsx:apply` during `build`, run `openspec archive` during `close`.

## Responsibility

- **I trigger**: `/dev:flow close` (Claude never assumes work is done)
- **Claude does**: check active work, route, track tasks, surface "all tasks complete"
- **Claude asks**: "This looks medium — want to propose?" / "All tasks done — ready to close?"
