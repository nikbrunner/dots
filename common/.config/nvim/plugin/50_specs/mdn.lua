-- My markdown helper plugin (auto-continue lists, etc.).

-- `on_filetype` re-sources the ftplugin for already-open markdown buffers
-- (e.g. restored from a session before the plugin was on the rtp).
vim.g.mdn_config = {}
Edit.on_filetype("markdown", function()
	local dev = vim.fn.expand("~/repos/nikbrunner/mdn.nvim")
	vim.opt.rtp:prepend(dev)
	vim.opt.rtp:append(dev .. "/after")
	vim.pack.add({ "git@github.com:nikbrunner/mdn.nvim" })
end)
