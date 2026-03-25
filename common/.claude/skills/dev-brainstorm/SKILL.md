---
name: "dev:brainstorm"
description: "Collaborative exploration of ideas, requirements, and design decisions. Use when starting a new feature, reviewing architecture decisions, or pressure-testing a design before implementation."
---

# Brainstorm

Explore ideas collaboratively until we reach a shared understanding of what to build and how.

## Process

1. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.
2. For each question, provide your recommended answer with reasoning.
3. If a question can be answered by exploring the codebase, explore the codebase instead of asking.
4. Don't move on from a branch until we've reached agreement.
5. After all branches are resolved, summarize the final shared understanding.

## Guidelines

- Be direct. Challenge weak reasoning. Apply the Blind Spot Rule.
- Group related questions — don't ask one at a time when three are interrelated.
- Surface hidden assumptions and edge cases early.
- Track open vs resolved decisions as you go.
- When we reach shared understanding, produce a concise summary of all decisions made.

## OpenSpec Awareness

If `openspec/` exists in the project, check for active changes via `openspec list --json`. If the user's request relates to an existing change, delegate exploration to `openspec-explore` (`/opsx:explore`) — it has the same brainstorming stance but with OpenSpec plumbing for reading/updating change artifacts. When delegating, also offer `dev:visual-companion` for visual questions (see below).

If no `openspec/` exists, or the topic doesn't relate to an existing change, continue with the brainstorm process above.

See `about:openspec` for directory structure and CLI reference.

## Visual Companion

When upcoming questions involve visual content (UI layouts, architecture diagrams, mockup comparisons), offer the `dev:visual-companion` skill:

> "Some of what we're working on might be easier to show visually in a browser. Want me to start the visual companion?"

If accepted, invoke `dev:visual-companion` to start the server. Then per question, decide whether to use the browser (visual content) or terminal (text/conceptual content). Stop the server when brainstorming is done or all remaining questions are text-only.
