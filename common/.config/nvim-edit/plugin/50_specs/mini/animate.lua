Edit.later(function()
	require("mini.animate").setup()

	-- Disable in floating/special buffers where animations are distracting
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("mini-animate-disable", { clear = true }),
		pattern = { --
			"minifiles",
			"minipick",
			"notify",
		},
		callback = function(args)
			vim.b[args.buf].minianimate_disable = true
		end,
	})
end)
