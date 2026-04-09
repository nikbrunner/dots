---
name: frontend-component-library-eval
description: Component library deferred, Storybook abandoned for /dev route, visual dev via TanStack Router routes
type: project
---

## Component Library Decision (deferred as of 2026-04-07)

Issue #29 rewritten from "evaluate BaseUI vs Mantine" to "UI rework: CSS Modules foundation and
first components." The library decision is intentionally deferred.

**Current approach:** Build Badge, Button, ColorSwatch as custom Dumb Components with CSS Modules +
CVA. Evaluate what a library would buy us after seeing the actual needs. Base UI is installed in
deno.json but unused.

**Why:** Nik pushed back on deciding the library before knowing which components we need. The "Warm
Precision" aesthetic (0px radius, 1px borders, bracket buttons, monochrome chrome) is too custom
for any library's defaults. Better to build custom first and see if headless primitives (focus
management, aria, dialogs) are needed.

**How to apply:** Don't assume any component library. Build custom with CSS Modules + CVA. If a
component needs complex accessibility or interaction patterns (dialogs, dropdowns, focus traps),
then evaluate Base UI for that specific need.

## Visual Development Environment

**Storybook attempted (2026-04-07) and abandoned.** Issues: CJS/ESM conflicts with Deno,
addon-essentials removed in SB9+, version conflicts between package.json and deno.json. Not worth
the complexity.

**Replaced with `/dev` route system:**

- TanStack Router routes under `/dev` (layout route + child pages)
- `DevLayout` component — Layout role with nav/aside/children slots
- `ThemeProvider` — independent theme switching for dev routes
- `deno task dev:ui` opens Vite standalone (no Tauri) at `/dev`
- Pages: `/dev/badge` (primitives), `/dev/typography`
- Extensible: add `/dev/buttons`, `/dev/colors` etc. as new components are built

**How to apply:** When building new components, add a `/dev/<component>` route to showcase variants.
Don't suggest Storybook — it was tried and doesn't work well with the Deno + Vite stack.
