---
name: claude-statusline-and-cache
description: ccstatusline replaced custom statusline; cache TTL facts (1h personal / 5m work); PreCompact hooks cannot inject instructions
metadata:
  node_type: memory
  type: project
  originSessionId: 22f10b99-08fc-48f7-9731-cddb07ec7461
---

# Claude Code statusline & prompt-cache setup (2026-07-10, commit c1a1e01f)

- Statusline is **ccstatusline** (mise-pinned `npm:ccstatusline = prefix:2`), config at `common/.config/ccstatusline/settings.json`, `refreshInterval: 5`. The old hand-rolled `claude-statusline` script was deleted (git history has it).
- Cache countdown widget: `common/.local/bin/claude-cache-countdown` — custom-command widget on the cache line; reads transcript mtime + detects TTL from `ephemeral_1h/5m_input_tokens` buckets.
- **Cache TTL facts (verified from transcripts)**: personal Max subscription = 1h TTL; ImFusion work account = 5m TTL. API docs default is 5m; Claude Code opts subscriptions into 1h.
- **PreCompact hooks CANNOT inject compaction instructions** — verified empirically 2026-07-10: hook output with `hookSpecificOutput.additionalContext` fails schema validation (PreCompact has no hookSpecificOutput variant; only decision/systemMessage). CLAUDE.md also does not influence the compaction summarizer.
- `/park` resolution: no automation possible; Nik keeps a clipboard string `/compact PARK this session for a cold restart: …` (ticket/branch, goal, decisions+why, rejected approaches, one next step, no code blocks). Worth using for breaks > 1h (personal) / > 5m (work) on heavy sessions.
- Both accounts share `common/.claude/settings.json` (multi-target symlink to `~/.claude` and `~/.claude-work`) — statusline/hook changes always affect both.
