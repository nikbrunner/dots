# Livery Project Memory

## Tauri v2 Learnings

See [tauri-learnings.md](tauri-learnings.md) for details on FS scoping, shell permissions, and webview constraints.

## Nvim Updater Research

See [nvim-updater-research.md](nvim-updater-research.md) for socket-based live reload, config persistence patterns, and DEV-315 fix status.

## Nik's Git Workflow Preferences

- **Every commit must be green** — a working state. Don't commit broken code.
- **Amend** small fixes into the previous commit rather than creating fix-on-fix commits.
- Only create a new commit when it represents a distinct, working change.
- **Always include the Linear issue number** (e.g., `[DEV-294]`) in commit messages.
- **Update the Linear ticket** (status to Done) after committing.
