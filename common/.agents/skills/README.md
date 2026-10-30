# Skills

Global agent skills, read by Pi through `~/.agents/skills`. The `install.sh` of nikbrunner/skills links `~/.claude/skills`
and `~/.claude-work/skills` here.
Neither agent loads this file: Claude Code reads `*/SKILL.md`, and Pi ignores root `.md` files here.

Skills Nik wrote carry the `nbr-` prefix, and each `name` matches its directory. They and the third-party skills they build
on live in [nikbrunner/skills](https://github.com/nikbrunner/skills): its `skills-lock.json` records each third-party
source, and its `install.sh` restores them and links everything in here. `plannotator-*` come from the Plannotator
installer, and `imfg-*` link to the ImFusion agents repo; `tldraw-offline` and `terminal-browser` belong to their apps.

## Map

The map of how the skills call each other lives in the [nikbrunner/skills README](https://github.com/nikbrunner/skills#how-they-work-together).

## Adding a skill

Use the installed `skill-creator` and `writing-for-agents` skills. A personal skill gets the `nbr-` prefix; a new convention
is a topic in `nbr-repo-conventions` with a block in its `AUDIT_CHECKLIST.md`, not a new skill. Update that map when a skill or an
arrow changes.
