---
name: dev-flow
description: "Development workflow — assess, plan, implement, review, close. Invoke with an argument to jump to a phase, or without to see the overview."
argument-hint: "[assess|plan|implement|review|close]"
---

# dev:flow

The development lifecycle in 5 phases. Read the phase doc matching `$ARGUMENTS` and follow its steps.

## Flow

```
assess --> plan --> implement --> review --> close
  |          |          ^
  |          +- park ---+-- park
  +- trivial/small -----+
```

**The flow can be parked after any phase.** When work is tracked (issue filed, plan written) but not continuing now, confirm the artifact is complete and end cleanly. Don't leave the user hanging mid-flow.

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

## Sub-documents

Phase docs reference these helpers — **load them when indicated**:

| File                                        | Used by      | Purpose                                            |
| ------------------------------------------- | ------------ | -------------------------------------------------- |
| [interview.md](guides/interview.md)         | assess, plan | Structured Q&A to reach shared understanding       |
| [write-a-prd.md](guides/write-a-prd.md)     | assess       | PRD template + GitHub issue creation checklist     |
| [prd-to-plan.md](guides/prd-to-plan.md)     | plan         | Break PRD into phased plan file (vertical slices)  |
| [prd-to-issues.md](guides/prd-to-issues.md) | plan         | Break PRD into GitHub sub-issues (vertical slices) |

## Further context

If repo path contains `black-atom-industries`, load `about:bai` skill.
