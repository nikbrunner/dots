# shellcheck shell=bash
# Arch Linux-specific ZSH configuration
# Sourced from ~/.zshrc

# Default Applications =======================================================
export BROWSER="helium-browser"

# NVM (official script) ======================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# IP Address =================================================================
myip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || echo "Not connected")

# Functions ==================================================================
waybar-reload() {
    killall waybar 2>/dev/null
    waybar &>/dev/null & disown
    echo "waybar reloaded"
}

# ZSH Plugins (system packages) ==============================================
[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
