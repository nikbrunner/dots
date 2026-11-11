Edit.later(function()
	if not vim.env.REX_SESSION then
		return
	end
	for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
		vim.keymap.set("n", "<C-" .. key .. ">", function()
			local win = vim.api.nvim_get_current_win()
			vim.cmd.wincmd(key)
			if vim.api.nvim_get_current_win() == win then
				vim.system({ "rex", "focus", direction, "-s", vim.env.REX_SESSION })
			end
		end, { desc = "Navigate " .. direction .. " (nvim/rex)" })
	end
end)
