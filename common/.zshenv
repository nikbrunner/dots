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
