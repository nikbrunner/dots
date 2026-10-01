---
name: nbr-audit-docs
description:
  "Find documentation a diff made stale. Use as the docs check before a commit (`--staged`), or for a periodic sweep over
  recent commits (`--commits N`). Reports only; fixes happen in the caller."
argument-hint: "[--staged | --commits N]"
---

# Docs audit

Diff-driven and conservative: a finding needs a changed symbol, path, command, or behavior that a doc still describes the
old way.

1. Read the diff: `git diff --cached` for `--staged` (the default), `git diff HEAD~N` for `--commits N`.
2. Name what changed: structure (files, modules, paths), behavior, configuration (keys, flags, env, scripts), conventions.
3. Collect candidate docs: tracked `.md` files, minus the skip list.
4. Search them for each changed name and read the hits.
5. Report each finding with `path:line`, the class, and the edit that fixes it.

| Class  | Meaning                                                         |
| ------ | --------------------------------------------------------------- |
| STALE  | A doc states something the diff made false                      |
| DRIFT  | Two docs, or a doc and a config, now disagree                   |
| GAP    | The diff adds a surface (command, key, convention) no doc names |
| SCHEMA | A documented format or example no longer matches the code       |

No findings is a result: say "docs in sync" and stop.

Skip `plans/`, `tmp/`, `handoffs/`, `ROADMAP.md`, `CHANGELOG.md`, `node_modules/`, `dist/`, and generated files.
