Edit.pickers = {}

local function get_project_dirs()
	local repos_path = require("config").pathes.repos
	local dirs = {}
	local orgs = vim.fn.readdir(repos_path, function(name)
		return vim.fn.isdirectory(repos_path .. "/" .. name) == 1
	end)
	for _, org in ipairs(orgs) do
		local org_path = repos_path .. "/" .. org
		local projects = vim.fn.readdir(org_path, function(name)
			return vim.fn.isdirectory(org_path .. "/" .. name) == 1
		end)
		for _, project in ipairs(projects) do
			table.insert(dirs, {
				text = org .. "/" .. project,
				path = repos_path .. "/" .. org .. "/" .. project,
			})
		end
	end
	return dirs
end

function _G.Edit.pickers.smart_files()
	local MiniPick = require("mini.pick")
	local MiniVisits = require("mini.visits")
	local cwd = vim.fn.getcwd()
	local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

	local visited = {}
	for _, path in ipairs(MiniVisits.list_paths(cwd)) do
		local rel = vim.fn.fnamemodify(path, ":.")
		if rel ~= current and vim.uv.fs_stat(path) then
			table.insert(visited, rel)
		end
	end

	local visited_set = {}
	for _, f in ipairs(visited) do
		visited_set[f] = true
	end

	local all_files = vim.fn.systemlist({ "rg", "--files", "--hidden", "--glob", "!.git" })
	local unvisited = vim.tbl_filter(function(f)
		return f ~= current and not visited_set[f]
	end, all_files)

	local items = vim.list_extend(vim.deepcopy(visited), unvisited)
	MiniPick.start({
		source = {
			items = items,
			name = "Files",
			choose = function(item)
				local target = MiniPick.get_picker_state().windows.target
				vim.api.nvim_win_call(target, function()
					vim.cmd.edit(item)
				end)
			end,
		},
	})
end

function _G.Edit.pickers.git_changed()
	local MiniPick = require("mini.pick")
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		vim.notify("Not in a git repository", vim.log.levels.ERROR)
		return
	end
	-- Run git from the repo root so `git ls-files` returns paths relative
	-- to the root regardless of the current cwd.
	local items = {}
	for _, f in ipairs(vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_root) .. " ls-files --modified")) do
		table.insert(items, { text = "M " .. f, path = git_root .. "/" .. f, status = "M" })
	end
	for _, f in ipairs(vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_root) .. " ls-files --others --exclude-standard")) do
		table.insert(items, { text = "? " .. f, path = git_root .. "/" .. f, status = "?" })
	end
	if #items == 0 then
		vim.notify("No modified or untracked files", vim.log.levels.INFO)
		return
	end
	MiniPick.start({
		source = {
			items = items,
			name = "Git Changed",
			preview = function(buf_id, item)
				local lines
				if item.status == "M" then
					lines = vim.fn.systemlist("git diff -- " .. vim.fn.shellescape(item.path))
				end
				if not lines or #lines == 0 then
					lines = vim.fn.readfile(item.path)
				end
				vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
			end,
			choose = function(item)
				local target = MiniPick.get_picker_state().windows.target
				vim.api.nvim_win_call(target, function()
					vim.cmd.edit(vim.fn.fnameescape(item.path))
				end)
			end,
		},
	})
end

function _G.Edit.pickers.project_switch()
	local MiniPick = require("mini.pick")
	local get_session_name = require("lib.sessions").get_session_name
	local items = vim.tbl_map(function(d)
		return { text = d.text, path = d.path }
	end, get_project_dirs())

	MiniPick.start({
		source = {
			items = items,
			name = "Switch Project",
			choose = function(item)
				vim.schedule(function()
					local MS = require("mini.sessions")
					vim.g._mini_session_switching = true
					MS.write(get_session_name(), { force = true })
					vim.iter(vim.lsp.get_clients()):each(function(c)
						c:stop(true)
					end)
					vim.cmd("silent! %bwipeout!")
					vim.fn.chdir(item.path)
					local target_session = get_session_name(item.path)
					if MS.detected[target_session] then
						local data = MS.detected[target_session]
						vim.cmd(("silent! source %s"):format(vim.fn.fnameescape(data.path)))
						vim.v.this_session = data.path
					else
						vim.cmd.enew()
						vim.notify("Switched to " .. item.text .. " (no session)")
					end
					vim.g._mini_session_switching = false
				end)
			end,
		},
	})
end

function _G.Edit.pickers.worktree_switch()
	local MiniPick = require("mini.pick")
	local git_root = vim.fs.root(0, ".git")
	if not git_root then
		vim.notify("Not in a git repository", vim.log.levels.ERROR)
		return
	end
	local worktrees = require("lib.git").get_worktrees(git_root)
	if #worktrees == 0 then
		vim.notify("No worktrees found", vim.log.levels.WARN)
		return
	end
	local cwd = vim.fn.getcwd()
	local items = vim.tbl_map(
		function(wt)
			return { text = wt.display, path = wt.path, branch = wt.branch, is_main = wt.is_main }
		end,
		vim.tbl_filter(function(wt)
			return wt.path ~= cwd
		end, worktrees)
	)
	if #items == 0 then
		vim.notify("Already on the only worktree", vim.log.levels.INFO)
		return
	end
	MiniPick.start({
		source = {
			items = items,
			name = "Worktrees",
			choose = function(item)
				vim.schedule(function()
					vim.g._mini_session_switching = true
					vim.fn.chdir(item.path)
					vim.g._mini_session_switching = false
					local label = item.is_main and "main" or item.branch
					vim.notify("Switched to " .. label .. " (" .. item.path .. ")", vim.log.levels.INFO)
				end)
			end,
		},
	})
end

function _G.Edit.pickers.associated_files()
	local MiniPick = require("mini.pick")
	local current_filename = vim.fn.expand("%:t:r")
	local base_name = current_filename:match("^([^.]+)") or current_filename
	local current_path = vim.fn.expand("%:.")
	local items = vim.tbl_filter(function(f)
		return f ~= current_path
	end, vim.fn.systemlist({ "rg", "--files", "--glob", "**/" .. base_name .. ".*" }))
	if #items == 0 then
		vim.notify("No associated files found", vim.log.levels.INFO)
		return
	end
	MiniPick.start({ source = { items = items, name = "Associated Files" } })
end

function _G.Edit.pickers.buffer_jumps()
	local MiniPick = require("mini.pick")
	local current_buf = vim.api.nvim_get_current_buf()
	local jumps = vim.fn.getjumplist()[1]
	local items = {}
	for _, jump in ipairs(jumps) do
		local buf = jump.bufnr and vim.api.nvim_buf_is_valid(jump.bufnr) and jump.bufnr or 0
		if buf == current_buf and jump.lnum > 0 then
			local lines = vim.api.nvim_buf_get_lines(buf, jump.lnum - 1, jump.lnum, false)
			table.insert(items, 1, {
				text = string.format("%d: %s", jump.lnum, vim.trim(lines[1] or "")),
				lnum = jump.lnum,
				col = jump.col,
			})
		end
	end
	if #items == 0 then
		vim.notify("No jumps in current buffer", vim.log.levels.INFO)
		return
	end
	MiniPick.start({
		source = {
			items = items,
			name = "Buffer Jumps",
			choose = function(item)
				vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
			end,
		},
	})
end
