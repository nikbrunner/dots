#!/bin/sh

. "$CONFIG_DIR/colors.sh"

label="[$(date '+%d %b %H.%M' | tr '[:lower:]' '[:upper:]')]"

sketchybar --set "$NAME" label="$label" label.color="$CLOCK_COLOR"
