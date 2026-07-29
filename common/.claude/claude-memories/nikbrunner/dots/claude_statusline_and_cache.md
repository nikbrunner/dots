---
name: claude-statusline-and-cache
description: statusline is a bash script (node spawning saturates Gatekeeper); cache TTL facts (1h personal / 5m work); PreCompact hooks cannot inject instructions
metadata:
  node_type: memory
  type: project
  originSessionId: 22f10b99-08fc-48f7-9731-cddb07ec7461
---

# Claude Code statusline & prompt-cache setup (2026-07-10, commit c1a1e01f)

- Statusline is `common/.local/bin/claude-statusline` — bash + one `jq` call, no `refreshInterval` (renders on events only). Shows account, model, repo/branch, context %, 5h and 7d rate limits, session cost.
- **Never use a node-based statusline here.** A node statusline on a timer spawns a fresh `node` every render. Un-stapled binaries (Apple cannot staple a notarization ticket to a bare Mach-O, only to .app/.pkg/.dmg/.kext) get a full Gatekeeper crypto validation on every exec, which saturates `syspolicyd` and slows *every* exec machine-wide — measured ~1ms to ~75ms for unrelated binaries, with multi-second stalls. Diagnose with `log stream --predicate 'senderImagePath CONTAINS "AppleSystemPolicy"'` (kernel messages carry unredacted paths; `eslogger` needs Full Disk Access). Emergency relief: `fuckoff` alias = `sudo killall syspolicyd`.
- Signing *quality* is not the predictor of exec cost — ad-hoc-signed `rg` runs at ~2ms while Developer-ID-signed `node` costs ~35ms. Stapling and spawn rate are what matter.
- **Cache TTL facts (verified from transcripts)**: personal Max subscription = 1h TTL; ImFusion work account = 5m TTL. API docs default is 5m; Claude Code opts subscriptions into 1h.
- **PreCompact hooks CANNOT inject compaction instructions** — verified empirically 2026-07-10: hook output with `hookSpecificOutput.additionalContext` fails schema validation (PreCompact has no hookSpecificOutput variant; only decision/systemMessage). CLAUDE.md also does not influence the compaction summarizer.
- `/park` resolution: no automation possible; Nik keeps a clipboard string `/compact PARK this session for a cold restart: …` (ticket/branch, goal, decisions+why, rejected approaches, one next step, no code blocks). Worth using for breaks > 1h (personal) / > 5m (work) on heavy sessions.
- Both accounts share `common/.claude/settings.json` (multi-target symlink to `~/.claude` and `~/.claude-work`) — statusline/hook changes always affect both.
