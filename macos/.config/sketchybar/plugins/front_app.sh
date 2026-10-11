#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

DINKY=/opt/homebrew/bin/dinky

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dinky"

# Four characters each, so the bar does not shift. PICK while the layout mode waits for a key.
layout_text() {
    mode="$MODE"
    [ -n "$mode" ] || mode=$("$DINKY" list-modes --current 2>/dev/null) || return
    if [ "$mode" = layout ]; then
        echo "PICK"
        return
    fi

    workspace=$("$DINKY" list-workspaces --focused 2>/dev/null)
    layout=$(cat "$STATE_DIR/layout-$workspace" 2>/dev/null)
    if [ -z "$layout" ]; then
        case "$("$DINKY" list-windows --focused --format '%{window-layout}' 2>/dev/null)" in
        *accordion) layout=accordion ;;
        *) layout=tiles ;;
        esac
    fi

    case "$layout" in
    scrolling) echo "SCRL" ;;
    accordion) echo "ACRD" ;;
    *) echo "TILE" ;;
    esac
}

if [ "$NAME" = "front_app" ]; then
    if [ "$SENDER" = "front_app_switched" ]; then
        sketchybar --set "$NAME" label="[$(printf '%s' "$INFO" | tr '[:lower:]' '[:upper:]')]"
    fi
elif [ "$NAME" = "front_app_layout" ]; then
    LAYOUT=$(layout_text)
    if [ -n "$LAYOUT" ]; then
        sketchybar --set "$NAME" drawing=on label="[LAYOUT: $LAYOUT]"
    else
        sketchybar --set "$NAME" drawing=off
    fi
fi
