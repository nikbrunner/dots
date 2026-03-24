---
name: nvim-updater-research
description: Nvim updater implementation notes — socket-based live reload, platform-specific paths
type: project
---

## Nvim Live Reload

Neovim auto-creates a server socket at `$TMPDIR/nvim.<user>/*/nvim.*` — no `--listen` flag needed.

The nvim updater does two things:

1. Updates config file for persistence (via `patch_text_file` with configurable pattern)
2. Sends `:colorscheme` via sockets to all running instances for live switch

**Platform-specific:** macOS uses `/var/folders/`, Linux uses `/tmp/`. Use `$TMPDIR` for portability.

## Nvim Adapter Bug (DEV-315) — FIXED

The `load()` function in black-atom/nvim had a Lua module caching issue preventing highlight reapplication on colorscheme switch. Fixed on 2026-03-18.
