local Wezterm = require("wezterm")

-- Source: https://github.com/tjex/wezterm-conf/blob/main/functions/funcs.lua#L79
local M = {}

function M.switch(window, pane, workspace)
	if type(workspace) == "string" then
		workspace = { name = workspace }
	end

	local current_workspace = window:active_workspace()

	if current_workspace == workspace.name then
		return
	end

	-- Update the previous workspace variable before switching
	Wezterm.GLOBAL.previous_workspace = current_workspace

	window:perform_action(Wezterm.action.SwitchToWorkspace(workspace), pane)
end

function M.switch_to_previous(window, pane)
	local current_workspace = window:active_workspace()
	local workspace = Wezterm.GLOBAL.previous_workspace

	-- Initialize previous_workspace if it doesn't exist
	if Wezterm.GLOBAL.previous_workspace == nil then
		Wezterm.GLOBAL.previous_workspace = current_workspace
		Wezterm.log_info("No previous workspace to switch to - initializing with current workspace")
		return
	end

	if current_workspace == workspace then
		Wezterm.log_info("Already in the target workspace")
		return
	end

	M.switch(window, pane, workspace)
end

return M
