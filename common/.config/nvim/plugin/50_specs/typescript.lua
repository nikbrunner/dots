-- TypeScript extras: project-wide tsc type-checking and human-readable
-- TS error messages.

Edit.later(function()
	vim.pack.add({
		"git@github.com:dmmulroy/tsc.nvim",
		"git@github.com:dmmulroy/ts-error-translator.nvim",
	})

	require("tsc").setup({
		use_trouble_qflist = true,
		flags = {
			skipLibCheck = true,
		},
	})

	require("ts-error-translator").setup({})
end)
