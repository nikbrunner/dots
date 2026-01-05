# OS Detection ===========================================================
case "$(uname -s)" in
    Darwin)
        # macOS-specific configuration
        OS="macos"
        # HomeBrew
        brew_path="/opt/homebrew/bin"
        brew_opt_path="/opt/homebrew/opt"
        export PATH=${brew_path}:${PATH}
        export PATH=${brew_opt_path}/python@3.10/bin/python3:$PATH

        # NVM (Homebrew)
        export NVM_DIR=$HOME/.nvm
        [ -s "${brew_opt_path}/nvm/nvm.sh" ] && . "${brew_opt_path}/nvm/nvm.sh"
        ;;
    Linux)
        # Linux-specific configuration
        OS="linux"
        # NVM (official script installation)
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        ;;
esac

set -a; source ~/.env; set +a

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
alias tn="tmux new"
alias ta="tmux attach"
alias tk="tmux kill-server"
alias zj="zellij"
alias start="repos open nikbrunner/dots"
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias gdl="gallery-dl"
alias npmu="npm-upgrade"
alias scratch="$EDITOR $HOME/scratchpad.md"
alias ydl=yt-dlp --audio-format mp3 --embed-thumbnail --embed-metadata --extract-audio

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

# Misc =================================================================
# Get IP address (cross-platform)
case "$OS" in
    macos)
        myip=$(ipconfig getifaddr en0 2>/dev/null || echo "Not connected")
        ;;
    linux)
        myip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || echo "Not connected")
        ;;
esac

# Git completion =========================================================
zstyle ':completion:*:*:git:*' script ~/.config/.zsh/git-completion.bash
fpath=(~/.config/.zsh $fpath)
autoload -Uz compinit && compinit

eval "$(zoxide init zsh)"

# OS-Specific Plugin Loading ============================================
case "$OS" in
    macos)
        # macOS (Homebrew)
        source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ;;
    linux)
        # Linux (system packages)
        [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
            source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
            source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ;;
esac

# bind Ctrl-y to accept autosuggestion
bindkey '^y' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# Push current line to buffer, run another command, then restore
bindkey '^g' push-line-or-edit

# Atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Minimal Prompt (gray path, green branch, red job count, yellow $)
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{green}%b%f'
setopt PROMPT_SUBST
PROMPT='%F{gray}%~%f${vcs_info_msg_0_}%(1j. %F{red}[%j]%f.)
%F{yellow}$%f '

source <(av completion zsh)

# Added by Antigravity
export PATH="/Users/nbr/.antigravity/antigravity/bin:$PATH"
