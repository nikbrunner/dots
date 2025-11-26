# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Dotfiles Configuration ===================================================
# Ported from common/.zshrc for Linux/bash compatibility

# Cross-Platform Path Exports ===========================================
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/Applications:$PATH
export PATH=/usr/bin/python:$PATH
export PATH=/usr/bin/python3:$PATH
export PATH=$HOME/.deno/bin:$PATH
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Globals ================================================================
export EDITOR="nvim"

export BC_OFFICE_LAN_IP=10.2.0.95
export BC_OFFICE_WLAN_IP=10.2.0.109
export BC_OFFICE_ST=67S3033

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
alias vin="NVIM_APPNAME=nvim_mnml nvim"

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
alias start="tmux new -s dots -c ~/.config/nvim && rr"
alias scratch="$EDITOR $HOME/scratchpad.md"

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
export FZF_DEFAULT_OPTS="--bind='ctrl-e:execute(echo {+} | xargs -o nvim)' --reverse --no-separator --no-info --no-scrollbar --border=bold --border-label-pos=3 --padding=1,5 --color=bg+:gray,fg+:white,gutter:-1,border:yellow,prompt:cyan,pointer:yellow,marker:cyan,spinner:green,header:blue,label:yellow,query:magenta --highlight-line --prompt='  ' --ansi"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Initialize fzf for bash
eval "$(fzf --bash)"

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

# Misc =================================================================
# Get IP address (Linux)
myip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || echo "Not connected")

# NVM ===================================================================
set -h # Re-enable hashing (omarchy disables it with set +h)
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Initialize tools =======================================================
# Zoxide
eval "$(zoxide init bash)"

# Atuin
# [ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
# eval "$(atuin init bash)"

# Minimal Prompt (gray path, green branch, $ symbol)
__git_branch() {
    git branch 2>/dev/null | grep '^\*' | cut -d' ' -f2
}
PS1='\[\e[90m\]\w\[\e[0m\]$(__git_branch | sed "s/.*/\[\e[32m\] &\[\e[0m\]/")\n$ '
