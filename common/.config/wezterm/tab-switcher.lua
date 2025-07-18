local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

-- Get all tabs across all windows and workspaces
local function get_all_tabs()
	local tabs = {}

	-- Get all windows
	local windows = mux.all_windows()

	for _, window in ipairs(windows) do
		local window_id = window:window_id()
		local workspace = window:get_workspace() or "default"
		local window_tabs = window:tabs()

		for tab_idx, tab in ipairs(window_tabs) do
			local tab_id = tab:tab_id()
			local title = tab:get_title()
			-- Fallback for unnamed tabs
			if title == "" or title == nil then
				title = "Unnamed"
			end

			-- Get pane information for additional context
			local panes = tab:panes()
			local pane_info = ""
			if #panes > 1 then
				pane_info = string.format(" (%d panes)", #panes)
			end

			-- Create label with workspace and window context
			-- tab_idx is 1-indexed already from the loop
			local label = string.format("[%s] %d: %s%s", workspace, tab_idx, title, pane_info)

			table.insert(tabs, {
				id = string.format("%d:%d:%d", window_id, tab_id, tab_idx),
				label = label,
			})
		end
	end

	-- Sort by label
	table.sort(tabs, function(a, b)
		return a.label < b.label
	end)

	return tabs
end

-- Switch to selected tab
function M.switch_tab(window, pane)
	local tabs = get_all_tabs()

	if #tabs == 0 then
		window:toast_notification("Tab Switcher", "No tabs found")
		return
	end

	window:perform_action(
		wezterm.action.InputSelector({
			action = wezterm.action_callback(function(win, _, id, label)
				if not id then
					wezterm.log_info("Tab switch cancelled")
					return
				end

				-- Parse the id to get window_id, tab_id, and tab_idx
				local window_id, tab_id, tab_idx = id:match("(%d+):(%d+):(%d+)")
				window_id = tonumber(window_id)
				tab_id = tonumber(tab_id)
				tab_idx = tonumber(tab_idx)

				if not window_id or not tab_id or not tab_idx then
					wezterm.log_error("Invalid tab id format: " .. id)
					return
				end

				-- Find the window and tab
				local target_window = nil
				local target_tab = nil

				for _, w in ipairs(mux.all_windows()) do
					if w:window_id() == window_id then
						target_window = w
						local window_tabs = w:tabs()
						for _, t in ipairs(window_tabs) do
							if t:tab_id() == tab_id then
								target_tab = t
								break
							end
						end
						break
					end
				end

				if target_window and target_tab then
					-- Get the workspace of the target window
					local target_workspace = target_window:get_workspace()

					-- Switch to the workspace first
					if target_workspace then
						mux.set_active_workspace(target_workspace)
					end

					-- Wait a bit for the workspace switch to complete
					wezterm.sleep_ms(50)

					-- Get the gui window and activate the tab
					local gui_window = target_window:gui_window()
					if gui_window then
						-- Focus the window by activating its current tab first
						-- This ensures the window is focused
						local current_active_tab = target_window:active_tab()
						if current_active_tab then
							local current_idx = 0
							for i, t in ipairs(target_window:tabs()) do
								if t:tab_id() == current_active_tab:tab_id() then
									current_idx = i - 1
									break
								end
							end
							gui_window:perform_action(wezterm.action.ActivateTab(current_idx), gui_window:active_pane())
						end

						-- Now activate the target tab
						gui_window:perform_action(
							wezterm.action.ActivateTab(tab_idx - 1), -- Convert back to 0-indexed
							gui_window:active_pane()
						)

						window:toast_notification("Tab Switcher", "Switched to " .. label)
					else
						wezterm.log_error("Could not get GUI window for window id: " .. window_id)
					end
				else
					wezterm.log_error("Could not find tab with id: " .. id)
				end
			end),
			fuzzy = true,
			fuzzy_description = "Search tabs: ",
			title = "Tab Switcher",
			choices = tabs,
		}),
		pane
	)
end

return M

