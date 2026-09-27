Edit.later(function()
	vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

	_G.oil_winbar_dir = function()
		local dir = require("oil").get_current_dir()
		if not dir then
			return ""
		end
		dir = dir:gsub("/+$", "")
		local root = vim.fs.root(dir, ".git")
		return (root and vim.fs.relpath(root, dir)) or dir
	end

	local bookmarks = {
		{ key = "1", path = "~/repos/nikbrunner/dots", label = "dots" },
		{ key = "2", path = "~/repos/nikbrunner/notes", label = "notes" },
		{ key = "3", path = "~/repos/nikbrunner/scarth-johnson", label = "scarth-johnson" },
		{ key = "4", path = "~/repos/black-atom-industries/core", label = "black-atom core" },
		{ key = "5", path = "~/repos/black-atom-industries/nvim", label = "black-atom nvim" },
		{ key = "6", path = "~/repos/black-atom-industries/livery", label = "livery" },
		{ key = "7", path = "~/repos/nikbrunner/nbr.haus", label = "nbr.haus" },
		{ key = "8", path = "~/repos/nikbrunner/koyo", label = "koyo" },
		{ key = "9", path = "~/repos", label = "repos" },
		{ key = "0", path = "~", label = "~" },
	}

	local ns_git = vim.api.nvim_create_namespace("oil_git_status")

	local jump_git = function(forward)
		for _ = 1, vim.v.count1 do
			local row = vim.api.nvim_win_get_cursor(0)[1] - 1
			local mark
			if forward then
				mark = vim.api.nvim_buf_get_extmarks(0, ns_git, { row + 1, 0 }, -1, { limit = 1 })[1]
					or vim.api.nvim_buf_get_extmarks(0, ns_git, 0, -1, { limit = 1 })[1]
			else
				mark = (row > 0 and vim.api.nvim_buf_get_extmarks(0, ns_git, { row - 1, 0 }, 0, { limit = 1 })[1])
					or vim.api.nvim_buf_get_extmarks(0, ns_git, -1, 0, { limit = 1 })[1]
			end
			if not mark then
				return
			end
			vim.api.nvim_win_set_cursor(0, { mark[2] + 1, 0 })
		end
	end

	local keymaps = {
		["<C-l>"] = false,
		["<C-h>"] = false,

		["q"] = { "actions.close", mode = "n" },

		["<C-v>"] = { "actions.select", opts = { vertical = true, close = true } },

		["H"] = { "actions.parent", mode = "n" },
		["L"] = {
			callback = function()
				local entry = require("oil").get_cursor_entry()
				if entry and require("oil.util").is_directory(entry) then
					require("oil").select()
				end
			end,
			desc = "Enter directory",
			mode = "n",
		},

		["]c"] = { callback = function() jump_git(true) end, desc = "Next git status", mode = "n" },
		["[c"] = { callback = function() jump_git(false) end, desc = "Prev git status", mode = "n" },
	}

	for _, bm in ipairs(bookmarks) do
		keymaps[bm.key] = {
			callback = function()
				require("oil").open(vim.fn.expand(bm.path))
			end,
			desc = bm.label,
			mode = "n",
		}
	end

	require("oil").setup({
		default_file_explorer = true,
		view_options = {
			show_hidden = true,
			skip_confirm_for_simple_edits = true,
			prompt_save_on_select_new_entry = false,
		},
		watch_for_changes = true,
		lsp_file_methods = {
			-- Enable or disable LSP file operations
			enabled = true,
			timeout_ms = 1000,
			-- Set to true to autosave buffers that are updated with LSP willRenameFiles
			-- Set to "unmodified" to only save unmodified buffers
			autosave_changes = true,
		},
		win_options = {
			winbar = "%{v:lua.oil_winbar_dir()}",
			signcolumn = "yes:1",
		},
		keymaps = keymaps,
	})

	local hint_buf = vim.api.nvim_create_buf(false, true)
	local hint_width = 0
	local hint_lines = {}
	for _, bm in ipairs(bookmarks) do
		local line = " " .. bm.key .. "  " .. bm.label .. " "
		table.insert(hint_lines, line)
		hint_width = math.max(hint_width, #line)
	end
	vim.api.nvim_buf_set_lines(hint_buf, 0, -1, false, hint_lines)
	local ns_hint = vim.api.nvim_create_namespace("oil_bookmark_hint")
	for i = 0, #hint_lines - 1 do
		vim.api.nvim_buf_set_extmark(hint_buf, ns_hint, i, 1, { end_col = 2, hl_group = "Special" })
	end

	local ns_active = vim.api.nvim_create_namespace("oil_bookmark_active")
	local highlight_active = function(buf)
		vim.api.nvim_buf_clear_namespace(hint_buf, ns_active, 0, -1)
		local dir = require("oil").get_current_dir(buf)
		if not dir then
			return
		end
		dir = vim.fs.normalize(dir)
		local best, best_len
		for i, bm in ipairs(bookmarks) do
			local path = vim.fs.normalize(vim.fn.expand(bm.path))
			if vim.fs.relpath(path, dir) and (not best_len or #path > best_len) then
				best, best_len = i, #path
			end
		end
		if best then
			vim.api.nvim_buf_set_extmark(hint_buf, ns_active, best - 1, 0, { line_hl_group = "CursorLine" })
		end
	end

	local hint_win
	local close_hint = function()
		if hint_win and vim.api.nvim_win_is_valid(hint_win) then
			vim.api.nvim_win_close(hint_win, true)
		end
		hint_win = nil
	end

	vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
		callback = function(args)
			close_hint()
			if vim.bo[args.buf].filetype ~= "oil" then
				return
			end
			highlight_active(args.buf)
			local win = vim.api.nvim_get_current_win()
			hint_win = vim.api.nvim_open_win(hint_buf, false, {
				relative = "win",
				win = win,
				anchor = "NE",
				row = 0,
				col = vim.api.nvim_win_get_width(win),
				width = hint_width,
				height = #hint_lines,
				style = "minimal",
				border = "solid",
				focusable = false,
				noautocmd = true,
			})
		end,
	})

	local git_rank = " !?TCRDAMU"
	local git_hl = {
		M = "Changed",
		T = "Changed",
		R = "Changed",
		C = "Changed",
		A = "Added",
		["?"] = "Added",
		D = "Removed",
		U = "DiagnosticError",
		["!"] = "Comment",
	}
	local git_status = {}

	local draw_git = function(buf)
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		vim.api.nvim_buf_clear_namespace(buf, ns_git, 0, -1)
		local status = git_status[buf]
		if not status then
			return
		end
		for lnum = 1, vim.api.nvim_buf_line_count(buf) do
			local entry = require("oil").get_entry_on_line(buf, lnum)
			local code = entry and status[entry.name]
			if code then
				local wt = code:sub(2, 2)
				vim.api.nvim_buf_set_extmark(buf, ns_git, lnum - 1, 0, {
					sign_text = code,
					sign_hl_group = git_hl[wt ~= " " and wt or code:sub(1, 1)],
				})
			end
		end
	end

	-- Per column, the highest-ranked status of all paths below an entry wins
	local refresh_git = function(buf)
		local dir = require("oil").get_current_dir(buf)
		if not dir or vim.fn.isdirectory(dir) == 0 then
			return
		end
		local cmd = { "git", "-c", "status.relativePaths=true", "-c", "core.quotePath=false" }
		vim.list_extend(cmd, { "status", "--short", "--untracked-files=normal", "--ignored", "." })
		vim.system(
			cmd,
			{ cwd = dir, text = true },
			vim.schedule_wrap(function(out)
				local status = {}
				if out.code == 0 then
					for line in vim.gsplit(out.stdout, "\n", { trimempty = true }) do
						local path = line:sub(4):gsub("^.* %-> ", ""):gsub('^"(.*)"$', "%1")
						local name = path:match("^[^/]+")
						local prev = status[name] or "  "
						local merged = ""
						for i = 1, 2 do
							local a, b = prev:sub(i, i), line:sub(i, i)
							merged = merged .. (git_rank:find(b, 1, true) > git_rank:find(a, 1, true) and b or a)
						end
						status[name] = merged
					end
				end
				git_status[buf] = status
				draw_git(buf)
			end)
		)
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "OilEnter",
		callback = function(args)
			refresh_git(args.data.buf)
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		pattern = "OilActionsPost",
		callback = function()
			refresh_git(vim.api.nvim_get_current_buf())
		end,
	})
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "oil://*",
		callback = function(args)
			refresh_git(args.buf)
		end,
	})
	vim.api.nvim_create_autocmd("TextChanged", {
		pattern = "oil://*",
		callback = function(args)
			draw_git(args.buf)
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		pattern = "oil://*",
		callback = function(args)
			git_status[args.buf] = nil
		end,
	})

	local open_parent = function()
		local dir = vim.fn.expand("%:p:h")
		if vim.bo.buftype == "" and vim.fn.isdirectory(dir) == 0 then
			require("oil").open(vim.fn.getcwd())
		else
			require("oil").open()
		end
	end

	local open_git_root = function()
		local git_dir = vim.fs.find({ ".git" }, { upward = true })[1]
		if git_dir then
			require("oil").open(vim.fs.dirname(git_dir))
		else
			require("oil").open()
		end
	end

	vim.keymap.set("n", "-", open_parent, { desc = "Open parent directory" })
	vim.keymap.set("n", "<leader>we", open_parent, { desc = "[E]xplorer" })
	vim.keymap.set("n", "_", open_git_root, { desc = "Open Git root directory" })
	vim.keymap.set("n", "<leader>wE", open_git_root, { desc = "[E]xplorer (Git root)" })
end)
