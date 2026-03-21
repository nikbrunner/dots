# Claude Code → OpenCode Migration Reference

This document captures the structural differences between Claude Code and OpenCode for potential migration.

---

## Directory Structure Mapping

| Concept            | Claude Code                  | OpenCode                             |
| ------------------ | ---------------------------- | ------------------------------------ |
| **Project config** | `.claude/`                   | `.opencode/`                         |
| **Global config**  | `~/.claude/`                 | `~/.config/opencode/`                |
| **Commands**       | `.claude/commands/`          | `.opencode/commands/`                |
| **Agents**         | `.claude/agents/`            | `.opencode/agents/`                  |
| **Plugins**        | N/A (built-in only)          | `.opencode/plugins/`                 |
| **Instructions**   | `CLAUDE.md`                  | `AGENTS.md`                          |
| **Settings**       | `settings.json`              | `opencode.json`                      |
| **MCP servers**    | `~/.claude/mcp-servers.json` | Inside `opencode.json` under `"mcp"` |

---

## Instructions File (CLAUDE.md → AGENTS.md)

**Good news**: OpenCode has backward compatibility. It will read `CLAUDE.md` if `AGENTS.md` doesn't exist.

To maintain both tools, you can:

1. Keep `CLAUDE.md` as-is (OpenCode reads it as fallback)
2. Symlink: `ln -s CLAUDE.md AGENTS.md`
3. Have both with shared content via includes

OpenCode also supports loading multiple instruction files via `opencode.json`:

```json
{
  "instructions": ["docs/guidelines.md", "packages/*/AGENTS.md"]
}
```

---

## Commands Migration

### Format Comparison

**Claude Code** (`.claude/commands/user/bugs.md`):

```yaml
---
description: Use bug-finder agent to hunt for logical errors
argument-hint: [optional: specific file or function]
---
# Bug Finder Command
...
$ARGUMENTS
```

**OpenCode** (`.opencode/commands/bugs.md`):

```yaml
---
description: Use bug-finder agent to hunt for logical errors
agent: bug-finder
model: anthropic/claude-sonnet-4-20250514
---
# Bug Finder Command
...
$ARGUMENTS
```

### Key Differences

| Feature             | Claude Code                                    | OpenCode                                   |
| ------------------- | ---------------------------------------------- | ------------------------------------------ |
| **Frontmatter**     | `description`, `argument-hint`                 | `description`, `agent`, `model`, `subtask` |
| **Namespacing**     | Folder-based (`bai/status.md` → `/bai/status`) | Flat or folder-based (same behavior)       |
| **Shell injection** | `` !`command` ``                               | `` !`command` `` (same)                    |
| **Arguments**       | `$ARGUMENTS`, `$1`, `$2`                       | `$ARGUMENTS`, `$1`, `$2` (same)            |
| **File inclusion**  | `@filename`                                    | `@filename` (same)                         |

### Migration Script Concept

Commands are mostly compatible. The main changes needed:

1. Move from `.claude/commands/` to `.opencode/commands/`
2. Replace `argument-hint` with appropriate frontmatter
3. Add `agent:` if the command should use a specific agent

---

## Agents Migration

### Format Comparison

**Claude Code** (`.claude/agents/bug-finder.md`):

```yaml
---
name: bug-finder
description: A software detective that hunts for bugs
tools: Read, Grep, Glob, Bash
---
You are an expert Software Detective...
```

**OpenCode** (`.opencode/agents/bug-finder.md`):

```yaml
---
description: A software detective that hunts for bugs
mode: subagent
tools:
  write: false
  edit: false
permission:
  bash: ask
---
You are an expert Software Detective...
```

### Key Differences

| Feature              | Claude Code                     | OpenCode                                 |
| -------------------- | ------------------------------- | ---------------------------------------- |
| **Tool restriction** | Allowlist (`tools: Read, Grep`) | Denylist (`tools: { write: false }`)     |
| **Mode**             | Implicit (Task tool spawns)     | Explicit (`mode: primary/subagent/all`)  |
| **Permissions**      | Global settings.json            | Per-agent (`permission: { bash: deny }`) |
| **Model override**   | Not supported                   | `model: provider/model-id`               |
| **Temperature**      | Not supported                   | `temperature: 0.7`                       |
| **Max steps**        | Not supported                   | `steps: 25`                              |

### Migration Notes

1. **Tool restrictions need inversion**: Claude Code uses allowlist, OpenCode uses denylist
2. **Mode must be explicit**: Most Claude Code agents would be `mode: subagent`
3. **Permissions are per-agent**: More granular than Claude Code's global approach

---

## Hooks → Plugins Migration

This is the **most significant change**. Claude Code hooks are shell commands; OpenCode plugins are JavaScript/TypeScript modules.

### Claude Code Hooks (settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "WebFetch|WebSearch",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"permissionDecision\": \"allow\"}'"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.local/bin/helm-hook SessionStart"
          }
        ]
      }
    ]
  }
}
```

### OpenCode Equivalent Plugin (`.opencode/plugins/hooks.ts`)

```typescript
import type { Plugin } from "opencode/plugin";

export default function hooksPlugin(): Plugin {
  return {
    name: "custom-hooks",

    hooks: {
      // Equivalent to PreToolUse
      "tool.execute.before": async (input, output) => {
        if (input.tool === "web_fetch" || input.tool === "web_search") {
          // Auto-allow - no action needed, just don't throw
          return;
        }
        // For other tools, could call external script:
        // await $`~/.local/bin/helm-hook PreToolUse ${input.tool}`
      },

      // Equivalent to SessionStart
      "session.created": async (session) => {
        await $`~/.local/bin/helm-hook SessionStart`;
      },

      // Equivalent to SessionEnd
      "session.deleted": async (session) => {
        await $`~/.local/bin/helm-hook SessionEnd`;
      },

      // Equivalent to Stop (session idle/complete)
      "session.idle": async () => {
        await $`~/.local/bin/helm-hook Stop`;
      },
    },
  };
}
```

### Hook Event Mapping

| Claude Code    | OpenCode              |
| -------------- | --------------------- |
| `PreToolUse`   | `tool.execute.before` |
| `PostToolUse`  | `tool.execute.after`  |
| `SessionStart` | `session.created`     |
| `SessionEnd`   | `session.deleted`     |
| `Stop`         | `session.idle`        |
| `Notification` | `tui.toast.show`      |

### Additional OpenCode Events (no Claude equivalent)

- `file.edited` - After file modifications
- `permission.asked` / `permission.replied` - Permission flow
- `lsp.client.diagnostics` - LSP integration
- `message.updated` - Message streaming
- `session.compacted` - Context summarization

---

## MCP Servers Migration

### Claude Code (`~/.claude/mcp-servers.json`)

```json
{
  "mcpServers": {
    "exa": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/exa-mcp-server"],
      "env": { "EXA_API_KEY": "..." }
    }
  }
}
```

### OpenCode (`opencode.json`)

```json
{
  "mcp": {
    "exa": {
      "type": "local",
      "command": ["npx", "-y", "@anthropic-ai/exa-mcp-server"],
      "environment": { "EXA_API_KEY": "..." }
    }
  }
}
```

### Key Differences

| Feature            | Claude Code              | OpenCode                  |
| ------------------ | ------------------------ | ------------------------- |
| **Location**       | Separate JSON file       | Inside main config        |
| **Command format** | `command` + `args` array | Single `command` array    |
| **Env vars**       | `env`                    | `environment`             |
| **Remote servers** | Not directly supported   | `type: "remote"` with URL |
| **OAuth**          | Manual                   | Built-in OAuth flow       |
| **Timeout**        | Not configurable         | `timeout` in ms           |

---

## Formatters (OpenCode-only)

OpenCode auto-formats files after edits. No Claude Code equivalent.

```json
{
  "formatter": {
    "prettier": { "disabled": false },
    "biome": { "disabled": true }
  }
}
```

To disable all: `"formatter": false`

---

## Symlink Strategy Analysis

### The Challenge

Both tools look for different directory names:

- Claude Code: `.claude/`, `CLAUDE.md`
- OpenCode: `.opencode/`, `AGENTS.md`

### Option 1: Duplicate with Symlinks (Partial)

```
# Instructions file - works
ln -s CLAUDE.md AGENTS.md

# Directories - won't work cleanly
# Claude Code expects .claude/commands/foo.md
# OpenCode expects .opencode/commands/foo.md
# Different frontmatter requirements
```

**Verdict**: Only works for `CLAUDE.md` → `AGENTS.md` since content is compatible.

### Option 2: Shared Source with Build Script

```
dots/
├── ai-config/
│   ├── commands/        # Canonical source
│   ├── agents/          # Canonical source
│   └── instructions.md  # Canonical source
├── .claude/             # Generated/symlinked
└── .opencode/           # Generated/symlinked
```

A script could:

1. Read canonical commands
2. Transform frontmatter for each tool
3. Write to respective directories

**Verdict**: Most flexible but requires maintenance.

### Option 3: Accept Divergence

Keep both configurations separate. Use Claude Code as primary, OpenCode for experimentation with minimal config.

**Verdict**: Pragmatic for evaluation period.

---

## Migration Priority

### Phase 1: Parallel Installation (No Migration)

- Install OpenCode
- Use `CLAUDE.md` (backward compatible)
- Configure MCP servers in `opencode.json`
- Test with Zen free models or BYOK

### Phase 2: Commands (Low Effort)

- Copy commands to `.opencode/commands/`
- Adjust frontmatter as needed
- Namespace folders work the same

### Phase 3: Agents (Medium Effort)

- Rewrite tool restrictions (allowlist → denylist)
- Add `mode: subagent` to all
- Test each agent individually

### Phase 4: Hooks → Plugins (High Effort)

- Rewrite `helm-hook` integration as TypeScript plugin
- Map event names
- Test permission flows

---

## Provider Configuration (OpenCode)

### Using Anthropic API Key (BYOK)

```json
{
  "provider": {
    "anthropic": {
      "apiKey": "${ANTHROPIC_API_KEY}"
    }
  }
}
```

### Using OpenCode Zen

```bash
# In TUI
/connect
# Select "OpenCode Zen", enter API key from opencode.ai
```

### Model Selection

```json
{
  "model": {
    "default": "anthropic/claude-sonnet-4-20250514",
    "large": "anthropic/claude-opus-4-20250514"
  }
}
```

---

## Quick Reference: Config File Locations

| Purpose              | Claude Code                  | OpenCode                       |
| -------------------- | ---------------------------- | ------------------------------ |
| Global instructions  | `~/.claude/CLAUDE.md`        | `~/.config/opencode/AGENTS.md` |
| Project instructions | `./CLAUDE.md`                | `./AGENTS.md`                  |
| Global commands      | `~/.claude/commands/`        | `~/.config/opencode/commands/` |
| Project commands     | `.claude/commands/`          | `.opencode/commands/`          |
| Global agents        | `~/.claude/agents/`          | `~/.config/opencode/agents/`   |
| Project agents       | `.claude/agents/`            | `.opencode/agents/`            |
| Global plugins       | N/A                          | `~/.config/opencode/plugins/`  |
| Project plugins      | N/A                          | `.opencode/plugins/`           |
| Settings             | `.claude/settings.json`      | `opencode.json`                |
| MCP servers          | `~/.claude/mcp-servers.json` | Inside `opencode.json`         |

---

## Resources

- [OpenCode Docs](https://opencode.ai/docs/)
- [OpenCode GitHub](https://github.com/sst/opencode)
- [Commands Reference](https://opencode.ai/docs/commands/)
- [Agents Reference](https://opencode.ai/docs/agents/)
- [Plugins Reference](https://opencode.ai/docs/plugins/)
- [MCP Servers Reference](https://opencode.ai/docs/mcp-servers/)
