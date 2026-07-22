# AGENTS.md

This file provides guidance to Claude Code and Pi when working with code in this repository. The canonical global instructions live in `common/.agents/AGENTS.md` (symlinked to `~/.claude/CLAUDE.md` and `~/.pi/agent/AGENTS.md`). This file supplements it with repo-specific context.

## Repository Overview

A symlink-based dotfiles management system for deploying configuration files across macOS and Arch Linux machines. Configuration files live in this repository and are symlinked to their expected home directory locations.

## Directory Structure

```
dots/
├── symlinks.yml          # Symlink definitions with OS-specific sections
├── common/               # Cross-platform configs (mirrors ~/)
│   ├── .config/          # Tool configurations
│   ├── .local/bin/       # Custom scripts (wildcard-linked)
│   └── .zshrc, etc.      # Root dotfiles
├── macos/                # macOS-specific configs
├── arch/                 # Arch Linux-specific configs
├── install/              # Machine bootstrap & dependency management
└── scripts/              # Runtime management scripts
```

## Commands

- **`dots`** — Dotfiles management. Run `dots` with no args for usage. See `common/.local/bin/dots`.
- **`shiplog`** — AI-powered git operations (commit, branch). Run `shiplog --help` for usage. See [nikbrunner/shiplog](https://github.com/nikbrunner/shiplog).
- **`helm`** — External tool for multi-repo management (pull, push, status, rebuild). Invoked by `dots pull` and `dots push`.

Full machine setup: follow `install/mac/README.md` or `install/arch/README.md`.

## Symlink Configuration

The `symlinks.yml` file defines all symlinks with OS-specific sections:

- **Section names** must match OS detection output: `common`, `macos`, `arch`
- **Processing order**: `common` section loads first, then platform-specific section
- **Wildcard patterns**: `"common/.local/bin/*": "~/.local/bin"` links individual files
- **Backups**: Existing files are backed up as `.<name>.backup.YYYYMMDD_HHMMSS`
- **Repo-internal targets**: When a target's directory resolves into the repo itself (e.g. `~/.pi/agent` via the `common/.pi: ~/.pi` dir-link), the link is created repo-relative so it stays portable when committed

### Managing Configurations

**Add**: Place file in `common/` or `<os>/` → add entry to `symlinks.yml` → `dots link`

**Remove**: Delete file → remove from `symlinks.yml` → `dots link` (cleans broken links)

**Move/Rename**: Move file in repo → `dots link` (auto-removes old, creates new)

## Architecture

### Script Sourcing Chain

The `dots` CLI sources two shared libraries:

1. `scripts/log.sh` — logging functions (`log_section`, `log_success`, `log_warning`, `log_error`, `log_info`), plus `has_gum`, `confirm`, `choose` helpers. Uses `gum` for enhanced output when available.
2. `scripts/dots/lib.sh` — config loading (`load_config`), git URL parsing, repo state detection, and automated chore staging functions (`dots_stage_*`: theme, sessions, pi, radar, lazy-lock, bookmarks, gitconfig, gitconfig.delta, helm, claude-memories). Each stages its files; `cmd_chores` rolls them into a single commit.

`lib.sh` requires `DOTS_DIR` to be set before sourcing and reads helm config from `~/.config/helm/config.yml` for `REPOS_BASE_PATH`.

### Black Atom Theme Integration

Theme files in this repo are symlinks to Black Atom adapter repos. `dots link` automatically runs `scripts/dots/theme-link.sh` which creates relative symlinks from dots theme directories to Black Atom adapter repos at `~/repos/black-atom-industries/`.

## Key Files

- `common/.local/bin/dots` — Main CLI implementation (dispatcher + `cmd_pull`, `cmd_push`, `cmd_chores`, `cmd_link`)
- `scripts/dots/lib.sh` — Shared library (config loading, repo helpers, chore staging functions)
- `scripts/dots/symlinks.sh` — Symlink creation/cleanup logic (also sourceable as a library)
- `scripts/dots/detect-os.sh` — OS detection (`macos`, `arch`, `linux`)
- `scripts/dots/theme-link.sh` — Black Atom theme symlink creation
- `scripts/log.sh` — Shared logging/UI functions
- `install/mac/Brewfile`, `install/arch/pkglist.txt` — OS-specific native packages
- `common/.config/mise/config.toml` — Cross-platform CLI tools + runtimes (via mise)
- `scripts/claude-mcp.sh` — Claude Code MCP server configuration (legacy)

## Environment Variables

- `DOTS_DIR` — Override dots directory (default: `~/repos/nikbrunner/dots`)
- `BLACK_ATOM_DIR` — Override Black Atom repos directory (default: `~/repos/black-atom-industries`)
- `ANTHROPIC_API_KEY` — Required for `shiplog commit --smart` / `shiplog branch --smart` API mode

## Shell Conventions

- All scripts use `set -e` (exit on error)
- `yq` is required for YAML parsing (`symlinks.yml`, helm config)
- `gum` is optional but enhances UI (confirmations, spinners, styled output)
- Scripts are linted with `shellcheck`
