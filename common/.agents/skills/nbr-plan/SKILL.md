---
name: nbr-plan
description:
  "Nik's planning flow and plan shape: grill the idea to shared understanding, optionally record decisions in the repo's
  docs, then write a plan that reads for a Product Owner and a Developer (prose per section, implementation and
  verification beneath it) and review it in Plannotator. Use when asked to plan a change, for every plan written in plan mode, and when asked to grill an idea,
  which stops after the grill."
---

# Plan a change

A plan has two readers. The **Product Owner** reads it top to bottom and skips every Implementation block: the goal,
the decisions, each slice's prose, and the scope must tell them what changes for the user, why, and in which order, in
product language with no code terms. The **Developer** reads the same plan and finds what they need to build and verify
each slice in its Implementation block.

## 1. Grill

Interview until the design is settled. Map the decisions as a **design tree**: each decision branches into the ones that
hang off it, and the **frontier** is every decision whose prerequisites are settled.

- Ask one frontier question per message, with your recommended answer, and wait. Bundle questions only when they are
  facets of one decision.
- Facts are your job: look up what the repo, docs, or tools can answer, and dispatch a subagent for longer digs. Only
  decisions go to Nik.
- A question already settled by the conversation is skipped.

The grill is done when the frontier is empty and Nik confirms the shared understanding. A small, clear request can reach
that after one or two questions.

## 2. Record decisions (optional)

Ask once whether any decision belongs in the repo's documentation, and propose where. Write only on a yes.

Decisions go into the repo's real documentation, following the `docs-structure` topic of `nbr-repo-conventions`: the
`docs/<topic>.md` page a reader would open for that subject, extended or new, with the decision's reason.

## 3. Write the plan

Use this shape:

```markdown
# <Plan title>

<Goal: a short paragraph for the Product Owner. What changes, for whom, and why now.>

## Decisions

- <Decision>, because <reason>.

## <One section per slice, in build order>

<For the Product Owner: what this slice changes for the user and why, in prose.>

**Implementation**

- For the Developer: files, APIs, data shapes, edge cases
- Verification: how this slice is proven to work

## Out of scope

## Open questions
```

- A slice is a piece that works and can be verified on its own.
- The prose carries the reasoning, in words the Product Owner uses. A technical decision with product impact (a slower
  first load, a migration users notice) is stated there by its effect.
- The Implementation bullets carry what the Developer, human or agent, needs to execute: paths, names, commands, and
  existing code to reuse. Code snippets appear only where a signature or shape is the decision.
- Add a Mermaid diagram after the goal when three or more components interact and the text alone leaves the flow unclear.
- Empty Out of scope or Open questions sections are dropped.

Run `humanizer` over everything the Product Owner reads. The Implementation bullets stay as written.

The plan is ready when the Product Owner pass, reading only the prose, explains every slice, and every Implementation
block lets the Developer start and verify that slice without asking.

## 4. Review

Present the plan through the host's plan mode; exiting plan mode opens it in Plannotator. Without plan mode, write it to
a file and open it with `plannotator-annotate`. Address every annotation, revise, and present again until Nik approves.
