-- My markdown helper plugin (auto-continue lists, etc.).

-- `on_filetype` re-sources the ftplugin for already-open markdown buffers
-- (e.g. restored from a session before the plugin was on the rtp).
Edit.on_filetype("markdown", function()
	vim.pack.add({ "git@github.com:nikbrunner/mdn.nvim" })
	-- vim.opt.rtp:prepend(vim.fn.expand("~/repos/nikbrunner/mdn.nvim"))

	require("mdn").setup()
end)
