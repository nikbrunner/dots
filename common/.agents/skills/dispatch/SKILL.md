---
name: dispatch
description: Use when a task belongs in another repository or a separate Herdr pane, especially when the user asks to spawn, dispatch, sidekick, fork, or hand off work to Pi, Claude Code, Codex, or another coding harness.
---

# Dispatch

Start a separate coding-agent session in a user-selected repository. Use Herdr's CLI directly so the flow works from Pi, Claude Code, Codex, or another harness.

## Rules

- This skill requires `HERDR_ENV=1`. If it is not `1`, explain that dispatch must run inside Herdr and stop.
- Dispatch is non-blocking after selection. Never wait for, read from, summarize, or close the dispatched child.
- The temporary picker may wait for the user's choice. The child pane remains open after completion.
- Use only the built-in harnesses `pi`, `claude`, and `codex`.
- Parse every Herdr ID from its JSON response. Never guess IDs or rely on UI focus.
- Do not use Pi subagent tools or npm orchestration packages.

## Select the repository

1. Extract a short repository hint from the user's brief. Keep the full brief for the child prompt.
2. If the brief contains an explicit existing directory, validate it with `git -C <path> rev-parse --show-toplevel` and use that root.
3. Otherwise create a temporary result file and a focused picker pane:

```bash
picker=$(herdr pane split --current --direction right --cwd "$PWD" --focus)
picker_id=$(printf '%s\n' "$picker" | jq -er '.result.pane.pane_id')
printf -v picker_command 'herdr-project-picker --query %q --result-file %q --root %q' \
  "$hint" "$result_file" "$repo_parent"
herdr pane run "$picker_id" "$picker_command"
herdr pane wait-output "$picker_id" --regex '__DISPATCH_PICKER_(SELECTED|CANCELLED)__'
```

Add one `--root %q` segment for each existing standard root before running the command. Build the command with `printf -v` so spaces and shell characters in paths or the query stay arguments to the picker.

Tell the user to select a repository in the focused pane. Read the result file only after the sentinel appears. On cancellation, close the picker pane and stop. Validate the returned path before launching anything.

Use the current repository's parent and existing `$HOME/repos`, `$HOME/src`, `$HOME/projects`, and `$HOME/work` directories as roots. Do not scan the whole home directory.

## Select the harness

Use an explicit `pi`, `claude`, or `codex` request from the brief. Otherwise use the harness running the current session. If that cannot be identified, run `herdr-project-picker --harness` in the same temporary picker pane and let the user choose.

## Launch

Build a concise child prompt containing the selected repository, the user's task, relevant current-session context, known constraints, and the instruction to implement, verify, and stop. Do not paste the raw conversation.

Create the real child pane and send exactly one prompt:

```bash
child=$(herdr pane split --current --direction right --cwd "$target_repo" --no-focus)
child_id=$(printf '%s\n' "$child" | jq -er '.result.pane.pane_id')
herdr agent start "$agent_name" --kind "$harness" --pane "$child_id"
herdr agent prompt "$agent_name" "$child_prompt"
```

Do not add `--wait`. `agent start` may wait briefly for startup readiness; that is not child-task waiting. After `agent prompt` returns, report the harness, repository, and pane name, then finish the turn.
