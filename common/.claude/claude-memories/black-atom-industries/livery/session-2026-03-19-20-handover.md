---
name: session-handover-2026-04
description: Current project status as of 2026-04-04 — post v0.2.0 features shipped, frontend/UI milestone next
type: project
---

## v0.2.0 Released (2026-03-24)

All "Base Updaters" milestone work is complete. See git log for full PR list.

### Shipped post-v0.2.0 (on main, pre-v0.3.0)

| Commit  | What                                                      | Issue |
| ------- | --------------------------------------------------------- | ----- |
| ce766be | Glossary: added "Update" term                             | —     |
| 340d725 | Fix: skip obsidian reload when app not running            | —     |
| 1170141 | Global shortcut to toggle window visibility               | —     |
| e654a30 | macOS install task (`deno task install:macos`) + PATH fix | #41   |

### Global Shortcut

- Uses `tauri-plugin-global-shortcut`
- Configurable via `config.keymappings.toggle_window` (default: `super+ctrl+alt+shift+KeyT` = Hypr+T)
- Reads shortcut string from config at startup, registers globally
- Nik's preference: shortcut in config as preparation for future UI configurability

### macOS Install

- `deno task install:macos`: builds via `@tauri-apps/cli`, copies `.app` bundle to `/Applications/`

### Next milestone: Frontend & UI

Open items tracked as GitHub Issues:

- #29 — frontend architecture (Nik considers this a research/preparation issue, may split)
- Progress indicator redesign
- Settings page UI design
- Setup wizard
- Logo and banner

### Tooling

- Issue tracking on GitHub Issues (migrated from Linear 2026-03-28)
- `GLOSSARY.md` — formal domain glossary
- Stitch MCP connected (confirmed 2026-04-04) — project ID 11018168170664527349
