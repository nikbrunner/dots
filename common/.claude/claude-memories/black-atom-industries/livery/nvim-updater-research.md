---
name: nvim-updater-research
description: Research findings for the nvim updater — socket-based live reload works, config file persistence needs configurable pattern matching
type: project
---

## Nvim Live Reload

Neovim auto-creates a server socket at `$TMPDIR/nvim.<user>/*/nvim.*` — no `--listen` flag needed.

Send `:colorscheme X` to all running instances:

```bash
for s in $(find /var/folders -path "*/nvim.nbr/*/nvim.*" -type s 2>/dev/null); do
  nvim --server "$s" --remote-send ':colorscheme black-atom-jpn-koyo-hiru<CR>' 2>/dev/null
done
```

**Why:** Platform-specific: macOS uses `/var/folders/`, Linux uses `/tmp/`. Use `$TMPDIR` for portability.

**How to apply:** The nvim updater needs two actions: (1) update config file for persistence, (2) send `:colorscheme` via sockets for live switch.

## Nvim Adapter Bug (DEV-315) — FIXED

The `load()` function in black-atom/nvim had a Lua module caching issue preventing highlight reapplication on colorscheme switch. Fixed on 2026-03-18.

## Config File Persistence — TODO

Nik's nvim config has the theme in `~/.config/nvim/lua/config.lua`:

```lua
colorscheme = "black-atom-terra-fall-night",
```

This varies per user setup. The nvim updater needs configurable `match_pattern` and `replace_template` fields in `AppConfig` — same design noted on DEV-286 and DEV-287.

## Tmux Updater — TODO

Needs `themes_path` + collection name to build the source-file path. Pattern: `source-file .../themes/$collection/$theme.conf`. The `ThemeDefinition.meta.collection.key` provides the collection.
