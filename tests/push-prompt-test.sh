#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DOTS_DIR="$TMP_DIR/dots"
mkdir -p "$DOTS_DIR/common/.config/black-atom/livery" "$DOTS_DIR/common/.config/herdr" "$DOTS_DIR/common/.config/mise" "$DOTS_DIR/scripts/dots" "$TMP_DIR/home/.config/helm"
cp common/.local/bin/dots "$DOTS_DIR/dots"
cp scripts/log.sh "$DOTS_DIR/scripts/log.sh"
cp scripts/dots/lib.sh "$DOTS_DIR/scripts/dots/lib.sh"
cp scripts/dots/packages.sh "$DOTS_DIR/scripts/dots/packages.sh"
cp scripts/dots/detect-os.sh "$DOTS_DIR/scripts/dots/detect-os.sh"
printf '%s\n' '{}' >"$DOTS_DIR/common/.config/black-atom/livery/config.json"
printf '%s\n' '{}' >"$DOTS_DIR/common/.config/herdr/session.json"
printf '%s\n' '[tools]' >"$DOTS_DIR/common/.config/mise/config.toml"
: >"$DOTS_DIR/common/.config/mise/mise.lock"

cd "$DOTS_DIR"
git init -q
git config user.email test@example.com
git config user.name test
git add .
git commit -qm init
printf '%s\n' '{"changed":true}' >"$DOTS_DIR/common/.config/black-atom/livery/config.json"

cat >"$DOTS_DIR/.git/hooks/post-commit" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' '{"rewritten":true}' >common/.config/herdr/session.json
EOF
chmod +x "$DOTS_DIR/.git/hooks/post-commit"

output=$(printf 'N\n4\n' | env -u PI_CODING_AGENT -u CLAUDE_VERSION HOME="$TMP_DIR/home" DOTS_DIR="$DOTS_DIR" bash "$DOTS_DIR/dots" push 2>&1)

[[ "$output" != *"Open LazyGit?"* ]] || {
    printf '%s\n' "$output" >&2
    printf '%s\n' 'FAIL: push asked the LazyGit question before its dots decision' >&2
    exit 1
}
[[ "$(grep -c 'Phase 2: Dots commit & push' <<<"$output")" -eq 1 ]] || {
    printf '%s\n' "$output" >&2
    printf '%s\n' 'FAIL: push did not present exactly one dots decision' >&2
    exit 1
}

printf '%s\n' 'ok - push presents one decision for post-chores changes'
