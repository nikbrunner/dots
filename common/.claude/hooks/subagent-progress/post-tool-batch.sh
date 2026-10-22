#!/usr/bin/env bash
# Claude Code PostToolBatch hook: reminds a subagent to write a fresh
# `PROGRESS: n/m · step` line (see subagent-start.sh) once it has made
# THRESHOLD tool calls without one, then again every THRESHOLD calls.
# Main-session batches exit untouched.

THRESHOLD=20

input=$(cat)
agent_id=$(jq -r '.agent_id // ""' <<<"$input")
[[ -n $agent_id ]] || exit 0
transcript=$(jq -r '.transcript_path // ""' <<<"$input")

# transcript_path may name the subagent's own file or the main session's.
id=${agent_id#agent-}
if [[ $(basename "$transcript") == agent-*.jsonl ]]; then
    file=$transcript
else
    file="${transcript%.jsonl}/subagents/agent-$id.jsonl"
fi
[[ -f $file ]] || exit 0

# Only assistant lines: the start hook's instruction text contains an example PROGRESS line.
read -r total since < <(grep '"type":"assistant"' "$file" | awk '
	/PROGRESS: [0-9]+\/[0-9]+ · / { since = 0 }
	{ n = gsub(/"type":"tool_use"/, "&"); total += n; since += n }
	END { print total + 0, since + 0 }')

state_dir="${TMPDIR:-/tmp}/claude-subagent-progress"
state="$state_dir/$id"
last=$(cat "$state" 2>/dev/null || echo 0)
((since >= THRESHOLD && total - last >= THRESHOLD)) || exit 0
mkdir -p "$state_dir" && echo "$total" >"$state"

jq -cn --arg n "$since" '{hookSpecificOutput: {hookEventName: "PostToolBatch", additionalContext:
	("Progress reporting: \($n) tool calls since your last `PROGRESS:` line, so the status line still shows that step. " +
	"In your next message, before any tool call, write the current `PROGRESS: <step>/<total> · <what this step does>` line as visible text. " +
	"Repeating the current step is fine if you are still on it; adjust the total if your plan changed.")}}'
