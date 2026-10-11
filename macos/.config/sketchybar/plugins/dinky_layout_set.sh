#!/bin/sh

# Records the layout picked for the focused workspace. dinky reports a scrolling workspace's windows as
# tiles, so the bar reads the layout from here. Called from the layout mode bindings in dinky.toml.

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dinky"
workspace=$(/opt/homebrew/bin/dinky list-workspaces --focused) || exit 1

mkdir -p "$STATE_DIR"
printf '%s\n' "$1" >"$STATE_DIR/layout-$workspace"
sketchybar --trigger dinky_layout_changed
