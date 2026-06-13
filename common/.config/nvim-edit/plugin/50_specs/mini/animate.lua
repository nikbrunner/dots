Edit.later(function()
	local animate = require("mini.animate")
	animate.setup({
		cursor = {
			timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
		},
		scroll = {
			timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
		},
		resize = {
			timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
		},
		open = {
			timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
		},
		close = {
			timing = animate.gen_timing.linear({ duration = 80, unit = "total" }),
		},
	})

	-- Disable in floating/special buffers where animations are distracting
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("mini-animate-disable", { clear = true }),
		pattern = { --
			"iter",
			"iter-diff",
			"minifiles",
			"minipick",
			"notify",
		},
		callback = function(args)
			vim.b[args.buf].minianimate_disable = true
		end,
	})
end)
