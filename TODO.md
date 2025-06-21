# TODO

## High Priority

- [x] **Fix `dots status` symlink checking** - Fixed by delegating to external script like `link.sh`
- [ ] **Refactor `dots` command** - See [docs/DOTS_COMMAND_REFACTOR.md](./docs/DOTS_COMMAND_REFACTOR.md)
- [ ] **Add test script** - Comprehensive system validation script
- [ ] **Test complete Linux setup on EndeavorOS** - Validate cross-platform functionality

## Medium Priority

- [ ] **Implement enhanced testing framework** - More comprehensive validation
- [ ] **Add configuration backup/restore functionality** - Safety features for dotfiles management
- [ ] **Improve error handling and user feedback** - Better UX for failed operations
- [ ] **Add configuration templates** - Quick setup for common tools

## Low Priority

- [ ] **Performance optimizations** - Speed up symlink operations for large configurations
- [ ] **Extended platform support** - Ubuntu/Debian, CentOS/RHEL support
- [ ] **Integration with cloud sync** - Backup strategy configuration
- [ ] **Advanced logging and monitoring** - Detailed operation tracking

## Research & Investigation

- [ ] **Investigate `dots status` hanging issue** - Deep dive into execution context differences
- [ ] **Evaluate alternative symlink management approaches** - Potential architectural improvements
- [ ] **Security audit** - Review all scripts for security best practices

## Completed ✅

- [x] Migrate wezterm
- [x] Remove `*backup` files
- [x] Archive old dotfiles
- [x] Make this repo public
- [x] Remove hooks
- [x] Add `sub-commit` command
- [x] Add `sub-status` command
- [x] Add `format` command
- [x] Standardize bash across all scripts
- [x] Implement unified dependency management (see [docs/DEPENDENCY_MANAGEMENT.md](./docs/DEPENDENCY_MANAGEMENT.md))
- [x] Implement repos cleanup workflow
- [x] Verify that install script is working
- [x] Document `~/.ssh` setup (see [docs/SSH_SETUP.md](./docs/SSH_SETUP.md))
- [x] Add cross-platform support for macOS/Linux (OS detection, package managers)

---

*This file tracks all pending tasks and improvements for the dotfiles system. Items are prioritized by impact and urgency.*