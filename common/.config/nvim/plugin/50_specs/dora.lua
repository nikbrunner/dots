Edit.later(function()
	vim.pack.add({ "git@github.com:beardedsakimonkey/nvim-dora.git" })

	require("dora").setup({
		show_root = true,
	})

	vim.keymap.set("n", "-", "<Cmd>Dora<CR>")
	vim.keymap.set("n", "_", "<Cmd>Dora " .. vim.fn.getcwd() .. "<CR>")
end)
