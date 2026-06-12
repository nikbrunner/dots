Edit.now(function()
	vim.pack.add({ "https://github.com/barrettruth/diffs.nvim" })

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

	vim.keymap.set("n", "gs", function()
		require("iter").status()
	end, { desc = "Git Status" })
end)
