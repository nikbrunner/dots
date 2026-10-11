# Dependencies

Dependency upgrades run through a project skill, `repo-dep-upgrades`, which knows the repo's package manager, its
verification command, and its commit prefix. `nbr-repo-setup dependencies` generates it.

- Read the changelog and check the package's usage in the project before upgrading.
- Patch and minor upgrades go in one batch; each major goes on its own.
- Run the verification command after every upgrade, and commit only a green upgrade.
- An upgrade commit stages only the manifest, the lock file, and the code the upgrade required.
- With Conventional Commits, upgrades use `build(deps):`, which does not count toward a release.
- Dependabot or Renovate PRs, when configured, go through the same skill.
