---
name: repo-release
description:
  "Prepare and ship a {{project}} release. Use this when cutting a version, preparing release notes, or merging the
  release-please PR. Ask for approval before merging the release PR."
argument-hint: "[version, for example 0.7.0; defaults to the release PR's version]"
allowed-tools: Bash Read Edit
---

# Release {{project}}

Follow [`docs/releases.md`](../../../docs/releases.md). It is the maintainer source of truth for the release PR, the curated
changelog commit, and checking the GitHub Release.

Prepare the release notes with [`repo-changelog`](../repo-changelog/SKILL.md) in release mode before merging:
it curates the section and sets the release date. The section's version must match the release PR title. Read the title
after release-please has finished its run for the latest push to `main`; each run can change the version.

{{release_assets}}

Ask for explicit approval immediately before merging the release PR.
