-- Global autocommands.
-- Not here: yank highlight + terminal insert (mini.basics), LSP progress
-- (mini.notify), gitcommit buffer settings (ftplugin/gitcommit.lua).

-- Clean up old ShaDa temp files on startup.
-- These accumulate when Neovim crashes or is force-killed during writes.
-- Once all 26 slots (a-z) are full, ShaDa writes fail with E138.
Edit.new_autocmd("VimEnter", nil, function()
	local shada_dir = vim.fn.stdpath("state") .. "/shada"
	vim.fn.system(string.format("find %s -name 'main.shada.tmp.*' -mtime +7 -delete", shada_dir))
end, "Clean up old ShaDa temp files")

-- Close these filetypes with `q` in normal mode
Edit.new_autocmd("FileType", {
	"checkhealth",
	"help",
	"lspinfo",
	"man",
	"qf",
	"startuptime",
}, function(event)
	vim.bo[event.buf].buflisted = false
	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
end, "Close with q")

-- Go to last cursor position when opening a buffer
Edit.later(function()
	require("mini.misc").setup_restore_cursor()
end)

-- Resize splits if window got resized
Edit.new_autocmd("VimResized", nil, function()
	local current_tab = vim.fn.tabpagenr()
	vim.cmd("tabdo wincmd =")
	vim.cmd("tabnext " .. current_tab)
end, "Equalize splits on resize")

-- Close buffers whose files no longer exist on disk
Edit.new_autocmd("FocusGained", nil, function()
	local closed_buffers = {}
	vim.iter(vim.api.nvim_list_bufs())
		:filter(function(bufnr)
			return vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr)
		end)
		:filter(function(bufnr)
			local buf_path = vim.api.nvim_buf_get_name(bufnr)
			local does_not_exist = vim.uv.fs_stat(buf_path) == nil
			local not_special_buffer = vim.bo[bufnr].buftype == ""
			local not_new_buffer = buf_path ~= ""
			return does_not_exist and not_special_buffer and not_new_buffer
		end)
		:each(function(bufnr)
			table.insert(closed_buffers, vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)))
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end)

	if #closed_buffers == 0 then
		return
	end

	if #closed_buffers == 1 then
		vim.notify("Buffer closed: " .. closed_buffers[1])
	else
		vim.notify("Buffers closed:\n- " .. table.concat(closed_buffers, "\n- "))
	end
end, "Close buffers of deleted files")

-- Check for external file changes (pairs with 'autoread')
local function should_check()
	local mode = vim.api.nvim_get_mode().mode
	return not (
		mode:match("[cR!s]") -- Skip: command-line, replace, ex, select modes
		or vim.fn.getcmdwintype() ~= "" -- Skip: command-line window is open
	)
end

Edit.new_autocmd({ "FocusGained", "TermLeave", "BufEnter", "WinEnter", "CursorHold", "CursorHoldI" }, nil, function()
	if should_check() then
		vim.cmd("checktime")
	end
end, "Check for external file changes")
