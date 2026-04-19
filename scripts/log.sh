#!/usr/bin/env bash
# Shared logging functions for dots scripts

# Guard against double-sourcing
[[ -n "${_LOG_SH_LOADED:-}" ]] && return 0
_LOG_SH_LOADED=1

# Colors (only on real TTY, unless FORCE_COLOR=1)
if [ -t 1 ] || [ -n "${FORCE_COLOR:-}" ]; then
    ESC=$'\033'
    _BOLD="${ESC}[1m"
    _GREEN="${ESC}[32m"
    _YELLOW="${ESC}[33m"
    _RED="${ESC}[31m"
    _CYAN="${ESC}[36m"
    _RESET="${ESC}[0m"
else
    _BOLD=""
    _GREEN=""
    _YELLOW=""
    _RED=""
    _CYAN=""
    _RESET=""
fi

# Section header
log_section() {
    echo "${_BOLD}─── $1 ───${_RESET}"
}

# Success message
log_okay() {
    echo "${_GREEN}::OKAY::${_RESET} $1"
}

# Warning message
log_warn() {
    echo "${_YELLOW}::WARN::${_RESET} $1"
}

# Error message
log_fail() {
    echo "${_RED}::FAIL::${_RESET} $1"
}

# Info message
log_info() {
    echo "${_CYAN}::INFO::${_RESET} $1"
}

# Confirmation prompt (returns 0 for yes, 1 for no)
confirm() {
    local prompt="$1"
    local default="${2:-false}"

    local yn_hint="(y/N)"
    [[ "$default" == "true" ]] && yn_hint="(Y/n)"

    echo -n "$prompt $yn_hint "
    read -r response

    if [[ "$default" == "true" ]]; then
        [[ ! "$response" =~ ^[Nn]$ ]]
    else
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Interactive choice menu (returns selected option)
choose() {
    local header="$1"
    shift
    local options=("$@")

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
}
