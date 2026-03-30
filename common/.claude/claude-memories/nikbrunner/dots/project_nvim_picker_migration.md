---
name: Nvim picker migration to Snacks
description: Migrated all picker functionality from MiniPick to Snacks.picker on 2026-03-28. Snacks is sole picker, mini.pick fully removed.
type: project
---

On 2026-03-28, migrated all Neovim picker functionality from MiniPick back to Snacks.picker. Snacks is now the sole picker — mini.pick, mini.extra, and mini.visits were all removed.

**Why:** Nik wanted Snacks as the main picker again after trying MiniPick (migrated via commit b271caaadad9 on 2026-02-24). Decision was full replacement — no MiniPick fallback.

**How to apply:** All picker keymaps and custom pickers live in `lua/specs/snacks.lua`. Session helpers extracted to `lua/lib/sessions.lua` for cross-spec use.

## What changed

- **snacks.lua** (420 → 639 lines): Added 4 custom pickers (project_files, project_switch, associated_files, buffer_jumps), ~60 keymaps, restored source configs, enabled ui_select
- **mini.lua** (1093 → 775 lines): Removed MiniPick section (~440 lines), removed M.extra() and M.visits(), updated MiniFiles picker to use Snacks
- **New file**: `lua/lib/sessions.lua` — extracted get_session_name for cross-spec use (snacks project_switch + mini.sessions)
- **project_switch** integrates with mini.sessions (save/restore), not Snacks.dashboard

## Key architecture decisions

- `Snacks.picker.smart()` replaces custom frecency picker (Snacks has built-in frecency + cwd_bonus)
- `Snacks.picker.git_status()` replaces custom git_changed picker
- Custom pickers use `Snacks.picker({ items = ..., confirm = ... })` API
- `vim.ui.select` now handled by Snacks (ui_select = true)

## Status

Committed as `6cef1af` on 2026-03-28 on `feat/openspec-integration` branch. Not yet merged to main.
