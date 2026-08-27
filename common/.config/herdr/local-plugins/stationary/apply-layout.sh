#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
RECIPE_PATH="$SCRIPT_DIR/layouts.toml"

log() {
    printf 'dots.stationary: %s\n' "$*" >&2
}

require_id() {
    name=$1
    eval "value=\${$name:-}"
    if [ -z "$value" ]; then
        log "Missing required event value: $name"
        exit 1
    fi
}

require_id HERDR_WORKSPACE_ID
require_id HERDR_TAB_ID
require_id HERDR_PANE_ID

if [ -z "${HERDR_BIN_PATH:-}" ] || ! HERDR_BIN=$(command -v "$HERDR_BIN_PATH" 2>/dev/null); then
    log "Herdr binary is unavailable"
    exit 1
fi

configuration_failed() {
    message=$1
    log "$message"
    "$HERDR_BIN" notification show "Stationary configuration failed" \
        --body "$message" --sound request >/dev/null 2>&1 || true
    exit 1
}

REAPPLY=false
if [ "$#" -eq 1 ] && [ -n "$1" ]; then
    LAYOUT_NAME=$1
elif [ "$#" -eq 2 ] && [ -n "$1" ] && [ "$2" = "--reapply" ]; then
    LAYOUT_NAME=$1
    REAPPLY=true
else
    configuration_failed "Expected a layout name, optionally followed by --reapply"
fi

if ! command -v jq >/dev/null 2>&1; then
    configuration_failed "jq is unavailable"
fi
if ! command -v yq >/dev/null 2>&1; then
    configuration_failed "yq is unavailable"
fi
if [ ! -f "$RECIPE_PATH" ]; then
    configuration_failed "Layout recipe is unavailable: $RECIPE_PATH"
fi

if ! RECIPE_JSON=$(yq -p toml -o json '.' "$RECIPE_PATH" 2>/dev/null); then
    configuration_failed "Layout recipe is not valid TOML: $RECIPE_PATH"
fi

if ! printf '%s\n' "$RECIPE_JSON" | jq -e '
  def allowed($names):
    type == "object" and ((keys_unsorted - $names) | length) == 0;
  def has_all($names):
    . as $object |
    all($names[]; . as $name | $object | has($name));
  def safe_text:
    type == "string" and length > 0 and
    (test("[\u0000-\u001f\u007f-\u009f\u2028\u2029]") | not);
  def optional_text($name):
    . as $object |
    (($object | has($name) | not) or ($object[$name] | safe_text));
  def optional_boolean($name):
    . as $object |
    (($object | has($name) | not) or (($object[$name] | type) == "boolean"));
  def root_valid:
    allowed(["pane", "run", "focus"]) and
    has_all(["pane"]) and
    (.pane | safe_text) and
    optional_text("run") and
    optional_boolean("focus");
  def split_valid:
    allowed(["source", "direction", "ratio", "pane", "run", "focus"]) and
    has_all(["source", "direction", "ratio", "pane"]) and
    (.source | safe_text) and
    (.pane | safe_text) and
    (.direction == "right" or .direction == "down") and
    ((.ratio | type) == "number" and .ratio > 0 and .ratio < 1) and
    optional_text("run") and
    optional_boolean("focus");
  def tab_valid:
    . as $tab |
    ($tab | allowed(["order", "root", "splits"])) and
    ($tab | has_all(["order", "root", "splits"])) and
    (($tab.order | type) == "number" and $tab.order == ($tab.order | floor)) and
    ($tab.root | root_valid) and
    (($tab.splits | type) == "array") and
    (reduce range(0; ($tab.splits | length)) as $index
      ({
        ok: true,
        seen: [$tab.root.pane],
        focus_count: (if $tab.root.focus? == true then 1 else 0 end)
      };
       ($tab.splits[$index]) as $split |
       . as $state |
       {
         ok: ($state.ok and
              ($split | split_valid) and
              (($state.seen | index($split.source)) != null) and
              (($state.seen | index($split.pane)) == null)),
         seen: ($state.seen + [$split.pane]),
         focus_count: ($state.focus_count +
           (if $split.focus? == true then 1 else 0 end))
       }) |
     .ok and .focus_count <= 1);
  def layout_valid:
    . as $layout |
    ($layout | allowed(["focus", "tabs"])) and
    ($layout | has_all(["focus", "tabs"])) and
    ($layout.focus | safe_text) and
    (($layout.tabs | type) == "object" and ($layout.tabs | length) > 0) and
    ($layout.tabs | has($layout.focus)) and
    (all($layout.tabs | to_entries[];
      (.key | safe_text) and (.value | tab_valid))) and
    ([$layout.tabs[].order] as $orders |
      if all($orders[]; type == "number" and . == floor) then
        ($orders | sort) == [range(1; ($orders | length) + 1)]
      else false end);
  def document_valid:
    allowed(["layouts"]) and
    has_all(["layouts"]) and
    ((.layouts | type) == "object" and (.layouts | length) > 0) and
    all(.layouts | to_entries[];
      (.key | safe_text) and (.value | layout_valid));
  document_valid
' >/dev/null; then
    configuration_failed "Layout recipe does not match the Stationary schema: $RECIPE_PATH"
fi

if ! LAYOUT_JSON=$(printf '%s\n' "$RECIPE_JSON" | jq -cer --arg name "$LAYOUT_NAME" '.layouts[$name]'); then
    configuration_failed "Unknown Stationary layout: $LAYOUT_NAME"
fi

TABS_JSON=$("$HERDR_BIN" tab list --workspace "$HERDR_WORKSPACE_ID")
PANES_JSON=$("$HERDR_BIN" pane list --workspace "$HERDR_WORKSPACE_ID")
TAB_COUNT=$(printf '%s\n' "$TABS_JSON" | jq -er '.result.tabs | length')
PANE_COUNT=$(printf '%s\n' "$PANES_JSON" | jq -er '.result.panes | length')

OLD_TAB_IDS=
if [ "$REAPPLY" = true ]; then
    if ! printf '%s\n' "$TABS_JSON" | jq -e --arg id "$HERDR_TAB_ID" 'any(.result.tabs[]; .tab_id == $id)' >/dev/null; then
        configuration_failed "Current tab is unavailable in workspace $HERDR_WORKSPACE_ID"
    fi
    OLD_TAB_IDS=$(printf '%s\n' "$TABS_JSON" | jq -er '.result.tabs[].tab_id')
else
    if [ "$TAB_COUNT" -ne 1 ] || [ "$PANE_COUNT" -ne 1 ]; then
        log "Skipping Stationary for non-fresh workspace $HERDR_WORKSPACE_ID"
        exit 0
    fi

    TAB_ID=$(printf '%s\n' "$TABS_JSON" | jq -er '.result.tabs[0].tab_id')
    PANE_ID=$(printf '%s\n' "$PANES_JSON" | jq -er '.result.panes[0].pane_id')

    if [ "$TAB_ID" != "$HERDR_TAB_ID" ] || [ "$PANE_ID" != "$HERDR_PANE_ID" ]; then
        log "Skipping Stationary for non-fresh workspace $HERDR_WORKSPACE_ID"
        exit 0
    fi
fi

verify_repairable() {
    EXPECTED_TAB_LABELS=$(printf '%s\n' "$LAYOUT_JSON" | jq -c '[.tabs | keys[]] | sort') || return 1
    ACTUAL_TAB_LABELS=$(printf '%s\n' "$TABS_JSON" | jq -c '[.result.tabs[].label] | sort') || return 1
    [ "$EXPECTED_TAB_LABELS" = "$ACTUAL_TAB_LABELS" ] || return 1

    TAB_ROWS=$(printf '%s\n' "$LAYOUT_JSON" | jq -c '.tabs | to_entries | sort_by(.value.order)[]') || return 1
    while IFS= read -r TAB_JSON; do
        TAB_NAME=$(printf '%s\n' "$TAB_JSON" | jq -er '.key') || return 1
        TAB_ID=$(printf '%s\n' "$TABS_JSON" | jq -er --arg name "$TAB_NAME" \
            '.result.tabs[] | select(.label == $name) | .tab_id') || return 1
        EXPECTED_PANE_LABELS=$(printf '%s\n' "$TAB_JSON" | jq -c \
            '[.value.root.pane] + [.value.splits[].pane] | sort') || return 1
        ACTUAL_PANE_LABELS=$(printf '%s\n' "$PANES_JSON" | jq -c --arg tab_id "$TAB_ID" \
            '[.result.panes[] | select(.tab_id == $tab_id) | .label] | sort') || return 1
        [ "$EXPECTED_PANE_LABELS" = "$ACTUAL_PANE_LABELS" ] || return 1

        ROOT_SOURCE_NAME=$(printf '%s\n' "$TAB_JSON" | jq -er '.value.root.pane') || return 1
        SOURCE_ID=$(printf '%s\n' "$PANES_JSON" | jq -er \
            --arg tab_id "$TAB_ID" --arg name "$ROOT_SOURCE_NAME" \
            '.result.panes[] | select(.tab_id == $tab_id and .label == $name) | .pane_id') || return 1
        TAB_LAYOUT=$("$HERDR_BIN" pane layout --pane "$SOURCE_ID") || return 1
        EXPECTED_DIRECTIONS=$(printf '%s\n' "$TAB_JSON" | jq -c '[.value.splits[].direction]') || return 1
        ACTUAL_DIRECTIONS=$(printf '%s\n' "$TAB_LAYOUT" | jq -c '[.result.layout.splits[].direction]') || return 1
        [ "$EXPECTED_DIRECTIONS" = "$ACTUAL_DIRECTIONS" ] || return 1

        SPLIT_ROWS=$(printf '%s\n' "$TAB_JSON" | jq -c '.value.splits[]') || return 1
        INDEX=0
        if [ -n "$SPLIT_ROWS" ]; then
            while IFS= read -r SPLIT_JSON; do
                SOURCE_NAME=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.source') || return 1
                SOURCE_ID=$(printf '%s\n' "$PANES_JSON" | jq -er \
                    --arg tab_id "$TAB_ID" --arg name "$SOURCE_NAME" \
                    '.result.panes[] | select(.tab_id == $tab_id and .label == $name) | .pane_id') || return 1
                TARGET_NAME=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.pane') || return 1
                TARGET_ID=$(printf '%s\n' "$PANES_JSON" | jq -er \
                    --arg tab_id "$TAB_ID" --arg name "$TARGET_NAME" \
                    '.result.panes[] | select(.tab_id == $tab_id and .label == $name) | .pane_id') || return 1
                DIRECTION=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.direction') || return 1
                TARGET_RATIO=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.ratio + 0') || return 1
                CURRENT_RATIO=$(printf '%s\n' "$TAB_LAYOUT" | jq -er --argjson index "$INDEX" \
                    '.result.layout.splits[$index].ratio + 0') || return 1
                FOCUS=$(printf '%s\n' "$SPLIT_JSON" | jq -r '.focus // false') || return 1
                printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                    "$TAB_ID" "$SOURCE_ID" "$TARGET_ID" "$DIRECTION" \
                    "$TARGET_RATIO" "$CURRENT_RATIO" "$FOCUS"
                INDEX=$((INDEX + 1))
            done <<EOF
$SPLIT_ROWS
EOF
        fi
    done <<EOF
$TAB_ROWS
EOF
}

focus_to_pane() {
    TAB_ID=$1
    CURRENT_ID=$2
    TARGET_ID=$3
    DIRECTION=$4
    "$HERDR_BIN" tab focus "$TAB_ID" >/dev/null || return 1

    STEPS=0
    while [ "$CURRENT_ID" != "$TARGET_ID" ]; do
        NEXT_ID=$("$HERDR_BIN" pane neighbor --pane "$CURRENT_ID" \
            --direction "$DIRECTION" | jq -er \
            '.result.neighbor.neighbor_pane_id // .result.neighbor_pane_id // empty') || return 1
        [ -n "$NEXT_ID" ] || return 1
        [ "$NEXT_ID" != "$CURRENT_ID" ] || return 1
        "$HERDR_BIN" pane focus --pane "$CURRENT_ID" --direction "$DIRECTION" >/dev/null || return 1
        CURRENT_ID=$NEXT_ID
        STEPS=$((STEPS + 1))
        [ "$STEPS" -lt 100 ] || return 1
    done
}

apply_repair_plan() {
    while IFS='	' read -r TAB_ID SOURCE_ID TARGET_ID DIRECTION TARGET_RATIO CURRENT_RATIO FOCUS; do
        [ -n "$TAB_ID" ] || continue
        AMOUNT=$(awk -v target="$TARGET_RATIO" -v current="$CURRENT_RATIO" \
            'BEGIN { difference = target - current; if (difference < 0) difference = -difference; printf "%.6g", difference }')
        if awk -v amount="$AMOUNT" 'BEGIN { exit !(amount > 0.001) }'; then
            if awk -v target="$TARGET_RATIO" -v current="$CURRENT_RATIO" \
                'BEGIN { exit !(target > current) }'; then
                RESIZE_DIRECTION=$DIRECTION
            else
                case "$DIRECTION" in
                    right) RESIZE_DIRECTION=left ;;
                    down) RESIZE_DIRECTION=up ;;
                    left) RESIZE_DIRECTION=right ;;
                    up) RESIZE_DIRECTION=down ;;
                    *) return 1 ;;
                esac
            fi
            "$HERDR_BIN" pane resize --pane "$SOURCE_ID" \
                --direction "$RESIZE_DIRECTION" --amount "$AMOUNT" >/dev/null || return 1
        fi
        if [ "$FOCUS" = true ]; then
            focus_to_pane "$TAB_ID" "$SOURCE_ID" "$TARGET_ID" "$DIRECTION" || return 1
        fi
    done <"$1"

    FOCUS_TAB_NAME=$(printf '%s\n' "$LAYOUT_JSON" | jq -er '.focus') || return 1
    FOCUS_TAB_ID=$(printf '%s\n' "$TABS_JSON" | jq -er --arg name "$FOCUS_TAB_NAME" \
        '.result.tabs[] | select(.label == $name) | .tab_id') || return 1
    "$HERDR_BIN" tab focus "$FOCUS_TAB_ID" >/dev/null || return 1
}

if [ "$REAPPLY" = true ]; then
    REPAIR_PLAN=$(mktemp)
    if verify_repairable >"$REPAIR_PLAN" && apply_repair_plan "$REPAIR_PLAN"; then
        rm -f "$REPAIR_PLAN"
        log "Repaired Stationary layout $LAYOUT_NAME in workspace $HERDR_WORKSPACE_ID"
        exit 0
    fi
    rm -f "$REPAIR_PLAN"
    log "Stationary repair was not possible; rebuilding workspace $HERDR_WORKSPACE_ID"
    RESULT=$(
        "$HERDR_BIN" tab create --workspace "$HERDR_WORKSPACE_ID" \
            --label "$LAYOUT_NAME" --no-focus
    )
    TAB_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.tab.tab_id')
    PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.root_pane.pane_id')
fi

WORK_DIR=$(mktemp -d)
PANE_MAP="$WORK_DIR/panes"
TAB_MAP="$WORK_DIR/tabs"
COMMANDS="$WORK_DIR/commands"
: >"$PANE_MAP"
: >"$TAB_MAP"
: >"$COMMANDS"

mutation_failed() {
    status=$?
    trap - EXIT HUP INT TERM
    rm -rf "$WORK_DIR"
    log "Failed to apply Stationary to workspace $HERDR_WORKSPACE_ID"
    "$HERDR_BIN" notification show "Stationary failed" \
        --body "Workspace $HERDR_WORKSPACE_ID may have a partial layout." \
        --sound request >/dev/null 2>&1 || true
    exit "$status"
}
trap mutation_failed EXIT HUP INT TERM

mapped_id_for() {
    map_file=$1
    wanted=$2
    while IFS='	' read -r mapped_name mapped_id; do
        if [ "$mapped_name" = "$wanted" ]; then
            printf '%s\n' "$mapped_id"
            return 0
        fi
    done <"$map_file"
    return 1
}

pane_id_for() {
    mapped_id_for "$PANE_MAP" "$1"
}

TAB_ROWS=$(printf '%s\n' "$LAYOUT_JSON" | jq -c '.tabs | to_entries | sort_by(.value.order)[]')
while IFS= read -r TAB_JSON; do
    TAB_NAME=$(printf '%s\n' "$TAB_JSON" | jq -er '.key')
    ORDER=$(printf '%s\n' "$TAB_JSON" | jq -er '.value.order')
    ROOT_NAME=$(printf '%s\n' "$TAB_JSON" | jq -er '.value.root.pane')

    if [ "$ORDER" -eq 1 ]; then
        CURRENT_TAB_ID=$TAB_ID
        ROOT_PANE_ID=$PANE_ID
        "$HERDR_BIN" tab rename "$CURRENT_TAB_ID" "$TAB_NAME" >/dev/null
    else
        RESULT=$("$HERDR_BIN" tab create --workspace "$HERDR_WORKSPACE_ID" \
            --label "$TAB_NAME" --no-focus)
        CURRENT_TAB_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.tab.tab_id')
        ROOT_PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.root_pane.pane_id')
    fi

    printf '%s\t%s\n' "$TAB_NAME" "$CURRENT_TAB_ID" >>"$TAB_MAP"
    : >"$PANE_MAP"
    printf '%s\t%s\n' "$ROOT_NAME" "$ROOT_PANE_ID" >>"$PANE_MAP"
    "$HERDR_BIN" pane rename "$ROOT_PANE_ID" "$ROOT_NAME" >/dev/null

    if ROOT_RUN=$(printf '%s\n' "$TAB_JSON" | jq -er '.value.root.run // empty'); then
        printf '%s\t%s\n' "$ROOT_PANE_ID" "$ROOT_RUN" >>"$COMMANDS"
    fi

    SPLIT_ROWS=$(printf '%s\n' "$TAB_JSON" | jq -c '.value.splits[]')
    if [ -n "$SPLIT_ROWS" ]; then
        while IFS= read -r SPLIT_JSON; do
            SOURCE_NAME=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.source')
            DIRECTION=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.direction')
            RATIO=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.ratio + 0')
            NEW_NAME=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.pane')
            SOURCE_ID=$(pane_id_for "$SOURCE_NAME")
            if [ "$(printf '%s\n' "$SPLIT_JSON" | jq -r '.focus // false')" = true ]; then
                FOCUS_FLAG=--focus
            else
                FOCUS_FLAG=--no-focus
            fi

            RESULT=$("$HERDR_BIN" pane split --pane "$SOURCE_ID" \
                --direction "$DIRECTION" --ratio "$RATIO" "$FOCUS_FLAG")
            NEW_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.pane.pane_id')
            printf '%s\t%s\n' "$NEW_NAME" "$NEW_ID" >>"$PANE_MAP"
            "$HERDR_BIN" pane rename "$NEW_ID" "$NEW_NAME" >/dev/null

            if RUN_COMMAND=$(printf '%s\n' "$SPLIT_JSON" | jq -er '.run // empty'); then
                printf '%s\t%s\n' "$NEW_ID" "$RUN_COMMAND" >>"$COMMANDS"
            fi
        done <<EOF
$SPLIT_ROWS
EOF
    fi
done <<EOF
$TAB_ROWS
EOF

while IFS='	' read -r COMMAND_PANE_ID COMMAND; do
    "$HERDR_BIN" pane run "$COMMAND_PANE_ID" "$COMMAND" >/dev/null
done <"$COMMANDS"

FOCUS_TAB_NAME=$(printf '%s\n' "$LAYOUT_JSON" | jq -er '.focus')
FOCUS_TAB_ID=$(mapped_id_for "$TAB_MAP" "$FOCUS_TAB_NAME")
"$HERDR_BIN" tab focus "$FOCUS_TAB_ID" >/dev/null

if [ "$REAPPLY" = true ]; then
    while IFS= read -r OLD_TAB_ID; do
        [ -n "$OLD_TAB_ID" ] && "$HERDR_BIN" tab close "$OLD_TAB_ID" >/dev/null
    done <<EOF
$OLD_TAB_IDS
EOF
fi

trap - EXIT HUP INT TERM
rm -rf "$WORK_DIR"
log "Applied Stationary layout $LAYOUT_NAME to workspace $HERDR_WORKSPACE_ID"
