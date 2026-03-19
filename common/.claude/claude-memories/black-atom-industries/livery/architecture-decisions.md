---
name: architecture-decisions
description: Key architecture decisions made during livery development — Rust OS boundary, naming conventions, updater patterns
type: project
---

## Rust Owns OS Operations

All file system and shell operations go through Rust commands (`invoke()`), not the Tauri Shell plugin. The Shell plugin was removed entirely. Each app reload is a typed Rust command:
- `reload_ghostty` — `pkill -SIGUSR2 ghostty`
- `reload_nvim` — finds nvim sockets in `$TMPDIR`, sends `:colorscheme` via `--server`

**Why:** Security (no arbitrary shell execution from webview) and type safety.
**How to apply:** When adding new updaters, create a `src-tauri/src/updaters/<app>.rs` file.

## Naming: "Apps" not "Tools"

Config uses `apps` (not `tools`). Types are `AppName`, `AppConfig`, `AppUpdater`. Each configured application has an updater in the registry.

**Why:** Nik felt "tool" was too broad — we're configuring specific applications with updaters.

## Configurable Pattern System

Each updater uses `replaceConfigPattern` (object arg) with defaults from `src/updaters/defaults.ts`. Users can override `match_pattern` and `replace_template` in their config for non-standard setups. `{themeKey}` is the only placeholder currently.

## Claude CI Review Workflow

Label-triggered (`needs-review`), concurrency guard prevents duplicates, auto-swaps to `reviewed` label on success. Uses custom prompt with `gh pr comment` (not the inline plugin).

## Config File Location

`~/.config/black-atom/livery/config.json` — uses `"apps"` key. Old configs with `"tools"` silently fall back to defaults (Rust serde ignores unknown keys).
