---
name: architecture-decisions
description: Key architecture decisions made during livery development — Rust/TS boundary, updater consolidation, file_ops, tauri-specta
type: project
---

## TypeScript = Orchestrator, Rust = Executor

The fundamental boundary:

- **TypeScript** manages UI, state, calling order. Decides _what_ to do.
- **Rust** handles all OS operations — file I/O, process signals, socket communication. Does _how_.

No direct file system access from TypeScript. No shell commands from TypeScript. All OS operations go through typed Rust commands.

**Why:** Consistency, security (no arbitrary shell/file access from webview), type safety.

## Consolidated Updater Architecture (DEV-327)

As of v0.2.0, there are no per-app frontend updater files. The `src/updaters/` directory was removed entirely.

**Two Rust commands handle all updates:**

- `update_app` — takes `AppName` + `ThemeContext`, dispatches to the correct per-app module internally
- `update_system_appearance` — macOS `osascript` / Linux appearance toggle

**Per-app Rust modules** (`src-tauri/src/updaters/`): ghostty, nvim, tmux, lazygit, zed, obsidian, system_appearance

**How to apply:** When adding new updaters, add a Rust module in `src-tauri/src/updaters/`, register it in `mod.rs`'s dispatch match. No frontend changes needed.

## File Operations Library (`file_ops/`)

Three file operation modules in `src-tauri/src/updaters/file_ops/`:

- `text.rs` — `patch_text_file`: regex find-and-replace with template variables (ghostty, nvim, tmux, delta)
- `yaml.rs` — `patch_yaml_file`: lossless YAML merge with comment preservation (lazygit). Uses nikbrunner/yaml-edit fork.
- `jsonc.rs` — `patch_jsonc_file`: format-preserving JSONC editing (zed)

All three share: home-directory guard with `canonicalize()`, tilde expansion, path validation.

## tauri-specta (DEV-329)

Type-safe invoke calls via tauri-specta. Rust commands are exported as typed TypeScript functions in `src/bindings.ts` (auto-generated on dev build). Frontend calls `commands.updateApp(...)` instead of raw `invoke("update_app", ...)`.

## Naming: "Apps" not "Tools"

Config uses `apps` (not `tools`). Types are `AppName`, `AppConfig`. Each configured application has an updater module.

## Configurable Pattern System

Pattern defaults live in `config/defaults.rs`. Each text-based app has a `matchPattern` (regex) and `replaceTemplate` (with `{themeKey}`, `{appearance}`, `{collectionKey}`, `{themesPath}` placeholders). Users can override via `match_pattern`/`replace_template` in their config.

## Config File Location

`~/.config/black-atom/livery/config.json` — uses `"apps"` key.
