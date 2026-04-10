---
name: Helm Architecture
description: Current file structure, mode list, and package layout for the helm TUI
type: project
---

Helm is a Go TUI for tmux session management (Bubbletea/Lipgloss).

## Model Split (2026-03-24)

`internal/model/model.go` was split into mode-specific files:

| File           | Contents                                                            |
| -------------- | ------------------------------------------------------------------- |
| `model.go`     | Model struct, `New()`, `Update()`/`View()` dispatch, shared helpers |
| `session.go`   | `handleNormalMode`, `viewSessionList`, self-session pinning         |
| `clone.go`     | Clone choice/URL/repo modes, `cloneSelectedRepo`                    |
| `bookmarks.go` | `handleBookmarksMode`, `viewBookmarks`                              |
| `directory.go` | `handlePickDirectoryMode`, `viewPickDirectory`                      |

## 10 Modes

ModeNormal, ModeConfirmKill, ModeCreate, ModeCreatePath, ModePickDirectory, ModeConfirmRemoveFolder, ModeCloneChoice, ModeCloneRepo, ModeCloneURL, ModeBookmarks

## Key Packages

| Package                          | Purpose                                                                 |
| -------------------------------- | ----------------------------------------------------------------------- |
| `cmd/helm/main.go`               | Entry point + subcommands (init, setup, bookmark, tmux-bindings, repos) |
| `cmd/helm/repos.go`              | `helm repos` subcommand (status, pull, push, dirty, add, rebuild)       |
| `cmd/helm/setup.go`              | Bulk clone from `ensure_cloned` config                                  |
| `internal/config/user_config.go` | YAML config with custom unmarshalers                                    |
| `internal/config/app.go`         | App-level constants (name, paths)                                       |
| `internal/ui/`                   | colors, styles, keys, columns, scrolllist, layout, sidebar, section     |
| `internal/tmux/tmux.go`          | tmux command wrappers                                                   |
| `internal/claude/status.go`      | Claude Code status file parsing                                         |
| `internal/git/`                  | status.go, repo.go, remote.go                                           |
| `internal/github/github.go`      | GitHub API for repo listing                                             |

## Recent Additions (2026-03-25)

- **Sidebar UI** (`sidebar.go`, `section.go`): Action buttons in a sidebar box, mode-specific actions
- **`--initial-view` flag**: Start helm in a specific mode (bookmarks, projects, clone)
- **OpenSpec**: Behavioral specs in `openspec/` directory, used for change proposals
- **Self-session pinning**: Current tmux session shown at top of session list with separator

**Why:** Future sessions need accurate file locations and feature awareness.

**How to apply:** Use these paths when navigating code. Mode-specific logic lives in its own file, not model.go.
