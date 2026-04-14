#!/usr/bin/env bash
# Configure MCP servers for Claude Code
# Called by install.sh during machine setup
# Usage: ./claude-mcp.sh [--dry-run]

set -e

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

if ! command -v claude &>/dev/null; then
    echo "Claude Code not installed, skipping MCP setup"
    exit 0
fi

echo "Configuring Claude Code MCP servers..."

if [[ "$DRY_RUN" == true ]]; then
    echo "  [DRY] Would add MCP server: exa (npx exa-mcp-server)"
    echo "  [DRY] Would add MCP server: Ref (https://api.ref.tools/mcp)"
    echo "  [DRY] Would add MCP server: chrome-devtools (npx chrome-devtools-mcp)"
    echo "  [DRY] Would add MCP server: linear (https://mcp.linear.app/mcp)"
    if command -v bun &>/dev/null; then
        echo "  [DRY] Would install @open-pencil/mcp globally via bun"
        echo "  [DRY] Would add MCP server: open-pencil (openpencil-mcp)"
    else
        echo "  [DRY] Would skip open-pencil (bun not installed)"
    fi
    echo "MCP dry run complete"
    exit 0
fi

claude mcp add --scope user exa -e "EXA_API_KEY=$EXA_API_KEY" -- npx -y exa-mcp-server || true
claude mcp add --scope user --transport http Ref https://api.ref.tools/mcp -H "x-ref-api-key: $REF_API_KEY" || true
claude mcp add --scope user chrome-devtools -- npx chrome-devtools-mcp@latest || true
claude mcp add --scope user --transport http linear https://mcp.linear.app/mcp || true

# OpenPencil requires global bun install (not available via npx)
if command -v bun &>/dev/null; then
    bun add -g @open-pencil/mcp 2>/dev/null || true
    claude mcp add --scope user open-pencil -- openpencil-mcp || true
else
    echo "bun not installed, skipping open-pencil MCP"
fi

echo "MCP servers configured"
