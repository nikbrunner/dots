-- Custom pickers with no stock Snacks source: frecency-aware smart files,
-- project/worktree switching, related documents, and buffer jump history.
-- Backed by Snacks.picker.pick. (git_status uses the builtin source.)

local function get_project_dirs()
	local repos_path = vim.fn.expand("~/repos")
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

local function smart_files_finder(opts, _ctx)
	local MiniVisits = require("mini.visits")
	local cwd = vim.fn.getcwd()
	local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

	local rg_args = { "rg", "--files", "--glob", "!.git" }
	if opts.hidden then
		table.insert(rg_args, "--hidden")
	end
	if opts.ignored then
		table.insert(rg_args, "--no-ignore")
	end
	if opts.follow then
		table.insert(rg_args, "-L")
	end

	local visited, visited_set = {}, {}
	for _, path in ipairs(MiniVisits.list_paths(cwd)) do
		local rel = vim.fn.fnamemodify(path, ":.")
		if rel ~= current and vim.uv.fs_stat(path) then
			visited[#visited + 1] = rel
			visited_set[rel] = true
		end
	end

	local unvisited = vim.tbl_filter(function(f)
		return f ~= current and not visited_set[f]
	end, vim.fn.systemlist(rg_args))

	local files = vim.list_extend(vim.deepcopy(visited), unvisited)
	local items = {}
	for idx, f in ipairs(files) do
		items[#items + 1] = { text = f, file = f, idx = idx }
	end
	return items
end

local function smart_files()
	Snacks.picker.pick({
		source = "smart_files",
		finder = smart_files_finder,
		format = "file",
		title = "Files",
		hidden = true,
	})
end

local function project_switch()
	local get_session_name = require("lib.sessions").get_session_name
	local items = {}
	for idx, d in ipairs(get_project_dirs()) do
		items[#items + 1] = { text = d.text, path = d.path, idx = idx }
	end

	Snacks.picker.pick({
		source = "project_switch",
		items = items,
		title = "Switch Project",
		confirm = function(picker, item)
			picker:close()
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
	})
end

local function worktree_switch()
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
	local items = {}
	local idx = 0
	for _, wt in ipairs(worktrees) do
		if wt.path ~= cwd then
			idx = idx + 1
			items[#items + 1] =
				{ text = wt.display, path = wt.path, branch = wt.branch, is_main = wt.is_main, idx = idx }
		end
	end
	if #items == 0 then
		vim.notify("Already on the only worktree", vim.log.levels.INFO)
		return
	end
	Snacks.picker.pick({
		source = "worktree_switch",
		items = items,
		title = "Worktrees",
		confirm = function(picker, item)
			picker:close()
			vim.schedule(function()
				vim.g._mini_session_switching = true
				vim.fn.chdir(item.path)
				vim.g._mini_session_switching = false
				local label = item.is_main and "main" or item.branch
				vim.notify("Switched to " .. label .. " (" .. item.path .. ")", vim.log.levels.INFO)
			end)
		end,
	})
end

local function related_documents()
	local current_filename = vim.fn.expand("%:t:r")
	local base_name = current_filename:match("^([^.]+)") or current_filename
	local current_path = vim.fn.expand("%:.")
	local current_dir = vim.fn.fnamemodify(current_path, ":h")
	local files = vim.tbl_filter(function(f)
		return f ~= current_path
	end, vim.fn.systemlist({ "rg", "--files", "--glob", "**/" .. base_name .. ".*" }))
	if #files == 0 then
		vim.notify("No associated files found", vim.log.levels.INFO)
		return
	end
	table.sort(files, function(a, b)
		local a_colocated = vim.fn.fnamemodify(a, ":h") == current_dir
		local b_colocated = vim.fn.fnamemodify(b, ":h") == current_dir
		if a_colocated ~= b_colocated then
			return a_colocated
		end
		return a < b
	end)
	local items = {}
	for idx, f in ipairs(files) do
		items[#items + 1] = { text = f, file = f, idx = idx }
	end
	Snacks.picker.pick({
		source = "related_documents",
		items = items,
		format = "file",
		title = "Associated Files",
	})
end

local function buffer_jumps()
	local current_buf = vim.api.nvim_get_current_buf()
	local jumps = vim.fn.getjumplist()[1]
	local items = {}
	local idx = 0
	for _, jump in ipairs(jumps) do
		local buf = jump.bufnr and vim.api.nvim_buf_is_valid(jump.bufnr) and jump.bufnr or 0
		if buf == current_buf and jump.lnum > 0 then
			local lines = vim.api.nvim_buf_get_lines(buf, jump.lnum - 1, jump.lnum, false)
			idx = idx + 1
			table.insert(items, 1, {
				text = string.format("%d: %s", jump.lnum, vim.trim(lines[1] or "")),
				buf = current_buf,
				pos = { jump.lnum, jump.col },
				idx = idx,
			})
		end
	end
	if #items == 0 then
		vim.notify("No jumps in current buffer", vim.log.levels.INFO)
		return
	end
	Snacks.picker.pick({
		source = "buffer_jumps",
		items = items,
		title = "Buffer Jumps",
		confirm = function(picker, item)
			picker:close()
			vim.api.nvim_win_set_cursor(0, item.pos)
		end,
	})
end

Edit.later(function()
	local map = vim.keymap.set

	-- stylua: ignore start
	map("n", "<leader><leader>", function() smart_files() end,       { desc = "Files (smart)" })
	map("n", "<leader>aw",       function() project_switch() end,    { desc = "[W]orkspace" })
	map("n", "<leader>ww",       function() worktree_switch() end,   { desc = "[W]orktrees" })
	map("n", "<leader>dr",       function() related_documents() end, { desc = "[R]elated Documents" })
	map("n", "<leader>dj",       function() buffer_jumps() end,      { desc = "[J]umps" })
	-- stylua: ignore end
end)
