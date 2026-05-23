---
name: dev-browser
description: Primary browser automation via agent-browser CLI — navigate, fill, click, screenshot, extract. Falls back to Chrome MCP for DevTools tasks (Lighthouse, perf traces, network analysis).
allowed-tools: Bash(npx agent-browser:*), Bash(agent-browser:*)
---

# Browser Automation with agent-browser

## Quick Start

```bash
# Install
npm i -g agent-browser
agent-browser install          # Downloads Chrome if needed

# Core workflow: navigate → snapshot → interact → re-snapshot
agent-browser open https://example.com
agent-browser snapshot -i      # Shows interactive elements with @refs
agent-browser click @e1
agent-browser fill @e2 "value"
agent-browser screenshot
```

## Essential Commands

### Navigation & Page

- `agent-browser open <url>` — navigate (also: goto, navigate)
- `agent-browser close` / `close --all` — close session(s)
- `agent-browser get text @e1` / `get url` / `get title` — get page info

### Snapshot (always use `-i` for interactive refs)

- `agent-browser snapshot -i` — get element refs like `@e1`, `@e2`
- `agent-browser snapshot -i --urls` — also show href URLs
- `agent-browser snapshot -s "#selector"` — scope to CSS selector

### Interaction (use @refs from snapshot)

- `agent-browser click @e1` — click element
- `agent-browser fill @e2 "text"` — clear and type
- `agent-browser select @e3 "option"` — dropdown
- `agent-browser check @e4` — checkbox
- `agent-browser press Enter` — keyboard action
- `agent-browser scroll down 500` — scroll

### Capture

- `agent-browser screenshot` / `screenshot --full` / `screenshot --annotate`
- `agent-browser pdf output.pdf`

### Wait

- `agent-browser wait 2000` — milliseconds
- `agent-browser wait @e1` — wait for element
- `agent-browser wait --text "Welcome"` — wait for text

### Batch (always use for 2+ sequential commands)

```bash
agent-browser batch "open https://example.com" "snapshot -i"
```

## Ref Lifecycle

Refs are **invalidated** after navigation, form submission, or dynamic content changes. Always re-snapshot: `click → snapshot -i → next action`.

## Key Patterns

| Pattern                             | Where                                                                |
| ----------------------------------- | -------------------------------------------------------------------- |
| Auth / login flows                  | [references/authentication.md](references/authentication.md)         |
| Full command reference              | [references/commands.md](references/commands.md)                     |
| Session management                  | [references/session-management.md](references/session-management.md) |
| Snapshot refs deep dive             | [references/snapshot-refs.md](references/snapshot-refs.md)           |
| Cloud providers (Browserbase, etc.) | `agent-browser -p <provider>`                                        |
| Config file                         | `agent-browser.json` in project root                                 |

## Efficiency Tips

- Use `--urls` to get all links upfront, avoid re-navigation
- Snapshot once, batch remaining actions
- `agent-browser --session-name myapp` auto-saves/restores auth state
- `agent-browser --auto-connect` reuses user's running Chrome (auth pre-filled)
- ALWAYS `close` when done to avoid leaked processes

## Chrome MCP Fallback

For **DevTools-level tasks** not available in agent-browser, use the Chrome MCP (`chrome-devtools__*` tools):

| Task                                     | Tool            |
| ---------------------------------------- | --------------- |
| Lighthouse performance audit             | Chrome MCP      |
| Performance trace (timeline)             | Chrome MCP      |
| Memory/heap snapshot                     | Chrome MCP      |
| Network request inspection (full detail) | Chrome MCP      |
| Console message inspection               | Chrome MCP      |
| Everything else                          | `agent-browser` |
