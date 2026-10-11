#!/bin/sh

# Shows dinky's binding mode next to the front app's layout, hidden in the main mode and in the layout
# mode, which the layout item shows as PICK. dinky's mode-changed
# hook sends the new mode as $MODE; on startup and other events, ask dinky.

. "$CONFIG_DIR/colors.sh"

mode="$MODE"
[ -n "$mode" ] || mode=$(/opt/homebrew/bin/dinky list-modes --current 2>/dev/null)

if [ -z "$mode" ] || [ "$mode" = main ] || [ "$mode" = layout ]; then
    sketchybar --set "$NAME" drawing=off
else
    sketchybar --set "$NAME" drawing=on label="[$(printf '%s' "$mode" | tr '[:lower:]' '[:upper:]')]"
fi
