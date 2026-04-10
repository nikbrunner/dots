---
name: livery
description: Black Atom desktop theme manager (Tauri v2 + React) — GUI replacement for pick-theme
type: project
---

Livery is a Black Atom Industries desktop app for managing themes across developer tools. It's the GUI evolution of the `pick-theme` CLI script in dots.

**Why:** pick-theme works but is script-based; Livery provides a proper desktop UI with Tauri v2.

**How to apply:** When working on pick-theme or theme infrastructure in dots, consider how changes affect Livery. Livery should support CLI arguments for programmatic testing without the UI (same pattern as `pick-theme <theme-name>`).

- Repo: `~/repos/black-atom-industries/livery`
- Tracking: GitHub Issues + GitHub Projects ("Black Atom V1" project #7, migrated from Linear 2026-03-30)
- Stack: Deno, Tauri v2, React 18, Vite 6, Tailwind v4, `@black-atom/core` (JSR)
- Config: `~/.config/black-atom/livery/config.json`
