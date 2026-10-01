# Agent tooling

How a repository tells coding agents what they need: one instruction file, project skills, and enforcement. Tool details
live in [`agent-tooling/claude-code.md`](agent-tooling/claude-code.md) and [`agent-tooling/pi.md`](agent-tooling/pi.md).

## Layout

```
<repo>/
├── AGENTS.md                # canonical instructions, read by Claude Code and Pi
├── .agents/skills/<name>/   # canonical project skills, SKILL.md per directory
└── .claude/skills           # relative symlink → ../.agents/skills
```

- `AGENTS.md` and `.agents/skills/` are agent-neutral and canonical. Agent-specific config lives only in that agent's own
  directory: `.claude/settings.json`, `.pi/settings.json`, `.pi/extensions/`.
- `.claude/skills` is a relative symlink, so it survives clones and worktrees. Pi discovers `.agents/skills/` on its own.
- Project skills carry the project prefix (`lj-commit`); personal global skills carry `nbr-`.

## AGENTS.md

Lean: about 50 lines, holding only what an agent would get wrong without it. The decision test for every line: _would the
agent make a costly mistake without this, or would it just need to read a file first?_ When reading a file is enough, the
line goes.

Discoverable from the repo, so it stays out:

- dev commands (`package.json`, `Makefile`, `deno.json`, `mise.toml`)
- runtime versions (`.nvmrc`, `.tool-versions`, `engines`)
- path aliases, lint and format config, test setup
- generated files a framework explains (route trees)
- architecture already written up in `docs/`

What stays: the project's identity and constraints, unwritten conventions, the reason behind a non-obvious choice, gotchas,
and pointers to skills and docs with the condition for reading them.

## Where an instruction belongs

| Kind                                                            | Home                                              |
| --------------------------------------------------------------- | ------------------------------------------------- |
| Always-on context: identity, constraints, core principles       | `AGENTS.md`                                       |
| A workflow or domain knowledge needed only for some tasks       | A skill in `.agents/skills/`                      |
| A deterministic rule ("never X", "always Y") a script can check | Enforcement: a Claude Code hook or a Pi extension |
| Anything discoverable, duplicated, or stale                     | Nowhere                                           |

A skill only the human should start sets `disable-model-invocation: true`, which keeps its description out of every session.
Knowledge and workflow skills the agent should reach on its own keep a description that names their triggers.

## Feedback loops

An agent works best against fast, deterministic checks: a typecheck script, a lint, Git hooks with staged checks on
pre-commit and the CI-parity pass on pre-push (`nbr-git-hooks` sets them up).

## Health

A setup drifts like code. Signs to look for: `AGENTS.md` lines the decision test removes, skills naming removed files or
APIs, two skills or a skill and `AGENTS.md` saying the same thing, enforcement for tools the repo no longer uses, and
project areas with recurring agent mistakes and no skill.
