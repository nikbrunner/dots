local MS = require("mini.sessions")

---Get session name for a given path (defaults to cwd)
---@param path? string Absolute path to derive session name from
---@return string
local function get_session_name(path)
	local dir = path or vim.fn.getcwd()
	local home = vim.fn.expand("~")

	-- Strip home directory to make portable across macOS/Linux
	local name = dir
	if vim.startswith(dir, home) then
		name = string.sub(dir, #home + 2) -- +2 to skip the trailing slash
	end

	-- Replace remaining slashes with underscores
	name = string.gsub(name, "/", "_")

	local result = vim.fn.system("git -C " .. vim.fn.shellescape(dir) .. " branch --show-current")
	local branch = vim.trim(result)
	branch = string.gsub(branch, "/", "_")

	if vim.v.shell_error == 0 and branch ~= "" then
		return name .. "_" .. branch
	else
		return name
	end
end

-- Directories that should auto-create sessions
local auto_create_session_dirs = {
	vim.fn.expand("~/repos/"),
}

MS.setup({
	autowrite = true,
	directory = vim.fn.stdpath("config") .. "/sessions/",
	hooks = {
		pre = {
			-- Save current session before loading a different one
			-- (e.g., after branch switch in lazygit)
			read = function()
				if vim.v.this_session ~= "" then
					local current = vim.fn.fnamemodify(vim.v.this_session, ":t")
					require("mini.sessions").write(current)
				end
			end,
			write = function()
				-- Close codediff tabpages so their scratch buffers don't end up in the session
				local ok, codediff = pcall(require, "codediff.ui.lifecycle.session")
				if ok and codediff.get_active_diffs then
					local active_diffs = codediff.get_active_diffs()
					for tabpage, _ in pairs(active_diffs) do
						if vim.api.nvim_tabpage_is_valid(tabpage) then
							vim.api.nvim_set_current_tabpage(tabpage)
							vim.cmd("tabclose")
						end
					end
				end

				-- Delete ephemeral and non-visible buffers before writing session
				vim.iter(vim.api.nvim_list_bufs())
					:filter(function(bufnr)
						return vim.api.nvim_buf_is_valid(bufnr)
					end)
					:filter(function(bufnr)
						local buftype = vim.bo[bufnr].buftype
						local bufpath = vim.api.nvim_buf_get_name(bufnr)

						-- Delete if special buffer type (but preserve help files)
						if buftype ~= "" and buftype ~= "help" then
							return true
						end

						-- Delete if file doesn't exist on disk (but not empty/new buffers)
						if bufpath ~= "" and vim.uv.fs_stat(bufpath) == nil then
							return true
						end

						-- Delete if buffer is not in any tabpage's window list
						local buffer_in_tabpage = false
						for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
							for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
								if vim.api.nvim_win_get_buf(win) == bufnr then
									buffer_in_tabpage = true
									break
								end
							end
							if buffer_in_tabpage then
								break
							end
						end

						if not buffer_in_tabpage then
							return true
						end

						return false
					end)
					:each(function(bufnr)
						vim.api.nvim_buf_delete(bufnr, { force = true })
					end)
			end,
		},
	},
})

vim.keymap.set("n", "<leader>ass", function()
	require("mini.sessions").write(get_session_name())
end, { desc = "[S]ave" })

vim.keymap.set("n", "<leader>asl", function()
	require("mini.sessions").select("read")
end, { desc = "[L]ist" })

vim.keymap.set("n", "<leader>asd", function()
	require("mini.sessions").select("delete", { force = true })
end, { desc = "[D]elete" })

vim.keymap.set("n", "<leader>asc", function()
	vim.system({ "dots", "clean-sessions", "--raw" }, {}, function(result)
		vim.schedule(function()
			local output = vim.trim(result.stdout or "")
			if output == "" or result.code ~= 0 then
				vim.notify("No sessions to clean up", vim.log.levels.INFO)
				return
			end

			local orphans, old = {}, {}
			for _, line in ipairs(vim.split(output, "\n")) do
				local name = line:match("^ORPHAN:(.+)$")
				if name then
					table.insert(orphans, name)
				else
					name = line:match("^OLD:(.+)$")
					if name then
						table.insert(old, name)
					end
				end
			end

			local parts = {}
			if #orphans > 0 then
				table.insert(parts, string.format("%d orphaned: %s", #orphans, table.concat(orphans, ", ")))
			end
			if #old > 0 then
				table.insert(parts, string.format("%d old (>2d): %s", #old, table.concat(old, ", ")))
			end

			if #parts > 0 then
				vim.notify(string.format("Cleaned %s", table.concat(parts, ", ")), vim.log.levels.INFO)
			else
				vim.notify("No sessions to clean up", vim.log.levels.INFO)
			end
		end)
	end)
end, { desc = "[C]lean" })

-- no args, or if the only arg is the current directory `nvim .`
if vim.fn.argc(-1) == 0 or (vim.fn.argc(-1) == 1 and vim.fn.argv(0) == ".") then
	-- Auto-load existing session on VimEnter event
	vim.api.nvim_create_autocmd({ "VimEnter" }, {
		nested = true,
		callback = function()
			local MS = require("mini.sessions")
			local session_name = get_session_name()

			if MS.detected[session_name] then
				MS.read(session_name)
			end
		end,
	})

	-- Auto-switch sessions on TermLeave event (like closing the lazygit terminal)
	vim.api.nvim_create_autocmd({ "TermLeave" }, {
		callback = function(event)
			-- Skip if project_switch is in progress
			if vim.g._mini_session_switching then
				return
			end

			-- Only proceed if it's a Snacks terminal (skip fzf-lua and others)
			local buf = event.buf or vim.api.nvim_get_current_buf()
			if vim.bo[buf].filetype ~= "snacks_terminal" then
				return
			end

			-- Don't load session if we're already in a session load
			if vim.g.SessionLoad == 1 then
				return
			end

			local session_name = get_session_name()

			-- Load existing session or create new one
			if MS.detected[session_name] then
				MS.read(session_name)
			end
		end,
	})

	-- Auto-create session on VimLeave for specified directories
	vim.api.nvim_create_autocmd({ "VimLeave" }, {
		callback = function()
			local session_name = get_session_name()
			local cwd = vim.fn.getcwd()

			-- Check if cwd is in any of the auto_create_session_dirs
			local should_auto_create = false
			for _, dir in ipairs(auto_create_session_dirs) do
				if vim.startswith(cwd, dir) then
					should_auto_create = true
					break
				end
			end

			-- Only create if in specified dir and session doesn't exist
			if should_auto_create and not MS.detected[session_name] then
				-- Skip session creation inside git worktrees (e.g., .claude/worktrees/)
				if cwd:find("worktrees", 1, true) then
					return
				end
				MS.write(session_name)
			end
		end,
	})
end
