---
name: {{prefix}}-release
description:
  "Prepare and ship a {{project}} release. Use this when cutting a version, preparing release notes, or merging the
  release-please PR. Ask for approval before merging the release PR."
argument-hint: "[version, for example 0.7.0; defaults to the release PR's version]"
allowed-tools: Bash Read Edit
---

# Release {{project}}

Follow [`docs/releases.md`](../../../docs/releases.md). It is the maintainer source of truth for the release PR, the curated
changelog commit, and checking the GitHub Release.

Prepare the release notes with [`{{prefix}}-changelog`](../{{prefix}}-changelog/SKILL.md) in release mode before merging:
it curates the section and sets the release date. The section's version must match the release PR title.

{{release_assets}}

Ask for explicit approval immediately before merging the release PR.
