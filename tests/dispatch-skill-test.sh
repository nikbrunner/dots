#!/usr/bin/env bash
set -euo pipefail

SKILL="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/common/.agents/skills/dispatch/SKILL.md"

contains() {
    grep -Fq -- "$1" "$SKILL"
}

contains 'disable-model-invocation: true'
contains "Invoke this skill explicitly as \`/skill:dispatch\`."
contains "infer a candidate from Git repositories under \`~/repos\`"
contains 'Ask the user to confirm the resolved absolute target path'
contains "git -C \"\$target_repo\" status --short"
contains 'worktree.checkout_path'
contains 'create an unfocused target workspace'
contains 'Launch anyway'
contains 'Write a handoff'
contains 'Create a tracker issue'
contains 'Ask for confirmation again before creating an external issue'
contains 'Pre-existing changes:'
contains "herdr agent start \"\$agent_name\" --kind \"\$harness\" --pane \"\$child_id\""
contains "herdr agent prompt \"\$agent_name\" \"\$child_prompt\""
contains 'ask one focused question'
if contains 'user-invocable:'; then
    printf 'unsupported Pi frontmatter is still referenced\n' >&2
    exit 1
fi
if contains 'herdr pane split --current'; then
    printf 'dispatch still splits the caller workspace\n' >&2
    exit 1
fi
contains 'Tell the child that its final response must contain only this copy-ready handoff'
contains 'Repository:'
contains 'Remaining issues:'
contains 'Suggested next step:'
contains 'not delegate this task'
contains 'Do not invoke Pi subagent tools'
contains 'Do not inspect or switch to another repository'
contains 'ignore unrelated skills'
contains 'You are the dispatched worker.'
contains 'Do not launch reviewers or other agents.'
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
