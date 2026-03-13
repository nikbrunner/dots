# TODO

- [x] Add command `dots git-chores` that cleans up git chores `common/.claude/commands/dots/git-chores.md` `common/.claude/commands/dots/git-status-cleanup.md` 
  - The goal would be that its not necessary to start claude first
- [x] `dots mcp` - simplified to 4 direct commands in scripts/claude-mcp.sh
- [x] Make `dots` print help menu faster
- [ ] Clean out un-used `dots` commands
  - [x] Remove all `sub-*` commands
  - [x] Remove `dots sync` command (superseded by `dots pull`)
  - [x] Resolve `repo` command — replaced by `brick`
- [ ] Command or functionality to clean up backup files created by `dots link`
- [ ] Remove outdated links
- [ ] Remove outdated bins
- [ ] Update README.md (stale command table, remove `repos` references, remove submodules section)
- [ ] Use [chezmoi](https://www.chezmoi.io/) under the hood?
- [ ] Reorganize `dots` scripts into multipe files in a dedicated `scripts/dots` directory
