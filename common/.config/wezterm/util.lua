local M = {}

--- Get current cwd from active pane
---Expect PaneInformation https://wezfurlong.org/wezterm/config/lua/PaneInformation.html
---@see https://wezfurlong.org/wezterm/config/lua/pane/get_current_working_dir.html
---@see https://wezfurlong.org/wezterm/config/lua/wezterm.url/Url.html
---@return string
function M.get_cwd_from_pane(pane)
	return pane:get_current_working_dir().path
end

return M
