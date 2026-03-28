# Phase 1: Start

## When to use

Automatic entry point for any development task. Runs whenever I describe work or invoke `/dev:flow start`.

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

4. **Present the assessment.** "This looks [scope] — I'll [route]. Sound right?" Let me confirm or override.

5. **If scope is unclear**, ask ONE clarifying question via `AskUserQuestion`. Infer what you can — don't over-ask.

## Routing

| Scope   | Route                                                               |
| ------- | ------------------------------------------------------------------- |
| Trivial | Implement directly, verify, commit, done                            |
| Small   | Optional brainstorm, implement, close                               |
| Medium  | Suggest Phase 2 (propose). If declined, implement directly          |
| Large   | Suggest Phase 2 (propose) + `dev:prd-to-issues` for issue breakdown |

## Brainstorm (optional, any scope)

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

- Challenge weak reasoning. Surface hidden assumptions early
- For refactors: consider alternatives first, ruthlessly cut scope, define what's explicitly out of scope
- If `openspec/` exists and the topic relates to an active change, delegate to `opsx:explore`
- Offer `dev:util:visual-companion` when questions involve UI layouts or diagrams

## Transition to Phase 2

I invoke `/dev:flow propose` or `/opsx:propose`. Claude suggests it for medium+ scope but never forces it. I can always say "skip planning, just code" to jump to Phase 3.
