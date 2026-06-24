-- My markdown helper plugin (auto-continue lists, etc.).

Edit.now_if_args(function()
	vim.pack.add({ "git@github.com:nikbrunner/mdn.nvim" })
	-- vim.opt.rtp:prepend(vim.fn.expand("~/repos/nikbrunner/mdn.nvim"))

	require("mdn").setup()
end)
