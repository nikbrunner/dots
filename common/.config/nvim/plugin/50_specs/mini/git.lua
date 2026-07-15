require("mini.git").setup()

local map = vim.keymap.set

-- `:vert Git blame -- %` shows per-line commit annotations in a vertical split.
-- The align autocmd below syncs the blame split with the source window: same
-- topline, cursor line, and scrollbind so they scroll together. (From the
-- mini.git docs, `MiniGitCommandSplit` User event.)
local align_blame = function(au_data)
	if au_data.data.git_subcommand ~= "blame" then
		return
	end

	local win_src = au_data.data.win_source
	vim.wo.wrap = false
	vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
	vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })

	-- Bind both windows so that they scroll together
	vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniGitCommandSplit",
	callback = align_blame,
	desc = "Align :Git blame split with source window + scrollbind",
})

map("n", "<leader>sgb", "<Cmd>vertical Git blame -- %<CR>", { desc = "[B]lame (mini.git)" })
