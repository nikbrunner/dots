---
name: dev:flow
description: "Development workflow — assess, plan, implement, review, close. Invoke with an argument to jump to a phase, or without to see the overview."
argument-hint: "[assess|plan|implement|review|close]"
---

# dev:flow

The development lifecycle in 5 phases. Read the phase doc matching `$ARGUMENTS` and follow its steps.

## Flow

```
assess ──→ plan ──→ implement ──→ review ──→ close
  │                     ↑
  └─ trivial/small ─────┘  (skip plan)
```

Any phase can be entered directly via `/dev:flow <phase>`.

## Routing

| Argument    | Phase doc                        | What happens                                               |
| ----------- | -------------------------------- | ---------------------------------------------------------- |
| `assess`    | [1-assess.md](1-assess.md)       | Orient, gather context, assess scope, write PRD if needed  |
| `plan`      | [2-plan.md](2-plan.md)           | Create implementation plan from PRD                        |
| `implement` | [3-implement.md](3-implement.md) | Implement tasks, per-task verification, track progress     |
| `review`    | [4-review.md](4-review.md)       | Final verification, implementation review, human test plan |
| `close`     | [5-close.md](5-close.md)         | Ship (merge/PR/keep), close issues, knowledge sync         |
| _(none)_    | Show this overview               | Ask which phase, or auto-detect from context               |

## Further context

If repo path contains `black-atom-industries`, load `about:bai` skill.
