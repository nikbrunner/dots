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
      "skip-changelog": true,
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
`skip-changelog` keeps release-please out of `CHANGELOG.md`. `include-component-in-tag: false` makes the tag `v<version>`,
which the publish job and `docs/releases.md` expect. The `changelog-sections` decide which commit types count toward a
release; the commit skill's type rules repeat that list.

**Bootstrap** (first adoption only):

- Released before (tags exist): the manifest holds the latest released version. Set top-level `"bootstrap-sha"` to the
  commit of that release so older, non-conventional history stays out of the first release PR.
- Never released: the manifest is `{}` and the package sets `"initial-version"` to the first version to ship.

## `.github/.release-please-manifest.json`

```json
{ ".": "<latest released version>" }
```

After bootstrap, only release-please edits it.

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

  publish:
    needs: release-please
    if: needs.release-please.outputs.release_created == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          ref: ${{ needs.release-please.outputs.tag_name }}
          fetch-depth: 0

      - name: extract release notes
        env:
          VERSION: ${{ needs.release-please.outputs.version }}
        run: |
          awk -v heading="## \`${VERSION}\`" '
            index($0, heading) == 1 { found = 1; next }
            found && /^---$/ { exit }
            found { print }
          ' CHANGELOG.md > "${RUNNER_TEMP}/release-notes.md"
          if ! grep -q '[^[:space:]]' "${RUNNER_TEMP}/release-notes.md"; then
            echo "CHANGELOG.md has no section for ${VERSION}" >&2
            exit 1
          fi

      - name: replace release notes
        env:
          GH_TOKEN: ${{ github.token }}
          TAG: ${{ needs.release-please.outputs.tag_name }}
        run: gh release edit "$TAG" --notes-file "${RUNNER_TEMP}/release-notes.md"
```

The awk is the other half of the changelog's heading contract: the section starts at a line beginning with
``## `<version>` `` and ends at the first `---`.

### Release artifacts

When the project ships files with a release (binaries, archives, a packaged plugin), add the toolchain setup and the
project's own build command between the extraction and the notes step, then attach the output:

```yaml
- name: build artifacts
  run: <the project's release build, writing to dist/>

- name: attach artifacts
  env:
    GH_TOKEN: ${{ github.token }}
    TAG: ${{ needs.release-please.outputs.tag_name }}
  run: gh release upload "$TAG" dist/* --clobber
```

A repo that already has a release tool which takes a notes file keeps it and passes it `${RUNNER_TEMP}/release-notes.md`
in place of the two `gh` steps.

`{{publish}}` is the sentence `docs/releases.md` uses for this job: "The publish job then replaces the release notes with
the `CHANGELOG.md` section for that version", plus the artifacts it attaches when it builds any.

Publishing to a package registry (npm, JSR, crates.io, PyPI) is a separate decision with its own credentials. Add it only
when Nik asks for it.

## `CHANGELOG.md`

When the repo has none, start it as a bare `# Changelog` heading. The first entry adds `## [Unreleased]` below it.

An existing changelog in another format stays as history below a `---`; new sections follow the kit's heading format.

## Actions permission

release-please opens its PR with `GITHUB_TOKEN`, which needs the repository to let Actions create pull requests. This changes
a repo-level setting and needs admin access, so it runs only after Nik says yes:

```sh
gh api --method PUT "/repos/{{repo}}/actions/permissions/workflow" \
  -f default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=true
```

The workflow declares its own `permissions`, so the repo default stays `read`.
