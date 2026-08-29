vim.g.mdn_config = {}
Edit.on_filetype("markdown", function()
	local dev = vim.fn.expand("~/repos/nikbrunner/mdn.nvim")
	vim.opt.rtp:prepend(dev)
	vim.opt.rtp:append(dev .. "/after")

	vim.pack.add({ "git@github.com:nikbrunner/mdn.nvim" })
end)
