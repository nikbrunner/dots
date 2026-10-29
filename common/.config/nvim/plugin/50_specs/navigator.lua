Edit.later(function()
	if vim.env.REX_SESSION then
		for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
			vim.keymap.set("n", "<C-" .. key .. ">", function()
				local win = vim.api.nvim_get_current_win()
				vim.cmd.wincmd(key)
				if vim.api.nvim_get_current_win() == win then
					vim.system({ "rex", "focus", direction, "-s", vim.env.REX_SESSION })
				end
			end, { desc = "Navigate " .. direction .. " (nvim/rex)" })
		end
		return
	end

	vim.pack.add({ "https://github.com/aimdevlee/herdr-nvim-nav" })
	require("herdr-nvim-nav").setup()
end)
