---
name: dev:tanstack
description: "TanStack ecosystem entry point -- CLI tools, doc verification, and routing to library-specific skills. Load when any @tanstack/* package is in dependencies."
user-invocable: true
---

# TanStack Ecosystem

Entry point for working with TanStack libraries. This skill introduces the CLI for doc lookup and routes you to library-specific skills that contain Nik's personal patterns and preferences.

## TanStack CLI

The `tanstack` CLI is installed globally and is the **primary way to verify TanStack docs** -- prefer it over Ref MCP for TanStack-specific lookups.

### Key Commands

| Command       | Purpose                     | Example                                                         |
| ------------- | --------------------------- | --------------------------------------------------------------- |
| `search-docs` | Search docs by keyword      | `tanstack search-docs "search params" --library router --json`  |
| `doc`         | Read a specific doc page    | `tanstack doc router framework/react/guide/data-loading --json` |
| `libraries`   | List all TanStack libraries | `tanstack libraries --json`                                     |
| `ecosystem`   | Discover ecosystem tools    | `tanstack ecosystem --category auth --json`                     |

### Usage Notes

- Always use `--json` for deterministic parsing
- Use `--library <id>` to scope searches (e.g., `query`, `router`, `form`, `store`, `start`, `table`)
- Use `--framework react` when relevant
- `doc` takes a library ID and a path (e.g., `tanstack doc query framework/react/guides/query-keys`)

## Library-Specific Skills

The following `dev-tanstack-*` skills contain **Nik's personal patterns and preferences** for each library. Only load the one relevant to your current task -- don't load Query patterns when working on a Form.

| Skill                | When to load                         |
| -------------------- | ------------------------------------ |
| `dev:tanstack-query` | Data fetching, caching, server state |
| `dev:tanstack-form`  | Form handling, validation            |

For all other TanStack libraries (Router, Store, Start, Table, Virtual, etc.), use the CLI to look up docs directly.

## Workflow

1. Identify which TanStack library is relevant to the task
2. If a `dev-tanstack-*` skill exists for it, load that skill for Nik's preferences
3. Use `tanstack search-docs` / `tanstack doc` to verify patterns against current docs before implementing
4. For libraries without a dedicated skill, rely on CLI docs alone
