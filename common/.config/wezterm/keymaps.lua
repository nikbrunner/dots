---@diagnostic disable: unused-local
local FontUtil = require("font-util")
local ColorSchemeUtil = require("colorscheme-util")

return function(wezterm, config)
	local action = wezterm.action

	config.bypass_mouse_reporting_modifiers = "CMD"

	config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 1000 }

	-- Non-multiplexer keybindings
	config.keys = {
		{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
		{ key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen },

		-- Leader key actions
		{ key = "f", mods = "LEADER", action = FontUtil.selector_action() },
		{ key = "t", mods = "LEADER", action = ColorSchemeUtil.selector_action() },

		-- Additional Leader actions
		{ key = "r", mods = "LEADER", action = action.ReloadConfiguration },
		{ key = "?", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "FUZZY|KEY_ASSIGNMENTS" }) },

		-- System Level
		{ key = ";", mods = "CMD", action = action.ActivateCommandPalette },
		{ key = "f", mods = "CMD", action = action.Search({ CaseSensitiveString = "" }) },
		{ key = "Escape", mods = "ALT", action = action.ActivateCopyMode },
		{ key = "d", mods = "ALT", action = action.ShowDebugOverlay },
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = action.Multiple({
				action.ClearScrollback("ScrollbackAndViewport"),
				action.SendKey({ key = "L", mods = "CTRL" }),
			}),
		},

		-- Emoji Picker
		{
			key = "u",
			mods = "SHIFT|CTRL",
			action = action.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
		},
	}

	-- Multiplexer bindings (comment out when using tmux as multiplexer)
	-- local multiplexer_keys = require("keymaps-multiplexer")
	-- for _, key in ipairs(multiplexer_keys) do
	-- 	table.insert(config.keys, key)
	-- end
	-- When using tmux: comment out the above 3 lines
end
