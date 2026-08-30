#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

REPO_DIR="$TMP_DIR/repo"
export MISE_LOG="$TMP_DIR/mise.log"
mkdir -p "$REPO_DIR/common/.config/mise" "$REPO_DIR/scripts" "$TMP_DIR/bin"
cp "$ROOT/scripts/log.sh" "$REPO_DIR/scripts/log.sh"
printf '[tools]\n' >"$REPO_DIR/common/.config/mise/config.toml"
: >"$REPO_DIR/common/.config/mise/mise.lock"

git -C "$REPO_DIR" init -q
git -C "$REPO_DIR" config user.email test@example.com
git -C "$REPO_DIR" config user.name test
git -C "$REPO_DIR" add .
git -C "$REPO_DIR" commit -qm init

cat >"$TMP_DIR/bin/mise" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$MISE_LOG"
[[ "$*" == "lock --global --quiet" ]]
EOF
chmod +x "$TMP_DIR/bin/mise"
printf '# changed\n' >>"$REPO_DIR/common/.config/mise/config.toml"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

DOTS_DIR="$REPO_DIR" PATH="$TMP_DIR/bin:$PATH" bash -c 'source "$1/scripts/dots/lib.sh"; dots_stage_mise "$DOTS_DIR" || exit 1; [[ "$(wc -l <"$MISE_LOG")" -eq 1 ]] || exit 3; git -C "$DOTS_DIR" commit -qm changed; : >"$MISE_LOG"; if dots_stage_mise "$DOTS_DIR"; then exit 2; fi; [[ ! -s "$MISE_LOG" ]] || exit 4; exit 0' bash "$ROOT" || fail 'clean mise files still invoked the lock resolver'

git -C "$REPO_DIR" diff --cached --quiet || fail 'test repo has unexpected staged changes'
printf '%s\n' 'ok - unchanged mise files do not create a chore change'
