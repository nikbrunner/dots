# Dependencies setup

Generates `.agents/skills/repo-dep-upgrades/SKILL.md` from [`templates/dep-upgrades.md`](../templates/dep-upgrades.md),
following the `dependencies` topic of `nbr-repo-conventions`.

## Survey

| Value                 | Source                                                                                                         |
| --------------------- | -------------------------------------------------------------------------------------------------------------- |
| Package manager       | `package.json` → npm/pnpm/bun (by lock file), `go.mod` → Go, `Cargo.toml` → Rust, `pyproject.toml` → Python |
| Lock file             | `package-lock.json`, `pnpm-lock.yaml`, `bun.lockb`, `go.sum`, `Cargo.lock`                                     |
| Verification commands | Scripts in `package.json`, `Makefile`, `justfile`, `mise.toml`; the CI workflows                               |
| Extra verification    | Storybook, Playwright, Cypress, when present                                                                   |
| Dependabot/Renovate   | `.github/dependabot.yml`, `renovate.json`, `.renovaterc`                                                       |
| Commit prefix         | `repo-commit` when it exists, else `git log --oneline -20`                                                     |

The plan carries the filled values in one table with their source, and the template's ecosystem table supplies the
commands.
