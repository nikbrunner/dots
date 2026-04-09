---
name: design-brainstorm-2026-03-21
description: Black Atom UI design — DESIGN.md at design/DESIGN.md, token system working, /dev route replaces Storybook, Phase 1 in progress on feat/ui-rework-foundation
type: project
---

## Black Atom Design Language — Status as of 2026-04-08

**DESIGN.md:** `livery/design/DESIGN.md` — refined with 3-voice typography, component patterns,
anti-patterns, color system referencing core's Terra Fall hue range.

**Implementation branch:** `feat/ui-rework-foundation` — Phase 1 in progress.

**Completed (committed by 2026-04-08):**

- CVA installed and working with Deno + Vite
- Token mapping module (`src/lib/tokens.ts`) imports `@black-atom/core` from JSR, maps theme UI
  colors to CSS custom properties on `:root`. 36 variables. All hex, no OKLCH conversion needed.
- Root layout wires tokens via useEffect — defaults to `terra-fall-night` for app chrome
- `selectedTheme` renamed to `currentTheme` across codebase for clarity

**Completed (uncommitted, in working tree 2026-04-08):**

- Storybook 10 attempted → abandoned (CJS/ESM issues, SB9 breaking changes, addon-essentials removed)
- `/dev` route system built as Storybook replacement:
  - `DevLayout` component (Layout role: nav/aside/children slots, structural CSS only)
  - `ThemeProvider` component for independent theme switching in dev routes
  - `/dev/badge` (primitives showcase), `/dev/typography` pages
  - `deno task dev:ui` opens Vite standalone at `/dev`
- Badge component built (first Dumb Component with CSS Modules + CVA)
- `autoCodeSplitting` disabled in vite.config.ts (caused 504s with TanStack Router, not needed)

**Remaining Phase 1 tasks:**

- Commit and verify the /dev route + Badge + ThemeProvider work
- Global theme-switching decorator in /dev layout (partially done — ThemeProvider exists)

**Plan file:** `plans/ui-rework-foundation.md` — 4 phases covering infra, new components,
migration of existing 5 components, and Tailwind removal.

**PRD:** GitHub #29 — rewritten as UI rework kickoff issue.

**Design direction (unchanged):**

- Creative north star: "Warm Precision"
- 3-voice typography: Space Grotesk (display), IBM Plex Sans or Geist (body, TBD), JetBrains Mono (mono)
- Berkeley Mono licensing inquiry pending (ui#5)
- Terra Fall family (hue ~50) is closest core reference for light mode
- Default Dark (hue 195) works for dark mode
- 0px border-radius, 1px borders, no shadows, tonal layering only

**Key decisions:**

- Stitch abandoned as design tool (too little control, Google dependency)
- Storybook abandoned — replaced with `/dev` route system (simpler, no extra deps, works with Deno)
- Component library decision deferred until after building first components
- CSS Modules migration happens during component redesign, not separately
- All 5 existing components get migrated + redesigned in one issue
- Colors import from @black-atom/core via JSR — no hardcoded hex values
- autoCodeSplitting disabled — not worth the complexity for small app
