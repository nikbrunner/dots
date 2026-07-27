---
name: herdr-env-var-stale-shell
description: "An env var set in .zshenv reaches new shells but not herdr's server until the shell that spawned herdr is itself replaced"
metadata: 
  node_type: memory
  type: reference
  originSessionId: baa48d15-ebf7-4200-8e6d-c46c63e4573d
  modified: 2026-07-27T09:30:45.301Z
---

herdr's plugin actions (e.g. `vim-herdr-navigation`'s `navigate.sh`) inherit the
environment of the **herdr server process**, not of the pane shell. A pane shell
is spawned by the server and sources `.zshenv` itself, so `echo $VAR` in a pane
can succeed while the server lacks the variable entirely. That echo proves
nothing about the server.

`herdr session stop` is per-socket. `herdr session list` may show several running
sessions, each with its own server; stopping one leaves the others alive.

The trap: a terminal shell can outlive its window (parent `login ... exec -`,
later reparented to ppid 1). Relaunching herdr from that shell re-seeds the old
environment no matter how many times herdr itself is killed.

Diagnosis, in order:

```sh
ps -eo pid,ppid,lstart,command | grep "[h]erdr"   # note ppid and start time
ps eww -p <server-pid> | tr ' ' '\n' | grep VAR   # the only check that counts
```

Walk `ppid` upward until reaching a shell, then check that shell's start time. If
it predates the edit, that shell is the culprit — kill it, open a genuinely new
terminal window, and launch herdr there. A logout/login is the reliable hammer.

Note for agents: a Claude Code Bash tool shell sources a captured
`~/.claude/shell-snapshots/` snapshot, so its own env reflects session-start
state and is not evidence about the live user environment.

Related: [[claude_statusline_and_cache]]
