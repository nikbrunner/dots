---
name: no-agent-config-edits
description: "Nik declines tooling that edits agent config — no PreToolUse hooks, no AGENTS.md writes (e.g. @tanstack/intent)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1d449ab1-252f-4362-83a3-134e3305cd43
  modified: 2026-07-31T16:10:44.522Z
---

Nik keeps his agent config hand-owned. When a setup step wants to write to `AGENTS.md`/`CLAUDE.md` or install
`PreToolUse` hooks, skip it and install the library only. Asked for this explicitly when adding `@tanstack/react-router`,
which would otherwise have pulled in `npx @tanstack/intent install` + `hooks install`.

**Why:** a gate that denies edits until a skill loads, plus generated blocks in his own instruction files, takes control
of his setup away from him.

**How to apply:** install the dependency, skip the config wiring, build the feature anyway. Fall back to the installed
package's own `.d.ts` and `npx tanstack` docs for library guidance. Name the tradeoff once, then drop it — don't re-ask
on the next TanStack dependency.
