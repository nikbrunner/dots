# Skills

Global agent skills, linked to `~/.claude/skills` and `~/.claude-work/skills`, and read by Pi through `~/.agents/skills`.
Neither agent loads this file: Claude Code reads `*/SKILL.md`, and Pi ignores root `.md` files here.

Skills Nik wrote carry the `nbr-` prefix, and each `name` matches its directory. Everything else is installed:
`../.skill-lock.json` records the source of each one, and `npx skills update` refreshes them. `imfg-*` link to the ImFusion
agents repo; `tldraw-offline` and `terminal-browser` belong to their apps.

## Map

Arrows are references written in the skill files.

```
PROJECT SETUP
  nbr-workflow-kit  setup | audit
    0 agent setup ───reads───▶ nbr-conventions › agent-tooling
    1 hooks ─────delegates───▶ nbr-git-hooks
    2 skills ────generates───▶ <prefix>-commit · <prefix>-changelog · <prefix>-release
    3 pipeline                 release-please · release.yml · CHANGELOG.md
  nbr-glossary                 GLOSSARY.md from the conversation
  nbr-dep-upgrade-skill ─generates─▶ <project> dep-upgrades skill

CONVENTIONS
  nbr-conventions   knowledge: typescript · react · css · state · tanstack · agent-tooling
    templates/AUDIT_CHECKLIST.md · templates/REPORT.md
          ▲ runs against
  nbr-audit         read-only, [full|<topic>] [path]

COMMIT
  nbr-git-clean ──▶ nbr-commit ──▶ nbr-audit-docs
                    defers to a project <prefix>-commit when one exists
  nbr-create-pr            PR description: slice title, nested bullets, tests, how to test

SESSION AND AGENTS
  nbr-handoff              handoff doc in <worktree>/handoffs/
  nbr-dispatch             fresh agent in a Herdr workspace
  nbr-afk-implementation   finish approved work while Nik is away
  nbr-slow-mode            learning first, speed second
  nbr-self-reflection

TOOLS
  nbr-how-to-test          HOW_TO_TEST.md acceptance checklist
  nbr-nvim                 Neovim and Lua workflow
  nbr-things               Things 3 tasks
  nbr-changelog-things     today's work logged as Things items
```

## Adding a skill

Use the installed `skill-creator` and `writing-for-agents` skills. A personal skill gets the `nbr-` prefix; a new convention
is a topic in `nbr-conventions` with a block in its `AUDIT_CHECKLIST.md`, not a new skill. Update the map when a skill or an
arrow changes.
