#!/usr/bin/env bash
set -e

DOTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$DOTS_DIR/.git/hooks/pre-commit"

cat >"$HOOK" <<'EOF'
#!/usr/bin/env bash
set -e

make fmt
EOF

chmod +x "$HOOK"
echo "pre-commit hook installed at $HOOK"
