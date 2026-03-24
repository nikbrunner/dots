---
name: tauri-learnings
description: Tauri v2 platform constraints — FS scoping gotchas, webview limitations, debugging tips
type: project
---

## FS Plugin Scoping

- `fs:allow-read-text-file` / `fs:allow-write-text-file` grant the API, NOT path access
- Must add `fs:scope` with explicit `allow` entries for every path
- **Dotfolders (`.config`, `.ssh`) are NOT matched by globs** like `$HOME/.config/**/*`
- Must specify paths after the dotfolder explicitly: `$HOME/.config/ghostty/*`
- `requireLiteralLeadingDot: false` in `tauri.conf.json` did NOT fix dotfolder glob matching
- Scope variables: `$HOME`, `$CONFIG`, `$APPDATA`, etc. — not tilde expansion
- **Capabilities are compiled into the binary** — they are static, not runtime-configurable

## Shell Plugin Scoping

- Shell `validator` regex needs `.+` (not `\S+`) because `sh -c` args contain spaces
- Commands are scoped by name (e.g., `exec-sh`) — reference by name in `Command.create()`

## Webview vs Deno Runtime

- `Deno.env`, `Deno.readTextFile`, `@std/path` do NOT exist in the Tauri webview
- Use `@tauri-apps/api/path` for `homeDir()`, `join()`, etc.
- Use `@tauri-apps/plugin-fs` for file operations
- Use `@tauri-apps/plugin-shell` for shell commands

**Note:** As of v0.2.0, FS and Shell plugins are removed (DEV-288, DEV-323). All OS operations go through typed Rust commands via tauri-specta.

## Debugging

- Errors caught silently are invisible — always `console.error` in catch blocks
- Tauri webview devtools: right-click → Inspect Element in dev mode
- Chrome DevTools MCP connects to browser tabs, not the Tauri webview
