---
name: Helm Architecture
description: Current file structure, mode list, and package layout for the helm TUI
type: project
---

Helm is a Go TUI for tmux session management (Bubbletea/Lipgloss).

## Model Split (2026-03-24, commit e4b771a)

`internal/model/model.go` was split into mode-specific files:

| File                    | Contents                                                                   |
| ----------------------- | -------------------------------------------------------------------------- |
| `model.go` (~800 lines) | Model struct, `New()`, `Update()`/`View()` dispatch, shared helpers        |
| `session.go`            | `handleNormalMode`, `viewSessionList`                                      |
| `clone.go`              | Clone choice/URL/repo modes, `cloneSelectedRepo`, `fetchAvailableReposCmd` |
| `bookmarks.go`          | `handleBookmarksMode`, `viewBookmarks`                                     |
| `directory.go`          | `handlePickDirectoryMode`, `viewPickDirectory`                             |

## 10 Modes

ModeNormal, ModeConfirmKill, ModeCreate, ModePickDirectory, ModeConfirmRemoveFolder, ModeCloneChoice, ModeCloneRepo, ModeCloneURL, ModeBookmarks, ModeCreatePath

## Key Packages

| Package                          | Purpose                                                                 |
| -------------------------------- | ----------------------------------------------------------------------- |
| `cmd/helm/main.go`               | Entry point + subcommands (init, setup, bookmark, tmux-bindings, repos) |
| `cmd/helm/repos.go`              | `helm repos` subcommand (status, pull, push, dirty, add, rebuild)       |
| `cmd/helm/setup.go`              | Bulk clone from `ensure_cloned` config                                  |
| `internal/config/user_config.go` | YAML config with custom unmarshalers                                    |
| `internal/config/app.go`         | App-level constants (name, paths)                                       |
| `internal/ui/`                   | colors.go, styles.go, keys.go, columns.go, scrolllist.go, layout.go     |
| `internal/tmux/tmux.go`          | tmux command wrappers                                                   |
| `internal/claude/status.go`      | Claude Code status file parsing                                         |
| `internal/git/`                  | status.go, repo.go, remote.go                                           |
| `internal/github/github.go`      | GitHub API for repo listing                                             |

**Why:** Future sessions need accurate file locations. The old memory referenced `internal/repos/config.go` (deleted) and `internal/config/config.go` (renamed).

**How to apply:** Use these paths when navigating code. The model split means mode-specific logic lives in its own file, not in model.go.
