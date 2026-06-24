Edit.now(function()
	-- Register diffs.nvim without sourcing its plugin/ files (load = false
	-- behaves like `:packadd!`): it's only needed when a diff preview is
	-- rendered inside `gs`, so defer the ~19ms of sourcing + module requires
	-- to first use. iter.setup() itself never requires diffs.
	vim.pack.add({ "https://github.com/barrettruth/diffs.nvim" }, { load = false })

	-- vim.pack.add({ "git@github.com:black-atom-industries/iter.nvim.git" })
	vim.opt.rtp:prepend(vim.fn.expand("~/repos/black-atom-industries/iter.nvim"))

	require("iter").setup({
		preview = {
			-- Start diff previews with wrapping disabled.
			wrap = false,

			-- Diff preview layout: 'stacked', 'split', or 'auto'.
			diff_layout = "auto",

			-- Editor width where 'auto' switches from stacked to split.
			diff_auto_threshold = 120,
		},
	})

	-- Lazy-load diffs.nvim on first `gs`: `:packadd` (without `!`) sources
	-- plugin/diffs.lua, which runs runtime.configure() + registers the `:Diff`
	-- command and FileType attach autocmds that iter's diff preview needs.
	-- Idempotent: diffs.nvim guards with `vim.g.loaded_diffs`.
	vim.keymap.set("n", "gs", function()
		vim.cmd.packadd("diffs.nvim")
		require("iter").status()
	end, { desc = "Git Status" })
end)
