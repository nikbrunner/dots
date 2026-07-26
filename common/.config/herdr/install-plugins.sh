#!/bin/sh

# https://github.com/paulbkim-dev/vim-herdr-navigation
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes

# https://github.com/thanhdat77/herdr-picker-plus
herdr plugin install thanhdat77/herdr-picker-plus --yes

# https://github.com/third774/herdr-last-workspace
herdr plugin install persiyanov.reviewr --yes

# https://github.com/cloudmanic/herdr-plus
herdr plugin install cloudmanic/herdr-plus --yes

# herdr-plus applies its worktrees/ auto-layouts on worktree events only, so a
# plain "open repo as workspace" gets no layout. Subscribing the same handler to
# workspace.created covers that case. Only a wildcard (repo = "*") layout matches
# there: workspace.created carries no repo metadata yet, so named layouts can't
# be resolved. Reinstalling the plugin overwrites the manifest, so this reapplies
# it and re-registers via `plugin link`.
herdr_plus_root=$(herdr plugin list --json 2>/dev/null |
    python3 -c 'import json,sys; print(next(p["plugin_root"] for p in json.load(sys.stdin)["result"]["plugins"] if p["plugin_id"]=="cloudmanic.herdr-plus"))' 2>/dev/null)

if [ -n "$herdr_plus_root" ] && [ -f "$herdr_plus_root/herdr-plugin.toml" ]; then
    if grep -q 'on = "workspace.created"' "$herdr_plus_root/herdr-plugin.toml"; then
        echo "herdr-plus: workspace.created hook already present"
    else
        cat >>"$herdr_plus_root/herdr-plugin.toml" <<'EOF'

[[events]]
on = "workspace.created"
command = ["./bin/herdr-plus", "on-worktree"]
platforms = ["linux", "macos"]
EOF
        herdr plugin link "$herdr_plus_root" >/dev/null && echo "herdr-plus: added workspace.created hook"
    fi
else
    echo "herdr-plus: plugin root not found, skipped workspace.created hook" >&2
fi
