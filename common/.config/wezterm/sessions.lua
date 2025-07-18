local wezterm = require("wezterm") --[[@as Wezterm]]
local mux = wezterm.mux
local workspace_config = require("workspace-config")

local M = {}

-- Initialize global workspace tracking
if not wezterm.GLOBAL.dynamic_workspaces then
	wezterm.GLOBAL.dynamic_workspaces = {}
end

local function workspace_exists(workspace_name)
	local workspaces = mux.get_workspace_names()
	for _, name in ipairs(workspaces) do
		if name == workspace_name then
			return true
		end
	end
	return false
end

local function switch_or_create_workspace(workspace_name, create_function)
	if workspace_exists(workspace_name) then
		mux.set_active_workspace(workspace_name)
	else
		create_function()
	end
end

function M.private_notes_workspace()
	local config = workspace_config.workspaces.private_notes
	local workspace_name = config.name

	local function create_workspace()
		for i, tab_config in ipairs(config.tabs) do
			local tab, pane, window
			if i == 1 then
				tab, pane, window = mux.spawn_window({
					workspace = workspace_name,
					cwd = tab_config.cwd,
				})
			else
				tab, pane = window:spawn_tab({
					cwd = tab_config.cwd,
				})
			end
			tab:set_title(tab_config.title)
			if tab_config.command then
				pane:send_text(tab_config.command)
			end
		end
	end

	switch_or_create_workspace(workspace_name, create_workspace)
end

function M.work_notes_workspace()
	local config = workspace_config.workspaces.work_notes
	local workspace_name = config.name

	local function create_workspace()
		for i, tab_config in ipairs(config.tabs) do
			local tab, pane, window
			if i == 1 then
				tab, pane, window = mux.spawn_window({
					workspace = workspace_name,
					cwd = tab_config.cwd,
				})
			else
				tab, pane = window:spawn_tab({
					cwd = tab_config.cwd,
				})
			end
			tab:set_title(tab_config.title)
			if tab_config.command then
				pane:send_text(tab_config.command)
			end
		end
	end

	switch_or_create_workspace(workspace_name, create_workspace)
end

function M.default_workspace()
	local config = workspace_config.workspaces.default
	local workspace_name = config.name

	local function create_workspace()
		local window
		for i, tab_config in ipairs(config.tabs) do
			local tab, pane
			if i == 1 then
				local spawn_options = {
					workspace = workspace_name,
					cwd = tab_config.cwd,
				}
				if config.position then
					spawn_options.position = config.position
				end
				tab, pane, window = mux.spawn_window(spawn_options)
			else
				tab, pane = window:spawn_tab({
					cwd = tab_config.cwd,
				})
			end
			tab:set_title(tab_config.title)
			if tab_config.command then
				pane:send_text(tab_config.command)
			end
		end

		local gui_window = window:gui_window()
		local active_pane = gui_window:active_pane()
		gui_window:perform_action(wezterm.action.ActivateTab(0), active_pane)
	end

	switch_or_create_workspace(workspace_name, create_workspace)
end

function M.dynamic_workspace_action(slot_number)
	return wezterm.action_callback(function(window, pane)
		local slot_key = "slot_" .. slot_number
		local assigned_workspace = wezterm.GLOBAL.dynamic_workspaces[slot_key]

		if assigned_workspace and workspace_exists(assigned_workspace) then
			mux.set_active_workspace(assigned_workspace)
		else
			local Workspace = require("workspace")

			-- Get projects from sessionizer
			local Sessionizer = require("sessionizer")
			local projects = {}

			-- Use sessionizer's internal getProjects function
			if not wezterm.GLOBAL.projectsCache then
				wezterm.GLOBAL.projectsCache = { timestamp = 0, projects = {} }
			end

			-- Force refresh projects if cache is empty
			if #wezterm.GLOBAL.projectsCache.projects == 0 then
				Sessionizer.refreshCache()
			end

			projects = wezterm.GLOBAL.projectsCache.projects

			window:perform_action(
				wezterm.action.InputSelector({
					action = wezterm.action_callback(function(win, _, id, label)
						if id and label then
							wezterm.GLOBAL.dynamic_workspaces[slot_key] = id
							Workspace.switch(win, pane, { name = id, spawn = { cwd = label } })
						end
					end),
					fuzzy = true,
					title = "Select project for CMD+" .. slot_number,
					choices = projects,
				}),
				pane
			)
		end
	end)
end

return M
