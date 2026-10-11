#!/bin/sh

# Names every connected VPN service macOS knows (Tailscale, ProtonVPN, WireGuard tunnels), or OFF.

. "$CONFIG_DIR/colors.sh"

names=$(scutil --nc list | grep '^\* (Connected)' | grep ' VPN (' | sed -E 's/.*"([^"]*)".*/\1/' | sed -E 's/ +$//' | paste -sd, - | tr '[:lower:]' '[:upper:]')

if [ -n "$names" ]; then
    sketchybar --set "$NAME" label="[VPN: $names]" label.color="$VPN_ON_COLOR"
else
    sketchybar --set "$NAME" label="[VPN: OFF]" label.color="$VPN_OFF_COLOR"
fi
