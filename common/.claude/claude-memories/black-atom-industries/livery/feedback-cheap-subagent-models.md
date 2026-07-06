---
name: feedback-cheap-subagent-models
description: Use cheaper models (haiku/sonnet) for subagents — Nik hit his session limit from Fable-priced agents
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 6374ae24-82e7-45ee-8f9d-3679300afd0c
---

On 2026-07-04, running exploration/review/fetch subagents on the session default model (Fable)
exhausted Nik's session limit mid-task. He asked: "you should use cheaper models for the subagents,
otherwise we reach the limit too fast."

**Why:** Subagent token spend counts against the same session limit; most delegated tasks
(exploration, mechanical fetching, doc review) don't need frontier capability.

**How to apply:** On EVERY Agent call, first judge task complexity, then pick the cheapest model
that can do it: `model: "haiku"` for mechanical work (fetching, file listing, simple search,
scripted transforms), `model: "sonnet"` for standard exploration/review/migration work. Only omit
the model override (inheriting the expensive session model) when the task genuinely needs
frontier judgment. Nik repeated this instruction twice on 2026-07-04 — treat it as a standing
rule, not an optimization.
Exception: `subagent_type: "fork"` always inherits the parent model (harness rule) — use forks only
when session-bound authorizations (e.g. DesignSync from [[design-brainstorm-2026-03-21]] work)
require it, and keep their task lists short.
