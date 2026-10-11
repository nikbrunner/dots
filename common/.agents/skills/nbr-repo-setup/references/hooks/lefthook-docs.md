# Lefthook documentation map

Use this map to choose a page, then fetch its Markdown from the official repository. Read only the pages needed for the task. This is a navigation aid, not a copy of the documentation.

Paths checked against the upstream tree on 2026-09-06. The topic descriptions draw on the configuration index and representative pages for installation, usage, jobs, file selection, examples, and AI hooks. Recheck paths when using another version or when a page is missing.

## Find and read a page

1. Check the installed CLI version and relevant command help. Prefer documentation at its matching release tag when available. `master` describes upstream development and may include features absent from the installed binary.
2. Select a topic below. All paths are relative to `docs/` and case-sensitive.
3. Fetch `https://raw.githubusercontent.com/evilmartians/lefthook/<ref>/docs/<path>`, replacing `<ref>` with the verified tag or `master`. Preserve the exact repository path rather than deriving it from the website route.
4. Resolve relative Markdown links against the source file's directory, keeping the same ref. Ignore site frontmatter and presentation directives when extracting technical content.
5. If the map does not cover the task, fetch the current tree before guessing filenames. If a request fails, report the failure; do not present remembered behavior as verified.

Example: [configuration/run.md as raw Markdown](https://raw.githubusercontent.com/evilmartians/lefthook/master/docs/configuration/run.md).

## Discover the structure

- [Browse the docs directory](https://github.com/evilmartians/lefthook/tree/master/docs).
- [Fetch the recursive repository tree](https://api.github.com/repos/evilmartians/lefthook/git/trees/master?recursive=1). Select entries with `type: blob` and paths starting with `docs/` and ending in `.md`. Check `truncated` before treating the list as complete; if true, traverse the docs subtree separately.
- For a release, replace `master` in the tree request with the verified tag. Retain the returned commit SHA if subsequent requests need a consistent snapshot.
- [Configuration index as Markdown](https://raw.githubusercontent.com/evilmartians/lefthook/master/docs/configuration/README.md) lists many options and their relationships. Use the tree for completeness; an index can omit a newer page.

## Topic map

| Need                                     | Start here                                                                   | Read next when needed                                                                                                                                                          |
| ---------------------------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Overview and installation choice         | `index.md`, `install.md`                                                     | `installation/` contains package-manager and OS-specific instructions                                                                                                          |
| Node installation and lifecycle behavior | `installation/node.md`                                                       | `usage/commands/install.md`                                                                                                                                                    |
| Standalone provisioning                  | `installation/mise.md`, `installation/homebrew.md`, `installation/manual.md` | Other platform pages under `installation/`                                                                                                                                     |
| Config filenames and local overrides     | `configuration.md`                                                           | `configuration/README.md`, `examples/lefthook-local.md`                                                                                                                        |
| Hook structure, named jobs and groups    | `configuration/Hook.md`, `configuration/jobs.md`                             | `configuration/group.md`, `configuration/Commands.md`, `configuration/Scripts.md`                                                                                              |
| Commands, file placeholders and quoting  | `configuration/run.md`                                                       | `configuration/files.md`, `configuration/files-global.md`                                                                                                                      |
| File selection and monorepo directories  | `examples/filters.md`                                                        | `configuration/glob.md`, `configuration/exclude.md`, `configuration/file_types.md`, `configuration/root.md`                                                                    |
| Execution order and concurrency          | `configuration/parallel.md`, `configuration/piped.md`                        | `configuration/group.md`, `configuration/priority.md`                                                                                                                          |
| Skip rules and selecting checks          | `configuration/skip.md`, `configuration/only.md`                             | `configuration/tags.md`, `configuration/exclude_tags.md`, `examples/skip.md`                                                                                                   |
| Autofix, staging and detecting changes   | `configuration/stage_fixed.md`                                               | `configuration/fail_on_changes.md`, `configuration/fail_on_changes_diff.md`, `examples/stage_fixed.md`                                                                         |
| Shared configuration                     | `configuration/extends.md`, `configuration/remotes.md`                       | `configuration/configs.md`, `configuration/ref.md`, `configuration/refetch.md`, `examples/remotes.md`                                                                          |
| Scripts, arguments and standard input    | `configuration/Scripts.md`, `configuration/args.md`                          | `configuration/use_stdin.md`, `usage/features/pass-stdin.md`, `usage/features/git-args.md`                                                                                     |
| Install, inspect, validate and run       | `usage.md`                                                                   | `usage/commands/install.md`, `usage/commands/check-install.md`, `usage/commands/dump.md`, `usage/commands/validate.md`, `usage/commands/run.md`, `usage/commands/uninstall.md` |
| Environment, diagnostics and CI          | `usage/envs/LEFTHOOK_VERBOSE.md`, `usage/envs/CI.md`                         | `usage/envs/LEFTHOOK.md`, `usage/envs/LEFTHOOK_CONFIG.md`, `configuration/env.md`, `configuration/output.md`                                                                   |
| Optional AI hooks (beta)                 | `configuration/ai.md`                                                        | Follow its provider documentation links for event semantics and generated-settings behavior                                                                                    |
| Commit-message checks                    | `examples/commitlint.md`                                                     | `configuration/run.md`, `usage/features/git-args.md`                                                                                                                           |

## Reading boundaries

Use CLI help for supported commands and flags, the selected-version Markdown for configuration behavior, and project policy for what to configure. Examples illustrate mechanisms; their autofix, concurrency, and stage choices are not defaults for the project.

For AI hooks, read the provider-specific installation behavior. The current documentation distinguishes providers that preserve user-authored settings from Copilot's Lefthook-owned file, which is rewritten on installation and removed on uninstall.
