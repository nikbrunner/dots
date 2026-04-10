---
name: feedback-css-modules
description: Nik prefers CSS Modules over Tailwind — migration actively underway in feat/ui-rework-foundation
type: feedback
---

Default styling approach is CSS Modules + CVA, not Tailwind.

Tailwind is currently installed and used (`@import "tailwindcss"` in `src/index.css`), but the
migration to CSS Modules is actively underway on `feat/ui-rework-foundation`. New components (Badge,
DevLayout, ThemeProvider) already use CSS Modules. Phase 4 of the plan removes Tailwind entirely.

**Why:** Explicit preference — Nik corrected when Tailwind was assumed for DEV-318.

**How to apply:** All new components use CSS Modules + CVA. Don't suggest Tailwind. Existing Tailwind
usage will be removed during Phase 3-4 of the UI rework (#29). Folder convention: `badge/badge.tsx`

- `badge/badge.module.css` + `badge/index.ts` (kebab-case, per AGENTS.md).
