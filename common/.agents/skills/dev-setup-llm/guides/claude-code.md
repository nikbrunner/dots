# Claude Code Setup Guide

## Global Config Structure

```
~/.claude/
├── CLAUDE.md          # symlink → ~/.agents/AGENTS.md
├── settings.json      # permissions, hooks, plugins
├── skills/            # symlink → ~/.agents/skills/
└── hooks/enforce/     # bash enforcement scripts
```

## Project Config Structure

```
<project>/
├── CLAUDE.md          # project-level instructions
└── .claude/
    ├── settings.json  # project overrides
    └── skills/        # project-local skills
```

## Hooks (Enforcement)

Hooks are bash scripts registered in `settings.json`. They run at specific lifecycle events.

| Event              | Use for                                          |
| ------------------ | ------------------------------------------------ |
| `SessionStart`     | Inject skill content, set context                |
| `UserPromptSubmit` | Inject date/time, suggest skills                 |
| `PreToolUse`       | Block dangerous or malformed tool calls          |
| `PostToolUse`      | Warn after writes (e.g., TypeScript `any` check) |

Hook registration in `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/enforce/semantic-commits.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/enforce/warn-any-type.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/enforce/session-start.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/enforce/current-datetime.sh"
          }
        ]
      },
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/enforce/skills-check.sh"
          }
        ]
      }
    ]
  }
}
```

Hook scripts must be executable (`chmod +x`). Exit 0 = allow, exit 2 = block.

## Plugins

Plugins extend Claude Code with LSP servers, additional skills, and behaviors. Managed via `settings.json`:

```json
{
  "enabledPlugins": {
    "typescript-lsp@claude-plugins-official": true,
    "impeccable@impeccable": true
  },
  "extraKnownMarketplaces": {
    "impeccable": {
      "source": { "source": "github", "repo": "pbakaus/impeccable" }
    }
  }
}
```

Note: Claude Code plugins have no Pi equivalent. Consider using `skills.sh` packages instead:

- `impeccable` → `npx skills add pbakaus/impeccable@teach-impeccable`
- `readwise` → `npx skills add readwiseio/readwise-skills@<skill>`

## Skills

Claude Code auto-discovers skills from:

- `~/.claude/skills/` (global — symlinked to `~/.agents/skills/`)
- `.claude/skills/` in project

Invoke via `/skill:name` (slash command) or let Claude load contextually.

## Verification

```bash
claude mcp list              # confirm MCP servers active
ls ~/.claude/hooks/enforce/  # confirm hook scripts exist and are executable
# Start a session and check SessionStart output for injected context
```
