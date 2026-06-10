-- Open related component files (tsx + scss + story) side by side.
-- Keymap: gC opens the component under the cursor.

---@class component-nvim.Config
---@field projects component-nvim.Project[]

---@class component-nvim.Project
---@field root_folder string
---@field recognition_pattern string
---@field extensions string[]

---@type component-nvim.Config
local config = {
	projects = {
		{
			root_folder = "bc-desktop-client",
			recognition_pattern = "src/*/**/*components/**/*.tsx",
			extensions = { "tsx", "scss", "story.tsx" },
		},
	},
}

local function close_all_windows_except_current()
	local current_win = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if win ~= current_win then
			vim.api.nvim_win_close(win, true)
		end
	end
end

---@param str string
local function trim_newline(str)
	return (str:gsub("\n", ""))
end

---Get the current project configuration based on the project path.
---@param projects component-nvim.Project[]
---@return component-nvim.Project | nil
local function get_current_project_config(projects)
	local current_working_dir = vim.fn.system("git rev-parse --show-toplevel")

	if current_working_dir == "" then
		vim.notify("No git repository found")
		return nil
	end

	local project_folder = vim.fn.fnamemodify(trim_newline(current_working_dir), ":t")

	for _, project in ipairs(projects) do
		if project.root_folder == project_folder then
			return project
		end
	end

	vim.notify("No matching project config found")
	return nil
end

---@param extension string
---@param name string
local function find_files_by_extension_and_name(extension, name)
	local file_path = vim.fn.system(string.format("rg --files --hidden --glob '%s.%s'", name, extension))
	return trim_newline(file_path)
end

---@param component_name string
---@param extensions string[]
local function open_files_by_type(component_name, extensions)
	local all_wins
	local first_file = true

	for _, ext in ipairs(extensions) do
		local file_path = find_files_by_extension_and_name(ext, component_name)

		if file_path ~= "" then
			if first_file then
				vim.cmd(string.format("edit %s", file_path))
				first_file = false
			else
				vim.cmd(string.format("vsplit %s", file_path))
			end
		end

		all_wins = vim.api.nvim_tabpage_list_wins(0)
	end

	if #all_wins > 0 then
		vim.api.nvim_set_current_win(all_wins[1])
	end
end

---Find and open a component file under the cursor.
---@param component_name? string
local function find_and_open_component_file(component_name)
	component_name = component_name or vim.fn.expand("<cword>")

	local project_config = get_current_project_config(config.projects)

	if not project_config then
		return
	end

	if not component_name then
		vim.notify("No component name found")
		return
	end

	for _, ext in ipairs(project_config.extensions) do
		local path = find_files_by_extension_and_name(ext, component_name)

		if path ~= "" then
			vim.ui.select({ "No", "Yes" }, { prompt = "Open component in a new tab?" }, function(choice)
				if choice == "Yes" then
					vim.cmd.tabnew()
				else
					close_all_windows_except_current()
				end
				open_files_by_type(component_name, project_config.extensions)
			end)

			return
		end
	end

	vim.notify("No component found for " .. component_name)
end

vim.keymap.set("n", "gC", function()
	find_and_open_component_file()
end, { desc = "Component under cursor" })
