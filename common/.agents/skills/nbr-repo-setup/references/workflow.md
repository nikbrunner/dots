# Workflow kit setup

Builds the kit the `workflow` topic of `nbr-repo-conventions` describes.

## Survey

Collect, without asking:

- `gh repo view --json nameWithOwner,defaultBranchRef`. The kit requires a GitHub remote; stop and say so when there is none.
- Ecosystem and release-type, from the manifest files in [`pipeline.md`](pipeline.md), and whether a release ships
  artifacts.
- `git tag --sort=-v:refname | head`, `git log --oneline -30`: latest version, commit style, recurring scopes.
- Check commands from `Makefile`, `package.json` scripts, `mise.toml`, CI workflows: the CI-parity pass and a docs lint.
- Hooks: `lefthook.yml`, `.githooks/`, `core.hooksPath`.
- `GLOSSARY.md`, `docs/`, and a `CONTEXT.md` when an older repo has one: domain names and the docs the commit skill audits.
- Existing kit pieces: `.agents/skills/*-{commit,changelog,release}`, the release-please files, `release.yml`,
  `CHANGELOG.md`, `docs/releases.md`, and the `.claude/skills` symlink.
- Declared commit grammar in `AGENTS.md`, `CLAUDE.md` (also `.claude/CLAUDE.md`), and `CONTRIBUTING.md`. A grammar that
  contradicts Conventional Commits stops the survey: show the conflict and ask before building the kit.

The survey is done when every placeholder below has a proposed value or is marked unused.

## Values

The plan carries one table of placeholder values with what each was inferred from.

| Placeholder          | Meaning                                                                                                          | Example                                           |
| -------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `{{project}}`        | Display name                                                                                                     | `my-cli`                                          |
| `{{repo}}`           | `owner/name`                                                                                                     | `nikbrunner/my-cli`                               |
| `{{reader}}`         | Who reads the changelog                                                                                          | `user`; a library says `consumer`                 |
| `{{check}}`          | CI-parity command, the pre-push pass                                                                             | `make check`, `npm run verify`, `deno task check` |
| `{{lint_docs}}`      | Docs lint command; drop every line naming it when there is none                                                  | `make lint-docs`                                  |
| `{{hooks}}`          | One sentence on what the hooks run                                                                               | "The pre-commit hook runs `verify:staged`."       |
| `{{e2e}}`            | When to run the end-to-end suite `{{check}}` leaves out, and to fix its specs in the same commit; drop when none | "Also run `deno task test:e2e` when ..."          |
| `{{suffix}}`         | Sentence naming the commit-subject suffix; drop when there is none                                               | "End the subject with ` (#<issue>)`."             |
| `{{scopes}}`         | Commit scopes from history                                                                                       | `ui`, `config`, `cli`                             |
| `{{docs}}`           | Docs to check when config, commands, or terms change                                                             | `README.md`, `docs/config.md`                     |
| `{{release_assets}}` | Release-time asset step for `repo-release` and `docs/releases.md`; drop when there is none                       | "Record the clips with `nbr-record-clip`"         |
| `{{publish}}`        | Sentence on the publish job for `docs/releases.md`, see [`pipeline.md`](pipeline.md); drop when no artifacts     | "GoReleaser then builds the archives ..."         |
| `{{verify_install}}` | Commands in `docs/releases.md` that install the release and print its version; drop when none                    | `npx <pkg>@<version> --version`                   |
| release-please       | `release-type`, manifest version, `initial-version`, `bootstrap-sha`, artifacts                                  | `node`, `0.8.0`                                   |

## Build

Write each missing piece from its source, replace every placeholder, and keep the prose as the template has it:

| Write                                                          | From                                                                                  |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `.agents/skills/repo-commit/SKILL.md`                          | [`templates/commit.md`](../templates/commit.md)                                       |
| `.agents/skills/repo-changelog/SKILL.md`                       | [`templates/changelog.md`](../templates/changelog.md)                                 |
| `.agents/skills/repo-changelog/references/curated-release.md`  | [`templates/changelog-curated-release.md`](../templates/changelog-curated-release.md) |
| `.agents/skills/repo-release/SKILL.md`                         | [`templates/release.md`](../templates/release.md)                                     |
| `docs/releases.md`                                             | [`templates/releases-doc.md`](../templates/releases-doc.md)                           |
| release-please config, manifest, `release.yml`, `CHANGELOG.md` | [`pipeline.md`](pipeline.md)                                                          |
| CI on the default branch                                       | A workflow that runs `{{check}}` on pushes to the default branch, when none does yet  |

A dropped placeholder takes its line and one adjacent blank line with it. The build is done when every piece exists, no
`{{` remains in the repo, and the written files pass the repo's formatter.

## Hand off

Report what was written and the audit result, then name the two steps that remain with the maintainer:

- The repository setting that lets Actions open the release PR ([`pipeline.md`](pipeline.md#actions-permission)). Run it
  only after an explicit yes.
- Committing the kit, through the new `repo-commit` skill, as `ci: add the workflow kit`.
