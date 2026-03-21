# Design: Personal Dev Skills for Claude Code

**Date:** 2026-03-07
**Status:** Approved
**Context:** Create personal development skills that capture Nik's coding style and preferences, so Claude writes code that feels like Nik wrote it.

## Decision: Approach C — Progressive Disclosure

Skills use lean SKILL.md files (~40-70 lines) with detailed `references/` for examples and deep dives. This follows the official Claude Code skill architecture (3-level Progressive Disclosure).

## Namespace

All skills use `dev-*` directory names and `dev:*` in the `name` field. All are `user-invocable: false` — Claude discovers and loads them automatically based on project context.

## Skill Catalog

### `dev-react` — Component Architecture

**SKILL.md (~70 lines):** Core principles — the 4 roles (Dumb Component, Smart Container, Partial, Layout Component), composition rules, prop conventions, localization.

| Reference                 | Content                                                                                                                                                 |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `component-patterns.md`   | Pseudocode examples per role, Broad vs Deep Split, anti-patterns                                                                                        |
| `folder-structure.md`     | Technical separation (`components/`, `containers/`, `partials/`, `hooks/`), multi-file component folders, co-located sub-components, naming conventions |
| `hooks-as-logic-layer.md` | Topic hooks for logic encapsulation, containers as orchestrators, co-location rules                                                                     |

**Replaces:** `react-patterns` skill (deleted).

### `dev-query` — TanStack Query & Data Fetching

**SKILL.md (~50 lines):** Server State vs Client State definition, no default library dogma, 3 complexity levels overview, TKDodo as primary influence.

| Reference             | Content                                                                                                                                                                                                    |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `query-patterns.md`   | Complexity 1 (file per endpoint with pseudocode), Complexity 2 (folder per topic), Complexity 3 (API folder for GraphQL), topic key pattern, auto-invalidation, `Omit<>` for query options, no-spread rule |
| `fetch-wrapper.md`    | Single source of truth for fetch function, auth headers, base URL, error handling                                                                                                                          |
| `state-separation.md` | Server vs Client State with examples, URL State as third category, migration pattern (Redux-everything to Redux-client + Query-server)                                                                     |

### `dev-typescript` — TypeScript Conventions

**SKILL.md (~50 lines, no references/):** Compact enough to stay in one file.

Content:

- `any` forbidden, `unknown` as last resort
- Explicit and implicit types where each makes sense
- Object arguments over positional parameters
- Clear variable and function names
- Remove unused code immediately
- Generics and type annotations actively used
- No temporal coupling (no init-to-null-then-update)
- Standard APIs over custom wrappers
- Clean, minimal, self-documenting code

### `dev-testing` — Testing Approach

**SKILL.md (~40 lines):** Testing philosophy — what to test and how.

| Reference     | Content                                                                                                                                                                                              |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `patterns.md` | Vitest for unit tests (lib/utility functions), Storybook visual regression (screenshot comparison), Storybook interaction tests (Playwright-based), direction toward programmatic user story testing |

### `dev-greenfield` — Project & Feature Kickoff

**SKILL.md (~50 lines):** Design-before-code process — when to wireframe, when screenshots suffice, multi-document planning.

| Reference              | Content                                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------------------- |
| `wireframing-tools.md` | OpenPencil (AI-native, local, .fig compatible, BYOK), Excalidraw (quick sketches), Figma (real designs) |
| `planning-tools.md`    | Beads (git-backed graph issue tracker), Linear (team projects), Markdown plans (solo/small projects)    |

## CLAUDE.md Changes

Slimmed from 47 to ~33 lines:

- **Keep:** Who I Am (3 lines), Communication + Blind Spot Rule (full), "Research before implementation"
- **Move to `dev-typescript`:** no `any`, no temporal coupling, standard APIs over custom wrappers, clean/minimal code
- **Cut (redundant):** "Ask before creating new files" (system prompt), "Prefer editing existing" (system prompt), semantic commits (enforced by hook)
- **Cut (Penny territory):** Task Management section (3 lines)
- **Update:** Skill reference links to new `dev-*` names

## Deleted Files

- `skills/react-patterns/SKILL.md` — replaced by `dev-react`

## Out of Scope (Future)

- Atomic React/TS concept skills inspired by react.dev/reference
- Beads integration — evaluate, no skill yet
- OpenPencil workflow — mentioned in reference, no dedicated skill
- Task Management lines — removed, revisit in penny-profile if needed

## Key Influences

- Dan Abramov: Smart and Dumb Components (the original concept)
- Jake Trent: Smart and Dumb Components in React (Broad vs Deep Split)
- TKDodo: Practical React Query blog (query patterns, auto-invalidation, render optimizations)
- Claude Code Skill Architecture: Progressive Disclosure design principle

## First Test Case

ImFusion DICOM Dashboard coding assignment (2026-03-12, max 4h). Skills `dev-react`, `dev-query`, `dev-typescript`, and `dev-greenfield` should all trigger naturally.
