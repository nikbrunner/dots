# shellcheck shell=bash
# macOS-specific ZSH configuration
# Sourced from ~/.zshrc

# Homebrew ===================================================================
brew_path="/opt/homebrew/bin"
brew_opt_path="/opt/homebrew/opt"
export PATH=${brew_path}:${PATH}
export PATH=${brew_opt_path}/python@3.10/bin/python3:$PATH

# NVM (Homebrew) =============================================================
export NVM_DIR=$HOME/.nvm
[ -s "${brew_opt_path}/nvm/nvm.sh" ] && . "${brew_opt_path}/nvm/nvm.sh"

# IP Address =================================================================
myip=$(ipconfig getifaddr en0 2>/dev/null || echo "Not connected")

# ZSH Completion (must be before plugins that use compdef) ===================
autoload -Uz compinit && compinit

# ZSH Plugins (Homebrew) =====================================================
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Aviator CLI ================================================================
command -v av &>/dev/null && source <(av completion zsh)
