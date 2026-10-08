# Pipeline

The files under the kit's skills. Paths are fixed: config and manifest live in `.github/`, never the repo root.

## `.github/release-please-config.json`

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "packages": {
    ".": {
      "release-type": "<type>",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": false,
      "include-component-in-tag": false,
      "changelog-sections": [
        { "type": "feat", "section": "Features" },
        { "type": "refactor", "section": "Refactors" },
        { "type": "fix", "section": "Bug Fixes" },
        { "type": "docs", "section": "Documentation" },
        { "type": "perf", "section": "Performance" }
      ]
    }
  }
}
```

| Ecosystem        | `release-type` | Extra                                                                                   |
| ---------------- | -------------- | --------------------------------------------------------------------------------------- |
| `go.mod`         | `go`           |                                                                                         |
| `package.json`   | `node`         |                                                                                         |
| `Cargo.toml`     | `rust`         |                                                                                         |
| `pyproject.toml` | `python`       |                                                                                         |
| `deno.json`      | `simple`       | `"extra-files": [{ "type": "json", "path": "deno.json", "jsonpath": "$.version" }]`     |
| Obsidian plugin  | `simple`       | `"extra-files": [{ "type": "json", "path": "manifest.json", "jsonpath": "$.version" }]` |
| Anything else    | `simple`       |                                                                                         |

`bump-minor-pre-major` keeps a breaking change before `1.0.0` on the next minor version; without it, release-please jumps
to `1.0.0`. `bump-patch-for-minor-pre-major` stays at the release-please default, so `feat` bumps the minor version too.
`include-component-in-tag: false` makes the tag `v<version>`, which `docs/releases.md` expects. The `changelog-sections`
decide which commit types count toward a release and the groups of the generated `CHANGELOG.md` section; the commit skill's
type rules repeat that list.

**Bootstrap** (first adoption only):

- Released before (tags exist): the manifest holds the latest released version. Set top-level `"bootstrap-sha"` to the
  commit of that release so older, non-conventional history stays out of the first release PR.
- Never released: the manifest is `{}` and the package sets `"initial-version"` to the first version to ship.

## `.github/.release-please-manifest.json`

```json
{ ".": "<latest released version>" }
```

After bootstrap, only release-please edits it. It writes compact JSON, so exclude the manifest from the repo's formatter; otherwise the format check
fails on every release commit.

## `.github/workflows/release.yml`

Use the repo's default branch. Pin action majors to the ones the repo's other workflows use, and to current majors when it
has none.

```yaml
name: release

on:
  push:
    branches: [<default-branch>]

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    outputs:
      release_created: ${{ steps.release.outputs.release_created }}
      tag_name: ${{ steps.release.outputs.tag_name }}
      version: ${{ steps.release.outputs.version }}
    steps:
      - uses: googleapis/release-please-action@v4
        id: release
        with:
          config-file: .github/release-please-config.json
          manifest-file: .github/.release-please-manifest.json
```

release-please creates the GitHub Release from the merged release PR's description, so the notes need no publish step.

### Release artifacts

When the project ships files with a release (binaries, archives, a packaged plugin), add a publish job that sets up the
toolchain, builds them with the project's own command, and attaches them without touching the notes:

```yaml
  publish:
    needs: release-please
    if: needs.release-please.outputs.release_created == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          ref: ${{ needs.release-please.outputs.tag_name }}
          fetch-depth: 0

      - name: build artifacts
        run: <the project's release build, writing to dist/>

      - name: attach artifacts
        env:
          GH_TOKEN: ${{ github.token }}
          TAG: ${{ needs.release-please.outputs.tag_name }}
        run: gh release upload "$TAG" dist/* --clobber
```

A repo that already has a release tool keeps it, configured to leave existing notes alone. GoReleaser does that with
`release.mode: keep-existing`, its default, plus `changelog.disable: true`.

`{{publish}}` is the sentence `docs/releases.md` uses for this job, such as "GoReleaser then builds the archives and attaches
them, keeping the notes." Drop it when the project ships no artifacts.

Publishing to a package registry (npm, JSR, crates.io, PyPI) is a separate decision with its own credentials. Add it only
when Nik asks for it.

## `CHANGELOG.md`

When the repo has none, start it as a bare `# Changelog` heading; release-please adds the first section below it.

release-please inserts a new section above the first heading that matches `\n###? v?[0-9[]`, a heading starting with
`## [` or `## <digit>`. When no heading matches, it puts the section under the title and demotes the old `# Changelog` to a
second `## Changelog`. An existing changelog therefore moves its release headings to release-please's format once, such
as `## [0.9.0](https://github.com/{{repo}}/compare/v0.8.0...v0.9.0) (2026-10-01)`, and drops any `## [Unreleased]` block.
Its sections hold no line that is only `---`.

release-please writes `*` bullets. When older sections use `-`, the docs lint disables the one-list-style rule
(markdownlint `MD004`), or the first generated section fails it.

The first release PR opened before this switch carries no `CHANGELOG.md` change. release-please updates a release PR only
when its generated description differs, so change the PR description and rerun the release workflow to rebuild it.

## Actions permission

release-please opens its PR with `GITHUB_TOKEN`, which needs the repository to let Actions create pull requests. This changes
a repo-level setting and needs admin access, so it runs only after Nik says yes:

```sh
gh api --method PUT "/repos/{{repo}}/actions/permissions/workflow" \
  -f default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=true
```

The workflow declares its own `permissions`, so the repo default stays `read`.
