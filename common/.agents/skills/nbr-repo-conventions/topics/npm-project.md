# npm project

Project metadata, scripts, and dependency policy live in `package.json`, `.npmrc`, and the lockfile.

## package.json

- ESM: `"type": "module"`.
- The Node floor is set with `engines.node` or `.nvmrc`.
- The `#/` source alias is wired through the `imports` field and the matching TypeScript paths. Node's `#` subpath prefix
  cannot clash with an npm scope.
- `private: true` only for packages that are never published.

## Scripts

The same check has the same name in every repo. `verify:*` scripts only read; `format` and `lint` write (see
[git](git.md#check-never-write)).

| Script             | Purpose                                 |
| ------------------ | --------------------------------------- |
| `dev`              | Start local development                 |
| `build`            | Create a production build               |
| `verify:format`    | Check formatting                        |
| `verify:lint`      | Check lint                              |
| `verify:typecheck` | Run TypeScript without emitting         |
| `verify:tests`     | Run tests once                          |
| `verify:knip`      | Check dead code and unused exports      |
| `verify:staged`    | The pre-commit scope                    |
| `verify:full`      | The CI and pre-push scope               |
| `format`           | Rewrite formatting                      |
| `lint`             | Rewrite fixable lint issues             |
| `git:config`       | Apply the repository Git config         |

A repo has the scripts it needs; read `package.json` before running one.

## Dependencies

- The committed lockfile is the pin. Version ranges (`^`, `~`) are fine in `package.json`; `latest` is not.
- `.npmrc` sets `ignore-scripts=true` when the project relies on explicit setup commands rather than install-time lifecycle
  scripts.
