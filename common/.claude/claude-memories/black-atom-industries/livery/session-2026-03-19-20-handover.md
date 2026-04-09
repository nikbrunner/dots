---
name: session-handover-2026-04
description: Current project status as of 2026-04-08 — Storybook abandoned for /dev routes, theme persistence issue filed, pre-commit hooks migrated
type: project
---

## v0.2.0 Released (2026-03-24)

All "Base Updaters" milestone work is complete. See git log for full PR list.

### Shipped post-v0.2.0 (on main, pre-v0.3.0)

| Commit  | What                                                       | Issue |
| ------- | ---------------------------------------------------------- | ----- |
| ce766be | Glossary: added "Update" term                              | —     |
| 340d725 | Fix: skip obsidian reload when app not running             | —     |
| 1170141 | Global shortcut to toggle window visibility                | —     |
| e654a30 | macOS install task (`deno task install:macos`) + PATH fix  | #41   |
| 9048ae5 | Reorganized design docs into `design/` directory           | —     |
| 638f25e | Migrated pre-commit hooks to `.githooks/` + core.hooksPath | —     |

### Feature branch: `feat/ui-rework-foundation`

Commits so far:

- Stitch skills added then removed (cleanup)
- CVA + token mapping from @black-atom/core (#29)
- `selectedTheme` → `currentTheme` rename

Uncommitted work in progress:

- `/dev` route system (Storybook replacement)
- Badge component (first Dumb Component)
- ThemeProvider, DevLayout components
- autoCodeSplitting disabled in vite.config.ts

### Current milestone: Frontend & UI (implementation active)

- **#29** — UI rework: CSS Modules foundation and first components (in progress, rewritten PRD)
- **#44** — Persist current theme in Tauri app data (created 2026-04-07, todo)
- **#42** — Design language via Stitch (STALE — Stitch abandoned, design captured in DESIGN.md)
- **#43** — Plan UI components (STALE — subsumed by rewritten #29)
- Other open: progress indicator redesign (#30), settings page (#32), setup wizard (#35)

### Pre-commit Hooks (2026-04-07)

Migrated from `scripts/hooks/` + manual copy to `.githooks/` + `git config core.hooksPath`. Frontend format check switched from `deno fmt` (write) to `deno fmt --check` (reject). Check scripts live in `.githooks/checks-frontend.ts` and `.githooks/checks-backend.ts`.

### Tooling

- Issue tracking on GitHub Issues (migrated from Linear 2026-03-28)
- `GLOSSARY.md` — formal domain glossary
