-- Notifications in a floating window (replaces vim.notify) + automatic
-- LSP progress reports. `now` so early startup messages are caught too.

Edit.now(function()
	require("mini.notify").setup({
		window = {
			-- Render messages as Markdown so links show as their labels. The float
			-- opens with `noautocmd`, so window options can only be set from here.
			config = function(buf)
				vim.schedule(function()
					if not vim.treesitter.highlighter.active[buf] then
						pcall(vim.treesitter.start, buf, "markdown")
					end
					for _, win in ipairs(vim.fn.win_findbuf(buf)) do
						vim.wo[win].conceallevel = 2
						vim.wo[win].concealcursor = "nvic"
					end
				end)
				local pad = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0)
				return { anchor = "SE", col = vim.o.columns, row = vim.o.lines - pad }
			end,
		},
	})

	vim.keymap.set("n", "<leader>an", function()
		MiniNotify.show_history()
	end, { desc = "[N]otifications" })
end)
