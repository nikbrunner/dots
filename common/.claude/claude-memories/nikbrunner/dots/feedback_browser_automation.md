---
name: agent-browser replaces WebFetch, not all web tools
description: Use agent-browser instead of WebFetch for rendered content; Exa for search, Ref MCP for docs — each tool has its lane
type: feedback
---

Use `agent-browser` (via Bash) instead of `WebFetch`, not instead of all web tools.

**Why:** WebFetch only retrieves initial HTML — for SPAs and client-rendered sites, that's an empty shell. `agent-browser` renders the page fully, giving access to the real DOM, navigation, and route exploration. But other tools have their own strengths.

**How to apply:**

- **agent-browser** → replaces WebFetch. Use for viewing/exploring rendered websites, especially client-rendered SPAs. Navigate subroutes, snapshot interactive elements.
- **Exa MCP** → replaces WebSearch. Use for searching the web.
- **Ref MCP** → documentation lookups. Use for checking library/framework/API docs.
- These three tools each have their lane — don't collapse them into one.
