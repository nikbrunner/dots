---
name: helm-architecture
description: "Current file structure, mode list, and package layout for the helm TUI"
metadata: 
  node_type: memory
  type: project
  originSessionId: f635f850-6405-49f4-be75-ca1051bf2364
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

## Theming (2026-07-02)

- helm is a **Black Atom adapter**: `black-atom-adapter.json` + Eta template `internal/ui/theme/collection.template.go` generate 38 committed self-registering Go theme files (`make themes`, needs deno). Registry in `internal/ui/theme/registry.go`.
- `theme:` config key / `HELM_THEME` env selects a theme; empty = ANSI-16 + reverse-video fallback (`selectedBase()` in styles.go branches on `ui.HasTheme`).
- Warn buttons use Fg.Error on Bg.Negative (diff-delete pairing) — `ui.fg.contrast` is only right on `ui.bg.contrast` (title bar), looks washed out on the negative tint.
- Paper collection themes exist only in local core (unpublished > JSR 0.4.0); regenerate with `deno run -A ~/repos/black-atom-industries/core/src/cli/index.ts generate` until next core release.
- Nik's dots config (`~/repos/nikbrunner/dots/common/.config/black-atom/helm/config.yml`) is **hardlinked** (same inode) to `~/.config/black-atom/helm/config.yml`; it sets `theme: black-atom-default-light` matching his ghostty theme.

**Why:** Future sessions need accurate file locations and feature awareness.

**How to apply:** Use these paths when navigating code. Mode-specific logic lives in its own file, not model.go.
