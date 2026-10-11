# Claude Code

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
├── AGENTS.md          # read natively; no CLAUDE.md needed
└── .claude/
    ├── settings.json  # project overrides
    └── skills         # relative symlink → ../.agents/skills
```

## Hooks (Enforcement)

Hooks are bash scripts registered in `settings.json`. They run at specific lifecycle events.

| Event              | Use for                                          |
| ------------------ | ------------------------------------------------ |
| `SessionStart`     | Inject skill content, set context                |
| `UserPromptSubmit` | Inject date/time, suggest skills                 |
| `PreToolUse`       | Block dangerous or malformed tool calls          |
| `PostToolUse`      | Warn after writes (e.g., TypeScript `any` check) |

Register hooks under `hooks.<Event>[].hooks[]` in `settings.json`, with a `matcher` for tool events. The `update-config`
skill and the Claude Code hooks docs have the current schema.

Hook scripts must be executable (`chmod +x`). Exit 0 = allow, exit 2 = block.

## Plugins

Plugins (LSP servers, skill bundles) are enabled in `settings.json` and have no Pi equivalent. Prefer a `skills.sh`
package (`npx skills add <repo>`) when the same skills exist there, so both agents get them.

## Skills

Claude Code auto-discovers skills from:

- `~/.claude/skills/` (global, symlinked to `~/.agents/skills/`)
- `.claude/skills/` in the project, the symlink to `.agents/skills/`

Invoke with `/<name>`, or let Claude load it from its description.

## Verification

```bash
claude mcp list              # confirm MCP servers active
ls ~/.claude/hooks/enforce/  # confirm hook scripts exist and are executable
# Start a session and check SessionStart output for injected context
```
