---
name: dev:react
description: "Nik's React component architecture -- dumb/smart/partial pattern, folder structure, and composition principles. Load when working in React codebases."
user-invocable: false
---

# React Component Architecture

## The 4 Roles

| Role | Purpose | Has Styling? | Fetches Data? |
|------|---------|-------------|---------------|
| **Dumb Component** | How things look | Yes | No |
| **Smart Container** | How things work | No (layout utils ok) | Yes (via hooks) |
| **Partial** | Reusable composition of components | Yes | Light logic ok |
| **Layout Component** | Structural arrangement | Yes (layout only) | No |

## Core Principles

- Components are "dumb" -- no data processing, no hardcoded values, no fetching
- Components know nothing about other components (unless they inherently belong together)
- Styling lives in components, not in containers. This implies the need for Layout Components.
- Props should be simple data types where possible
- Localized text is passed as props -- no hardcoded strings in components (unless no i18n exists)
- Small utility classes for one-off layout adjustments in containers are acceptable

## Partials

A Partial is a composition of Dumb Components with light logic -- reusable or extracted because it "feels right" as a unit. Example: a `UserProfileHeader` composing `Avatar` + `UserName` + `EditButton` with click handler wiring.

## Data Flow

Fetching and data processing happen in Containers, Hooks, or Partials -- never in Dumb Components. Containers are orchestrators that delegate complex logic to topic-specific hooks.

## References

- For component examples and anti-patterns, see `component-patterns.md`
- For folder structure conventions, see `folder-structure.md`
- For hook patterns, see `hooks-as-logic-layer.md`

### Key Influences

- Dan Abramov: Smart and Dumb Components (original concept)
- Jake Trent: Broad vs Deep Split
