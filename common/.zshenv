# Runs for every zsh invocation (login, interactive, non-interactive, subshells).
# Keep minimal — only PATH pieces non-interactive contexts need
# (Neovim :!cmd, Mason, make, cron).

# brew FIRST — sets base PATH for non-interactive shells.
# Without this, Neovim :!git, Mason, etc. can't find brew-installed tools.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# mise shims — prepended AFTER brew so mise wins precedence for any tool
# that exists in both (happens during migration: brew still has the old
# binary, mise has the new one; mise shim should take over).
export PATH="$HOME/.local/share/mise/shims:$PATH"

# ~/.local/bin — mise binary itself (installed via `curl https://mise.run`)
# plus dots scripts. Prepended last so these always win.
export PATH="$HOME/.local/bin:$PATH"

# Non-interactive contexts spawn an editor too — `git commit` from a script, a
# pre-commit hook, sudoedit. Without this they fall back to vi.
export EDITOR="nvim"

# vim-herdr-navigation reads this from the herdr process env, so it must be set
# here rather than in .zshrc — the plugin action is a herdr subprocess, not an
# interactive shell. These TUIs bind Ctrl+h/j/k/l themselves, so the keys are
# forwarded into the pane instead of moving herdr's pane focus.
# Leave such a pane with prefix+h/j/k/l — they do not cross out at an edge.
export HERDR_NAV_PASSTHROUGH_RE='^(lazygit|lazyjira)$'
