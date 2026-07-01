-- Deferred via `Edit.later`: mini.files is invoked on demand via the
-- <leader>we / - / _ keymaps set at the bottom of this file. The `User`
-- autocmds (MiniFilesBufferCreate, etc.) only fire when MF.open runs,
-- which is itself deferred here — so registration order is preserved.
Edit.later(function()
	local MF = require("mini.files")

	local invoking_win_pos = { 0, 0 }
	local preview_enabled = false

	MF.setup({
	content = {
		prefix = function() end,
	},
	mappings = {
		show_help = "g?",
		close = "q",
		go_in = "<CR>",
		go_in_plus = "<CR>",
		go_out = "-",
		go_out_plus = "_",
		mark_goto = "'",
		mark_set = "m",
		reset = "<BS>",
		reveal_cwd = "~",
		synchronize = "=",
		trim_left = "<",
		trim_right = ">",
	},
	options = {
		use_as_default_explorer = false,
		-- Workaround for mini.nvim bug on Neovim >= 0.11: `H.lsp_fs_hook_client`
		-- in mini/files.lua (~L2866) calls `is_scheme(uri, scheme)`, which does
		-- `scheme == nil` and `scheme .. ':'`. In Neovim 0.12+ `FileOperationFilter.scheme`
		-- is decoded as `vim.NIL` (a userdata) instead of Lua `nil`, so both the
		-- nil-check fails and the concatenation crashes on `=` (synchronize).
		-- The same hook also emits the `client.supports_method is deprecated`
		-- warning via `vim.lsp.get_clients({ method = ... })`. Setting
		-- `lsp_timeout = 0` early-returns from `H.lsp_fs_hook` and avoids both.
		-- TODO: Remove once upstream lands a `vim.NIL`-aware `is_scheme` fix.
		-- Trade-off: no LSP-driven import rewrites on file ops inside the explorer.
		-- Sources:
		--   https://github.com/nvim-mini/mini.nvim/pull/2340   -- introduced the buggy code
		--   https://github.com/nvim-mini/mini.nvim/issues/2215 -- parent feature request
		lsp_timeout = 0,
	},
	windows = {
		max_number = 3,
		preview = false,
		width_focus = 50,
		width_nofocus = 25,
		width_preview = 65,
	},
})

-- Override global winborder for MiniFiles
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesWindowOpen",
	callback = function(args)
		local config = vim.api.nvim_win_get_config(args.data.win_id)
		config.border = "solid"
		vim.api.nvim_win_set_config(args.data.win_id, config)
	end,
})

-- Anchor explorer to the split it was invoked from
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesWindowUpdate",
	callback = function(args)
		local config = vim.api.nvim_win_get_config(args.data.win_id)
		config.row = config.row + invoking_win_pos[1]
		config.col = config.col + invoking_win_pos[2]
		vim.api.nvim_win_set_config(args.data.win_id, config)
	end,
})

-- Split keymaps
local map_split = function(buf_id, lhs, direction)
	local rhs = function()
		local cur_target = MF.get_explorer_state().target_window
		local new_target = vim.api.nvim_win_call(cur_target, function()
			vim.cmd(direction .. " split")
			return vim.api.nvim_get_current_win()
		end)
		MF.set_target_window(new_target)
		MF.go_in({ close_on_file = true })
	end
	local desc = "Split " .. direction
	vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id
		map_split(buf_id, "<C-v>", "belowright vertical")
		map_split(buf_id, "<C-s>", "belowright horizontal")
		map_split(buf_id, "<C-t>", "tab")
	end,
})

-- Symlink indicators via extmarks
local ns_symlink = vim.api.nvim_create_namespace("mini_files_symlink")

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferUpdate",
	callback = function(args)
		local buf_id = args.data.buf_id
		vim.api.nvim_buf_clear_namespace(buf_id, ns_symlink, 0, -1)

		local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
		for i, _ in ipairs(lines) do
			local entry = MF.get_fs_entry(buf_id, i)
			if entry then
				local stat = vim.uv.fs_lstat(entry.path)
				if stat and stat.type == "link" then
					local target = vim.uv.fs_readlink(entry.path)
					local virt_text = target and ("→ " .. target) or "→"
					vim.api.nvim_buf_set_extmark(buf_id, ns_symlink, i - 1, 0, {
						virt_text = { { virt_text, "Comment" } },
						virt_text_pos = "eol",
					})
				end
			end
		end
	end,
})

-- Note: mini.files is LSP-aware for create/delete/rename on Neovim >= 0.11
-- (willRenameFiles / didRenameFiles), so no external rename hook is needed.

-- Wipe buffer when file is deleted via mini.files
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesActionDelete",
	callback = function(event)
		local path = event.data.from
		if path then
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == path then
					MiniBufremove.wipeout(buf, true)
				end
			end
		end
	end,
})

-- Path operations
local yank_path = function()
	local path = (MF.get_fs_entry() or {}).path
	if path == nil then
		return vim.notify("Cursor is not on valid entry")
	end
	vim.fn.setreg(vim.v.register, path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO)
end

local ui_open = function()
	local entry = MF.get_fs_entry()
	if entry then
		vim.ui.open(entry.path)
	end
end

-- Yank path variants
local yank_filename = function()
	local entry = MF.get_fs_entry()
	if entry then
		local name = vim.fn.fnamemodify(entry.path, ":t")
		vim.fn.setreg("+", name)
		vim.notify("Copied filename: " .. name, vim.log.levels.INFO)
	end
end

local yank_relative_path = function()
	local entry = MF.get_fs_entry()
	if entry then
		local relative_path = vim.fn.fnamemodify(entry.path, ":~:.")
		vim.fn.setreg("+", relative_path)
		vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
	end
end

local yank_path_from_home = function()
	local entry = MF.get_fs_entry()
	if entry then
		local path_from_home = vim.fn.fnamemodify(entry.path, ":~")
		vim.fn.setreg("+", path_from_home)
		vim.notify("Copied path from home: " .. path_from_home, vim.log.levels.INFO)
	end
end

local yank_absolute_path = function()
	local entry = MF.get_fs_entry()
	if entry then
		vim.fn.setreg("+", entry.path)
		vim.notify("Copied absolute path: " .. entry.path, vim.log.levels.INFO)
	end
end

local function setBranch(path)
	MF.set_branch({ vim.fn.expand(path) })
end

-- Buffer-local keymaps for MiniFiles
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local bufid = args.data.buf_id
		local map = vim.keymap.set

		-- Route :w to MF.synchronize via BufWriteCmd (requires buftype=acwrite)
		vim.bo[bufid].buftype = "acwrite"
		vim.api.nvim_create_autocmd("BufWriteCmd", {
			buffer = bufid,
			callback = function()
				MF.synchronize()
			end,
		})

        -- stylua: ignore start
        -- Path operations
        map("n", "gx", ui_open, { buffer = bufid, desc = "OS open" })

        -- Yank variants
        map("n", "gyp", yank_path, { buffer = bufid, desc = "Yank path" })
        map("n", "gyn", yank_filename, { buffer = bufid, desc = "Yank filename" })
        map("n", "gyr", yank_relative_path, { buffer = bufid, desc = "Yank relative path" })
        map("n", "gyh", yank_path_from_home, { buffer = bufid, desc = "Yank path from home" })
        map("n", "gya", yank_absolute_path, { buffer = bufid, desc = "Yank absolute path" })

        -- Bookmark navigation (g prefix)
        map("n", "g.", function() setBranch(vim.fn.getcwd()) end, { buffer = bufid, desc = "Current working directory" })
        map("n", "gh", function() setBranch("$HOME/") end, { buffer = bufid, desc = "Home", nowait = true })
        map("n", "gc", function() setBranch("$HOME/.config") end, { buffer = bufid, desc = "Config", nowait = true })
        map("n", "gr", function() setBranch("$HOME/repos") end, { buffer = bufid, desc = "Repos", nowait = true })
        map("n", "gl", function() setBranch("$HOME/.local/share/nvim/lazy") end, { buffer = bufid, desc = "Lazy Packages", nowait = true })

        -- Project bookmarks (g + number)
        map("n", "g0", function() setBranch("$HOME/repos/nikbrunner/dots") end, { buffer = bufid, desc = "nbr - dots" })
        map("n", "g1", function() setBranch("$HOME/repos/nikbrunner/notes") end, { buffer = bufid, desc = "nbr - notes" })
        map("n", "g2", function() setBranch("$HOME/repos/nikbrunner/scarth-johnson") end, { buffer = bufid, desc = "DCD - Notes" })
        map("n", "g4", function() setBranch("$HOME/repos/black-atom-industries/core") end, { buffer = bufid, desc = "Black Atom - core" })
        map("n", "g6", function() setBranch("$HOME/repos/black-atom-industries/livery") end, { buffer = bufid, desc = "Black Atom - radar.nvim" })
        map("n", "g5", function() setBranch("$HOME/repos/black-atom-industries/nvim") end, { buffer = bufid, desc = "Black Atom - nvim" })
        map("n", "g7", function() setBranch("$HOME/repos/nikbrunner/nbr.haus") end, { buffer = bufid, desc = "nikbrunner - nbr.haus" })
        map("n", "g8", function() setBranch("$HOME/repos/nikbrunner/koyo") end, { buffer = bufid, desc = "nikbrunner - koyo" })
        -- map("n", "g9", function() setBranch("$HOME/repos/dealercenter-digital/bc-desktop-client") end, { buffer = bufid, desc = "DCD - BC Desktop Client" })

        -- Toggle preview
        map("n", "<C-p>", function()
            preview_enabled = not preview_enabled
            MF.refresh({ windows = { preview = preview_enabled } })
        end, { buffer = bufid, desc = "Toggle preview" })

		-- stylua: ignore end
	end,
})

vim.keymap.set("n", "<leader>we", function()
	invoking_win_pos = vim.api.nvim_win_get_position(0)
	MF.open(vim.api.nvim_buf_get_name(0))
end, { desc = "[E]xplorer" })

vim.keymap.set("n", "-", function()
	invoking_win_pos = vim.api.nvim_win_get_position(0)
	MF.open(vim.api.nvim_buf_get_name(0))
end, { desc = "[E]xplorer" })

vim.keymap.set("n", "_", function()
	invoking_win_pos = vim.api.nvim_win_get_position(0)
	MF.open(vim.fn.getcwd())
end, { desc = "[E]xplorer" })

vim.keymap.set("n", "<leader>wE", function()
	invoking_win_pos = vim.api.nvim_win_get_position(0)
	MF.open(vim.fn.getcwd())
end, { desc = "[E]xplorer" })
end)
