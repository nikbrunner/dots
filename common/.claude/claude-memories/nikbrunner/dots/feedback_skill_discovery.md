---
name: skill-discovery-discipline
description: Always check skills before using MCP tools directly — knowing the tool doesn't mean skipping the skill
type: feedback
---

When creating Linear issues, using MCP tools, or performing BAI workflows, ALWAYS check for matching skills first (e.g., `bai:create` for issue creation).

**Why:** Skills contain project-specific workflow steps (assign to "me", ask about priority, check related issues, suggest project) that raw tool usage skips. Nik caught me bypassing `bai:create` and going straight to `mcp__linear__save_issue`.

**How to apply:** Before invoking any `mcp__linear__*` tool directly, check if a `bai:*` skill covers the action. The `bai:` skill namespace maps to BAI Linear workflows. "I already know how to use the tool" is the exact rationalization to watch for — the skill adds context the tool alone doesn't have.
