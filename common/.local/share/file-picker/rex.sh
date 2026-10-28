# shellcheck shell=bash
# file-picker adapter for Rex. The init.lua binding passes the calling block
# as REX_TARGET_BLOCK; REX_BLOCK is the popup's own block.

pane_is_agent() {
    local name
    name=$(rex block call -b "$REX_TARGET_BLOCK" process 2>/dev/null | jq -r '.foreground.argv0 // empty' 2>/dev/null || true)
    [[ "${name##*/}" =~ ^(claude|pi|codex|gemini|opencode)$ ]]
}

# The popup starts in the calling pane's cwd, so the core's $PWD fallback is it.
pane_cwd() {
    :
}

pane_send() {
    rex block send -b "$REX_TARGET_BLOCK" "$1"
}
