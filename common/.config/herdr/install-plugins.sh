#!/bin/sh
set -eu

if [ -L "$HOME/.config/herdr/plugins.json" ]; then
    rm "$HOME/.config/herdr/plugins.json"
fi

herdr plugin link "$HOME/.config/herdr/local-plugins/default-layout" --enabled

# https://github.com/aimdevlee/herdr-nvim-nav
herdr plugin install aimdevlee/herdr-nvim-nav --yes

# https://github.com/black-atom-industries/helm.herdr
herdr plugin install black-atom-industries/helm.herdr --yes

# https://github.com/persiyanov/herdr-reviewr
herdr plugin install persiyanov/herdr-reviewr --yes
