# shellcheck shell=bash
# Note: This is zsh config. Many shellcheck warnings are false positives.

[[ -r ~/.env ]] && { set -a; source ~/.env; set +a; }

# Git completion (fpath must be set before compinit in os.zsh) ===========
zstyle ':completion:*:*:git:*' script ~/.config/.zsh/git-completion.bash
fpath=(~/.config/.zsh $fpath)

# OS-Specific Configuration (must be early for Homebrew PATH) ===========
# Sources Homebrew paths, NVM, plugins, myip, and OS-specific functions
[[ -f ~/.config/zsh/os.zsh ]] && source ~/.config/zsh/os.zsh

# Cross-Platform Path Exports ===========================================
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/Applications:$PATH
export PATH=/usr/bin/python:$PATH
export PATH=/usr/bin/python3:$PATH
export PATH=$HOME/.deno/bin:$PATH
export PATH=$HOME/go/bin:$PATH
export XDG_CONFIG_HOME="$HOME/.config" # Because of https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#user-config
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Globals ================================================================
export EDITOR="nvim"
export MANPAGER='nvim +Man!'
export BAT_THEME="base16"

# Aliases ================================================================
alias vin="NVIM_APPNAME=nvim_mnml nvim"
alias mini="NVIM_APPNAME=nvim-minimax nvim"

alias ls="eza --all --oneline --long --icons --sort=type"
alias lt="eza --all --tree --icons --sort=type --level=1 --ignore-glob=\"node_modules|.git\""
alias lg="lazygit"
alias ld="lazydocker"
alias zed="zeditor"
alias tn="tmux new"
alias ta="tmux attach"
alias tk="tmux kill-server"
alias zj="zellij"
alias start="helm bookmark 1"
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias gdl="gallery-dl"
alias npmu="npm-upgrade"
alias scratch="$EDITOR $HOME/scratchpad.md"
alias ydl=yt-dlp --audio-format mp3 --embed-thumbnail --embed-metadata --extract-audio
alias groot='cd "$(git rev-parse --show-toplevel 2>/dev/null)" || echo "I am not Groot (not in a git repo)"'

alias :q=exit
alias :vs='tmux split-window -h -c "#{pane_current_path}"'
alias :sp='tmux split-window -v -c "#{pane_current_path}"'


# Yazi ==================================================================
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# fzf ====================================================================
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_DEFAULT_OPTS="--bind='ctrl-e:execute(echo {+} | xargs -o nvim)' --reverse --no-separator --no-info --no-scrollbar --border=bold --border-label-pos=3 --padding=1,5 --color=gutter:-1,border:yellow,prompt:cyan,pointer:yellow,marker:cyan,spinner:green,header:blue,label:yellow,query:magenta --highlight-line --prompt='  ' --ansi"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# Git Branch Switcher ====================================================
# Use branch-picker script from ~/bin
# Ctrl-R inside fzf toggles between local and remote branches
alias gbr='branch-picker'

alias ,,="fzf -m --preview='bat --color=always {}' --bind 'enter:become(nvim {+}),ctrl-y:execute-silent(echo {} | pbcopy)+abort'"

# Custom Script Functions ================================================
# Source 'run' script to enable print -z functionality
[ -f "$HOME/.local/bin/run" ] && source "$HOME/.local/bin/run"

eval "$(zoxide init zsh --cmd cd)"

# Plugin Configuration (after plugins loaded by os.zsh) ==================
bindkey '^y' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# Push current line to buffer, run another command, then restore
bindkey '^g' push-line-or-edit

# Atuin
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# Minimal Prompt (gray path, green branch, red job count, yellow $)
autoload -Uz vcs_info
precmd() { vcs_info; }
zstyle ':vcs_info:git:*' formats ' %F{green}%b%f'
setopt PROMPT_SUBST
PROMPT='%F{gray}%~%f${vcs_info_msg_0_}%(1j. %F{red}[%j]%f.)
%F{yellow}$%f '
