---
name: mcp-guide
description: Guide for using available MCP servers (Ref, Exa, Chrome) and GitHub CLI. Load when deciding which tool to use for documentation, search, or browser testing.
user-invocable: false
metadata:
  user-invocable: false
---

# MCP Tool Guide

These MCPs are configured and should be used — do not skip them.

| MCP                                                      | When to Use                                                                                                                    |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **Ref MCP** (`ref_search_documentation`, `ref_read_url`) | Documentation lookups for any library, framework, or API. Always check docs before implementing.                               |
| **EXA MCP** (`web_search_exa`, `get_code_context_exa`)   | Web searches for examples, patterns, or solutions not found in docs. Use for real-world code examples.                         |
| **Chrome MCP** (`chrome-devtools__*`)                    | Browser testing — opening URLs, HTML export verification, visual checks.                                                       |
| **GitHub CLI** (`gh`)                                    | All GitHub operations — PRs, issues, CI, releases, API. See `about:gh-cli` for full reference. BAI issues: use `bai-*` skills. |

## Rules

- Check Ref MCP for documentation before writing code against an unfamiliar API
- Use Exa if unsure about idioms or need real-world examples
- Don't guess when you can look it up
