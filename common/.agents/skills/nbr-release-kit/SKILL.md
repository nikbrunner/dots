---
name: nbr-release-kit
description:
  "Set up or audit the release kit of a personal GitHub project: project-local `<prefix>-commit`, `<prefix>-changelog`, and
  `<prefix>-release` skills on top of release-please and a hand-written, curated CHANGELOG.md. Use when setting up
  release-please, releases, or a changelog workflow in a repo, or when checking an existing kit for drift."
argument-hint: "setup | audit"
---

# Release kit

The **release kit** is one pipeline in three skills and four files:

| Piece                                                                 | Job                                                                    |
| --------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `<prefix>-commit`                                                     | Conventional Commit with changelog check, CI-parity run, approval gate |
| `<prefix>-changelog`                                                  | Mechanical entry per change, curated section per release               |
| `<prefix>-release`                                                    | Curate, merge the release PR, verify                                   |
| `docs/releases.md`                                                    | The release process a maintainer can run by hand                       |
| `.github/release-please-config.json`, `.release-please-manifest.json` | Version bumps from Conventional Commits, `skip-changelog`              |
| `.github/workflows/release.yml`                                       | release-please, then publish with the curated section as the notes     |

release-please owns the version and the tag. Humans and agents own `CHANGELOG.md`. The publish job copies the section for the
tagged version into the GitHub Release notes, so the heading format in the changelog and the extraction in the workflow are
one contract.

lazyjira (`~/repos/nikbrunner/lazyjira`) is the living reference: `lj-commit`, `lj-changelog`, `lj-release`. The templates
here are its wording with the project-specific parts lifted into placeholders.

## 1. Survey

Run in the project root. Collect, without asking:

- `gh repo view --json nameWithOwner,defaultBranchRef`. The kit requires a GitHub remote; stop and say so when there is none.
- Ecosystem and release-type, from the manifest files in [`references/pipeline.md`](references/pipeline.md), and whether a
  release ships artifacts.
- `git tag --sort=-v:refname | head`, `git log --oneline -30`: latest version, commit style, recurring scopes.
- Check commands from `Makefile`, `package.json` scripts, `mise.toml`, CI workflows: the CI-parity pass and a docs lint.
- Hooks: `lefthook.yml`, `.githooks/`, `core.hooksPath`.
- `GLOSSARY.md`, `CONTEXT.md`, `docs/`: domain names for topic roots and the docs the commit skill audits.
- Existing kit pieces: `.agents/skills/*-{commit,changelog,release}`, the release-please files, `release.yml`,
  `CHANGELOG.md`, `docs/releases.md`, and the `.claude/skills` symlink.

The survey is done when every placeholder below has a proposed value or is marked unused.

## 2. Pick the mode

- `setup`: build the missing pieces (steps 3 and 4), then audit the whole kit. Existing pieces change only through approved
  audit fixes.
- `audit`: run step 5 only and report.
- No argument: `audit` when any kit piece exists, otherwise `setup`.

## 3. Confirm the values

Show one table of placeholder values with what each was inferred from, and wait for Nik's confirmation.

| Placeholder          | Meaning                                                                                        | Example                                           |
| -------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `{{prefix}}`         | Skill prefix, short                                                                            | `lj`                                              |
| `{{project}}`        | Display name                                                                                   | `lazyjira`                                        |
| `{{repo}}`           | `owner/name`                                                                                   | `nikbrunner/lazyjira`                             |
| `{{reader}}`         | Who reads the changelog                                                                        | `user`; a library says `consumer`                 |
| `{{check}}`          | CI-parity command, the pre-push pass                                                           | `make check`, `npm run verify`, `deno task check` |
| `{{lint_docs}}`      | Docs lint command; drop every line naming it when there is none                                | `make lint-docs`                                  |
| `{{hooks}}`          | One sentence on what the hooks run                                                             | "The pre-commit hook formats staged files."       |
| `{{scopes}}`         | Commit scopes from history                                                                     | `ui`, `config`, `cli`                             |
| `{{docs}}`           | Docs to check when config, commands, or terms change                                           | `README.md`, `docs/config.md`                     |
| `{{topic_roots}}`    | Changelog topic roots, from the glossary when one exists                                       | Configuration, Documentation, CI and releases     |
| `{{release_assets}}` | Release-time asset step for `<prefix>-release` and `docs/releases.md`; drop when there is none | "Re-record the screenshots with ..."              |
| `{{publish}}`        | Sentence on the publish job for `docs/releases.md`, see the pipeline reference                 | "The publish job then replaces ..."               |
| `{{verify_install}}` | Commands in `docs/releases.md` that install the release and print its version                  | `npx <pkg>@<version> --version`                   |
| release-please       | `release-type`, manifest version, `initial-version`, `bootstrap-sha`, artifacts                | `node`, `0.8.0`                                   |

## 4. Build (`setup`)

Write each missing piece from its source, replace every placeholder, and keep the prose as the template has it:

| Write                                                               | From                                                                                                 |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `.agents/skills/{{prefix}}-commit/SKILL.md`                         | [`templates/commit.md`](templates/commit.md)                                                         |
| `.agents/skills/{{prefix}}-changelog/SKILL.md`                      | [`templates/changelog.md`](templates/changelog.md)                                                   |
| `.agents/skills/{{prefix}}-changelog/references/mechanical-log.md`  | [`templates/changelog-mechanical-log.md`](templates/changelog-mechanical-log.md)                     |
| `.agents/skills/{{prefix}}-changelog/references/curated-release.md` | [`templates/changelog-curated-release.md`](templates/changelog-curated-release.md)                   |
| `.agents/skills/{{prefix}}-release/SKILL.md`                        | [`templates/release.md`](templates/release.md)                                                       |
| `docs/releases.md`                                                  | [`templates/releases-doc.md`](templates/releases-doc.md)                                             |
| release-please config, manifest, `release.yml`, `CHANGELOG.md`      | [`references/pipeline.md`](references/pipeline.md)                                                   |
| CI on the default branch                                            | A workflow that runs `{{check}}` on pushes to the default branch, when none does yet                 |
| Git hooks                                                           | The `dev-setup-git-hooks` skill: Lefthook, fast staged checks on pre-commit, `{{check}}` on pre-push |

Set up the hooks before writing `{{hooks}}` into the commit skill, so the sentence describes what the hooks run.

When `.claude/skills` is not a relative symlink to `../.agents/skills`, the agent setup belongs to `dev-setup-llm`; name it as
a finding. Build is done when every piece exists and no `{{` remains in the repo.

## 5. Audit

Run every check in [`references/audit.md`](references/audit.md), also right after a build. Report each as pass or finding, with
the fix for each finding, and apply fixes only after Nik approves them.

## 6. Hand off

Leave every file unstaged. Report what was written and the audit result, then name the two steps that remain with Nik:

- The repository setting that lets Actions open the release PR ([`references/pipeline.md`](references/pipeline.md#actions-permission)).
  Run it only after an explicit yes.
- Committing the kit, through the new `{{prefix}}-commit` skill, as `ci: add the release kit`.

When an audit shows a project skill that improved on its template, propose carrying the improvement back into these
templates and into lazyjira's skills.
