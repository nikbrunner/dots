-- Presets for common mappings and autocommands. Options are a no-op here:
-- '10_options/base.lua' is sourced earlier and basics never overrides
-- manually set options (same for already existing mappings).
--
-- Gains:
-- - `\` prefix option toggles (`\w` wrap, `\s` spell, `\h` hlsearch, …)
-- - <C-hjkl> window navigation (overridden later by navigator.nvim, tmux-aware)
-- - <C-arrows> window resize (replaces the old Shift-arrow bindings)
-- - go / gO (add empty lines), gV (reselect), g/ (search in selection)
-- - Autocmds: yank highlight, start Insert mode in terminal

Edit.now(function()
	require("mini.basics").setup({
		options = {
			basic = true,
			-- Extra UI features ('winblend', 'listchars', 'pumheight', ...)
			extra_ui = true,
			-- Presets for window borders ('single', 'double', ...)
			-- Default 'auto' infers from 'winborder' option
			win_borders = "auto",
		},
		mappings = {
			basic = true,
			option_toggle_prefix = [[\]],
			windows = true,
			move_with_alt = false,
		},
		autocommands = {
			basic = true,
		},
	})
end)
