# Is this not default?
export XDG_CONFIG_HOME="$HOME/.config"

# HomeBrew
brew_path="/opt/homebrew/bin"
brew_opt_path="/opt/homebrew/opt"
export PATH=${brew_path}:${PATH}
export PATH=${brew_opt_path}/python@3.10/bin/python3:$PATH

# Path Exports ===========================================================
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/Applications:$PATH
export PATH=/usr/bin/python:$PATH
export PATH=/usr/bin/python3:$PATH 
export PATH=$HOME/.deno/bin:$PATH

# NVM ====================================================================
export NVM_DIR=$HOME/.nvm
[ -s "${brew_opt_path}/nvm/nvm.sh" ] && . "${brew_opt_path}/nvm/nvm.sh"

# Oh My ZSH ==============================================================
export ZSH="$HOME/.oh-my-zsh"
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
# ZSH_THEME=refined
source $ZSH/oh-my-zsh.sh

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
# Dotfiles 
alias df='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias dfu='df add -u && df commit -m "Update dotfiles" && df push'
alias dfs='df status'
alias dflg='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias vim="nvim"
alias ls="eza --all --oneline --long --icons --sort=type"
alias lt="eza --all --tree --icons --sort=type --level=1 --ignore-glob=\"node_modules|.git\""
alias lg="lazygit"
alias tn="tmux new"
alias ta="tmux attach"
alias tk="tmux kill-server"
alias zj="zellij"
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias id="gallery-dl"
alias npmu="npm-upgrade"

alias :q=exit

alias start="tmux new -s dots -c ~/.config/nvim && rr"
alias scratch="$EDITOR $HOME/scratchpad.md"

# MUSIC_DIR="$HOME/Library/CloudStorage/ProtonDrive-nik.brunner@proton.me-folder/Areas/Music/Inbox"
MUSIC_DIR="$HOME/pCloud\ Drive/02_AREAS/Music"
alias ytmp3="yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-metadata --add-metadata -o \"${MUSIC_DIR}/Inbox/%(uploader)s - %(title)s.%(ext)s\""
alias ytalbum="yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-metadata --add-metadata --write-thumbnail -o \"${MUSIC_DIR}/Youtube DL Inbox/%(uploader)s - %(playlist)s/%(playlist_index)02d - %(title)s.%(ext)s\""

function select_npm_script() {
  local color_scheme="fg:white,fg+:yellow,bg+:-1,gutter:-1,hl+:magenta,border:yellow,prompt:cyan,pointer:yellow,marker:cyan,spinner:green,header:blue,label:yellow,query:magenta"

  local fzf_output=$(
    {
      fc -ln 1 | grep "npm run" | sed 's/^/  /'
      [ -f package.json ] && jq -r '.scripts | keys | .[]' package.json | sed 's/^/  /'
    } | awk '!seen[$0]++' |
    fzf --reverse \
        --no-separator \
        --no-info \
        --no-scrollbar \
        --border=bold \
        --border-label="┃ npm scripts ┃" \
        --border-label-pos=3 \
        --prompt="❯ " \
        --padding="1,5" \
        --height=65% \
        --color="$color_scheme" \
        --header='Select an npm script:' \
        --expect=alt-enter \
        --bind 'alt-enter:accept' |
    sed 's/^[^ ]*  //'
  )

  local lines=("${(@f)fzf_output}")

  if [[ "${lines[1]}" == "alt-enter" ]]; then
    LBUFFER="${LBUFFER}npm run ${lines[2]} "
  else
    LBUFFER="${LBUFFER}${lines[1]} "
  fi

  zle reset-prompt
}

zle -N select_npm_script
bindkey '^N' select_npm_script

# Yazi ==================================================================
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	zle clear-screen
	yazi "$@" --cwd-file="$tmp" </dev/tty
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		BUFFER="cd ${(q)cwd}"
		zle accept-line
	else
		zle reset-prompt
	fi
	rm -f -- "$tmp"
}

# Create a widget from the function
zle -N y
bindkey '^E' y

# fzf ====================================================================
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs'
export FZF_DEFAULT_OPTS=" --bind 'ctrl-e:execute(echo {+} | xargs -o nvim)' "
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --prompt='  ' \
  --ansi \
  --border \
  --layout=reverse \
  --no-scrollbar \
  --color=16 \
  --color=gutter:-1 \
"
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
myip=$(ipconfig getifaddr en0)

# Git completion =========================================================
zstyle ':completion:*:*:git:*' script ~/.config/.zsh/git-completion.bash
fpath=(~/.config/.zsh $fpath)
autoload -Uz compinit && compinit

eval "$(zoxide init zsh)"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# bind Ctrl-y to accept autosuggestion
bindkey '^y' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/nbr.omp.json)"
