# Workflow

The **workflow kit** is everything a repo needs for the agent-driven commit-to-release cycle. It stands on the agent setup
([`agent-tooling`](agent-tooling.md)) and Git hooks ([`hooks`](hooks.md)), and adds one pipeline in three project skills
and four files:

| Piece                                                                 | Job                                                                 |
| --------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `repo-commit`                                                         | Conventional Commit with CI-parity run and approval gate            |
| `repo-changelog`                                                      | Curated Highlights per release, in the changelog and the release PR |
| `repo-release`                                                        | Curate on the release branch, merge the release PR, verify          |
| `docs/releases.md`                                                    | The release process a maintainer can run by hand                    |
| `.github/release-please-config.json`, `.release-please-manifest.json` | Version bumps and `CHANGELOG.md` sections from Conventional Commits |
| `.github/workflows/release.yml`                                       | release-please, then attach any release artifacts                   |

The kit needs a GitHub remote. `nbr-repo-setup workflow` builds it from templates.

## Ownership

release-please owns the version, the tag, and each release section of `CHANGELOG.md`. The curated Highlights are written on
the release branch and into the release PR description. release-please publishes that description as the GitHub Release
notes, so the changelog section and the release page match.

- Config and manifest live in `.github/`, never the repo root. Tags are `v<version>` (`include-component-in-tag: false`).
- After bootstrap, only release-please edits the manifest. The formatter excludes it.
- A release ships no step that edits the notes. A publish job only attaches artifacts.
- Publishing to a package registry is a separate decision with its own credentials.

## Commits

- Where release-please runs, every commit on the default branch is a Conventional Commit. release-please skips the rest
  without a word, so a lone `update stuff` never reaches a version bump.
- `changelog-sections` decide which types count toward a release: `feat`, `refactor`, `fix`, `docs`, `perf`. The commit
  skill's type rules repeat that list.
- Before `1.0.0`, a breaking change bumps the minor version (`bump-minor-pre-major`), and `feat` bumps the minor too.
- `AGENTS.md` holds no commit or changelog rules. `repo-commit` and `repo-changelog` own them.
- Repos without release-please keep their own commit style; `nbr-git-commit` resolves it per field.

## Changelog

- Release headings use release-please's format, `## [X.Y.Z](<compare-url>) (<date>)`. No `## [Unreleased]` block, and no
  line that is only `---`.
- A release PR opened by internal-only commits stays unmerged until a user-facing change joins it. Closing it does not
  help: release-please reopens it on the next push.

## Project skills

Kit skills carry the `repo-` prefix and live in `.agents/skills/`. They start as the setup templates with the
project-specific parts filled in; an extra step only one repo needs is fine. When a project skill improves on its
template, the improvement goes back into the template.
