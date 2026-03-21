---
name: browser-automation
description: "Browser automation via agent-browser CLI -- AI-optimized snapshots, element refs, screenshots. Load when any task involves browsing, testing UIs, filling forms, scraping, or analyzing websites."
user-invocable: false
---

# Browser Automation (agent-browser)

Use `agent-browser` via Bash for any browser interaction. Prefer this over Chrome DevTools MCP -- the snapshot output is purpose-built for AI agents.

## Core Workflow

```bash
# 1. Navigate
agent-browser open <url>

# 2. Understand the page (accessibility tree with @refs)
agent-browser snapshot

# 3. Interact using refs from snapshot
agent-browser click @e2
agent-browser fill @e3 "hello@example.com"
agent-browser press Enter

# 4. Verify result
agent-browser snapshot          # re-read page state
agent-browser screenshot /tmp/result.png  # visual check
agent-browser get text @e1      # extract specific content

# 5. Clean up
agent-browser close
```

## When to Use

- **UI testing** -- open a local dev server, snapshot, verify elements
- **Form filling** -- navigate, snapshot to find fields, fill, submit
- **Web scraping** -- snapshot for structured content, `get text` for specifics
- **Website analysis** -- snapshot + screenshot to understand layout and structure
- **Visual regression** -- `diff screenshot --baseline` to compare states
- **Debugging** -- `console`, `errors`, `network requests` for diagnostics

## Key Commands

| Command                   | Purpose                                           |
| ------------------------- | ------------------------------------------------- |
| `open <url>`              | Navigate to URL                                   |
| `snapshot`                | Accessibility tree with `@ref` IDs                |
| `snapshot -i`             | Interactive elements only (forms, buttons, links) |
| `snapshot -c`             | Compact -- remove empty structural elements       |
| `click @ref`              | Click element by ref                              |
| `fill @ref "text"`        | Clear field and type                              |
| `type @ref "text"`        | Append text to field                              |
| `press Enter`             | Press key                                         |
| `get text @ref`           | Extract text content                              |
| `get html @ref`           | Extract HTML                                      |
| `get url`                 | Current URL                                       |
| `screenshot [path]`       | Take screenshot                                   |
| `screenshot --annotate`   | Labeled screenshot with numbered legend           |
| `screenshot --full`       | Full page screenshot                              |
| `wait --load networkidle` | Wait for slow pages                               |
| `eval "js code"`          | Run JavaScript                                    |
| `close`                   | Close browser                                     |

## Chaining

Browser persists via daemon -- chain commands with `&&`:

```bash
agent-browser open http://localhost:3000 && agent-browser wait --load networkidle && agent-browser snapshot -i
```

## Tips

- Always `snapshot` after navigation or interaction to get fresh refs
- Use `snapshot -i` when you only care about clickable/fillable elements
- Refs (`@e1`, `@e2`) change after page mutations -- re-snapshot before interacting
- Use `--session <name>` for isolated parallel sessions
- `screenshot --annotate` is useful when you need visual + structural context together
