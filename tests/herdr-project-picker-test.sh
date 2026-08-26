#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
PICKER="$SCRIPT_DIR/../common/.local/bin/herdr-project-picker"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

root_dir="$TMP_DIR/repos"
fake_bin="$TMP_DIR/bin"
result_file="$TMP_DIR/result"
mkdir -p "$root_dir" "$fake_bin"

for repo in imf-notes other-project; do
    mkdir -p "$root_dir/$repo"
    git -C "$root_dir/$repo" init -q
    printf '%s\n' "$repo" >"$root_dir/$repo/README.md"
done

cat >"$fake_bin/fzf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${FAKE_FZF_CANCEL:-}" == 1 ]]; then
    exit 1
fi
if [[ "${FAKE_FZF_MANUAL:-}" == 1 ]]; then
    printf '__DISPATCH_ENTER_PATH__\n'
    exit 0
fi
if [[ "${FAKE_FZF_HARNESS:-}" == 1 ]]; then
    printf 'codex\n'
    exit 0
fi
while IFS= read -r line; do
    if [[ "$line" == *"${FAKE_FZF_SELECTION:-}"* ]]; then
        printf '%s\n' "$line"
        exit 0
    fi
done
exit 1
EOF
chmod +x "$fake_bin/fzf"

cat >"$fake_bin/gum" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == input ]]; then
    printf '%s\n' "${FAKE_GUM_INPUT:-}"
fi
EOF
chmod +x "$fake_bin/gum"

output=$(
    PATH="$fake_bin:$PATH" \
        FAKE_FZF_SELECTION=imf-notes \
        bash "$PICKER" \
        --query imf-notes \
        --result-file "$result_file" \
        --root "$root_dir"
)

expected=$(cd "$root_dir/imf-notes" && pwd -P)
[[ "$output" == *"__DISPATCH_PICKER_SELECTED__"* ]]
[[ "$(cat "$result_file")" == "$expected" ]]
printf 'ok - picker returns the selected absolute Git root\n'

cancel_output=$(
    PATH="$fake_bin:$PATH" \
        FAKE_FZF_CANCEL=1 \
        bash "$PICKER" \
        --query imf-notes \
        --result-file "$result_file" \
        --root "$root_dir"
)
[[ "$cancel_output" == *"__DISPATCH_PICKER_CANCELLED__"* ]]
[[ ! -s "$result_file" ]]
printf 'ok - picker reports cancellation without a result\n'

manual_output=$(
    PATH="$fake_bin:$PATH" \
        FAKE_FZF_MANUAL=1 \
        FAKE_GUM_INPUT="$root_dir/other-project" \
        bash "$PICKER" \
        --query missing \
        --result-file "$result_file" \
        --root "$root_dir"
)
[[ "$manual_output" == *"__DISPATCH_PICKER_SELECTED__"* ]]
expected_manual=$(cd "$root_dir/other-project" && pwd -P)
[[ "$(cat "$result_file")" == "$expected_manual" ]]
printf 'ok - picker accepts a manually entered repository path\n'

harness_output=$(
    PATH="$fake_bin:$PATH" \
        FAKE_FZF_HARNESS=1 \
        bash "$PICKER" \
        --harness \
        --result-file "$result_file"
)
[[ "$harness_output" == *"__DISPATCH_PICKER_SELECTED__"* ]]
[[ "$(cat "$result_file")" == codex ]]
printf 'ok - picker accepts a supported harness\n'
