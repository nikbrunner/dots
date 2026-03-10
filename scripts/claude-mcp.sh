#!/usr/bin/env bash
# Configure MCP servers for Claude Code
# Called by install.sh during machine setup
# Requires: EXA_API_KEY and REF_API_KEY environment variables

set -e

if ! command -v claude &>/dev/null; then
    echo "Claude Code not installed, skipping MCP setup"
    exit 0
fi

echo "Configuring Claude Code MCP servers..."

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
