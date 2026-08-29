#!/bin/sh
set -eu

HERDR_BIN=${HERDR_BIN_PATH:-herdr}

exec "$HERDR_BIN" plugin pane open \
    --plugin dots.herdr-somars \
    --entrypoint player \
    --placement popup \
    --width 80% \
    --height 80%
