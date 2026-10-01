# Audit

Every check names a coupling that breaks silently: nothing fails until a release ships wrong notes, the wrong version, or no
release at all. Run them all. The audit is done when each check reports pass or a finding with its fix.

## Skills

1. `.agents/skills/repo-{commit,changelog,release}/SKILL.md` and the changelog's two `references/` files exist, and each
   `name` matches its directory.
2. Every relative link in the kit's skills and `docs/releases.md` resolves. A link to a skill that lives only in the global
   skill directory (`humanizer`) is a finding; the fix names the skill instead of linking it.
3. Every skill the kit names (`humanizer`, `nbr-git-hooks`) exists in the project's `.agents/skills/` or the global
   `~/.claude/skills/`. A missing one is a finding that names the skill and where to install it, since the step that calls it
   silently does nothing.
4. No `{{` placeholder remains.
5. Every command the skills run exists: Makefile targets, `package.json` scripts, `mise` tasks.
6. The commit scopes and topic roots still match `git log` since the last tag and the glossary.
7. The agent setup passes the `agent-tooling` block of the `nbr-conventions` checklist; run `nbr-audit agent-tooling` and
   carry its findings over.
8. Hooks are installed (`lefthook.yml` with `lefthook install` run, or the repo's existing manager), pre-push runs the commit
   skill's CI-parity command, and the commit skill's sentence on hooks matches what they run.

## Pipeline

9. `release-please-config.json` has `skip-changelog: true` and `include-component-in-tag: false`, and its `release-type`
   matches the ecosystem.
10. The commit skill's type rules match `changelog-sections`: the types it says count toward a release are the listed ones.
11. The manifest version equals the latest `v*` tag, and the repo's formatter excludes the manifest. A leftover `bootstrap-sha`, `initial-version`, or `release-as` after the
    first release PR merged is a finding.
12. A workflow runs the CI-parity command on pushes to the default branch. The release PR gets no CI of its own, so this run
    is the release gate.
13. `release.yml` points at both `.github/` files, runs on the default branch, and its publish job replaces the notes with the
    extracted section.
14. `gh api /repos/<owner>/<repo>/actions/permissions/workflow` reports `can_approve_pull_request_reviews: true`.

## Changelog

15. Every release heading matches `` ## `X.Y.Z` `` + eight `&nbsp;` + `YYYY.MM.DD`, sections are separated by `---` with blank
    lines around it, and no `---` sits inside a section where it would cut the notes short.
16. The newest heading's version is the manifest version. When `gh pr list --label "autorelease: pending"` shows an open
    release PR, its version needs a section before the merge: without one, release-please tags and creates the release, and
    the publish job then fails on the missing section, leaving a release with generated notes and no artifacts. A release PR
    opened by internal-only commits is a finding too. Closing it does not help, since release-please reopens it on the next
    push; the fix leaves it unmerged until a user-facing change joins it, or writes a short section for it.
17. `## [Unreleased]` exists only while it holds entries, and every mechanical-log entry and topic root carries the author
    suffix. Highlights and code blocks carry none.
18. Since the last tag, every commit on the default branch is a Conventional Commit. release-please skips the rest without a
    word, so a lone `update stuff` is a change that never reaches a version bump.

## Template drift

19. Diff each kit file against its template with the project's values filled in. Sort each divergence:
    - **Project-specific**: an extra step only this repo needs, such as lazyjira's recordings. Keep it.
    - **Lag**: the template improved since the kit was written. Offer the update.
    - **Lead**: the project improved on the template. Propose carrying it back into the templates.
