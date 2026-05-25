#!/usr/bin/env bash
# Wire this repo's git hooks via native core.hooksPath.
#
# The hook itself lives at .githooks/pre-commit (prettier + shfmt + Makefile
# checks). This script just points git at it — git does not pick up .githooks/
# automatically, and the setting is per-clone, so it must run on every machine.
#
# Idempotent and safe to re-run.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

HOOK=".githooks/pre-commit"

echo "==> Wiring git hooks for $REPO_ROOT"

if [[ ! -f "$HOOK" ]]; then
    echo "    ERROR: $HOOK not found. Are you in the dots repo?" >&2
    exit 1
fi

chmod +x "$HOOK"
git config core.hooksPath .githooks
echo "    core.hooksPath -> $(git config core.hooksPath)"

# The hook needs prettier (via npx) and shfmt — both come from mise. Warn
# rather than fail: the wiring is valid even if the tools land later.
for tool in shfmt npx; do
    command -v "$tool" >/dev/null 2>&1 || echo "    WARN: '$tool' not on PATH yet — run 'mise install' (the hook needs it)."
done

echo "==> Done. The pre-commit hook now runs on every 'git commit'."
echo "    Format before committing with: make fmt"
