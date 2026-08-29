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
herdr plugin link "$HOME/.config/herdr/local-plugins/herdr-somars" --enabled

# https://github.com/aimdevlee/herdr-nvim-nav
herdr plugin install aimdevlee/herdr-nvim-nav --yes

# https://github.com/black-atom-industries/helm.herdr
herdr plugin install black-atom-industries/helm.herdr --yes

# https://github.com/persiyanov/herdr-reviewr
herdr plugin install persiyanov/herdr-reviewr --yes

# https://github.com/zenbu-labs/terminal-browser/tree/main/herdr-plugin
herdr plugin install zenbu-labs/terminal-browser/herdr-plugin --yes
