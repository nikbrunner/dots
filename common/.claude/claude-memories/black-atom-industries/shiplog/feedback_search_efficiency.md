---
name: Don't spend 10 minutes searching for config options
description: User got frustrated when assistant spent too long searching for Cliffy configuration — be direct, check docs or source fast
type: feedback
---

If a config option or API isn't found within a few targeted searches, state that it doesn't exist and propose alternatives.

**Why:** During the ANSI escape fix session (2026-03-31), the assistant spent ~10 minutes searching filesystem paths for Cliffy internals. User interrupted: "I'm gonna stop you right there. Either there is a config option or not."

**How to apply:** For library capabilities: (1) check docs via Ref MCP, (2) check types/exports in node_modules/deno cache, (3) if not found in 2-3 queries, say so and pivot to alternative approaches. Don't spiral into filesystem searches.
