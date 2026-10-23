-- Git status UI (black-atom-industries/iter.nvim), loaded from the local checkout.

-- Sourced at startup so `nvim iter://review` finds iter's BufReadCmd.
vim.opt.rtp:prepend(vim.fn.expand("~/repos/black-atom-industries/iter.nvim/"))
-- rtp is extended after startup sourced plugin/, so source iter's command file by hand
vim.cmd.runtime("plugin/iter.lua")

Edit.later(function()
	-- vim.pack.add({ "https://github.com/barrettruth/diffs.nvim" })

	local iter = require("iter")

	iter.setup({ diff = { layout = "auto" } })

	local map = vim.keymap.set

	map("n", "gs", function()
		iter.status()
	end, { desc = "Git [S]tatus (iter)" })

	-- stylua: ignore start
	map({ "n", "x" }, "<leader>dna", function() iter.annotate() end,                     { desc = "[A]nnotate line or selection" })
	map("n",          "<leader>dnf", function() iter.annotate({ scope = "file" }) end,   { desc = "Annotate [F]ile" })
	map("n",          "<leader>dnr", function() iter.annotate({ scope = "review" }) end, { desc = "Annotate [R]eview" })
	map("n",          "<leader>dnl", iter.annotations,                                   { desc = "[L]ist annotations" })
	map("n",          "<leader>dny", iter.yank,                                          { desc = "[Y]ank annotations" })
	-- stylua: ignore end
end)
