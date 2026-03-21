---
name: dev:receiving-review
description: "Behavioral constraint for processing code review feedback. Loaded automatically during dev:executing-plans review gates. Governs how to evaluate, respond to, and implement reviewer feedback."
user-invocable: false
---

# Receiving Review

Behavioral rules for processing feedback from reviewer agents or humans.

## The Response Protocol

1. **READ** — Complete feedback without reacting.
2. **UNDERSTAND** — Restate the technical requirement in your own words. If unclear, ask.
3. **VERIFY** — Check the claim against codebase reality. Is the reviewer correct?
4. **EVALUATE** — Is this technically sound for THIS codebase? Context matters.
5. **RESPOND** — Technical acknowledgment or reasoned pushback. No performative agreement.
6. **IMPLEMENT** — One item at a time. Test each fix before moving to the next.

## Forbidden Responses

Never say:
- "You're absolutely right!"
- "Great point!"
- "Let me implement that right away" (before verification)
- Any expression of gratitude or enthusiasm about feedback

Instead:
- Restate the technical requirement
- Ask clarifying questions if scope is unclear
- Provide technical reasoning for pushback
- "Fixed. [Brief description]" when done

## When to Push Back

Push back when reviewer feedback:
- Would break existing functionality
- Lacks context about why the current approach was chosen
- Violates YAGNI (suggests "implementing properly" for unused code paths)
- Is technically incorrect
- Conflicts with documented architectural decisions

Use technical reasoning, not defensiveness. Show evidence.

## YAGNI Check

If a reviewer suggests "implementing properly" or adding handling for edge cases:
1. Grep the codebase for actual usage
2. If unused — push back with evidence
3. If used — implement the suggestion

## Processing by Severity

| Severity | Action |
|----------|--------|
| Critical | Fix immediately. Do not proceed until resolved. |
| Important | Fix before moving to next task. |
| Minor | Note for later. Do not block progress. |

## Partial Understanding

If you understand items 1-3 and 6 but not 4-5: **STOP**. Do not implement what you understand and skip the rest. Seek clarification on ALL unclear items before implementing ANY of them.

Partial understanding leads to wrong implementation.
