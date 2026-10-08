---
name: nbr-workflow-kit
description:
  "Set up or audit the workflow kit of a personal GitHub project: agent setup, Git hooks, and project-local
  `repo-commit`, `repo-changelog`, and `repo-release` skills on top of release-please, which writes CHANGELOG.md and the
  release notes from a curated release PR. Use when setting up a repo for agent work, release-please, releases, or a
  changelog workflow, or when checking an existing kit for drift."
argument-hint: "setup | audit"
---

# Workflow kit

The **workflow kit** is everything a repo needs for the agent-driven commit-to-release cycle. It stands on the repo's agent
setup (the `agent-tooling` topic of `nbr-conventions`) and Git hooks (`nbr-git-hooks`), and adds one pipeline in three skills
and four files:

| Piece                                                                 | Job                                                                    |
| --------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `repo-commit`                                                         | Conventional Commit with CI-parity run and approval gate               |
| `repo-changelog`                                                      | Curated Highlights per release, in the changelog and the release PR    |
| `repo-release`                                                        | Curate on the release branch, merge the release PR, verify             |
| `docs/releases.md`                                                    | The release process a maintainer can run by hand                       |
| `.github/release-please-config.json`, `.release-please-manifest.json` | Version bumps and `CHANGELOG.md` sections from Conventional Commits    |
| `.github/workflows/release.yml`                                       | release-please, then attach any release artifacts                      |

release-please owns the version, the tag, and each release section of `CHANGELOG.md`. The curated Highlights are written on
the release branch and into the release PR description. release-please publishes that description as the GitHub Release
notes, so the changelog section and the release page match.

Every project skill carries the `repo-` prefix, so it reads as repo-specific next to the global `nbr-` skills.

lazyjira (`~/repos/nikbrunner/lazyjira`) is the living reference for the wording of the three skills. The templates are that
wording with the project-specific parts lifted into placeholders.

## 1. Survey

Run in the project root. Collect, without asking:

- `gh repo view --json nameWithOwner,defaultBranchRef`. The kit requires a GitHub remote; stop and say so when there is none.
- Ecosystem and release-type, from the manifest files in [`references/pipeline.md`](references/pipeline.md), and whether a
  release ships artifacts.
- `git tag --sort=-v:refname | head`, `git log --oneline -30`: latest version, commit style, recurring scopes.
- Check commands from `Makefile`, `package.json` scripts, `mise.toml`, CI workflows: the CI-parity pass and a docs lint.
- Hooks: `lefthook.yml`, `.githooks/`, `core.hooksPath`.
- `GLOSSARY.md`, `CONTEXT.md`, `docs/`: domain names and the docs the commit skill audits.
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

| Placeholder          | Meaning                                                                                       | Example                                           |
| -------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `{{project}}`        | Display name                                                                                  | `lazyjira`                                        |
| `{{repo}}`           | `owner/name`                                                                                  | `nikbrunner/lazyjira`                             |
| `{{reader}}`         | Who reads the changelog                                                                       | `user`; a library says `consumer`                 |
| `{{check}}`          | CI-parity command, the pre-push pass                                                          | `make check`, `npm run verify`, `deno task check` |
| `{{lint_docs}}`      | Docs lint command; drop every line naming it when there is none                               | `make lint-docs`                                  |
| `{{hooks}}`          | One sentence on what the hooks run                                                            | "The pre-commit hook formats staged files."       |
| `{{e2e}}`            | When to run the end-to-end suite `{{check}}` leaves out, and to fix its specs in the same commit; drop when none | "Also run `deno task test:e2e` when ..."          |
| `{{suffix}}`         | Sentence naming the commit-subject suffix; drop when there is none                            | "End the subject with ` #<issue>`."               |
| `{{scopes}}`         | Commit scopes from history                                                                    | `ui`, `config`, `cli`                             |
| `{{docs}}`           | Docs to check when config, commands, or terms change                                          | `README.md`, `docs/config.md`                     |
| `{{release_assets}}` | Release-time asset step for `repo-release` and `docs/releases.md`; drop when there is none    | "Re-record the screenshots with ..."              |
| `{{publish}}`        | Sentence on the publish job for `docs/releases.md`, see the pipeline reference; drop when no artifacts | "GoReleaser then builds the archives ..."         |
| `{{verify_install}}` | Commands in `docs/releases.md` that install the release and print its version; drop when none | `npx <pkg>@<version> --version`                   |
| release-please       | `release-type`, manifest version, `initial-version`, `bootstrap-sha`, artifacts               | `node`, `0.8.0`                                   |

## 4. Build (`setup`)

Write each missing piece from its source, replace every placeholder, and keep the prose as the template has it:

| Write                                                              | From                                                                                           |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| `.agents/skills/repo-commit/SKILL.md`                              | [`templates/commit.md`](templates/commit.md)                                                   |
| `.agents/skills/repo-changelog/SKILL.md`                           | [`templates/changelog.md`](templates/changelog.md)                                             |
| `.agents/skills/repo-changelog/references/curated-release.md`      | [`templates/changelog-curated-release.md`](templates/changelog-curated-release.md)             |
| `.agents/skills/repo-release/SKILL.md`                             | [`templates/release.md`](templates/release.md)                                                 |
| `docs/releases.md`                                                 | [`templates/releases-doc.md`](templates/releases-doc.md)                                       |
| release-please config, manifest, `release.yml`, `CHANGELOG.md`     | [`references/pipeline.md`](references/pipeline.md)                                             |
| CI on the default branch                                           | A workflow that runs `{{check}}` on pushes to the default branch, when none does yet           |
| Agent setup: `AGENTS.md`, `.agents/skills/`, `.claude/skills` link | The `agent-tooling` topic of `nbr-conventions`, before anything else                           |
| Git hooks                                                          | The `nbr-git-hooks` skill: Lefthook, fast staged checks on pre-commit, `{{check}}` on pre-push |

Build in order: agent setup first, since the kit's skills live in `.agents/skills/`; then hooks, so `{{hooks}}` describes
what they run; then the skills and the pipeline. An existing agent setup is checked with `nbr-audit agent-tooling` rather
than rebuilt. A dropped placeholder takes its line and one adjacent blank line with it. Build is done when every piece exists, no `{{`
remains in the repo, and the written files pass the repo's formatter.

## 5. Audit

Run every check in [`references/audit.md`](references/audit.md), also right after a build. Report each as pass or finding, with
the fix for each finding, and apply fixes only after Nik approves them.

## 6. Hand off

Leave every file unstaged. Report what was written and the audit result, then name the two steps that remain with Nik:

- The repository setting that lets Actions open the release PR ([`references/pipeline.md`](references/pipeline.md#actions-permission)).
  Run it only after an explicit yes.
- Committing the kit, through the new `repo-commit` skill, as `ci: add the workflow kit`.

When an audit shows a project skill that improved on its template, propose carrying the improvement back into these
templates and into lazyjira's skills.
