---@diagnostic disable: unused-local
local wezterm = require("wezterm")
local action = wezterm.action
local Sessionizer = require("sessionizer")
local Workspace = require("workspace")
local sessions = require("sessions")
local TabSwitcher = require("tab-switcher")
local Util = require("util")
local mux = wezterm.mux

local function isViProcess(pane)
	return pane:get_foreground_process_name():find("n?vim") ~= nil
end

local function isLazyGitProcess(pane)
	return pane:get_foreground_process_name():find("lazygit") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
	local vim_pane_changed = false

	if isViProcess(pane) or isLazyGitProcess(pane) then
		local before = pane:get_cursor_position()
		window:perform_action(
			-- This should match the keybinds you set in Neovim.
			action.SendKey({ key = vim_direction, mods = "CTRL" }),
			pane
		)
		wezterm.sleep_ms(100)
		local after = pane:get_cursor_position()

		if before.x ~= after.x and before.y ~= after.y then
			vim_pane_changed = true
		end
	end

	if not vim_pane_changed then
		window:perform_action(action.ActivatePaneDirection(pane_direction), pane)
	end
end

-- Register event handlers for vim-aware navigation
wezterm.on("ActivatePaneDirection-right", function(window, pane)
	conditionalActivatePane(window, pane, "Right", "l")
end)
wezterm.on("ActivatePaneDirection-left", function(window, pane)
	conditionalActivatePane(window, pane, "Left", "h")
end)
wezterm.on("ActivatePaneDirection-up", function(window, pane)
	conditionalActivatePane(window, pane, "Up", "k")
end)
wezterm.on("ActivatePaneDirection-down", function(window, pane)
	conditionalActivatePane(window, pane, "Down", "j")
end)

-- Return multiplexer keybindings
return {
	-- Direct workspace access (universal)
	{
		key = "0",
		mods = "LEADER",
		action = wezterm.action_callback(function()
			sessions.default_workspace()
		end),
	},
	{
		key = "1",
		mods = "LEADER",
		action = wezterm.action_callback(function()
			sessions.private_notes_workspace()
		end),
	},
	{
		key = "2",
		mods = "LEADER",
		action = wezterm.action_callback(function()
			sessions.work_notes_workspace()
		end),
	},
	{ key = "3", mods = "LEADER", action = sessions.dynamic_workspace_action(3) },
	{ key = "4", mods = "LEADER", action = sessions.dynamic_workspace_action(4) },
	{ key = "5", mods = "LEADER", action = sessions.dynamic_workspace_action(5) },
	{ key = "6", mods = "LEADER", action = sessions.dynamic_workspace_action(6) },
	{ key = "7", mods = "LEADER", action = sessions.dynamic_workspace_action(7) },
	{ key = "8", mods = "LEADER", action = sessions.dynamic_workspace_action(8) },
	{ key = "9", mods = "LEADER", action = sessions.dynamic_workspace_action(9) },

	-- Workspace Management
	-- macOS direct access (optional enhancement)
	{
		key = "0",
		mods = "CMD",
		action = wezterm.action_callback(function()
			sessions.default_workspace()
		end),
	},
	{
		key = "1",
		mods = "CMD",
		action = wezterm.action_callback(function()
			sessions.private_notes_workspace()
		end),
	},
	{
		key = "2",
		mods = "CMD",
		action = wezterm.action_callback(function()
			sessions.work_notes_workspace()
		end),
	},
	{ key = "3", mods = "CMD", action = sessions.dynamic_workspace_action(3) },
	{ key = "4", mods = "CMD", action = sessions.dynamic_workspace_action(4) },
	{ key = "5", mods = "CMD", action = sessions.dynamic_workspace_action(5) },
	{ key = "6", mods = "CMD", action = sessions.dynamic_workspace_action(6) },
	{ key = "7", mods = "CMD", action = sessions.dynamic_workspace_action(7) },
	{ key = "8", mods = "CMD", action = sessions.dynamic_workspace_action(8) },
	{ key = "9", mods = "CMD", action = sessions.dynamic_workspace_action(9) },

	-- Projects & Workspaces
	{ key = "s", mods = "ALT", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "s",
		mods = "ALT|SHIFT",
		action = wezterm.action_callback(function(win, pane)
			Sessionizer.toggle(win, pane)
			Sessionizer.refreshCache()
		end),
	},
	{
		key = "e",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			TabSwitcher.switch_tab(window, pane)
		end),
	},
	{
		key = "o",
		mods = "ALT",
		action = wezterm.action_callback(function(window, pane)
			Workspace.switch_to_previous(window, pane)
		end),
	},

	-- Tabs, Splits & Windows
	{ key = "r", mods = "ALT", action = action.ShowTabNavigator },
	{
		key = "n",
		mods = "LEADER",
		action = action.PromptInputLine({
			description = "Enter new name for tab",
			---@diagnostic disable-next-line: unused-local
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "N",
		mods = "LEADER",
		action = action.PromptInputLine({
			description = "Enter new name for Workspace",
			---@diagnostic disable-next-line: unused-local
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},

	-- Tab Management
	{ key = "1", mods = "ALT", action = action.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = action.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = action.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = action.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = action.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = action.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = action.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = action.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = action.ActivateTab(8) },
	{ key = "h", mods = "ALT", action = action({ ActivateTabRelative = -1 }) },
	{ key = "l", mods = "ALT", action = action({ ActivateTabRelative = 1 }) },
	{ key = "c", mods = "ALT", action = action.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "ALT", action = action.CloseCurrentTab({ confirm = true }) },
	{ key = ",", mods = "ALT", action = action.MoveTabRelative(-1) },
	{ key = ".", mods = "ALT", action = action.MoveTabRelative(1) },

	-- Workspace Navigation
	{ key = "j", mods = "ALT", action = action.SwitchWorkspaceRelative(-1) },
	{ key = "k", mods = "ALT", action = action.SwitchWorkspaceRelative(1) },

	-- Application Integration (CTRL - vim navigation)
	{ key = "h", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-left") },
	{ key = "j", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-down") },
	{ key = "k", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-up") },
	{ key = "l", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-right") },

	-- Pane Management (Splits)
	{ key = "l", mods = "ALT|SHIFT", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "j", mods = "ALT|SHIFT", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "z", mods = "ALT|SHIFT", action = action.TogglePaneZoomState },
	{ key = "x", mods = "ALT|SHIFT", action = action.CloseCurrentPane({ confirm = true }) },

	-- Pane Resizing (Alt+Shift+Arrow keys, consistent with splits)
	{ key = "LeftArrow", mods = "ALT|SHIFT", action = action.AdjustPaneSize({ "Left", 10 }) },
	{ key = "DownArrow", mods = "ALT|SHIFT", action = action.AdjustPaneSize({ "Down", 10 }) },
	{ key = "UpArrow", mods = "ALT|SHIFT", action = action.AdjustPaneSize({ "Up", 10 }) },
	{ key = "RightArrow", mods = "ALT|SHIFT", action = action.AdjustPaneSize({ "Right", 10 }) },

	-- LazyGit in new window (multiplexer feature)
	{
		key = "g",
		mods = "ALT",
		action = wezterm.action_callback(function(gui_win, gui_pane)
			local screens = wezterm.gui.screens()
			local active_screen = screens.active
			local tab, pane, window = mux.spawn_window({
				args = { os.getenv("SHELL"), "-c", "lazygit" },
				cwd = Util.get_cwd_from_pane(gui_pane),
				position = {
					origin = "MainScreen",
					x = active_screen.x,
					y = active_screen.y,
					height = active_screen.height,
					width = active_screen.width,
				},
			})
		end),
	},
}