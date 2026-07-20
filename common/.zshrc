fpath=("/Users/nbr/.zsh/completions" $fpath)
autoload -Uz compinit
compinit

for f in ~/.env ~/.env.*(N); do [[ -r "$f" ]] && {
    set -a
    source "$f"
    set +a
}; done

# Git completion (fpath must be set before compinit in os.zsh) ===========
zstyle ':completion:*:*:git:*' script ~/.config/.zsh/git-completion.bash
fpath=(~/.config/.zsh $fpath)

# OS-Specific Configuration (must be early for Homebrew PATH) ===========
# Sources Homebrew paths, NVM, plugins, myip, and OS-specific functions
[[ -f ~/.config/zsh/os.zsh ]] && source ~/.config/zsh/os.zsh

# Cross-Platform Path Exports ===========================================
# Tool runtimes (python, deno, node, go, rust) managed by mise. Keep
# only user-script dirs and version-manager-specific dirs here.
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
# For neovim binaries
export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH="/Users/nbr/.bun/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config" # Because of https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#user-config
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Globals ================================================================
export DOTS_DIR="$HOME/repos/nikbrunner/dots"
export SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"
export EDITOR="nvim"
export MANPAGER='nvim +Man!'
export BAT_THEME="base16"

# Aliases ================================================================
alias ls="eza --all --oneline --long --icons --sort=type"
alias lt="eza --all --tree --icons --sort=type"
alias lg="lazygit"
alias lj="lazyjira"
alias ld="lazydocker"
alias tn="tmux new"
alias ta="tmux attach"
alias tk="tmux kill-server"
alias zj="zellij"
alias start="helm bookmark 0"
alias lazyvim="NVIM_APPNAME=lazyvim nvim"
alias gdl="gallery-dl"
alias npmu="npm-upgrade"
alias pp="pass-cli"
alias scratch="\$EDITOR \$HOME/scratchpad.md"
alias ydl='yt-dlp --audio-format mp3 --embed-thumbnail --embed-metadata --extract-audio'
alias mise-edge='mise upgrade --interactive --minimum-release-age 0s'
# debug builds use ~/.config/herdr-dev; env -u strips the stable session's
# socket overrides so this works from inside a herdr pane
alias herdr-dev='env -u HERDR_SOCKET_PATH -u HERDR_CLIENT_SOCKET_PATH $HOME/repos/nikbrunner/herdr/target/debug/herdr'
# one-time snapshot of the real session into herdr-dev's default session;
# stop herdr-dev first or its server just overwrites session.json again
herdr-dev-sync-session() {
    if pgrep -f "target/debug/herdr server" >/dev/null; then
        echo "herdr-dev server is running; stop it first (herdr-dev server stop)" >&2
        return 1
    fi
    cp "$HOME/.config/herdr/session.json" "$HOME/.config/herdr-dev/session.json"
    cp "$HOME/.config/herdr/session-history.json" "$HOME/.config/herdr-dev/session-history.json"
    echo "copied session.json + session-history.json from herdr -> herdr-dev"
}
# release build of local master, to try out unreleased upstream changes;
# release binaries default to the stable ~/.config/herdr dir (no herdr-dev
# override), so pin XDG_CONFIG_HOME to an isolated dir to avoid touching
# the real stable session
alias herdr-master='env -u HERDR_SOCKET_PATH -u HERDR_CLIENT_SOCKET_PATH XDG_CONFIG_HOME="$HOME/.config/herdr-master-xdg" $HOME/repos/nikbrunner/herdr/target/release/herdr'
unalias groot 2>/dev/null
groot() {
    local dir
    dir=$(git rev-parse --git-common-dir 2>/dev/null) || {
        echo "I am not Groot (not in a git repo)"
        return 1
    }
    # parent of the common .git dir is the main worktree root (works in worktrees and plain repos)
    cd "$(cd "$dir" && pwd)/.."
}
alias noise="exec ffplay -hide_banner -loglevel error -nodisp -f lavfi 'anoisesrc=color=brown:amplitude=0.354,lowpass=f=550:poles=1,bass=g=12:f=60,afade=t=in:d=3'"

alias brewi='outdated=$(brew outdated); [[ -n "$outdated" ]] && fzf --multi <<< $outdated | xargs brew upgrade'

alias :q=exit
alias :vs='tmux split-window -h -c "#{pane_current_path}"'
alias :sp='tmux split-window -v -c "#{pane_current_path}"'

# Claude
alias claude='CLAUDE_CODE_NO_FLICKER=1 claude'

claude-work() {
    ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_IMFUSION" \
        CLAUDE_CONFIG_DIR="$HOME/.claude-work" \
        CLAUDE_CODE_NO_FLICKER=1 \
        command claude "$@"
}

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

# gwt wrapper — intercept `gwt cd` to change directory in current shell
gwt() {
    if [[ "$1" == "cd" ]]; then
        local dir
        dir=$(command gwt "$1" "${@:2}")
        if [[ -n "$dir" && -d "$dir" ]]; then
            cd "$dir"
        fi
    else
        command gwt "$@"
    fi
}

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

# Minimal prompt: gray path + green branch on line 1, yellow $ on line 2
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %F{green}%b%f'
precmd_functions+=(vcs_info)
setopt PROMPT_SUBST
PROMPT='%F{gray}%~%f${vcs_info_msg_0_}%(1j. %F{red}[%j]%f.)
%F{yellow}$%f '

# mise — runtime and tool version manager (MUST run last, after all
# PATH modifications, so mise's tool paths win precedence over user dirs).
command -v mise &>/dev/null && eval "$(mise activate zsh)"
