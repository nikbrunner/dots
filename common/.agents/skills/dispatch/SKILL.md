---
name: dispatch
description: Use when a task belongs in another repository or a separate Herdr pane, especially when the user asks to spawn, dispatch, sidekick, fork, or hand off work to Pi, Claude Code, Codex, or another coding harness.
user-invocable: true
disable-model-invocation: true
argument-hint: "[pi|claude|codex] task brief"
---

# Dispatch

Start a fresh coding-agent session in a separate Herdr pane. Invoke this skill explicitly as `/dispatch`.

## Resolve the target

Use the user's brief and the current session context to identify the repository. When the user says “this repository” or “here”, use the current working directory. When the brief names another repository, resolve it from the paths and repository context already available to the conversation.

Validate the target before launching:

```bash
target_repo=$(git -C "$target_repo" rev-parse --show-toplevel)
target_repo=$(cd -- "$target_repo" && pwd -P)
```

Do not scan repository roots or open a repository picker. If the repository is ambiguous, ask one focused question in the current conversation and wait for the answer.

## Resolve the harness

Use an explicit `pi`, `claude`, or `codex` request from the brief. Otherwise use the harness running the current session. If that cannot be identified, ask which of `pi`, `claude`, or `codex` to use in the current conversation. Do not open a harness picker.

## Launch

This skill requires `HERDR_ENV=1`. If it is not `1`, explain that dispatch must run inside Herdr and stop.

Build a concise child prompt containing the selected repository, the user's task, relevant current-session context, known constraints, and the instruction to implement, verify, and stop. Do not paste the raw conversation. Tell the child that it owns the task in a fresh pane and should not perform unrelated work.

Run these commands directly from the current pane:

```bash
test "${HERDR_ENV:-}" = 1 || {
  printf '%s\n' 'Dispatch must run inside Herdr.' >&2
  return 1 2>/dev/null || exit 1
}
child=$(herdr pane split --current --direction right --cwd "$target_repo" --no-focus)
child_id=$(printf '%s\n' "$child" | jq -er '.result.pane.pane_id')
agent_name="dispatch-$(date +%s)"
herdr agent start "$agent_name" --kind "$harness" --pane "$child_id"
herdr agent prompt "$agent_name" "$child_prompt"
```

Parse every Herdr ID from its JSON response. Never guess IDs or rely on UI focus. The new pane remains open. Do not add `--wait`, wait for child completion, read child output, summarize its work, or close its pane. Agent startup readiness may take a moment; that is not child-task waiting.

Use only Herdr's built-in commands. Do not use Pi subagent tools, npm orchestration packages, wrapper scripts, or picker scripts.
