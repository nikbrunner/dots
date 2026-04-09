---
name: Shiplog integration points and known issues
description: How shiplog is used outside its own repo — LazyGit, Neovim, dots, git aliases
type: project
---

Shiplog is invoked from multiple contexts beyond direct CLI:

- **LazyGit custom command**: Key "Z" in files context runs `shiplog commit --smart` (dots repo: `common/.config/lazygit/config.yml`)
- **Neovim `:!`**: Users run `:!shiplog commit -sy` — this is a non-TTY context where ANSI escape codes show as raw `^[[36m` etc. The `--raw` flag (added 2026-03-31) solves this for pipeable use.
- **Git aliases**: `git sc` = `shiplog commit -s`, `git sb` = `shiplog branch -s` (dots repo: `common/.gitconfig`)
- **dots "Stage all and commit with AI"**: The dots script invokes `git add -A && shiplog commit --smart --yes`

**Known issue (dots, not shiplog):** The dots repo pre-commit hook runs `make fmt` then `git diff --name-only --diff-filter=M | xargs git add`, which stages ALL modified files — not just already-staged ones. This caused unexpected files in commits when using shiplog via LazyGit Z. Fix: change to `--cached` in the hook. (Identified 2026-03-24, fix is in dots repo scope.)

**How to apply:** When modifying shiplog output or behavior, consider these non-TTY and embedded contexts. The `--raw` flag pattern is the established solution for pipeable output.
