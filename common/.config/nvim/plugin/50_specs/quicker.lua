-- Improved quickfix UI: styled output, context lines, editable buffer.
-- Buffer-local expand/collapse is configured via `keys`; global toggles are
-- mapped to <leader>q / <leader>l (no conflicts with existing bindings).

Edit.later(function()
	vim.pack.add({ "git@github.com:stevearc/quicker.nvim" })

	require("quicker").setup({
		-- Buffer-local keymaps (auto-applied in the quickfix buffer).
		keys = {
			{
				">",
				function()
					require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
				end,
				desc = "Expand quickfix context",
			},
			{
				"<",
				function()
					require("quicker").collapse()
				end,
				desc = "Collapse quickfix context",
			},
		},
	})

	local map = vim.keymap.set

	-- stylua: ignore start
	map("n", "<leader>q", function() require("quicker").toggle() end,          { desc = "[Q]uickfix toggle" })
	map("n", "<leader>l", function() require("quicker").toggle({ loclist = true }) end, { desc = "[L]oclist toggle" })
	-- stylua: ignore end
end)
