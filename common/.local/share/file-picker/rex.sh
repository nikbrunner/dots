# shellcheck shell=bash
# file-picker adapter for Rex. The init.lua binding passes the calling block
# as REX_TARGET_BLOCK; REX_BLOCK is the popup's own block.

_foreground() {
    rex block call -b "$REX_TARGET_BLOCK" process 2>/dev/null | jq -r ".foreground.$1 // empty" 2>/dev/null || true
}

pane_is_agent() {
    local name
    name=$(_foreground argv0)
    [[ "${name##*/}" =~ ^(claude|pi|codex|gemini|opencode)$ ]]
}

pane_cwd() {
    _foreground cwd
}

pane_send() {
    rex block send -b "$REX_TARGET_BLOCK" "$1"
}
