---
name: agent-status-architecture
description: "How helm tracks Claude/Pi status since the 2026-07-03 rework — unified internal/agent package, 1s poll, liveness check, JSON status files"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3c805cd6-fccf-407c-aa8e-abaf23699f5e
---

Since 2026-07-03, agent status lives in one package, `internal/agent` (the old
`internal/claude` and `internal/pi` copy-paste twins are deleted):

- `agent.Kind` parameterizes client differences (file extension, binary names);
  `agent.Kinds` lists Claude + Pi. Adding another agent (codex, aider…) is config,
  not a new package.
- Statuses are polled every 1s via `statusPollMsg` → `pollAgentStatusesCmd()`
  (async `tea.Cmd`, off the UI thread); the 300ms `animationTick` never touches disk.
- Ghost statuses are killed by a liveness check: `tmux.PanePIDs()` (one call, all
  sessions) + one `ps` snapshot; process tree walked under each pane's shell PID,
  matched against `Kind.BinaryNames` (interpreter-prefixed forms like
  `node .../claude` count). No live process → status file deleted.
- Status files are JSON since the hook rework (`{"state","ts","tool","session_id",
  "transcript","cwd"}`); legacy `state:timestamp` still parses. `background_tasks`
  in Stop payloads keeps state `working`.
- Multi-instance (implemented 2026-07-03): one file per agent instance —
  `<session>.<session_id>.status`. `agent.GetStatuses` returns a slice sorted
  most-active first; model maps are `map[string][]agent.Status`; the list glyph
  uses `statuses[0]`. Liveness is per-kind-per-session (can't attribute a specific
  dead instance); individual crashed instances age out via stale thresholds.
- Pitfall: Claude's `.status` extension is a suffix of Pi's `.pi-status` —
  `Kind.ownsFile` handles this; don't do plain `HasSuffix` matching on status files.
- Pitfall (fixed 2026-07-03): the hook must resolve the tmux session via
  `tmux display-message -t "$TMUX_PANE"` — without a target it reports the
  *focused client's* session, so agent statuses got written into whatever
  session the user was looking at when the hook fired (root cause of
  "agent missing from panel while clearly running").

Phase 3 UI (implemented 2026-07-03): AGENTS right panel (`internal/ui/agentpanel.go`,
per-instance state/elapsed/tool for the selected session, hides below 100×15;
list/panel split is percentage-based via `ui.AgentPanelRatio` = 35), compact
lazygit-style hint bar replacing the button rows (`ui.RenderHintBar`,
`ActionBarHeight` deleted), `?` help overlay (`ModeHelp`, only when filter empty).
Window/pane rows show a per-pane agent ident ("● claude"/"● pi") attributed via
the process tree (`Liveness.PaneAgent`, pane PIDs from `tmux.ListSessionPanes`)
— works for agents whose pane command is just "node". Nik's popup binding in
dots is `-w65% -h50%`. Pitfall: `max_name_width` in the session cache must
never be treated as a high-water mark — `calculateColumnWidths` fits current
sessions (stale cached 44 vs real 31 once reserved 13 phantom columns).
See [[known-bugs-and-investigation-notes]].
