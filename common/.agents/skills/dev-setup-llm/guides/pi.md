# Pi Setup Guide

## Global Config Structure

```
~/.pi/agent/
├── AGENTS.md          # loaded automatically at startup (or CLAUDE.md)
├── settings.json      # model, theme, packages, extensions
├── keybindings.json   # keyboard shortcuts
├── extensions/        # TypeScript extensions (auto-discovered)
│   └── enforce.ts
└── sessions/          # session files (managed by dots chores)

~/.agents/
└── skills/            # global skills (auto-discovered by Pi)
```

## Project Config Structure

```
<project>/
├── AGENTS.md          # project-level instructions (concatenated with global)
└── .pi/
    ├── settings.json  # project overrides (merged with global)
    └── skills/        # project-local skills
```

## Installing Packages

Pi installs missing packages from `settings.json` automatically on startup.

```bash
pi install npm:my-package        # install globally
pi install npm:my-package -l     # install for project only
pi list                          # show installed packages
pi update                        # update all non-pinned packages
```

## Extensions (Enforcement)

Extensions are TypeScript files auto-discovered from `~/.pi/agent/extensions/`.
They replace Claude Code hooks — no shell scripts needed.

Key events for enforcement:

| Event                | Use for                                        |
| -------------------- | ---------------------------------------------- |
| `before_agent_start` | Inject date/time or context into system prompt |
| `session_start`      | Inject skill content, set up session state     |
| `input`              | Intercept/transform user input, suggest skills |
| `tool_call`          | Block or modify tool calls before execution    |
| `tool_result`        | Inspect or warn after tool execution           |

Minimal extension template:

```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event, _ctx) => {
    return {
      systemPrompt: (event.systemPrompt ?? "") + "\n\nExtra context here",
    };
  });

  pi.on("tool_call", async (event, _ctx) => {
    // Return { block: true, reason: "..." } to block
  });
}
```

## Skills

Pi auto-discovers skills from:

- `~/.agents/skills/` (global, shared with Claude Code)
- `~/.pi/agent/skills/` (global, Pi-only)
- `.agents/skills/` in project and ancestor dirs
- `.pi/skills/` in project

Invoke via `/skill:name` or let Pi load contextually.

## Verification

```bash
pi list                         # confirm extensions and packages loaded
pi --plan                       # enter plan mode (Plannotator)
/reload                         # hot-reload extensions without restart
```
