---
name: architecture-decisions
description: Key architecture decisions made during livery development — Rust/TS boundary, naming conventions, updater patterns
type: project
---

## TypeScript = Orchestrator, Rust = Executor

The fundamental boundary:

- **TypeScript** manages UI, state, calling order. Decides _what_ to do.
- **Rust** handles all OS operations — file I/O, process signals, socket communication. Does _how_.

No direct file system access from TypeScript. No shell commands from TypeScript. All OS operations go through typed Rust commands via `invoke()`.

**Rust commands:**

- `replace_in_file` — generic regex find-and-replace on any file (used by all updaters)
- `reload_ghostty` — `pkill -SIGUSR2`
- `reload_nvim` — socket discovery + `:colorscheme` via `--server`
- `reload_tmux` — `tmux source-file`
- `get_config` / `save_config` — livery config management

**Removed:** Tauri Shell plugin (DEV-288) and Tauri FS plugin (DEV-323). Both replaced by typed Rust commands.

**Why:** Consistency, security (no arbitrary shell/file access from webview), type safety.
**How to apply:** When adding new updaters, add Rust commands in `src-tauri/src/updaters/`. TS updaters just call `invoke()`.

## Naming: "Apps" not "Tools"

Config uses `apps` (not `tools`). Types are `AppName`, `AppConfig`, `AppUpdater`. Each configured application has an updater in the registry.

**Why:** "tool" was too broad — we're configuring specific applications with updaters.

## Configurable Pattern System

Pattern defaults live in `src/updaters/defaults.ts`. Each app has a `matchPattern` (regex) and `replaceTemplate` (with `{themeKey}`, `{appearance}`, `{collectionKey}`, `{themesPath}` placeholders). Users can override via `match_pattern`/`replace_template` in their config.

The `replace_in_file` Rust command handles the regex compilation, template rendering, and file I/O. Rust tests cover all patterns.

## Claude CI Review Workflow

Label-triggered (`needs-review`), concurrency guard prevents duplicates, auto-swaps to `reviewed` label on success. Uses custom prompt with `gh pr comment`.

## Config File Location

`~/.config/black-atom/livery/config.json` — uses `"apps"` key. Old configs with `"tools"` silently fall back to defaults.
