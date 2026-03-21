#!/usr/bin/env bash
# Shared logging functions for dots scripts
# Uses gum for enhanced output when available, falls back to plain text

# Guard against double-sourcing
[[ -n "${_LOG_SH_LOADED:-}" ]] && return 0
_LOG_SH_LOADED=1

# Check if gum is available
has_gum() {
    command -v gum &>/dev/null
}

# Section header (bold, blue)
log_section() {
    if has_gum; then
        gum style --foreground=4 --bold "$1"
    else
        echo "$1"
    fi
}

# Success message (green checkmark)
log_success() {
    if has_gum; then
        gum style --foreground=2 "✓ $1"
    else
        echo "✓ $1"
    fi
}

# Warning message (yellow)
log_warning() {
    if has_gum; then
        gum style --foreground=3 "⚠ $1"
    else
        echo "⚠ $1"
    fi
}

# Error message (red)
log_error() {
    if has_gum; then
        gum style --foreground=1 "✗ $1"
    else
        echo "✗ $1"
    fi
}

# Info message (cyan arrow)
log_info() {
    if has_gum; then
        gum style --foreground=6 "→ $1"
    else
        echo "→ $1"
    fi
}

# Confirmation prompt (returns 0 for yes, 1 for no)
confirm() {
    local prompt="$1"
    local default="${2:-false}"

    if has_gum; then
        if [[ "$default" == "true" ]]; then
            gum confirm "$prompt"
        else
            gum confirm "$prompt" --default=false
        fi
    else
        local yn_hint="(y/N)"
        [[ "$default" == "true" ]] && yn_hint="(Y/n)"

        echo -n "$prompt $yn_hint "
        read -r response

        if [[ "$default" == "true" ]]; then
            [[ ! "$response" =~ ^[Nn]$ ]]
        else
            [[ "$response" =~ ^[Yy]$ ]]
        fi
    fi
}

# Interactive choice menu (returns selected option)
choose() {
    local header="$1"
    shift
    local options=("$@")

    if has_gum; then
        printf '%s\n' "${options[@]}" | gum choose --header "$header"
    else
        echo "$header"
        local i=1
        for opt in "${options[@]}"; do
            if [[ "$opt" == "─────────" ]]; then
                echo "  $opt"
            else
                echo "  [$i] $opt"
                ((i++))
            fi
        done
        echo -n "Choice: "
        read -r choice

        # Map number to option (skipping separators)
        local j=0
        for opt in "${options[@]}"; do
            if [[ "$opt" != "─────────" ]]; then
                ((j++))
                if [[ "$j" == "$choice" ]]; then
                    echo "$opt"
                    return
                fi
            fi
        done
    fi
}
