# Helm Project Memory

## Project Overview

- **helm** = Go TUI for tmux session management (Bubbletea/Lipgloss)
- Part of Black Atom Industries ecosystem
- Config: `~/.config/helm/config.yml` (YAML)
- Binary installs to `~/.local/bin/helm`

## Key Architecture

- `internal/config/config.go` — YAML config with custom unmarshalers
- `internal/model/model.go` — Main Bubbletea model (7 modes)
- `cmd/helm/main.go` — Entry point + subcommands (init, setup, bookmark, tmux-bindings)
- `cmd/helm/setup.go` — Bulk clone from `ensure_cloned` config
- `internal/repos/config.go` — Only has `ListClonedRepos` and `FilterUncloned` (config parts removed in DEV-197)

## Build & Test

- `make build` / `make install` — standard build
- `make lint` — runs `golangci-lint run`, `make fmt` works fine
- Test TUI inside tmux: `tmux display-popup -w50% -h35% -B -E "./helm"`

## Completed Work

- **DEV-197** (closed) — Merged repos config into helm, added `helm setup` subcommand
  - Added `EnsureClonedEntry` with custom `UnmarshalYAML` supporting string and object formats
  - Parallel cloning with goroutines + semaphore (max 4)
  - Wildcard expansion via `gh repo list`
  - Post-clone hooks support
  - Commit: `0bfcf47`

## Design Principles

- **Separation of concerns**: helm = general tmux manager, dots = personal machine management
- helm should NOT know about dots
- dots can read helm's config (via yq) but not the other way around
- `project_dirs` serves as clone target; if multiple, prompt user

## Pending Work

- **DEV-231** — Update `dots/repos-lib.sh` to read from helm's YAML config (yq instead of jq)
  - Lives in dots repo: `/Users/nbr/repos/nikbrunner/dots`
  - After done: delete `~/.config/repos/config.json` and the `repos` CLI script
- See [plan file](../plans/modular-squishing-charm.md) for full migration plan

## Linear Tracking

- Team: Development, Label: helm
- Closed in this session: DEV-190, DEV-191, DEV-196, DEV-197, DEV-198
- Created: DEV-231 (blocked by DEV-197, now unblocked)
