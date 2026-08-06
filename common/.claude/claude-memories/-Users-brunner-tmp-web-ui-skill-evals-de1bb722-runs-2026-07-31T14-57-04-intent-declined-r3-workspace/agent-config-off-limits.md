---
name: agent-config-off-limits
description: Nik manages his agent config by hand; tools may install deps but must not write hooks or AGENTS.md
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 0103e94a-e9ef-4c8e-bea0-79b5f906872d
  modified: 2026-07-31T16:17:28.024Z
---

Nik declined the `@tanstack/intent` wiring step when adding TanStack Router: "Install the library, but leave my agent config alone — no hooks, no edits to AGENTS.md."

**Why:** agent config is his to curate. A dependency install is a normal project change; rewriting the files that steer the agent is not.

**How to apply:** install and use the dependency, then read any Agent Skills it ships straight out of `node_modules` (e.g. `node_modules/@tanstack/router-core/skills/`) instead of wiring a CLI that edits config. Offer config changes, never assume them.
