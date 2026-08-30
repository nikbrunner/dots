#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

export DOTS_DIR="$TMP_DIR/dots"
export DOTS_TEST_LOG="$TMP_DIR/calls.log"
export HOME="$TMP_DIR/home"
mkdir -p "$DOTS_DIR/common/.config/mise" "$DOTS_DIR/install/mac" "$DOTS_DIR/install/arch" "$TMP_DIR/bin" "$HOME/Applications/old-app.app" "$HOME/Applications/new-app.app"
: >"$DOTS_DIR/common/.config/mise/config.toml"
: >"$DOTS_DIR/install/mac/Brewfile"
printf 'declared\n' >"$DOTS_DIR/install/arch/pkglist.txt"

cat >"$TMP_DIR/bin/mise" <<'EOF'
#!/usr/bin/env bash
printf 'mise %s\n' "$*" >>"$DOTS_TEST_LOG"
case " $* " in
  *" --current "*) printf '%s\n' '{"node":[{"version":"22.0.0"}]}' ;;
  *" --installed "*) printf '%s\n' '{"node":[{"version":"22.0.0"}],"orphan":[{"version":"1.0.0"}]}' ;;
esac
EOF

cat >"$TMP_DIR/bin/brew" <<'EOF'
#!/usr/bin/env bash
printf 'brew %s\n' "$*" >>"$DOTS_TEST_LOG"
case " $* " in
  *" bundle list --formula "*) printf '%s\n' 'declared' ;;
  *" bundle list --cask "*) printf '%s\n' 'app' ;;
  *" list --formula --installed-on-request "*) printf '%s\n' declared extra ;;
  *" list --formula "*) printf '%s\n' dependency-only ;;
  *" list --cask "*) printf '%s\n' app old-app new-app ;;
  *" info --json=v2"*old-app*) printf '%s\n' '{"casks":[{"artifacts":[{"app":["old-app.app"]}]}]}' ;;
  *" info --json=v2"*new-app*) printf '%s\n' '{"casks":[{"artifacts":[{"app":["new-app.app"]}]}]}' ;;
  *" info --json=v2"*) printf '%s\n' '{"casks":[]}' ;;
esac
EOF

cat >"$TMP_DIR/bin/paru" <<'EOF'
#!/usr/bin/env bash
printf 'paru %s\n' "$*" >>"$DOTS_TEST_LOG"
EOF

cat >"$TMP_DIR/bin/pacman" <<'EOF'
#!/usr/bin/env bash
printf 'pacman %s\n' "$*" >>"$DOTS_TEST_LOG"
if [[ "$*" == *"-Qqe"* ]]; then
  printf '%s\n' declared orphan-pkg
fi
EOF

cat >"$TMP_DIR/bin/gum" <<'EOF'
#!/usr/bin/env bash
printf 'gum %s\n' "$*" >>"$DOTS_TEST_LOG"
[[ -n "${DOTS_TEST_SELECTION:-}" ]] && printf '%s\n' "$DOTS_TEST_SELECTION"
EOF

cat >"$TMP_DIR/bin/mdls" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  *old-app*) printf '%s\n' '2020-01-01 00:00:00 +0000' ;;
  *new-app*) printf '%s\n' '2026-01-01 00:00:00 +0000' ;;
  *) printf '%s\n' '2026-01-01 00:00:00 +0000' ;;
esac
EOF

chmod +x "$TMP_DIR/bin"/*
export PATH="$TMP_DIR/bin:$PATH"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_log() {
    grep -Fq -- "$1" "$DOTS_TEST_LOG" || fail "missing call: $1"
}

assert_no_log() {
    ! grep -Fq -- "$1" "$DOTS_TEST_LOG" || fail "unexpected call: $1"
}

source "$ROOT/scripts/dots/packages.sh"

: "${DOTS_TEST_OS:=macos}"
get_os() { printf '%s\n' "$DOTS_TEST_OS"; }
confirm() { [[ "${DOTS_TEST_CONFIRM:-false}" == true ]]; }

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=macos packages_install
assert_log "mise install --cd $DOTS_DIR/common/.config/mise --locked"
assert_log "brew bundle install --no-upgrade --file=$DOTS_DIR/install/mac/Brewfile"

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=arch packages_install
assert_log "mise install --cd $DOTS_DIR/common/.config/mise --locked"
assert_log "paru -S --needed --noconfirm"
assert_no_log "brew bundle"

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=macos packages_install --upgrade
assert_log "mise upgrade --cd $DOTS_DIR/common/.config/mise"
assert_log "brew bundle install --upgrade --file=$DOTS_DIR/install/mac/Brewfile"
assert_no_log "--no-upgrade"

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=linux packages_install
assert_log "mise install --cd $DOTS_DIR/common/.config/mise --locked"
assert_no_log "brew bundle"
assert_no_log "paru -S"

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=macos packages_purge --dry-run >"$TMP_DIR/purge.txt"
assert_log "brew bundle list --formula"
assert_log "mise ls --global --installed --json"
assert_no_log "brew uninstall"
assert_no_log "mise uninstall"
assert_no_log "paru -Rns"

old_line=$(grep -n 'old-app' "$TMP_DIR/purge.txt" | cut -d: -f1)
new_line=$(grep -n 'new-app' "$TMP_DIR/purge.txt" | cut -d: -f1)
[[ "$old_line" -lt "$new_line" ]] || fail 'purge candidates are not sorted by last-used metadata'
! grep -Fq 'dependency-only' "$TMP_DIR/purge.txt" || fail 'dependency-only formula was offered for removal'

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=arch packages_purge --dry-run >"$TMP_DIR/arch-purge.txt"
assert_log "pacman -Qqe"
assert_no_log "brew bundle list"

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=macos DOTS_TEST_SELECTION='' packages_purge
assert_no_log "brew uninstall"
assert_no_log "mise uninstall"

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=macos DOTS_TEST_SELECTION='Homebrew formula: extra' DOTS_TEST_CONFIRM=false packages_purge
assert_no_log "brew uninstall"

: >"$DOTS_TEST_LOG"
DOTS_TEST_OS=macos DOTS_TEST_SELECTION='Homebrew formula: extra' DOTS_TEST_CONFIRM=true packages_purge
assert_log "brew uninstall --formula extra"
assert_no_log "brew uninstall --formula old-app"

printf '%s\n' 'ok - package sync and purge behavior'
