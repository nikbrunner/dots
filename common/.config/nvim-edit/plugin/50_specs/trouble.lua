-- Diagnostics, references, and symbol lists.
-- (The old snacks.picker integration was dropped — mini.pick is the picker here.)

Edit.later(function()
	vim.pack.add({ "git@github.com:folke/trouble.nvim" })

	require("trouble").setup({
		focus = true,
		auto_close = true,
		auto_refresh = false,
		indent_guides = false,
		follow = false,
		win = {
			title = "Trouble",
			wo = {
				winbar = "Trouble",
			},
		},
		modes = {
			lsp_document_symbols = {
				win = {
					type = "split",
					position = "right",
					size = { width = 0.33 },
				},
			},
			lsp_defnitions = {
				auto_jump = true, -- auto jump to the item when there's only one
				auto_close = true,
			},
			lsp_references = {
				params = {
					include_declaration = false,
				},
			},
		},
	})

	local map = vim.keymap.set

	-- stylua: ignore start
	map("n", "<leader>dP",  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "[P]roblems" })
	map("n", "<leader>wP",  "<cmd>Trouble diagnostics toggle<cr>",              { desc = "[P]roblems" })
	map("n", "<leader>sd",  "<cmd>Trouble lsp_definitions<cr>",                 { desc = "[D]efinition" })
	map("n", "<leader>st",  "<cmd>Trouble lsp_type_definitions<cr>",            { desc = "[T]ype Definition" })
	map("n", "<leader>sR",  "<cmd>Trouble lsp_references<cr>",                  { desc = "[R]eferences" })
	map("n", "<leader>sI",  "<cmd>Trouble lsp_implementations<cr>",             { desc = "[I]mplementations" })
	map("n", "<leader>sci", "<cmd>Trouble lsp_incoming_calls<cr>",              { desc = "[I]ncoming" })
	map("n", "<leader>sco", "<cmd>Trouble lsp_outgoing_calls<cr>",              { desc = "[O]utgoing" })
	-- stylua: ignore end

	map("n", "[q", function()
		if require("trouble").is_open() then
			require("trouble").prev({ skip_groups = true, jump = true })
		else
			local ok, err = pcall(vim.cmd.cprev)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
			end
		end
	end, { desc = "Previous Trouble/Quickfix Item" })

	map("n", "]q", function()
		if require("trouble").is_open() then
			require("trouble").next({ skip_groups = true, jump = true })
		else
			local ok, err = pcall(vim.cmd.cnext)
			if not ok then
				vim.notify(err, vim.log.levels.ERROR)
			end
		end
	end, { desc = "Next Trouble/Quickfix Item" })
end)
