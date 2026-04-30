---
name: about-dots
description: Dots dotfiles management system context. Load when dotfiles, dots repo, or machine config comes up.
user-invocable: false
metadata:
  user-invocable: false
---

# About Dots

My symlink-based dotfiles management system. Configs live in a git repo and are symlinked to their expected home directory locations, supporting both macOS and Arch Linux.

A `symlinks.yml` file defines all symlink mappings with OS-specific sections (`common`, `macos`, `arch`). The `dots` CLI handles linking, dependency management, and syncing across machines. `helm` (a separate BAI tool) handles multi-repo operations underneath `dots pull`/`dots push`.

Also contains my Claude Code configuration (skills, hooks, agents) which is symlinked to `~/.claude/`.

Key tools configured here: Neovim, Ghostty, tmux, Zed, zsh, Git, Lazygit, and various CLI utilities. Black Atom theme files in this repo are symlinks to adapter repos.

## Local Path

`~/repos/nikbrunner/dots/`
