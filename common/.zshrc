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

# Cross-Platform Path Exports ===========================================
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/Applications:$PATH
export PATH=/usr/bin/python:$PATH
export PATH=/usr/bin/python3:$PATH
export PATH=$HOME/.deno/bin:$PATH

# Because of https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#user-config
export XDG_CONFIG_HOME="$HOME/.config"

export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Globals ================================================================
export EDITOR="nvim"

export BC_OFFICE_LAN_IP=10.2.0.95
export BC_OFFICE_WLAN_IP=10.2.0.109
export BC_OFFICE_ST=67S3033

export BC_HOME_LAN_IP=null
export BC_HOME_WLAN_IP=192.168.2.109
export BC_HOME_ST=4WSMH53

export BC_DANIEL_IP=10.2.0.128
export BC_BEN_IP=10.2.0.94
export BC_HOME_IP=192.168.2.107
export BC_HOME_ST=CG7L9R2
export BC_JULIA_IP=10.2.0.195
export BC_JULIA_ST=CNRFGQ2

export BC_ANGELA_ST=CNZFGQ2

export BAT_THEME="base16"

# Aliases ================================================================
alias vim="nvim"
alias edit="nvim"
alias e="nvim"
alias ls="eza --all --oneline --long --icons --sort=type"
alias lt="eza --all --tree --icons --sort=type --level=1 --ignore-glob=\"node_modules|.git\""
alias lg="lazygit"
alias ld="lazydocker"
alias tn="tmux new"
alias ta="tmux attach"
alias tk="tmux kill-server"
alias zj="zellij"
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias gdl="gallery-dl"
alias npmu="npm-upgrade"

alias :q=exit

alias start="tmux new -s dots -c ~/.config/nvim && rr"
alias scratch="$EDITOR $HOME/scratchpad.md"


# Yazi ==================================================================
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# fzf ====================================================================
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_DEFAULT_OPTS="--bind='ctrl-e:execute(echo {+} | xargs -o nvim)' --reverse --no-separator --no-info --no-scrollbar --border=bold --border-label-pos=3 --padding=1,5 --color=bg+:-1,gutter:-1,border:yellow,prompt:cyan,pointer:yellow,marker:cyan,spinner:green,header:blue,label:yellow,query:magenta --highlight-line --prompt='  ' --ansi"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# Git Branch Switcher ====================================================
git_branch_switch() {
    local branches
    local target

    if [[ "$1" == "-a" || "$1" == "--all" ]]; then
        # Show all branches (local and remote)
        branches=$(git branch -a | grep -v HEAD | sed "s/.* //")
    else
        # Show only local branches
        branches=$(git branch | sed "s/.* //")
    fi

    target=$(echo "$branches" | fzf --ansi --preview-window=top:70% \
        --preview="git -c color.ui=always log -n 50 --graph --color=always \
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' {}")

    if [[ -n "$target" ]]; then
        if [[ "$target" == remotes/* ]]; then
            git checkout --track "${target#remotes/}"
        else
            git checkout "$target"
        fi
    fi
}

# Alias for switching local Git branches using fzf
alias gbr='git_branch_switch'

# Alias for switching all (including remote) Git branches using fzf
alias gbra='git_branch_switch -a'

alias ,,="fzf -m --preview='bat --color=always {}' --bind 'enter:become(nvim {+}),ctrl-y:execute-silent(echo {} | pbcopy)+abort'"

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

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

source ~/.config/zsh/prompt.zsh
