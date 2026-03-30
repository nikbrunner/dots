---
name: about:gh-cli
description: "My GitHub CLI (gh) reference -- core commands, JSON output, gh api, scripting patterns, environment variables. Load when using gh, GitHub CLI, pull requests, issues, releases, workflow runs, or GitHub API from the terminal."
user-invocable: false
---

# GitHub CLI (gh)

Installed version: 2.87.2. The `gh` CLI is my primary interface to GitHub — PRs, issues, releases, CI runs, and raw API access. Prefer `gh` over `curl`+token for all GitHub operations.

## Core Commands

| Command | Purpose | Key Flags |
|-|-|-|
| `gh pr` | Full PR lifecycle | `--fill`, `--fill-verbose`, `--draft`, `--json`, `--web`, `--search` |
| `gh issue` | Issue management | `--assignee "@me"`, `--label`, `--search`, `--template` |
| `gh repo` | Repo operations | `--public`/`--private`, `--clone`, `--template`, `--source` |
| `gh run` | CI/Actions runs | `--log`, `--log-failed`, `--exit-status`, `watch` |
| `gh release` | Release management | `--generate-notes`, `--draft`, `--verify-tag` |
| `gh search` | Search repos/issues/PRs/code/commits | `--` separator for exclusion syntax |
| `gh api` | Raw REST + GraphQL | `--paginate`, `--slurp`, `--cache`, `--jq`, `-F`/`-f` |
| `gh auth` | Authentication | `login`, `switch`, `status`, `token`, `--with-token` |
| `gh config` | Settings | `git_protocol`, `editor`, `prompt`, `pager` |
| `gh extension` | Plugin system | `install`, `browse`, `search`, `upgrade` |

## JSON Output & Formatting

The power pattern: `--json fields --jq 'expression'`

- `--json` without args lists available fields for that command
- `--jq` uses built-in jq (no system install needed)
- `--template` uses Go templates with helpers: `tablerow`, `tablerender`, `timeago`, `timefmt`, `truncate`, `hyperlink`, `color`/`autocolor`, `pluck`, `join`
- Sprig functions available: `contains`, `hasPrefix`, `hasSuffix`, `regexMatch`

## gh api

Raw GitHub API with automatic auth. Supports REST and GraphQL.

**Placeholders**: `{owner}`, `{repo}`, `{branch}` auto-resolve from current repo context.

**Field types**:
- `-f key=value` — raw string
- `-F key=value` — typed (auto-converts booleans, integers; `@file` reads from file; `@-` reads stdin)

**Pagination**:
- REST: `--paginate` fetches all pages; add `--slurp` to wrap into single JSON array
- GraphQL: requires `$endCursor: String` variable and `pageInfo{ hasNextPage, endCursor }` in query

**Caching**: `--cache 3600s` (or `60m`, `1h`)

**Debug**: `GH_DEBUG=api` logs full HTTP traffic

## Key Environment Variables

| Variable | Purpose |
|-|-|
| `GH_TOKEN` / `GITHUB_TOKEN` | Auth token override (precedence order) |
| `GH_REPO` | Target repo without `-R` flag (`[HOST/]OWNER/REPO`) |
| `GH_HOST` | GitHub Enterprise host |
| `GH_DEBUG` | `api` for HTTP logging, truthy for verbose |
| `GH_PROMPT_DISABLED` | Disable interactive prompts (for scripts) |
| `GH_FORCE_TTY` | Force terminal output in pipes |
| `NO_COLOR` | Disable ANSI color output |

## Anti-Patterns

| Don't | Do Instead |
|-|-|
| `curl` + bearer token | `gh api` (handles auth, pagination, placeholders) |
| Pipe to external `jq` | Use built-in `--jq` flag |
| Forget `--paginate` on list endpoints | Always paginate — default is 30 items |
| `--paginate` without `--slurp` in scripts | Add `--slurp` to get single JSON array |
| Interactive prompts in scripts | Set `GH_PROMPT_DISABLED=1` or supply all flags |
| Search exclusion `-label:bug` directly | Use `--` separator: `gh search issues -- "query -label:bug"` |

## Notable Extensions

- `gh-dash` — TUI dashboard for PRs and issues
- `gh-poi` — Clean up local branches after merge
- `gh-copilot` — GitHub Copilot in terminal

Install: `gh extension install owner/gh-name`
Browse: `gh extension browse`

## Sources of Truth

- **CLI Manual**: https://cli.github.com/manual
- **gh api GraphQL guide**: https://github.blog/developer-skills/github/exploring-github-cli-how-to-interact-with-githubs-graphql-api-endpoint/
- **jq syntax**: https://jqlang.github.io/jq/manual/
- **Go templates**: https://golang.org/pkg/text/template/
- **Extensions**: https://github.com/topics/gh-extension

## Cross-References

- `mcp-guide` — tool selection guide (when to use gh vs Ref vs Exa)
- `dev:commit` — uses gh for PR creation workflow

## References

- For scripting recipes and advanced examples, see `scripting-patterns.md`
