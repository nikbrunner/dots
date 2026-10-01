# Lefthook

Use this method after the main skill establishes project control and the intended checks.

## Sources of truth

Start with the [documentation map](../references/lefthook-docs.md) to select pages by topic and fetch their official raw Markdown. It includes exact paths, version selection, and a tree-discovery fallback. Use the website links below for human browsing.

Verify relevant syntax and installation behavior against the official documentation before changing a project:

- [Configuration](https://lefthook.dev/configuration/)
- [Jobs](https://lefthook.dev/configuration/jobs/)
- [File arguments](https://lefthook.dev/configuration/run/)
- [Installation](https://lefthook.dev/installation/)
- [Node installation](https://lefthook.dev/installation/node/)
- [Hook installation](https://lefthook.dev/usage/commands/install/)
- [Running hooks](https://lefthook.dev/usage/commands/run/)
- [AI hooks (beta)](https://lefthook.dev/configuration/ai/)

Check `lefthook --version`, `lefthook --help`, and relevant subcommand help using the project-local executable when available. Use the CLI to discover supported commands and flags for that version; use the official references for configuration semantics. If Lefthook is not installed, consult the documentation before selecting an installation method.

## Detect existing configuration

Inspect Lefthook configuration and its local overrides, extends, remotes, and scripts. For migrations, inspect native hooks, Husky, pre-commit/prek, staged-file runners, and their installation tasks. Keep an existing correct Lefthook setup intact.

## Configure

Read the official [configuration reference](https://lefthook.dev/configuration/), [jobs reference](https://lefthook.dev/configuration/jobs/), and [file argument documentation](https://lefthook.dev/configuration/run/) before writing configuration. Verify support in the project's installed or selected Lefthook version. Use these sources to establish syntax and behavior rather than relying on memory or copying the example below unverified. If the documentation cannot be accessed, report the limitation before implementing uncertain configuration.

Use the existing supported Lefthook config file, or create `lefthook.yml`. Give jobs meaningful names. Prefer existing scripts/tasks over reproducing their implementation in shell.

Illustrative Node configuration, only when these scripts exist and terminate without watch mode. Use whole-project pre-commit scripts only after verifying they are fast enough for this project. Prefer staged-file selection where supported:

```yaml
pre-commit:
  jobs:
    - name: format
      run: npm run format:check
    - name: lint
      run: npm run lint
pre-push:
  jobs:
    - name: typecheck
      run: npm run typecheck
    - name: test
      run: npm run test
```

Adapt to the detected package manager. In Deno projects, reuse `deno task` commands or the project's existing Deno checks. In other ecosystems, use their native commands.

Use `{staged_files}` and file filters for checks that accept file arguments. Use `{push_files}` only when the intended check is scoped to pushed files. Keep project-wide checks project-wide. Verify quoting, paths containing spaces, deletions, and no matching files. A selected working-tree file is not necessarily identical to its staged contents; preserve any existing protection for partially staged files and state limitations honestly.

Default new checks to read-only modes such as `--check`; keep formatting as an explicit developer action. Preserve or explicitly agree changes to existing autofix/staging behavior. Enable parallel execution only for independent checks; use documented sequential flow when one job depends on another.

## Install and migrate

Use the project's package manager or existing tool provisioning mechanism. For Node projects, use the `lefthook` dev dependency. Verify lifecycle-script permissions for the detected package-manager version; preserve unrelated lifecycle commands. For Deno and other projects using the standalone binary, document its installation and provide an explicit setup task running `lefthook install`.

Create the configuration before installing its hooks. Run the project-local Lefthook executable where applicable.

Handle `core.hooksPath` deliberately. Replace only the repository setting owned by the setup being migrated. Preserve global configuration and account for inherited settings and shared worktree configuration. Verify where Git will actually execute hooks before installing them.

Keep recoverable copies of replaced untracked hooks outside Git's active hooks directory. Preserve custom logic by calling its script from Lefthook when translating it would change behavior. Remove obsolete hook files, dependencies, and setup commands only after every check is represented and any other consumers are accounted for. Avoid retaining two active runners for the same checks.

Run `lefthook install` and update the contributor setup instructions. Reinstall when adding a hook stage and verify the installed entry point.

## Optional AI hooks

Configure AI hooks only when the user requests them for the target project. Read the official [AI hooks reference](https://lefthook.dev/configuration/ai/) and verify support in the selected Lefthook version. The feature is beta.

Identify the project's agent and consult its official hook documentation for supported events, input/output, and failure behavior. Inspect existing agent settings before generating changes. Reuse suitable Lefthook check groups across Git and agent events; choose checks that are appropriate for each event's frequency and available context.

Lefthook can generate provider settings during installation. Inspect the generated diff and preserve user-authored hooks. Verify the actual agent event and error handling before claiming the integration works. Keep agent hooks optional; Git hooks and CI remain independently usable.

## Verify

Use the installed version's validation command and inspect the effective configuration. Run each configured stage with representative input, using CLI help to determine supported file/ref options. Confirm actual hook installation and failure propagation as described in the main skill.
