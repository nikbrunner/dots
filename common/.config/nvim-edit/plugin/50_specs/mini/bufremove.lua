require("mini.bufremove").setup()

-- Wipe all buffers except the current one
vim.api.nvim_create_user_command("Bufonly", function()
	local cur = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and buf ~= cur and vim.bo[buf].buflisted then
			MiniBufremove.wipeout(buf, true)
		end
	end
end, { desc = "Wipe all buffers except current" })
