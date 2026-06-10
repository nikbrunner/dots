-- My markdown helper plugin (auto-continue lists, etc.).

Edit.later(function()
	vim.pack.add({ "git@github.com:nikbrunner/mdn.nvim" })

	require("mdn").setup({
		auto_continue = true,
	})
end)
