# Audit

Every check names a coupling that breaks silently: nothing fails until a release ships wrong notes, the wrong version, or no
release at all. Run them all. The audit is done when each check reports pass or a finding with its fix.

## Skills

1. `.agents/skills/repo-{commit,changelog,release}/SKILL.md` and the changelog's `references/curated-release.md` exist, and
   each `name` matches its directory.
2. Every relative link in the kit's skills and `docs/releases.md` resolves. A link to a skill that lives only in the global
   skill directory (`humanizer`) is a finding; the fix names the skill instead of linking it.
3. Every skill the kit names (`humanizer`, `nbr-git-hooks`) exists in the project's `.agents/skills/` or the global
   `~/.claude/skills/`. A missing one is a finding that names the skill and where to install it, since the step that calls it
   silently does nothing.
4. No `{{` placeholder remains.
5. Every command the skills run exists: Makefile targets, `package.json` scripts, `mise` tasks.
6. The commit scopes still match `git log` since the last tag.
7. The agent setup passes the `agent-tooling` block of the `nbr-conventions` checklist; run `nbr-audit agent-tooling` and
   carry its findings over.
8. Hooks are installed (`lefthook.yml` with `lefthook install` run, or the repo's existing manager), pre-push runs the commit
   skill's CI-parity command, and the commit skill's sentence on hooks matches what they run.
9. When the project has an end-to-end suite outside the CI-parity command, the commit skill names when to run it and that
   a failure means updating the suite in the same commit. A suite no skill runs is a finding: its specs rot unnoticed.
10. `AGENTS.md` holds no commit or changelog rules: the kit skills own them. A commit section is a finding; its suffix rule
    moves into `{{suffix}}` of `repo-commit`, and the rest goes.

## Pipeline

11. `release-please-config.json` has `include-component-in-tag: false` and no `skip-changelog`, and its `release-type`
    matches the ecosystem.
12. The commit skill's type rules match `changelog-sections`: the types it says count toward a release are the listed ones.
13. The manifest version equals the latest `v*` tag, and the repo's formatter excludes the manifest. A leftover `bootstrap-sha`, `initial-version`, or `release-as` after the
    first release PR merged is a finding.
14. A workflow runs the CI-parity command on pushes to the default branch and on pull requests. The curation commit pushed
    to the release branch runs it on the release PR, which is the release gate.
15. `release.yml` points at both `.github/` files and runs on the default branch. A publish job, when the project ships
    artifacts, only attaches them: no step edits the notes, and a release tool keeps existing notes.
16. `gh api /repos/<owner>/<repo>/actions/permissions/workflow` reports `can_approve_pull_request_reviews: true`.

## Changelog

17. Every release heading starts with `## [X.Y.Z](` or `## X.Y.Z`, the format release-please inserts above, no
    `## [Unreleased]` block remains, and no section holds a line that is only `---`. The docs lint passes on release-please's
    `*` bullets next to older `-` ones.
18. The newest heading's version is the manifest version. When `gh pr list --label "autorelease: pending"` shows an open
    release PR, its section on the release branch has `### Highlights` and the PR description's notes match that section
    before the merge: without them, the release ships with the bare commit list. A release PR opened by internal-only
    commits is a finding too. Closing it does not help, since release-please reopens it on the next push; the fix leaves it
    unmerged until a user-facing change joins it.
19. Each released version's GitHub Release notes (`gh release view v<version>`) match its `CHANGELOG.md` section.
20. Since the last tag, every commit on the default branch is a Conventional Commit. release-please skips the rest without a
    word, so a lone `update stuff` is a change that never reaches a version bump.

## Template drift

21. Diff each kit file against its template with the project's values filled in. Sort each divergence:
    - **Project-specific**: an extra step only this repo needs, such as lazyjira's recordings. Keep it.
    - **Lag**: the template improved since the kit was written. Offer the update.
    - **Lead**: the project improved on the template. Propose carrying it back into the templates.
