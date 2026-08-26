#!/usr/bin/env bash
set -euo pipefail

SKILL="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/common/.agents/skills/dispatch/SKILL.md"

contains() {
    grep -Fq -- "$1" "$SKILL"
}

contains 'user-invocable: true'
contains 'disable-model-invocation: true'
contains "herdr pane split --current --direction right --cwd \"\$target_repo\" --no-focus"
contains "herdr agent start \"\$agent_name\" --kind \"\$harness\" --pane \"\$child_id\""
contains "herdr agent prompt \"\$agent_name\" \"\$child_prompt\""
contains 'ask one focused question in the current conversation'
contains 'The final response must contain only the copy-ready handoff'
contains 'Repository:'
contains 'Remaining issues:'
contains 'Suggested next step:'
if contains 'herdr-dispatch'; then
    printf 'wrapper binary is still referenced\n' >&2
    exit 1
fi
if contains 'herdr-project-picker'; then
    printf 'project picker is still referenced\n' >&2
    exit 1
fi
if contains 'herdr pane wait-output'; then
    printf 'picker wait is still referenced\n' >&2
    exit 1
fi
if contains ' --focus'; then
    printf 'focused picker flow is still referenced\n' >&2
    exit 1
fi
if contains "agent prompt \"\$agent_name\" \"\$child_prompt\" --wait"; then
    printf 'blocking child prompt is still referenced\n' >&2
    exit 1
fi
printf '%s\n' 'ok - dispatch skill uses one direct non-blocking Herdr child pane'
