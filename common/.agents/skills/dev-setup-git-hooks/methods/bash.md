# Native shell hooks

Use this fallback when the user chooses native hooks or project conventions require them. Keep the check distribution defined in the main skill.

## References and discovery

Read the official [Git hook documentation](https://git-scm.com/docs/githooks) for each configured stage and [core.hooksPath documentation](https://git-scm.com/docs/git-config#Documentation/git-config.txt-corehooksPath) before changing installation.

Use `git --version` and local Git help to check available behavior. Inspect `git config --show-origin --get-all core.hooksPath` and resolve the effective hook directory with Git, including worktrees. Preserve global settings and unrelated hooks; changing the hook directory affects every stage.

## Configure

Use tracked `.githooks/` files, or maintain the project's existing native-hook directory. Prefer portable `#!/usr/bin/env sh` scripts with `set -e`; use Bash only when required by the implementation. Hook failures must propagate to Git.

Call existing project commands directly. For Node projects, reuse an existing staged-file runner for formatting/linting; if one is needed, choose it explicitly rather than implementing filename parsing and partial-stage handling in shell. Keep typechecking and non-watch tests at pre-push where policy allows.

For Deno projects, reuse existing `deno task` commands or appropriate built-in checks. Whole-project formatting/linting may suit small repositories; disclose their scope and cost rather than calling them staged-file checks.

Use check modes for new formatting jobs. Preserve existing autofix and staging behavior unless a change is agreed. Commands reading working-tree files do not necessarily check the staged contents; preserve partial-stage protections and report limitations.

Preserve stage-specific inputs. Pre-push receives remote arguments and ref updates on stdin; pass them through when existing checks use them. Do not make one consumer drain input needed by another.

## Install

Make the configured hook files executable. After accounting for all existing hooks and configuration scopes, enable the tracked directory with `git config --local core.hooksPath .githooks` when that is the selected location. Account for configuration shared by worktrees.

For Node projects, integrate installation into the project's existing setup or `prepare` script without replacing unrelated commands. For Deno projects, provide an explicit `install-hooks` task. Document the setup command for fresh clones.

## Verify

Check executable bits and Git's effective hook directory. Run scripts with representative arguments and input. Verify a failing check blocks the appropriate Git operation in a disposable repository. Direct script execution alone does not prove Git wiring. Follow the main skill's file-selection and working-tree preservation checks.
