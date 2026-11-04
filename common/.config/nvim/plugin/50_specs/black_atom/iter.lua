-- Git status UI (black-atom-industries/iter.nvim), loaded from the local checkout.

-- Sourced at startup so `nvim iter://review` finds iter's BufReadCmd.
local checkout = vim.fn.expand("~/repos/black-atom-industries/iter.nvim/")
local cwd = vim.fn.getcwd()

-- Started from a worktree of iter, run that worktree's code.
if vim.fs.basename(cwd):match("^iter%.nvim%-") then
	checkout = cwd
end

vim.opt.rtp:prepend(checkout)
-- rtp is extended after startup sourced plugin/, so source iter's command file by hand
vim.cmd.runtime("plugin/iter.lua")

-- Blank `Normal` cells between the dark gutter and the code. `Normal` would
-- notch a float's panel.
_G.PaddedStatuscolumn = function()
	local padding = 2
	local base = require("iter").statuscolumn()
	local win = vim.g.statusline_winid
	local wo = vim.wo[win]
	local gutter = wo.number or wo.relativenumber or wo.signcolumn ~= "no"

	if not gutter or vim.api.nvim_win_get_config(win).relative ~= "" then
		return base
	end

	local on_cursor = wo.cursorline and vim.v.relnum == 0 and vim.v.virtnum <= 0
	return base .. (on_cursor and "%#CursorLine#" or "%#Normal#") .. string.rep(" ", padding)
end

-- Set during startup: the option only reaches windows created after it, so
-- deferring it leaves the splits of a restored session without it.
vim.o.statuscolumn = "%!v:lua.PaddedStatuscolumn()"

Edit.later(function()
	-- vim.pack.add({ "https://github.com/barrettruth/diffs.nvim" })

	local iter = require("iter")

	iter.setup({ diff = { layout = "auto" } })

	local map = vim.keymap.set

	map("n", "<leader>ce", function()
		iter.status()
	end, { desc = "[C]hange [E]xplorer (iter)" })

	-- stylua: ignore start
	map({ "n", "x" }, "<leader>ia", function() iter.annotate() end,                     { desc = "[A]nnotate line or selection" })
	map("n",          "<leader>if", function() iter.annotate({ scope = "file" }) end,   { desc = "Annotate [F]ile" })
	map("n",          "<leader>ir", function() iter.annotate({ scope = "review" }) end, { desc = "Annotate [R]eview" })
	map("n",          "<leader>il", iter.sidebar,                                       { desc = "[L]ist annotations" })
	map("n",          "<leader>iy", iter.yank,                                          { desc = "[Y]ank annotations" })
	map("n",          "<leader>ix", iter.clear,                                         { desc = "Clear all annotations" })
	map("n",          "]a",          iter.next_annotation,                               { desc = "Next annotation" })
	map("n",          "[a",          iter.prev_annotation,                               { desc = "Previous annotation" })
	-- stylua: ignore end
end)
