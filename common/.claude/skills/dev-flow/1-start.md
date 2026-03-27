# Phase 1: Start

## When to use

Automatic entry point for any development task. Runs whenever Nik describes work or invokes `/dev:flow start`.

## BAI Auto-Detection

If repo path contains `black-atom-industries`, load Linear context automatically (team, project, active cycle). No separate `bai:start` needed.

## Steps

1. **Check for active OpenSpec changes.** If `openspec/` exists, run `openspec list --json`. If the request matches an existing change, route to Phase 3 via `opsx:apply` — skip everything else.

2. **Gather context from the prompt.** Look for:
   - Issue/ticket reference (GitHub, Linear)
   - Whether this is greenfield or modification
   - How many files/modules are likely involved

3. **Assess scope.**

   | Scope   | Signals                                     |
   | ------- | ------------------------------------------- |
   | Trivial | One-liner, typo, config change, rename      |
   | Small   | Single-file bugfix, isolated feature        |
   | Medium  | Multi-file feature, new module, API changes |
   | Large   | Multi-system, cross-cutting concerns        |

4. **Present the assessment.** "This looks [scope] — I'll [route]. Sound right?" Let Nik confirm or override.

5. **If scope is unclear**, ask ONE clarifying question via `AskUserQuestion`. Infer what you can — don't over-ask.

## Routing

| Scope   | Route                                                               |
| ------- | ------------------------------------------------------------------- |
| Trivial | Implement directly, verify, commit, done                            |
| Small   | Optional brainstorm, implement, close                               |
| Medium  | Suggest Phase 2 (propose). If declined, implement directly          |
| Large   | Suggest Phase 2 (propose) + `dev:prd-to-issues` for issue breakdown |

## Brainstorm (optional, any scope)

When Nik wants to explore before committing to an approach:

- Walk the design tree branch by branch, resolving decisions one at a time
- Provide recommended answers with reasoning — don't just ask, also propose
- If a question can be answered by reading code, read the code instead of asking
- Challenge weak reasoning. Surface hidden assumptions early
- Group related questions — don't ask one at a time when three are interrelated
- If `openspec/` exists and the topic relates to an active change, delegate to `opsx:explore`
- Offer `dev:util:visual-companion` when questions involve UI layouts or diagrams

## Transition to Phase 2

Nik invokes `/dev:flow propose` or `/opsx:propose`. Claude suggests it for medium+ scope but never forces it. Nik can always say "skip planning, just code" to jump to Phase 3.
