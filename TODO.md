# TODO

## High Priority (Omarchy-Inspired Enhancements)

### Foundation (BLOCKERS)
- [ ] **deps.json/yaml** - Structured package mappings for all platforms (BLOCKS: everything below) - See [plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md](./plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md)
- [ ] **Enhanced deps.sh** - Parse deps.json instead of hardcoded mappings (DEPENDS: deps.json) - See [plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md](./plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md)
- [ ] **User identification system** - Interactive setup for name/email (INDEPENDENT) - See [plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md](./plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md)

### Platform-Specific Installs  
- [ ] **install-macos.sh** - Homebrew-focused installation script (DEPENDS: deps.json) - See [plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md](./plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md)
- [ ] **install-arch.sh** - yay/pacman-focused with Omarchy patterns (DEPENDS: deps.json) - See [plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md](./plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md)
- [ ] **Enhanced install.sh** - Dispatcher to platform scripts (DEPENDS: platform scripts) - See [plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md](./plans/PLATFORM_SPECIFIC_INSTALL_SCRIPTS.md)

### Feature Integration
- [ ] **Migration system** - Timestamped update scripts (INDEPENDENT) - See [plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md](./plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md)
- [ ] **Hyprland/Wayland configs** - Extract snippets from Omarchy (waybar, wofi, hyprlock, hotkeys) (INDEPENDENT) - See [plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md](./plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md)
- [ ] **Web app integration** - Desktop launchers + hotkeys (DEPENDS: platform installs) - See [plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md](./plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md)
- [ ] **Theme system** - Multi-app theme switching (DEPENDS: user identification) - See [plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md](./plans/OMARCHY_ANALYSIS_AND_INSPIRATIONS.md)
- [ ] **Enhanced dots command** - Add theme/webapp/migrate commands (DEPENDS: all features)

## High Priority (Existing)

- [ ] **Fix colorscheme synchronization** - See [plans/COLORSCHEME_SYNC_SOLUTION.md](./plans/COLORSCHEME_SYNC_SOLUTION.md)
- [ ] **Linux** - Setup Wezterm & Multiplexer - See [plans/SIMPLE_MULTIPLEXER_BINDINGS.md](./plans/SIMPLE_MULTIPLEXER_BINDINGS.md)
- [ ] **Linux** - Setup docker
- [ ] Setup fonts
- [ ] Store and set `.zshenv` from macOS

## Medium Priority

- [ ] **Linux:** Setup Wallpaper  
- [ ] **Wezterm** - Clean up OS specific configurations
- [ ] **Enhanced testing framework** - Validate new Omarchy features - See [plans/TESTING_IMPLEMENTATION.md](./plans/TESTING_IMPLEMENTATION.md)  
- [ ] **repos command** - Complete ENSURED_INSTALL workflow

## Low Priority

- [ ] **Performance optimizations** - Speed up symlink operations
- [ ] **Security audit** - Review all scripts for security best practices

## Completed ✅

### Recently Completed
- [x] **Fix `dots status` symlink checking** - Delegated to external script  
- [x] **Fix `dots sync`** - Checks for local changes, offers to update symlinks
- [x] **Add test script** - Comprehensive system validation with `dots test`
- [x] **Colorscheme sync immediate fix** - Use absolute paths in nvim

### Previously Completed  
- [x] Migrate wezterm
- [x] Add `sub-commit` and `sub-status` commands
- [x] Add `format` command
- [x] Implement unified dependency management - See [plans/DEPENDENCY_MANAGEMENT.md](./plans/DEPENDENCY_MANAGEMENT.md)
- [x] Add cross-platform support for macOS/Linux
- [x] Document `~/.ssh` setup
- [x] Make repo public and remove hooks

---

**Next Focus**: Start with `deps.json` as it blocks most Omarchy enhancements.  
**Dependencies**: Items marked with `(DEPENDS: ...)` can't start until dependencies complete.  
**Parallel Work**: Items marked `(INDEPENDENT)` can be worked on simultaneously.
