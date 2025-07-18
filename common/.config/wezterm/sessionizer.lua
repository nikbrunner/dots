local Wezterm = require("wezterm")
local Workspace = require("workspace")

local M = {}

local fd = "/opt/homebrew/bin/fd"
local reposPath = "/Users/nbr/repos/"
local cacheLifetime = 3600 -- Cache lifetime in seconds (1 hour)

-- Initialize the cache in GLOBAL if it doesn't exist
if not Wezterm.GLOBAL.projectsCache then
	Wezterm.GLOBAL.projectsCache = {
		timestamp = 0,
		projects = {},
	}
end

local function getProjects()
	-- Check if cache is still valid
	if os.time() - Wezterm.GLOBAL.projectsCache.timestamp < cacheLifetime then
		return Wezterm.GLOBAL.projectsCache.projects
	end

	local projects = {
		{
			label = "/Users/nbr/.config",
			id = "Config",
		},
	}

	local success, stdout, stderr = Wezterm.run_child_process({
		fd,
		"-HI",
		"-td",
		"^.git$",
		"--max-depth=4",
		"--prune",
		reposPath,
		-- add more paths here
	})

	if not success then
		Wezterm.log_error("Failed to run fd: " .. stderr)
		return projects
	end

	for line in stdout:gmatch("([^\n]*)\n?") do
		local project = line:gsub("/.git/$", "")
		local label = project

		-- Extract the organization and repository name
		local relativePath = project:sub(#reposPath + 1) -- Get the part of the path relative to reposPath
		local id = relativePath:gsub("/", "/") -- Format the id as "org/repo"

		table.insert(projects, { label = tostring(label), id = tostring(id) })
	end

	Wezterm.GLOBAL.projectsCache.timestamp = os.time()
	Wezterm.GLOBAL.projectsCache.projects = projects

	return projects
end

M.toggle = function(window, pane)
	getProjects()

	Wezterm.GLOBAL.previous_workspace = window:active_workspace()

	window:perform_action(
		Wezterm.action.InputSelector({
			action = Wezterm.action_callback(function(win, _, id, label)
				if not id and not label then
					Wezterm.log_info("Cancelled")
					window:toast_notification("Sessionizer", "Cancelled")
				else
					Wezterm.log_info("Selected " .. label)
					window:toast_notification("Sessionizer", "Switched to " .. label)
					Workspace.switch(win, pane, { name = id, spawn = { cwd = label } })
				end
			end),
			fuzzy = true,
			title = "Select project",
			choices = Wezterm.GLOBAL.projectsCache.projects,
		}),
		pane
	)
end

M.refreshCache = function()
	Wezterm.GLOBAL.projectsCache.timestamp = 0
	getProjects()
	Wezterm.log_info("Projects cache refreshed manually")
end

return M
