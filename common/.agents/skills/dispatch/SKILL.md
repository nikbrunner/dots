---
name: dispatch
description: Start a fresh coding agent in a Herdr workspace for another repository. Use when the user asks to dispatch, spawn, sidekick, fork, or hand off a task to Pi, Claude Code, Codex, or another coding harness.
disable-model-invocation: true
---

# Dispatch

Start a fresh coding-agent session in the target repository's Herdr workspace. Invoke this skill explicitly as `/skill:dispatch`.

## Preconditions

This skill requires `HERDR_ENV=1`. Check it before inspecting Herdr or resolving a workspace:

```bash
test "${HERDR_ENV:-}" = 1 || {
  printf '%s\n' 'Dispatch must run inside Herdr.' >&2
  return 1 2>/dev/null || exit 1
}
```

## Resolve and confirm the target

Establish an exact Git checkout before creating a pane or starting an agent.

- When the brief says “here”, “this repository”, or otherwise clearly names the current checkout, use the current Git root as the candidate.
- When it refers to another project, infer a candidate from Git repositories under `~/repos`. Include ordinary checkouts and linked worktrees, deduplicate their canonical Git roots, and use the brief and current session context to choose the best candidate.
- A direct path in the brief is also a candidate.

Use this inventory when another project needs to be inferred:

```bash
find "$HOME/repos" \( -type d -name .git -prune -print \) -o \( -type f -name .git -print \) |
  while IFS= read -r git_entry; do
    git -C "$(dirname "$git_entry")" rev-parse --show-toplevel
  done | sort -u
```

Canonicalize the candidate before presenting it:

```bash
target_repo=$(git -C "$candidate" rev-parse --show-toplevel)
target_repo=$(cd -- "$target_repo" && pwd -P)
```

Ask the user to confirm the resolved absolute target path in the current conversation. For example: “I resolved this to `/Users/nik/repos/acme/project`. Dispatch there?” Do this even for the current checkout. If no candidate is clear or several candidates tie, ask one focused question for the path. Do not open a repository picker and do not create a pane from an unconfirmed inference.

## Check the target worktree

After the user confirms the path, check its state before creating a workspace or pane:

```bash
git -C "$target_repo" status --short
```

When the output is empty, continue. When it is not, show the changed-file summary and ask the user to choose one action:

- **Launch anyway**: start the worker and include the pre-existing status in its prompt. The worker must leave those changes alone unless the task explicitly requires them.
- **Write a handoff**: return a copy-ready handoff containing the target, task, dirty-state summary, and suggested next step. Do not launch an agent.
- **Create a tracker issue**: inspect the `origin` remote and identify its GitHub or Bitbucket target. Ask for confirmation again before creating an external issue. Use an authenticated, directly applicable tracker tool only when available. Otherwise return the copy-ready handoff. Do not infer a Jira project from a remote.
- **Stop**: make no change.

## Select the Herdr workspace

List the open workspaces:

```bash
herdr workspace list
```

An open workspace matches only when its `worktree.checkout_path` exactly equals `$target_repo`. A workspace for a linked worktree or another checkout of the same repository does not match. If several workspaces match, ask one focused question naming their labels and IDs. Do not use a picker.

For one matching workspace:

1. Read its active tab ID from the workspace result.
2. List its panes with `herdr pane list --workspace <workspace-id>`.
3. Select a pane from that active tab and inspect its layout with `herdr pane layout --pane <pane-id>`.
4. Split that explicit pane, choosing `right` or `down` from its geometry. Set the new pane's cwd to `$target_repo` and keep focus unchanged.

```bash
child=$(herdr pane split "$workspace_pane_id" --direction "$direction" --cwd "$target_repo" --no-focus)
child_id=$(printf '%s\n' "$child" | jq -er '.result.pane.pane_id')
```

When no workspace matches, create an unfocused target workspace and use its root pane directly:

```bash
target_label=$(basename "$target_repo")
created=$(herdr workspace create --cwd "$target_repo" --label "$target_label" --no-focus)
child_id=$(printf '%s\n' "$created" | jq -er '.result.root_pane.pane_id')
```

## Resolve the harness

Use an explicit `pi`, `claude`, or `codex` from the brief. Otherwise use the harness running the current session. If it cannot be identified, ask which of `pi`, `claude`, or `codex` to use. Do not open a harness picker.

## Launch

Build a concise child prompt containing the confirmed repository, the task, relevant current-session context, dirty-state summary when applicable, and the instruction to implement, verify, and stop. Do not paste the raw conversation.

Send these boundary instructions literally, alongside the task details:

```text
You are the dispatched worker.
Work directly in the selected repository and in this pane.
Do not launch reviewers or other agents.
Do not invoke Pi subagent tools, workflow orchestration, worktrees, or Herdr commands.
Do not inspect or switch to another repository.
Follow directly applicable task skills in this pane; ignore unrelated skills.
Pre-existing changes: <clean, or exact status summary>
```

The child may follow directly applicable task skills in this pane, but must not delegate this task to another agent or reviewer.

Tell the child that its final response must contain only this copy-ready handoff:

```text
Repository: <absolute path>
Task: <what was requested>
Status: <complete, blocked, or in progress>
Changes: <files and behavior changed>
Verification: <commands run and results>
Remaining issues: <none or exact unresolved items>
Suggested next step: <a recommendation or sensible options for continuing>
```

Run these commands from the current pane. Parse every Herdr ID from JSON responses. Never guess IDs or rely on UI focus.

```bash
agent_name="dispatch-$(date +%s)"
herdr agent start "$agent_name" --kind "$harness" --pane "$child_id"
herdr agent prompt "$agent_name" "$child_prompt"
```

Do not add `--wait`, wait for child completion, read child output, summarize its work, or close its pane. Return a short launch receipt with the confirmed repository, workspace, pane, agent name, and that the child will leave its handoff in its pane.
