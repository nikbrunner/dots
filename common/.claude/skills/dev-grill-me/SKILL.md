---
name: "dev:grill-me"
description: "Interview the user relentlessly about a plan or design until reaching shared understanding. Use when starting a new feature, reviewing architecture decisions, or pressure-testing a design before implementation."
---

# Grill Me

Interview me relentlessly about every aspect of this plan until we reach a shared understanding.

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
