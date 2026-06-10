Edit.later(function()
	-- vim.pack.add({ "git@github.com:black-atom-industries/iter.nvim.git" })

	vim.opt.rtp:prepend(vim.fn.expand("~/repos/black-atom-industries/iter.nvim"))

	require("iter").setup({
		preview = {
			-- Start diff previews with wrapping disabled.
			wrap = false,

			-- Show old/new line numbers in diff previews.
			show_line_numbers = true,

			-- Show git diff metadata rows such as `diff --git`, `index`, `---`,
			-- and `+++`.
			show_metadata = false,

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
