# Skills

Global agent skills, linked to `~/.claude/skills` and `~/.claude-work/skills`, and read by Pi through `~/.agents/skills`.
Neither agent loads this file: Claude Code reads `*/SKILL.md`, and Pi ignores root `.md` files here.

Skills Nik wrote carry the `nbr-` prefix, and each `name` matches its directory. Everything else is installed:
`../.skill-lock.json` records the source of each one, and `npx skills update` refreshes them. `imfg-*` link to the ImFusion
agents repo; `tldraw-offline` and `terminal-browser` belong to their apps.

## Map

Arrows are references written in the skill files.

```
REPO CONVENTIONS
  nbr-repo-conventions  knowledge: typescript · react · css · state · tanstack · validation ·
                        authentication · testing · assets · tooling · npm-project · git ·
                        docs-structure · agent-tooling · workflow · dependencies
    templates/AUDIT_CHECKLIST.md · templates/REPORT.md
          ▲ reads                         ▲ runs against
  nbr-repo-setup [topic]                nbr-repo-audit [topic] [path]   read-only, git/gh queries
    agent-tooling · npm-project · git     workflow drift ──compares──▶ nbr-repo-setup/templates
    workflow ──generates──▶ repo-commit · repo-changelog · repo-release · release-please
    docs-structure
    dependencies ─generates─▶ repo-dep-upgrades
  nbr-glossary                 GLOSSARY.md from the conversation

COMMIT
  nbr-git-commit-rebuild   history → dirty tree: target, backup, reset, verify
          │ hands the tree to
  nbr-git-commit-buckets   dirty tree → buckets, one report and one gate
          │ per bucket, reads Conventions · Review · Commit of
  nbr-git-commit           one commit: review ─▶ gate ─▶ commit
          ├──runs────▶ nbr-audit-docs   --staged · --worktree
          └──reads───▶ repo conventions, per field: project *-commit skill ·
                       AGENTS.md · tool config · git log
  nbr-create-pr            PR description: slice title, nested bullets, tests, how to test

SESSION AND AGENTS
  nbr-plan                 grill ─▶ optional docs ─▶ plan shape ─▶ humanizer ─▶ Plannotator
                           ▲ the plan-mode hook (~/.plannotator/hooks/compound) points here
  nbr-handoff              handoff doc in <worktree>/handoffs/
  nbr-dispatch             fresh agent in a Herdr workspace
  nbr-afk-implementation   finish approved work while Nik is away
  nbr-slow-mode            learning first, speed second
  nbr-self-reflection

TOOLS
  nbr-how-to-test          HOW_TO_TEST.md acceptance checklist
  nbr-nvim                 Neovim and Lua workflow
  nbr-record-clip          animated WebP clips: terminal · browser · native
  nbr-things               Things 3 tasks
  nbr-changelog-things     today's work logged as Things items
```

## Adding a skill

Use the installed `skill-creator` and `writing-for-agents` skills. A personal skill gets the `nbr-` prefix; a new convention
is a topic in `nbr-repo-conventions` with a block in its `AUDIT_CHECKLIST.md`, not a new skill. Update the map when a skill or an
arrow changes.
