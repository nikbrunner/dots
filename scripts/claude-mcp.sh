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

claude mcp add --scope user exa -e "EXA_API_KEY=$EXA_API_KEY" -- npx -y exa-mcp-server
claude mcp add --scope user Ref https://api.ref.tools/mcp -H "x-ref-api-key: $REF_API_KEY"
claude mcp add --scope user chrome-devtools -- npx chrome-devtools-mcp@latest
claude mcp add --scope user linear https://mcp.linear.app/mcp

echo "MCP servers configured"
