---
name: dev:testing
description: "Nik's testing approach -- unit tests for logic, visual regression via Storybook, interaction tests. Load when setting up tests or discussing test strategy."
user-invocable: false
---

# Testing Approach

## Philosophy

Test what matters. Logic gets unit tests. Components get visual tests. User flows get interaction tests.

## Testing Layers

| Layer | Tool | What to Test |
|-------|------|-------------|
| **Unit** | Vitest | Lib functions, utilities, pure logic, transformations |
| **Visual** | Storybook | Component appearance, states, variants (visual regression requires extra setup) |
| **Interaction** | Storybook + Playwright | User flows, click sequences, form submissions |

## Priorities

1. Unit tests for any non-trivial logic (pure functions, transformers, validators)
2. Storybook stories for every reusable component (doubles as documentation)
3. Interaction tests for critical user flows (emerging practice)

## What NOT to Test

- Implementation details (don't test that setState was called)
- Trivial code (simple prop pass-through, basic renders)
- Framework behavior (React rendering, router navigation)

## References

- For setup patterns and examples, see `patterns.md`
