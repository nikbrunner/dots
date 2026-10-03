#!/bin/sh
set -eu

if [ -L "$HOME/.config/herdr/plugins.json" ]; then
    rm "$HOME/.config/herdr/plugins.json"
fi

if herdr plugin list --plugin dots.default-layout --json |
    jq -e '.result.plugins | length > 0' >/dev/null; then
    herdr plugin unlink dots.default-layout
fi

herdr plugin link "$HOME/.config/herdr/local-plugins/stationary" --enabled

# The installer writes an absolute-path hook into settings.json, which dots
# shares across machines. Install into a throwaway config dir and keep only the
# script; the portable hook entry lives in common/.claude/settings.json.
claude_tmp="$(mktemp -d)"
CLAUDE_CONFIG_DIR="$claude_tmp" herdr integration install claude
mkdir -p "$HOME/.claude/hooks"
cp "$claude_tmp/hooks/herdr-agent-state.sh" "$HOME/.claude/hooks/"
rm -rf "$claude_tmp"

# https://github.com/narumiruna/pi-extensions/tree/main/packages/pi-usage
pi install npm:@narumitw/pi-usage

# https://github.com/aimdevlee/herdr-nvim-nav
herdr plugin install aimdevlee/herdr-nvim-nav --yes

# https://github.com/black-atom-industries/helm.herdr
herdr plugin install black-atom-industries/helm.herdr --yes

# https://github.com/zenbu-labs/terminal-browser/tree/main/herdr-plugin
herdr plugin install zenbu-labs/terminal-browser/herdr-plugin --yes

#  https://github.com/plannotator/herdr-annotate
herdr plugin install plannotator/herdr-annotate --yes
